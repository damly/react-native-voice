//
//  IflytekSynthesizerModule.m
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmPlayer.h"
#import "VoiceSynthesizerJsEvent.h"
#import "IflytekSynthesizerModule.h"
#import <Foundation/Foundation.h>


@implementation IflytekSynthesizerDelegate
{
    onFinish    _onFinish;
    onError     _onError;
    NSMutableData *_data;
}

- (id) initWithBlocks:(onFinish) onFinish onError:(onError) onError
{
    self = [super init];
    
    _onFinish = onFinish;
    _onError = onError;
    
    return self ;
}
-(id) init
{
    return [self initWithBlocks:nil onError:nil] ;
}

- (void) onCompleted:(IFlySpeechError *)error
{
    if (error != nil && error.errorCode != 0 && _onError != nil) {
        _onError(error.errorCode, error.errorDesc);
    }
    else if(_onFinish != nil){
        _onFinish();
    }
}

@end

@implementation IflytekSynthesizerModule
{
    VoiceSynthesizerJsEvent *_voiceSynthesizerJsEvent;
    IFlySpeechSynthesizer * _iFlySpeechSynthesizer;
    IflytekSynthesizerDelegate *_iflytekSynthesizerDelegate;
    PcmPlayer       *_pcmPlayer;
    NSString    *_content;
    NSString    *_filename;
    BOOL        _speaking;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(IflytekSynthesizerModule);

RCT_EXPORT_METHOD(init: (NSString *) AppId) {
    
    if (_iFlySpeechSynthesizer != nil) {
        [_voiceSynthesizerJsEvent onError:-1 message:@"please init iflytek synthesizer."];
        return;
    }
    
    _voiceSynthesizerJsEvent = [[VoiceSynthesizerJsEvent alloc] initWith:_bridge];
    _pcmPlayer = [[PcmPlayer alloc] initWithBlocks:^() {
        
    } onFinish:^(){
        _speaking = NO;
        [_voiceSynthesizerJsEvent onCompleted];
    } onError:^(int code ,NSString *message) {
        [_voiceSynthesizerJsEvent onError:code message:message];
    }];
    
    _iflytekSynthesizerDelegate = [[IflytekSynthesizerDelegate alloc] initWithBlocks:^(){
        [_pcmPlayer startPlaying:_filename];
    } onError:^(int code, NSString *message) {
        [_voiceSynthesizerJsEvent onError:code message:message];
        return;
    }];
    
    NSString * initIFlytekString = [[NSString alloc] initWithFormat: @"appid=%@", AppId];
    
    [IFlySpeechUtility createUtility: initIFlytekString];
    
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = _iflytekSynthesizerDelegate;
}

RCT_EXPORT_METHOD(start:(NSString *)content langCode:(NSString *)langCode pronounce:(int)pronounce speaker:(NSString *)speaker)
{
    if ([_iFlySpeechSynthesizer isSpeaking]) {
        [_iFlySpeechSynthesizer stopSpeaking];
    }
    _content = content;

    [_voiceSynthesizerJsEvent onStart:@"Iflytek"];
    
    [self synthesizeToFile:content langCode:langCode pronounce:pronounce speaker:speaker];
    // [_iFlySpeechSynthesizer startSpeaking:content];
}

- (void) synthesizeToFile:(NSString *)content langCode:(NSString *)langCode pronounce:(int)pronounce speaker:(NSString *)speaker
{
    if ([_iFlySpeechSynthesizer isSpeaking]) {
        [_iFlySpeechSynthesizer stopSpeaking];
    }
    _content = content;
    _filename = [self getFullPath: @"tts.pcm"];
    
    // 清空参数
    [_iFlySpeechSynthesizer setParameter: nil forKey: [IFlySpeechConstant PARAMS]];
    
    [_iFlySpeechSynthesizer setParameter: [IFlySpeechConstant TYPE_CLOUD] forKey: [IFlySpeechConstant ENGINE_TYPE]];
    // 设置在线合成发音人
    [_iFlySpeechSynthesizer setParameter: speaker forKey: [IFlySpeechConstant VOICE_NAME]];
    //设置合成语速
    [_iFlySpeechSynthesizer setParameter: @"50" forKey: [IFlySpeechConstant SPEED]];
    //设置合成音调
    [_iFlySpeechSynthesizer setParameter: @"50" forKey: [IFlySpeechConstant PITCH]];
    //设置合成音量
    [_iFlySpeechSynthesizer setParameter: @"50" forKey: [IFlySpeechConstant VOLUME]];

    [_iFlySpeechSynthesizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    [_iFlySpeechSynthesizer setParameter:@"tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];

   // [_iFlySpeechSynthesizer startSpeaking:_content];
    [_iFlySpeechSynthesizer synthesize: _content toUri: _filename];
}

RCT_EXPORT_METHOD(stop) {

}

RCT_EXPORT_METHOD(isSpeaking: (RCTPromiseResolveBlock) resolve
                  rejecter: (RCTPromiseRejectBlock) reject) {
    BOOL isSpeaking = [_iFlySpeechSynthesizer isSpeaking];
    resolve([NSNumber numberWithBool: isSpeaking]);
}

- (NSString *)getFullPath:(NSString *)fileName
{
    NSString *full = [self getPathForDirectory:NSCachesDirectory];
    
    full = [full stringByAppendingString:@"/"];
    if(fileName == nil) {
        full = [full stringByAppendingString:@"tts.pcm"];
    }
    else
    {
        full = [full stringByAppendingString:fileName];
    }
    
    return full;
}

- (NSString *)getPathForDirectory:(int)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths firstObject];
}

@end
