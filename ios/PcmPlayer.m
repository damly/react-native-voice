//
//  PcmPlayer.m
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmPlayer.h"
#import "AVAudioPlayer+PCM.h"
#import <Foundation/Foundation.h>

@implementation PcmPlayer
{
    AVAudioPlayer *_audioPlayer;
    onPlayerStart _onStart; //申明block
    onPlayerFinish _onFinish; //申明block
    onPlayerError _onError; //申明block
}

-(id) initWithBlocks:(onPlayerStart)onStart  onFinish:(onPlayerFinish) onFinish onError:(onPlayerError) onError
{
    self = [super init];
    
    _onStart = onStart;
    _onFinish = onFinish;
    _onError = onError;
    
    return self ;
}

-(id) init
{
    return [self initWithBlocks:nil onFinish:nil onError:nil] ;
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(_onFinish != nil) {
        _onFinish();
    }
}

- (void) startPlaying:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self startPlayingFromData:data];
}

- (void) startPlayingFromData:(NSData *)data
{
    NSError *error;
    
    AudioStreamBasicDescription format;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mSampleRate = 16000;
    
    format.mBitsPerChannel = 16;
    format.mChannelsPerFrame = 1;
    format.mBytesPerFrame = format.mChannelsPerFrame * (format.mBitsPerChannel / 8);
    
    format.mFramesPerPacket = 1;
    format.mBytesPerPacket = format.mFramesPerPacket * format.mBytesPerFrame;
    
    format.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithPcmData:data pcmFormat:format error:&error];
    _audioPlayer.volume = 1;
    _audioPlayer.delegate = self;
    if (error) {
        NSLog(@"audio playback loading error: %@", [error localizedDescription]);
        if(_onError != nil) {
            _onError([error code], [error localizedDescription]);
        }
    } else {
        NSLog(@"开始播放...");
        [_audioPlayer play];
    }
}

- (void) stopPlaying
{
    if(_audioPlayer != nil) {
        if (_audioPlayer.playing) {
            [_audioPlayer stop];
        }
    }
}

@end
