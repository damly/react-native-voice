//
//  IflytekSynthesizerModule.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>
#import <AVFoundation/AVFoundation.h>
#import <iflyMSC/IFlyMSC.h>

@interface IflytekSynthesizerModule : NSObject <RCTBridgeModule>

@end


@interface IflytekSynthesizerDelegate : NSObject <IFlySpeechSynthesizerDelegate>
typedef void (^onFinish)();
typedef void (^onError)(int code, NSString *message);

- (id) initWithBlocks:(onFinish) onFinish onError:(onError) onError;

@end
