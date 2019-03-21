//
//  AmbaRTSPPlayBack.h
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) on 7/30/15.
//  Copyright (c) 2015 Ambarella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ambaStateMachine.h"
#import "constants.h"
#import "AmbaRTSPPlayer.h"


@class AmbaRTSPPlayer;

@interface AmbaRTSPPlayBack : UIViewController<UIAlertViewDelegate>
{
    IBOutlet UIImageView    *rtspView;
    IBOutlet UIButton       *playButton;
    AmbaRTSPPlayer          *video;
    float                   lastFrameTime;

}

@property (nonatomic, retain) AmbaRTSPPlayer    *video;
@property (nonatomic, retain) IBOutlet UIImageView *rtspView;

- (IBAction)closeRTSPPlayBack:(id)sender;

@end
