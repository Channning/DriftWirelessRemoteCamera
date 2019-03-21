//
//  DriftRTSPPlayBack.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/21.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

#import "ambaStateMachine.h"
#import "constants.h"
#import "DriftRTSPPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface DriftRTSPPlayBack : UIViewController
{
    IBOutlet UIButton       *playButton;
    DriftRTSPPlayer          *video;
    float                   lastFrameTime;
    
}

@property (nonatomic, strong) DriftRTSPPlayer    *video;
@property (nonatomic, weak) IBOutlet UIImageView *rtspView;

- (IBAction)closeRTSPPlayBack:(id)sender;
@end

NS_ASSUME_NONNULL_END
