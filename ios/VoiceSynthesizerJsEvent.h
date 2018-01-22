//
//  VoiceSynthesizerJsEvent.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>

@interface VoiceSynthesizerJsEvent : NSObject

- (id) initWith:(RCTBridge *)bridge;
- (void) onStart:(NSString *)provider;
- (void) onCompleted;
- (void) onError:(int) code message:(NSString *) message;

@end
