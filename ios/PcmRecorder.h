//
//  PcmRecorder.h
//  VoiceManager
//
//  Created by damly on 2018/1/18.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PcmRecorder : NSObject<AVAudioRecorderDelegate>

typedef void (^onRecorderStart)();
typedef void (^onRecorderFinish)();
typedef void (^onRecorderVolumeChanged)(int Volume);
typedef void (^onRecorderError)(int code, NSString *message);

- (id) initWithBlocks:(onRecorderStart)onStart  onFinish:(onRecorderFinish) onFinish onError:(onRecorderError) onError onVolumeChanged:(onRecorderVolumeChanged) onVolumeChanged;
- (void) startRecording :(NSString *)path;
- (void) stopRecording;
- (NSString *)getFullPath:(NSString *)fileName;

@end
