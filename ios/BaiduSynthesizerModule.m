//
//  BaiduSynthesizerModule.m
//  VoiceManager
//
//  Created by damly on 2018/1/18.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmPlayer.h"
#import "MpgaConver.h"
#import "VoiceSynthesizerJsEvent.h"
#import "BaiduSynthesizerModule.h"
#import <Foundation/Foundation.h>


NSString *const BaiduTtsAccessUrl = @"https://openapi.baidu.com/oauth/2.0/token";
NSString *const BaiduTtsServiceUrl = @"https://tsn.baidu.com/text2audio";

@implementation BaiduSynthesizerModule
{
    VoiceSynthesizerJsEvent *_voiceSynthesizerJsEvent;
    PcmPlayer       *_pcmPlayer;
    MpgaConver      *_mpgaConver;
    NSString        *_token;
    NSString        *_appId;
    NSString        *_apiKey;
    NSString        *_secretKey;
    NSString        *_langCode;
    NSString        *_content;
    NSString        *_speaker;
    int            _pronounce;
    BOOL            _speaking;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(BaiduSynthesizerModule);

RCT_EXPORT_METHOD(init:(NSString *)appId apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey)
{
    _appId = appId;
    _apiKey = apiKey;
    _secretKey = secretKey;
    
    _mpgaConver = [[MpgaConver alloc] initWithBlocks:^(NSData *pcmData){
        [_pcmPlayer startPlayingFromData:pcmData];
    } onError:^(int code, NSString *message){
        [_voiceSynthesizerJsEvent onError:code message:message];
    }];
    
    _voiceSynthesizerJsEvent = [[VoiceSynthesizerJsEvent alloc] initWith:_bridge];
    _pcmPlayer = [[PcmPlayer alloc] initWithBlocks:^() {
        
    } onFinish:^(){
        _speaking = NO;
        [_voiceSynthesizerJsEvent onCompleted];
    } onError:^(int code ,NSString *message) {
        [_voiceSynthesizerJsEvent onError:code message:message];
    }];
    
    [self getToken];
}

RCT_EXPORT_METHOD(start:(NSString *)content langCode:(NSString *)langCode pronounce:(int)pronounce speaker:(NSString *)speaker)
{
    if(_token == nil) {
        [_voiceSynthesizerJsEvent onError:-1 message:@"please init baidu synthesizer."];
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
    NSString *uri = BaiduTtsAccessUrl;
    uri = [uri stringByAppendingString:@"?grant_type=client_credentials&"];
    uri = [uri stringByAppendingString:@"client_id="];
    uri = [uri stringByAppendingString:_apiKey];
    uri = [uri stringByAppendingString:@"&"];
    uri = [uri stringByAppendingString:@"client_secret="];
    uri = [uri stringByAppendingString:_secretKey];
    
    NSURL *url = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    @try {
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
        _token = [resultDic objectForKey:@"access_token"];
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
        
        NSLog(@"获取结果TOKEN：%@",_token);
        //  NSLog(@"获取结果：%@",str1);
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
        [_voiceSynthesizerJsEvent onError:-1 message:@"please init baidu synthesizer."];
        return;
    }
    
    [_voiceSynthesizerJsEvent onStart:@"Baidu"];
    
    _speaking = YES;
    
    NSString *uri = BaiduTtsServiceUrl;
    uri = [uri stringByAppendingString:@"?lan="];
    uri = [uri stringByAppendingString:@"zh"];
    uri = [uri stringByAppendingString:@"&ctp=1"];
    uri = [uri stringByAppendingString:@"&cuid=f4:5c:89:97:f3:09"];
    uri = [uri stringByAppendingString:@"&tok="];
    uri = [uri stringByAppendingString:_token];
    uri = [uri stringByAppendingString:@"&tex="];
    uri = [uri stringByAppendingString:_content];
    uri = [uri stringByAppendingString:@"&vol=10"];
    uri = [uri stringByAppendingString:@"&spd=5"];
    uri = [uri stringByAppendingString:@"&pit=5"];
    uri = [uri stringByAppendingString:@"&per="];
    uri = [uri stringByAppendingString:_speaker];
    
    NSLog(@"请求地址：%@", uri);
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        // 取得所有的请求的头
        NSDictionary *dictionary = [response allHeaderFields];
        NSString *type = [dictionary objectForKey:@"Content-Type"];
        NSLog(@"获取结果Content：%@",type);
        if ([type rangeOfString:@"json"].location == NSNotFound) {
            [_mpgaConver startConver:received];
            
        } else {
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
            int err_no = [[resultDic valueForKey:@"err_no"] intValue];
            
            //{"err_detail":"Internal error","err_msg":"backend error.","err_no":503,"err_subcode":20217,"tts_logid":2245073011}
            
            [_voiceSynthesizerJsEvent onError:err_no message:[resultDic objectForKey:@"err_msg"]];
            
            NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
            NSLog(@"获取结果：%@",str1);
        }
    }
    
    _speaking = NO;
}

- (NSString *)getPathForDirectory:(int)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths firstObject];
}

@end
