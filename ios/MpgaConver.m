//
//  MpgaConver.m
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import "MpgaConver.h"
#import <AVFoundation/AVFoundation.h>

@implementation MpgaConver
{
    AudioFileConvertOperation *_operation;
    NSURL *_sourceURL;
    NSURL *_destinationURL;
    onConverFinish _onFinish; //申明block
    onConverError _onError; //申明block
}

- (id) initWithBlocks:(onConverFinish) onFinish onError:(onConverError) onError
{
    self = [super init];
    
    _onFinish = onFinish;
    _onError = onError;
    
    return self ;
}

- (id) init
{
    return [self initWithBlocks:nil onError:nil] ;
}

- (void) startConver:(NSData *)mp3Data
{
     _sourceURL = [NSURL URLWithString:[self getFullPath:@"tts.mp3"]];
    [mp3Data writeToFile: [_sourceURL absoluteString] atomically: NO];
    
    _destinationURL = [NSURL URLWithString:[self getFullPath:@"tts.pcm"]];
    
    _operation = [[AudioFileConvertOperation alloc] initWithSourceURL:_sourceURL destinationURL:_destinationURL sampleRate:16000 outputFormat:kAudioFormatLinearPCM];
    
    _operation.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_operation start];
    });
}

- (NSString *)getFullPath:(NSString *)fileName
{
    NSString *full = [self getPathForDirectory:NSCachesDirectory];
    
    full = [full stringByAppendingString:@"/"];
    full = [full stringByAppendingString:fileName];
    
    return full;
}

- (NSString *)getPathForDirectory:(int)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [paths firstObject];
}

#pragma mark ---- AudioFileConvertOperationDelegate
- (void)audioFileConvertOperation:(AudioFileConvertOperation *)audioFileConvertOperation didEncounterError:(NSError *)error
{
    NSLog(@"mpega convert error");
    
    if(_onError != nil) {
        _onError([error code], [error description]);
    }
}

- (void)audioFileConvertOperation:(AudioFileConvertOperation *)audioFileConvertOperation didCompleteWithURL:(NSURL *)destinationURL
{
    NSLog(@"mpega convert complete destinationURL=%@",destinationURL);
    
    NSData *pcmData = [NSData dataWithContentsOfFile:[destinationURL absoluteString]];
    
    if(_onFinish != nil) {
        _onFinish(pcmData);
    }
}

@end
