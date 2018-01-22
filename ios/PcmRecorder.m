//
//  PcmRecorder.m
//  VoiceManager
//
//  Created by damly on 2018/1/18.
//  Copyright © 2018年 damly. All rights reserved.
//
#import "PcmRecorder.h"
#import <Foundation/Foundation.h>

@implementation PcmRecorder {
    AVAudioRecorder *_audioRecorder;

    NSTimeInterval _currentTime;
    id _progressUpdateTimer;
    int _progressUpdateInterval;
    NSDate *_prevProgressUpdateTime;
    NSURL *_audioFileURL;
    NSNumber *_audioQuality;
    NSNumber *_audioEncoding;
    NSNumber *_audioChannels;
    NSNumber *_audioSampleRate;
    AVAudioSession *_recordSession;
    BOOL _meteringEnabled;
    BOOL _measurementMode;
    onRecorderStart _onStart; //申明block
    onRecorderFinish _onFinish; //申明block
    onRecorderVolumeChanged _onVolumeChanged; //申明block
    onRecorderError _onError; //申明block
}

-(id) initWithBlocks:(onRecorderStart)onStart  onFinish:(onRecorderFinish) onFinish onError:(onRecorderError) onError onVolumeChanged:(onRecorderVolumeChanged) onVolumeChanged
{
    self = [super init];
    
    _onStart = onStart;
    _onFinish = onFinish;
    _onError = onError;
    _onVolumeChanged = onVolumeChanged;
    
    return self ;
}

-(id) init
{
    return [self initWithBlocks:nil onFinish:nil onError:nil onVolumeChanged:nil] ;
}

-(void)sendProgressUpdate {
    if (_audioRecorder && _audioRecorder.recording) {
        _currentTime = _audioRecorder.currentTime;
    } else {
        return;
    }
    
    if (_prevProgressUpdateTime == nil ||
        (([_prevProgressUpdateTime timeIntervalSinceNow] * -1000.0) >= _progressUpdateInterval)) {
        if (_meteringEnabled) {
            [_audioRecorder updateMeters];
        
            float _currentMetering = pow(10, (0.05 * [_audioRecorder averagePowerForChannel:0]));
            int volume = (int)(_currentMetering * 40.0);
            if(_onVolumeChanged != nil) {
                _onVolumeChanged(volume);
            }
        }
        _prevProgressUpdateTime = [NSDate date];
    }
}

- (void)stopProgressTimer {
    [_progressUpdateTimer invalidate];
}

- (void)startProgressTimer {
    _prevProgressUpdateTime = nil;
    
    [self stopProgressTimer];
    
    _progressUpdateTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(sendProgressUpdate)];
    [_progressUpdateTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {

    if(_onFinish != nil && flag) {
        _onFinish();
    }
    else if(_onError != nil && !flag) {
        _onError(-1, @"unknown recorder error!");
    }
}

- (void) startRecording :(NSString *)path
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
    
    _prevProgressUpdateTime = nil;
    [self stopProgressTimer];
    
    _audioFileURL = [NSURL fileURLWithPath:path];
    
    // Default options
    _audioQuality = [NSNumber numberWithInt:AVAudioQualityHigh];
    _audioEncoding = [NSNumber numberWithInt:kAudioFormatAppleIMA4];
    _audioChannels = [NSNumber numberWithInt:1];
    _audioSampleRate = [NSNumber numberWithFloat:16000.0];
    _meteringEnabled = YES;
    _audioEncoding =[NSNumber numberWithInt:kAudioFormatLinearPCM];
    _progressUpdateInterval = 50;
    _audioQuality =[NSNumber numberWithInt:AVAudioQualityMedium];
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    _audioQuality, AVEncoderAudioQualityKey,
                                    _audioEncoding, AVFormatIDKey,
                                    _audioChannels, AVNumberOfChannelsKey,
                                    _audioSampleRate, AVSampleRateKey,
                                    nil];
    
    
    
    NSError *error = nil;
    
    _recordSession = [AVAudioSession sharedInstance];
    
    if (_measurementMode) {
        [_recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [_recordSession setMode:AVAudioSessionModeMeasurement error:nil];
    }else{
        [_recordSession setCategory:AVAudioSessionCategoryMultiRoute error:nil];
    }
    
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:_audioFileURL
                      settings:recordSettings
                      error:&error];
    
    _audioRecorder.meteringEnabled = _meteringEnabled;
    _audioRecorder.delegate = self;
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        if(_onError != nil) {
            _onError([error code], [error localizedDescription]);
        }
    } else {
        [_audioRecorder prepareToRecord];
    }
    
    if (!_audioRecorder.recording) {
        
        if(_onStart != nil) {
            _onStart();
        }
        
        [self startProgressTimer];
        [_recordSession setActive:YES error:nil];
        [_audioRecorder record];
    }
}

- (void) stopRecording
{
    [_audioRecorder stop];
    [_recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    _prevProgressUpdateTime = nil;
}

- (NSString *)getFullPath:(NSString *)fileName
{
    NSString *full = [self getPathForDirectory:NSCachesDirectory];
    
    full = [full stringByAppendingString:@"/"];
    if(fileName == nil) {
        full = [full stringByAppendingString:@"asr.pcm"];
    }
    else
    {
        full = [full stringByAppendingString:fileName];
    }

    return full;
}

- (NSString *)getPathForDirectory:(int)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths firstObject];
}

@end
