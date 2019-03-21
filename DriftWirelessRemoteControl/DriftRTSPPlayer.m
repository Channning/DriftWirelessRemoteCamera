//
//  DriftRTSPPlayer.m
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import "DriftRTSPPlayer.h"
#import <CoreGraphics/CoreGraphics.h>
#import "AudioStreamer.h"


#ifndef AVCODEC_MAX_AUDIO_FRAME_SIZE
# define AVCODEC_MAX_AUDIO_FRAME_SIZE 384000 //192000 // 1 sec of 48khz 32bit audio
#endif

@interface DriftRTSPPlayer ()
@property (nonatomic, retain) AudioStreamer *audioController;
@end

@interface DriftRTSPPlayer (private)
-(void)convertFrameToRGB;
-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height;
-(void)setupScaler;
@end

@implementation DriftRTSPPlayer

@synthesize outputWidth, outputHeight;
@synthesize sourceHeight, sourceWidth;
@synthesize audioController = _audioController;
@synthesize audioPacketQueue;
@synthesize audioPacketQueueSize;
@synthesize _audioStream;
@synthesize _audioCodecContext;
@synthesize emptyAudioBuffer;
volatile bool _stopDecode;

- (id) init
{
    self = [super init];
    _stopDecode = false;
    return self;
    
}

/* Initialize with movie at moviePath. Output dimensions are set to source dimensions. */
-(id)initWithVideo:(NSString *)streamPath usesTcp:(BOOL)usesTcp decodeAudio:(BOOL)supportAudio
{
    
    if(!(self = [super init]))
        return nil;
    
    AVCodec *pCodec;
    
    //Step 1: Init ffmpeg library: init all codecs and container formats
    avcodec_register_all();
    av_register_all();
    //network stream
    avformat_network_init();
    
    //Step 2: Setup RTSP options
    AVDictionary *opts = 0;
    if (usesTcp)
        av_dict_set(&opts, "rtsp_transport", "tcp", 0);
    
    if (avformat_open_input(&_formatCtx,[streamPath UTF8String], NULL,&opts) != 0)
    {
        av_log(NULL,AV_LOG_ERROR, "Unable to Open File\n");
        NSLog(@"Unable to Open File\n");
        goto initError;
    }
    //setting Buffer for live View
    if ( (usesTcp  == NO) && (supportAudio == NO)) {
        _formatCtx->flags |= AVFMT_FLAG_NOBUFFER;
        _formatCtx->flags |= AVFMT_FLAG_NONBLOCK;
        _formatCtx->flags |= AVFMT_FLAG_DISCARD_CORRUPT;
    }
    
    
    //Step 3: retrive Streams (video/audio)
    //if ( avformat_find_stream_info(_formatCtx, &opts) < 0)
    if ( avformat_find_stream_info(_formatCtx, NULL) < 0)
    {
        av_log(NULL,AV_LOG_ERROR, "Unable to find Stream Information");
        NSLog(@"Unable to find stream Information");
        
        goto initError;
    }
    //Step 4:Find Video Stream
    videoStream = -1;
    audioStream = -1;
    
    for ( int i=0; i <_formatCtx->nb_streams; i++)
    {
        if (_formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO)
        {
            NSLog(@":Found Video Stream");
            videoStream = i;
        }
        if (_formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO)
        {
            audioStream = i;
            NSLog(@"Found Audio Stream");
        }
    }
    if (supportAudio == YES) {
        if (videoStream == -1 && audioStream == -1)
        {
            goto initError;
        }
    } else {
        if ( videoStream== -1)//// && audioStream== -1)
        {
            goto initError;
        }
    }
    //Step 5: Get ptr to codec Context from the video stream
    //Codec Context has all info about the codec the stream is using
    _codexCtx = _formatCtx->streams[videoStream]->codec;
    
    //Detect the type of codec
    pCodec = avcodec_find_decoder(_codexCtx->codec_id);
    if (pCodec  == NULL)
    {
        av_log(NULL, AV_LOG_ERROR,"Unsupported Codec");
        NSLog(@"Unsupported Codec!!!!!!!!");
        goto initError;
    }
    
    _codexCtx->skip_frame = AVDISCARD_NONREF;
    
    //Step 6: Now Open the Codec
    if (avcodec_open2(_codexCtx,pCodec, NULL) < 0)
    {
        av_log(NULL, AV_LOG_ERROR, "Unable to Open Video Decoder");
        NSLog(@"Unable to Open Video Decoder");
        goto initError;
    }
    //Step 7:Similar steps for Audio
    if (audioStream > -1)
    {
        NSLog(@"SetUp Audio Decoder");
        if (supportAudio == YES) {
            // [self setupAudioDecoder];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^(void){
                [self setupAudioDecoder];
            });
        }
        else
            NSLog(@"Disabling Audio Decoding for Live PreView");
        
    }
    
    //Step 8: Allocate Video Frame
    _frame = av_frame_alloc();
    
    outputWidth = _codexCtx->width;
    outputHeight = _codexCtx->height;
    _stopDecode = false;
    return self;
    
initError:
    NSLog(@"Error: Release Self");
    return nil;
}
- (int)sourceWidth
{
    return _codexCtx->width;
}

- (int)sourceHeight
{
    return _codexCtx->height;
}


- (void) setupAudioDecoder
{
    if (audioStream >= 0) {
        _audioBufferSize = AVCODEC_MAX_AUDIO_FRAME_SIZE;
        _audioBuffer = av_malloc(_audioBufferSize);
        _inBuffer = NO;
        
        _audioCodecContext = _formatCtx->streams[audioStream]->codec;
        _audioStream = _formatCtx->streams[audioStream];
        
        AVCodec *codec = avcodec_find_decoder(_audioCodecContext->codec_id);
        if (codec == NULL) {
            NSLog(@"audio codec is not Found!!!! ");
            return;
        }
        
        if ( avcodec_open2(_audioCodecContext,codec, NULL) < 0) {
            NSLog(@"Unable to Open Audio Codec!!!!");
            return;
        }
        
        if (audioPacketQueue) {
            audioPacketQueue = nil;
        }
        audioPacketQueue = [[NSMutableArray alloc] init];
        
        if (audioPacketQueueLock) {
            //[audioPacketQueueLock release];
            audioPacketQueueLock = nil;
            [audioPacketQueueLock unlock];
        }
        audioPacketQueueLock = [[NSLock alloc] init];
        
        if (_audioController) {
            [_audioController _stopAudio];
            //  [_audioController release];
            _audioController = nil;
        }
        _audioController = [[AudioStreamer alloc] initWithStreamer:self];
        NSLog(@"AudioDecoder: setup Done");
    } else {
        _formatCtx->streams[audioStream]->discard = AVDISCARD_ALL;
        audioStream = -1;
    }
}

- (BOOL)stepFrame
{
    LastStartTime = 0;
    int frameFinished=0;
    while (!_stopDecode && !frameFinished && av_read_frame(_formatCtx, &packet) >= 0)
    {
        if(packet.stream_index == videoStream) {
            //Decode video Frame
            avcodec_decode_video2(_codexCtx, _frame, &frameFinished, &packet);
        }
        if (packet.stream_index == audioStream) {
            [audioPacketQueueLock lock];
            
            audioPacketQueueSize += packet.size;
            [audioPacketQueue addObject:[NSMutableData dataWithBytes:&packet length:sizeof(packet)]];
            [audioPacketQueueLock unlock];
            
            if (!primed) {
                primed = YES;
                [_audioController _startAudio];
            }
            
            if (emptyAudioBuffer) {
                [_audioController enqueueBuffer:emptyAudioBuffer];
            }
            
        }
    }
    
    return frameFinished!=0;
}
- (UIImage *)currentImage
{
    if (!_frame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:outputWidth height:outputHeight];
}
-(void) convertFrameToRGB
{
    //release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    
    
    
    // Allocate RGB picture
    avpicture_alloc(&picture, AV_PIX_FMT_RGB24, outputWidth, outputHeight);
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(_codexCtx->width,
                                     _codexCtx->height,
                                     ////_codexCtx->pix_fmt,
                                     AV_PIX_FMT_YUV420P,
                                     outputWidth,
                                     outputHeight,
                                     AV_PIX_FMT_RGB24,
                                     sws_flags,
                                     NULL,
                                     NULL,
                                     NULL
                                     );
    sws_scale(img_convert_ctx,
              (uint8_t const * const *)_frame->data,
              _frame->linesize,
              0,
              _codexCtx->height,
              picture.data,
              picture.linesize);
}
- (UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height
{
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

- (void) stopRTSPDecode
{
    _stopDecode = true;
    [self closeAudio];
    [_audioController _stopAudio];
}
- (void)seekTime:(double)seconds
{
    AVRational timeBase = _formatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(_formatCtx, videoStream, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(_codexCtx);
}
-(void) setupScaler
{
    //release Old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    //Alloc RGB picture
    avpicture_alloc(&picture, AV_PIX_FMT_RGB24, outputWidth, outputHeight);
    //setupScaler
    static int sws_flags = SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(_codexCtx->width,
                                     _codexCtx->height,
                                     _codexCtx->pix_fmt,
                                     outputWidth,
                                     outputHeight,
                                     AV_PIX_FMT_RGB24,
                                     sws_flags,NULL,NULL, NULL);
}

- (double)duration
{
    return (double)_formatCtx->duration / AV_TIME_BASE;
}

- (AVPacket*)readPacket
{
    if (_currentPacket.size > 0 || _inBuffer) return &_currentPacket;
    
    NSMutableData *packetData = [audioPacketQueue objectAtIndex:0];
    _packet = [packetData mutableBytes];
    
    if (_packet) {
        if (_packet->dts != AV_NOPTS_VALUE) {
            _packet->dts += av_rescale_q(0, AV_TIME_BASE_Q, _audioStream->time_base);
        }
        
        if (_packet->pts != AV_NOPTS_VALUE) {
            _packet->pts += av_rescale_q(0, AV_TIME_BASE_Q, _audioStream->time_base);
        }
        [audioPacketQueueLock lock];
        audioPacketQueueSize -= _packet->size;
        if ([audioPacketQueue count] > 0) {
            //NSLog(@"remove obj from audioPacketQueue");
            [audioPacketQueue removeObjectAtIndex:0];
        }
        [audioPacketQueueLock unlock];
        
        _currentPacket = *(_packet);
    }
    
    return &_currentPacket;
}
- (void)closeAudio
{
    [_audioController _stopAudio];
    primed=NO;
}
@end
