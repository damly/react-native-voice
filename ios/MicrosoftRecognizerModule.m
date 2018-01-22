//
//  BaiduRecognizerModule.m
//  VoiceManager
//
//  Created by damly on 2018/1/18.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmRecorder.h"
#import "VoiceRecognizerJsEvent.h"
#import "MicrosoftRecognizerModule.h"
#import <Foundation/Foundation.h>

NSString *const MicrosoftAsrAccessUrl = @"https://api.cognitive.microsoft.com/sts/v1.0/issueToken";
NSString *const MicrosoftAsrServiceUrl = @"https://speech.platform.bing.com/speech/recognition/interactive/cognitiveservices/v1";

@implementation MicrosoftRecognizerModule
{
    VoiceRecognizerJsEvent *_voiceRecognizerJsEvent;
    PcmRecorder     *_pcmRecorder;
    NSString        *_token;
    NSString        *_subscriptionKey;
    NSString        *_fileName;
    NSString        *_langCode;
    BOOL            _recording;
    BOOL            _cancel;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(MicrosoftRecognizerModule);

RCT_EXPORT_METHOD(init:(NSString *)subscriptionKey)
{
    _subscriptionKey = subscriptionKey;
    
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
    
    [self getToken];
}

RCT_EXPORT_METHOD(start:(NSString *)langCode)
{
    if(_fileName == nil || _token == nil) {
        [_voiceRecognizerJsEvent onError:-1 message:@"please init microsoft recognizer."];
        return;
    }
    _langCode = langCode;
    _cancel = false;
    _recording = false;
    [_pcmRecorder stopRecording];
    NSLog(@"录制文件： %@", _fileName);
    [_pcmRecorder startRecording:_fileName];
}

RCT_EXPORT_METHOD(stop)
{
    [_pcmRecorder stopRecording];
    _recording = false;
    _cancel = false;
}

RCT_EXPORT_METHOD(cancel)
{
    _recording = false;
    _cancel = true;
    [_pcmRecorder stopRecording];
}

RCT_EXPORT_METHOD(isListening: resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([NSNumber numberWithBool: _recording]);
}

- (void) getToken
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(GetTonekThread:) object:nil];
    [thread start];
}

-(void)GetTonekThread:(NSString*)type
{
    NSString *uri = MicrosoftAsrAccessUrl;

    NSURL *url = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:_subscriptionKey forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    NSDictionary *resultDic = nil;
    @try {
        resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
        int err_no = [[resultDic valueForKey:@"statusCode"] intValue];
        NSString *message = [resultDic valueForKey:@"message"];
        [_voiceRecognizerJsEvent onError:err_no message:message];
    }
    @catch (NSException *exception) {
        _token = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    }
    @finally {
        NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        NSLog(@"微软TOKEN：%@",str1);
    }
}

- (void) startAsr
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(AsrThread:) object:nil];
    [thread start];
}

- (void)AsrThread:(NSString *)type
{
    
    if(_fileName == nil || _token == nil) {
        [_voiceRecognizerJsEvent onError:-1 message:@"please init baidu recognizer."];
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:_fileName];

    NSString *uri = MicrosoftAsrServiceUrl;
    uri = [uri stringByAppendingString:@"?language="];
    uri = [uri stringByAppendingString:_langCode];
    uri = [uri stringByAppendingString:@"&"];
    uri = [uri stringByAppendingString:@"format=simple"];
    
    NSLog(@"服务器地址：%@",uri);
    
    NSString *auth = @"Bearer ";
    auth = [auth stringByAppendingString:_token];
    
    NSURL *url = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"audio/wav; codec=audio/pcm; samplerate=16000" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json;text/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:data];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSLog(@"获取结果：%@",str1);
    
    NSDictionary *resultDic = nil;
    @try {
        resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
        NSString *text = [resultDic valueForKey:@"DisplayText"];
        [_voiceRecognizerJsEvent onResult:text isLast:YES provider:@"Microsoft"];
    }
    @catch (NSException *exception) {
        if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
            NSLog(@"%@", exception);
        } else {
            @throw exception;
        }
    }
    @finally {
        NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        NSLog(@"获取结果：%@",str1);
    }
}

@end
