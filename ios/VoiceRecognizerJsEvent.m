//
//  VoiceRecognizerJsEvent.m
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import "VoiceRecognizerJsEvent.h"
#import <Foundation/Foundation.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>

@implementation VoiceRecognizerJsEvent
{
    RCTBridge *_bridge;
}

- (id) initWith:(RCTBridge *)bridge
{
    self = [super init];
    
    _bridge = bridge;
    
    return self ;
}

- (id) init
{
    return [self initWith:nil] ;
}


- (void) onResult:(NSString *)result isLast:(BOOL) isLast provider:(NSString *)provider
{
    if(_bridge != nil)
    {
        NSDictionary * event = @{
                                 @"result": result,
                                 @"isLast": [NSNumber numberWithBool: isLast],
                                 @"provider": provider,
                                 };
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceRecognizerResult" body:event];
    }
}

- (void) onVolumeChanged:(int) volume
{
    if(_bridge != nil)
    {
        NSDictionary * event = @{
                                 @"volume": [NSNumber numberWithInt: volume]
                                 };
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceRecognizerVolumeChanged" body:event];
    }
}

- (void) onCancel
{
    if(_bridge != nil)
    {
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceRecognizerCancel" body:nil];
    }
}

- (void) onError:(int) code message:(NSString *) message
{
    if(_bridge != nil)
    {
        NSDictionary * event = @{
                                 @"errorCode": [NSNumber numberWithInt: code],
                                 @"errorDesc": message,
                                 };
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceRecognizerError" body:event];
    }
}

@end
