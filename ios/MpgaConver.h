//
//  MpgaConver.h
//  VoiceManager
//
//  Created by damly on 2018/1/19.
//  Copyright © 2018年 damly. All rights reserved.
//

#import "AudioFileConvertOperation.h"
#import <Foundation/Foundation.h>

@interface MpgaConver : NSObject<AudioFileConvertOperationDelegate>

typedef void (^onConverError)(int code, NSString *message);
typedef void (^onConverFinish)(NSData *data);

- (void) startConver:(NSData *)mp3Data;
- (id) initWithBlocks:(onConverFinish) onFinish onError:(onConverError) onError;

@end

