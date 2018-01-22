//
//  MicrosoftSynthesizerModule.m
//  VoiceManager
//
//  Created by damly on 2018/1/18.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmPlayer.h"
#import "VoiceSynthesizerJsEvent.h"
#import "MicrosoftSynthesizerModule.h"
#import <Foundation/Foundation.h>


NSString *const MicrosoftTtsAccessUrl = @"https://api.cognitive.microsoft.com/sts/v1.0/issueToken";
NSString *const MicrosoftTtsServiceUrl = @"https://speech.platform.bing.com/synthesize";

@implementation MicrosoftSynthesizerModule
{
    VoiceSynthesizerJsEvent *_voiceSynthesizerJsEvent;
    PcmPlayer       *_pcmPlayer;
    NSString        *_token;
    NSString        *_subscriptionKey;
    NSString        *_langCode;
    NSString        *_content;
    NSString        *_speaker;
    int             _pronounce;
    BOOL            _speaking;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(MicrosoftSynthesizerModule);

RCT_EXPORT_METHOD(init:(NSString *)subscriptionKey)
{
    _voiceSynthesizerJsEvent = [[VoiceSynthesizerJsEvent alloc] initWith:_bridge];
    _pcmPlayer = [[PcmPlayer alloc] initWithBlocks:^() {
        
    } onFinish:^(){
        _speaking = NO;
        [_voiceSynthesizerJsEvent onCompleted];
    } onError:^(int code ,NSString *message) {
        [_voiceSynthesizerJsEvent onError:code message:message];
    }];
    
    _subscriptionKey = subscriptionKey;
    [self getToken];
}

RCT_EXPORT_METHOD(start:(NSString *)content langCode:(NSString *)langCode pronounce:(int)pronounce speaker:(NSString *)speaker)
{
    if(_token == nil) {
        [_voiceSynthesizerJsEvent onError:-1 message:@"please init microsoft synthesizer."];
        return;
    }
    _content = content;
    _langCode = langCode;
    _pronounce = pronounce;
    _speaker = speaker;
    _speaking = NO;
    [self startTts];
}

RCT_EXPORT_METHOD(stop)
{

}

RCT_EXPORT_METHOD(isSpeaking: resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([NSNumber numberWithBool: _speaking]);
}

- (void) getToken
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(GetTonekThread:) object:nil];
    [thread start];
}

-(void)GetTonekThread:(NSString*)type
{
    
    NSString *uri = MicrosoftTtsAccessUrl;
    
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
        [_voiceSynthesizerJsEvent onError:err_no message:message];
    }
    @catch (NSException *exception) {
        _token = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    }
    @finally {
//        NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
//        NSLog(@"微软TOKEN：%@",str1);
    }
}

- (void) startTts
{
     NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(ttsThread:) object:nil];
     [thread start];
}

- (void)ttsThread:(NSString *)type
{
    if(_token == nil) {
        [_voiceSynthesizerJsEvent onError:-1 message:@"please init microsoft synthesizer."];
        return;
    }
    
    [_voiceSynthesizerJsEvent onStart:@"Microsoft"];
 
    _speaking = YES;
    
    NSString *gender = (_pronounce == 0 ? @"Female" : @"Male");
    NSString *message = [NSString stringWithFormat:@"<speak version='1.0' xml:lang='%@'><voice xml:lang='%@' xml:gender='%@' name='%@'>%@</voice></speak>", _langCode, _langCode, gender, _speaker, _content];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSString *len = [NSString stringWithFormat:@"%lu", data.length];
    
    NSString *uri = MicrosoftTtsServiceUrl;
    NSString *auth = @"Bearer ";
    auth = [auth stringByAppendingString:_token];
    
    NSURL *url = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/ssml+xml" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"riff-16khz-16bit-mono-pcm" forHTTPHeaderField:@"X-Microsoft-OutputFormat"];
    [request setValue:@"TTSiOS" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:auth forHTTPHeaderField:@"Authorization"];
    [request setValue:len forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPBody:data];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    [_pcmPlayer startPlayingFromData:received];
    _speaking = NO;
}

- (NSString *)getPathForDirectory:(int)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths firstObject];
}

@end
