//
//  VoiceRecognizerJsEvent.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>

@interface VoiceRecognizerJsEvent : NSObject

- (id) initWith:(RCTBridge *)bridge;
- (void) onResult:(NSString *)result isLast:(BOOL) isLast provider:(NSString *)provider;
- (void) onVolumeChanged:(int) volume;
- (void) onCancel;
- (void) onError:(int) code message:(NSString *) message;

@end
