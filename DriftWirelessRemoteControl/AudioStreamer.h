//
//  AudioStreamer.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/21.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "DriftRTSPPlayer.h"
#import "avformat.h"
#import "frame.h"

NS_ASSUME_NONNULL_BEGIN


#define kNumAQBufs 9

#define kAudioBufferSeconds 3


typedef enum _AUDIO_STATE {
    AUDIO_STATE_READY           = 0,
    AUDIO_STATE_STOP            = 1,
    AUDIO_STATE_PLAYING         = 2,
    AUDIO_STATE_PAUSE           = 3,
    AUDIO_STATE_SEEKING         = 4
} AUDIO_STATE;

@interface AudioStreamer : NSObject
{
    NSString *playingFilePath_;
    AudioStreamBasicDescription audioStreamBasicDesc_;
    AudioQueueRef audioQueue_;
    AudioQueueBufferRef audioQueueBuffer_[kNumAQBufs];
    BOOL started_, finished_;
    NSTimeInterval durationTime_, startedTime_;
    NSInteger state_;
    NSTimer *seekTimer_;
    NSLock *decodeLock_;
    DriftRTSPPlayer *_streamer;
    AVCodecContext *_audioCodecContext;
    ////
    AVFrame                     *pAudioFrame;
    SwrContext                  *pSwrCtx;
}

- (void)_startAudio;
- (void)_stopAudio;
- (BOOL)createAudioQueue;
- (void)removeAudioQueue;
- (void)audioQueueOutputCallback:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer;
- (void)audioQueueIsRunningCallback;
- (OSStatus)enqueueBuffer:(AudioQueueBufferRef)buffer;
- (id)initWithStreamer:(DriftRTSPPlayer *)streamer;

- (OSStatus)startQueue;



NS_ASSUME_NONNULL_END

@end



