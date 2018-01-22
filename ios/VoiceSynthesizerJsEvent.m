//
//  VoiceSynthesizerJsEvent.m
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import "VoiceSynthesizerJsEvent.h"
#import <Foundation/Foundation.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>

@implementation VoiceSynthesizerJsEvent
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

- (void) onStart:(NSString *)provider
{
    if(_bridge != nil)
    {
        NSDictionary * event = @{
                                 @"provider": provider,
                                 };
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceSynthesizerStart" body:event];
    }
}

- (void) onCompleted
{
    if(_bridge != nil)
    {
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceSynthesizerCompleted" body:nil];
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
        [_bridge.eventDispatcher sendAppEventWithName:@"onVoiceSynthesizerError" body:event];
    }
}

@end
