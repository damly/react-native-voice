//
//  IflytekRecognizerModule.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTLog.h>
#import <iflyMSC/IFlyMSC.h>

@interface IflytekRecognizerModule : NSObject <RCTBridgeModule, IFlySpeechRecognizerDelegate>

@end
