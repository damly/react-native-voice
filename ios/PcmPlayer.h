//
//  PcmPlayer.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PcmPlayer : NSObject<AVAudioPlayerDelegate>

typedef void (^onPlayerStart)();
typedef void (^onPlayerFinish)();
typedef void (^onPlayerError)(int code, NSString *message);

- (id) initWithBlocks:(onPlayerStart)onStart  onFinish:(onPlayerFinish) onFinish onError:(onPlayerError) onError;
- (void) startPlaying :(NSString *)path;
- (void) startPlayingFromData:(NSData *)data;
- (void) stopPlaying;

@end
