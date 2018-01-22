//
//  AVAudioPlayer+PCM.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayer (PCM)

/**
 *  AVAudioPlayer working with raw audio data
 *
 *  @param pcmData  raw audio data
 *  @param format   pcm format
 *  @param outError return error
 *
 *  @return AVAudioPlayer instance
 */
- (instancetype)initWithPcmData:(NSData *)pcmData pcmFormat:(AudioStreamBasicDescription)format error:(NSError **)outError;
@end
