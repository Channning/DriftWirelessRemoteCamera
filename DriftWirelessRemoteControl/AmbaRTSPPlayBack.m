//
//  AmbaRTSPPlayBack.m
//  AmbaRemoteCam
//
//  Created by Ram on 7/30/15.
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import "AmbaRTSPPlayBack.h"
unsigned int timerFlag; //0 - stop rtsp view. 1 -restart view

@interface AmbaRTSPPlayBack ()
@property (nonatomic, retain) NSTimer *nextFrameTimer;
@end


@implementation AmbaRTSPPlayBack
@synthesize video, rtspView;
@synthesize nextFrameTimer = _nextFrameTimer;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(querySessionHolder:)
                                                 name:querySessionHolderNotification
                                               object:nil];
     
    timerFlag = 1;
    [[ambaStateMachine getInstance] presentWorkingDir];
    
    [self performSelector:@selector(updateURL) withObject:nil afterDelay:0.5];
    
    
}


- (void) querySessionHolder: (NSNotification *)notificationParam
{
    if ([ ambaStateMachine getInstance].notificationCount ){
        
        UIAlertView *jsonDebugAlert = [[UIAlertView alloc] initWithTitle:@"Last Command Response:"
                                                                 message: [ambaStateMachine getInstance].notifyMsg
                                                                delegate:self
                                                       cancelButtonTitle:@"RetainSession"
                                                       otherButtonTitles:@"logout", nil];
        [jsonDebugAlert show];
        
        [ ambaStateMachine getInstance].notificationCount = 0;
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"LogOut button Selected");
    } else {
        [[ambaStateMachine getInstance ] keepSessionActive];
    }
}



-(void) updateURL {
    if ([ambaStateMachine getInstance].wifiBleComboMode || [ambaStateMachine getInstance].networkModeWifi)
    {
        NSString *playBackFileName = [ambaStateMachine getInstance].playbackFile;
        
        NSString *playbackURL = [NSString stringWithFormat:@"rtsp://192.168.42.1%@/%@",
                                 [ambaStateMachine getInstance].presentWorkingDirPath, playBackFileName
                                 //[ambaStateMachine getInstance].playbackFile
                                 ];
        
        //NSString *playbackURL = [NSString stringWithFormat:@"rtsp://192.168.42.1/live"];
        //NSLog(@"RTSP PlayBack URL: %@",playbackURL);
        if ( [[playBackFileName pathExtension] isEqualToString:@"mp4"] || [[playBackFileName pathExtension] isEqualToString:@"MP4"] )
        {
            //NOTE: TCP Stream for playback:
            // Linux UDP layer will set its SO_SNDBUF and SO_RCVBUF to most 64k ( which eg: linux will translate to a 128k buffer)
            // THat practically guarantees that any single frame larger then 128k (eg: an average I-frame in an 720p )
            //will not fit within the kernel socket buffer, resulting in atleast one packet (and a part of the frame)
            //dropped. This leads to the corruption we see while decoding
            video = [[AmbaRTSPPlayer alloc] initWithVideo:playbackURL usesTcp:YES decodeAudio:YES];
            video.outputWidth = 160;//320;//480;//640;//video.sourceWidth;
            video.outputHeight = 88;//176;//270;//360;//video.sourceHeight;
            NSLog(@"Source Video With:height %d x %d", video.sourceWidth, video.sourceHeight);
            /////[rtspView setContentMode:UIViewContentModeScaleAspectFit];
            [self startPlayBack];
        } else {
            NSLog(@" Selected file is not a mp4 file");
        }
        
    }
    
    
}

- (void) startPlayBack
{
    lastFrameTime = -1;
    [_nextFrameTimer invalidate];
    [video seekTime:0.0];
    self.nextFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60
                                                           target:self
                                                         selector:@selector(displayNextFrame:)
                                                         userInfo: nil
                                                          repeats:YES];
}
#define LERP(A,B,C)  ((A)*(1.0-C)+(B)*C)


- (void) displayNextFrame:(NSTimer  *)timer
{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    if (![video stepFrame]) {
        [timer invalidate];
        [playButton setEnabled:YES];
        [video closeAudio];
        return;
    }
    rtspView.image = video.currentImage;
    float frameTime = 1.0/([NSDate timeIntervalSinceReferenceDate]-startTime);
    if (lastFrameTime<0) {
        lastFrameTime = frameTime;
    } else {
        lastFrameTime = LERP(frameTime, lastFrameTime, 0.8);
    }
}
- (IBAction)closeRTSPPlayBack:(id)sender {
    //Stop RTSP decoding
    timerFlag = 0;
    video = nil;
    [video stopRTSPDecode];
    
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}
		
@end
