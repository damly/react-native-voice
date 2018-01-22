//
//  BaiduRecognizerModule.m
//  VoiceManager
//
//  Created by damly on 2018/1/18.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmRecorder.h"
#import "VoiceRecognizerJsEvent.h"
#import "BaiduRecognizerModule.h"
#import <Foundation/Foundation.h>

NSString *const BaiduAsrAccessUrl = @"https://openapi.baidu.com/oauth/2.0/token";
NSString *const BaiduAsrServiceUrl = @"https://vop.baidu.com/server_api";

@implementation BaiduRecognizerModule
{
    VoiceRecognizerJsEvent *_voiceRecognizerJsEvent;
    PcmRecorder     *_pcmRecorder;
    NSString        *_token;
    NSString        *_appId;
    NSString        *_apiKey;
    NSString        *_secretKey;
    NSString        *_fileName;
    NSString        *_langCode;
    BOOL            _recording;
    BOOL            _cancel;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(BaiduRecognizerModule);

RCT_EXPORT_METHOD(init:(NSString *)appId apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey)
{
    _appId = appId;
    _apiKey = apiKey;
    _secretKey = secretKey;
    
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
        [_voiceRecognizerJsEvent onError:-1 message: @"please init baidu recognizer."];
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
    NSString *uri = BaiduAsrAccessUrl;
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

- (void) startAsr
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(AsrThread:) object:nil];
    [thread start];
}

- (void)AsrThread:(NSString *)type
{
    if(_fileName == nil || _token == nil) {
        [_voiceRecognizerJsEvent onError:-1 message: @"please init baidu recognizer."];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long len = [[fileManager attributesOfItemAtPath:_fileName error:nil] fileSize];
  
    NSData *data = [NSData dataWithContentsOfFile:_fileName];
    NSString *speech = [data base64Encoding];
    NSDictionary * dict = @{
                             @"cuid": @"baidu_workshop",
                             @"token": _token,
                             @"lan": _langCode,
                             @"format": @"pcm",
                             @"rate": [NSNumber numberWithInt: 16000],
                             @"channel": [NSNumber numberWithInt: 1],
                             @"len": [NSNumber numberWithLong: len],
                             @"speech": speech,
                            };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *uri = BaiduAsrServiceUrl;
    NSLog(@"服务器地址：%@",uri);
    
    NSURL *url = [NSURL URLWithString:uri];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
 
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
   // NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    NSDictionary *resultDic = nil;
    @try {
        resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
        int err_no = [[resultDic valueForKey:@"err_no"] intValue];
        if(err_no == 0) {
            NSArray *texts = [resultDic objectForKey:@"result"];
            [_voiceRecognizerJsEvent onResult:[[resultDic objectForKey:@"result"] objectAtIndex:0] isLast:YES provider:@"Baidu"];
        }
        else {
            [_voiceRecognizerJsEvent onError:err_no message: [resultDic objectForKey:@"err_msg"]];
        }
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
