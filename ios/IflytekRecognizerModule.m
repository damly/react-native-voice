//
//  IflytekRecognizerModule.m
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import "PcmRecorder.h"
#import "VoiceRecognizerJsEvent.h"
#import "IflytekRecognizerModule.h"
#import <Foundation/Foundation.h>
#import <iflyMSC/IFlyMSC.h>

@implementation IflytekRecognizerModule
{
    VoiceRecognizerJsEvent *_voiceRecognizerJsEvent;
    PcmRecorder             *_pcmRecorder;
    IFlySpeechRecognizer    *_iFlySpeechRecognizer;
    NSMutableString         *_recognizerResult;
    NSString                *_langCode;
    NSString                *_fileName;
    BOOL                    _recording;
    BOOL                    _cancel;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(IflytekRecognizerModule);

RCT_EXPORT_METHOD(init: (NSString *) AppId) {
    if (_iFlySpeechRecognizer != nil) {
        return;
    }
    
    NSString * initIFlytekString = [[NSString alloc] initWithFormat: @"appid=%@", AppId];
    
    [IFlySpeechUtility createUtility: initIFlytekString];
    
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    _iFlySpeechRecognizer.delegate = self;
    
    _voiceRecognizerJsEvent = [[VoiceRecognizerJsEvent alloc] initWith:_bridge];
    _pcmRecorder = [[PcmRecorder alloc] initWithBlocks:^(){
        _recording = true;
        NSLog(@"开始录制");
    } onFinish:^(){
        NSLog(@"结束录制");
        if(_cancel) {
            [_voiceRecognizerJsEvent onCancel];
            _recording = false;
            _cancel = false;
        }
        else {
            [self startAsr];
        }
    } onError:^(int code, NSString *message) {
        _recording = false;
        _cancel = false;
        NSLog(@"录制出错");
        [_voiceRecognizerJsEvent onError:code message:message];
    } onVolumeChanged:^(int volume) {
        [_voiceRecognizerJsEvent onVolumeChanged:volume];
    }];
    
    _fileName = [_pcmRecorder getFullPath:nil];
}

RCT_EXPORT_METHOD(start:(NSString *)langCode) {

    _langCode = langCode;
    _cancel = false;
    _recording = false;
    [_pcmRecorder stopRecording];
    NSLog(@"录制文件： %@", _fileName);
    [_pcmRecorder startRecording:_fileName];
}

RCT_EXPORT_METHOD(cancel)
{
    if(_recording) {
        _cancel = true;
        _recording = false;
        [_pcmRecorder stopRecording];
    }
    else {
        _cancel = true;
        _recording = false;
        if ([_iFlySpeechRecognizer isListening]) {
            [_iFlySpeechRecognizer cancel];
        }
    }
}

RCT_EXPORT_METHOD(stop)
{
    if(_recording) {
        _recording = false;
        _cancel = false;
        [_pcmRecorder stopRecording];
    }
    else {
        _recording = false;
        _cancel = false;
        [_iFlySpeechRecognizer stopListening];
    }
}

RCT_EXPORT_METHOD(isListening: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject) {
    @try {
        BOOL isListening = [_iFlySpeechRecognizer isListening] || _recording;
        resolve([NSNumber numberWithBool: isListening]);
    } @catch (NSException * exception) {
        reject(@"101", @"Recognizer.isListening() ", nil);
    }
}

- (void) startAsr
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(AsrThread:) object:nil];
    [thread start];
}

- (void)AsrThread:(NSString *)type
{
    if ([_iFlySpeechRecognizer isListening]) {
        [_iFlySpeechRecognizer cancel];
    }
    
    _recognizerResult = [NSMutableString new];
    NSData *data = [NSData dataWithContentsOfFile:_fileName];
    
    NSString *accent = [[NSString alloc] init];
    if([_langCode caseInsensitiveCompare:@"zh_hk"] == NSOrderedSame) {
        accent = @"cantonese";
    }
    else {
        accent = @"mandarin";
    }
    
    // 清空参数
    [_iFlySpeechRecognizer setParameter: nil forKey: [IFlySpeechConstant PARAMS]];
    // 设置audio source
    [_iFlySpeechRecognizer setParameter: @"-1" forKey: [IFlySpeechConstant AUDIO_SOURCE]];
    // 设置听写引擎
    [_iFlySpeechRecognizer setParameter: [IFlySpeechConstant TYPE_CLOUD] forKey: [IFlySpeechConstant ENGINE_TYPE]];
    // 设置返回结果格式
    [_iFlySpeechRecognizer setParameter: @"json" forKey: [IFlySpeechConstant RESULT_TYPE]];
    // 设置语言
    [_iFlySpeechRecognizer setParameter: _langCode forKey: [IFlySpeechConstant LANGUAGE]];
    // 设置语言区域
    if([_langCode caseInsensitiveCompare:@"en"] != NSOrderedSame) {
        [_iFlySpeechRecognizer setParameter: accent forKey: [IFlySpeechConstant ACCENT]];
    }
    // 设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理
    [_iFlySpeechRecognizer setParameter: @"10000" forKey: [IFlySpeechConstant VAD_BOS]];
    // 设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
    [_iFlySpeechRecognizer setParameter: @"1500" forKey: [IFlySpeechConstant VAD_EOS]];
    // 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
    [_iFlySpeechRecognizer setParameter: @"1" forKey: [IFlySpeechConstant ASR_PTT]];
    
    [_iFlySpeechRecognizer startListening];
    [_iFlySpeechRecognizer writeAudio:data];
    [_iFlySpeechRecognizer stopListening];
}

- (void) onError: (IFlySpeechError *) error {
    [_voiceRecognizerJsEvent onError:error.errorCode message:error.errorDesc];
}

- (void) onResults: (NSArray *) results isLast: (BOOL) isLast {

    if(_cancel) {
        return;
    }
    
    NSMutableString * resultString = [NSMutableString new];
    NSDictionary * dic = results[0];
    
    for (NSString * key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString * resultFromJson = [self stringFromJson:resultString];
    
    [_recognizerResult appendString: resultFromJson];
    
    [_voiceRecognizerJsEvent onResult:_recognizerResult isLast:isLast provider:@"Iflytek"];
}

- (NSString *) stringFromJson: (NSString *) params {
    if (params == NULL) {
        return nil;
    }
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSDictionary *resultDic  = [NSJSONSerialization JSONObjectWithData:
                                [params dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    if (resultDic!= nil) {
        NSArray *wordArray = [resultDic objectForKey:@"ws"];
        
        for (int i = 0; i < [wordArray count]; i++) {
            NSDictionary *wsDic = [wordArray objectAtIndex: i];
            NSArray *cwArray = [wsDic objectForKey:@"cw"];
            
            for (int j = 0; j < [cwArray count]; j++) {
                NSDictionary *wDic = [cwArray objectAtIndex:j];
                NSString *str = [wDic objectForKey:@"w"];
                [tempStr appendString: str];
            }
        }
    }
    return tempStr;
}

@end
