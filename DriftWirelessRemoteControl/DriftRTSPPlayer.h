//
//  DriftRTSPPlayer.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "avformat.h"
#import "avcodec.h"
#import "avio.h"
#import "swscale.h"
#import "swresample.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

NS_ASSUME_NONNULL_BEGIN

@interface DriftRTSPPlayer : NSObject
{
    AVFormatContext *_formatCtx;
    AVCodecContext  *_codexCtx;
    ////AVCodec         *_codec;
    AVFrame         *_frame;
    AVPacket        packet;
    AVPacket         _currentPacket;
    int outputWidth, outputHeight;
    int sourceWidth, sourceHeight;
    int videoStream;
    int audioStream;
    AVPicture picture;
    UIImage *currentImage;
    struct SwsContext *img_convert_ctx;
    
    double duration;
    //Audio
    NSLock *audioPacketQueueLock;
    AVCodecContext *_audioCodecContext;
    int16_t *_audioBuffer;
    int audioPacketQueueSize;
    NSMutableArray *audioPacketQueue;
    AVStream *_audioStream;
    NSInteger _audioBufferSize;
    BOOL _inBuffer;
    AVPacket *_packet;
    BOOL primed;
    long LastStartTime;
    
    //
    SwrContext       *pSwrCtx;
}


/* Last decoded picture as UIImage */
@property (nonatomic, readonly) UIImage *currentImage;
//Output Image size set to the source size by default'
@property (nonatomic) int outputWidth, outputHeight;
//size of Video Frame
@property (nonatomic, readonly) int sourceWidth, sourceHeight;

/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
-(id)initWithVideo:(NSString *)moviePath usesTcp:(BOOL)usesTcp decodeAudio:(BOOL)supportAudio;

/* Read the next frame from the video stream. Returns false if no frame read (video over). */
-(BOOL)stepFrame;

/* Seek to closest keyframe near specified time */
-(void)seekTime:(double)seconds;
//- (AVPacket*)readPacket;
- (void) stopRTSPDecode;

/* Length of video in seconds */
@property (nonatomic, readonly) double duration;

@property (nonatomic, strong) NSMutableArray *audioPacketQueue;
@property (nonatomic, assign) AVCodecContext *_audioCodecContext;
@property (nonatomic, assign) AudioQueueBufferRef emptyAudioBuffer;
@property (nonatomic, assign) int audioPacketQueueSize;
@property (nonatomic, assign) AVStream *_audioStream;
- (AVPacket*)readPacket;
- (void)closeAudio;

@end

NS_ASSUME_NONNULL_END
