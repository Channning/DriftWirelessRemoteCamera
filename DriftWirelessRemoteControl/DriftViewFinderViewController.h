//
//  DriftViewFinderViewController.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/21.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"
#import "constants.h"
#import "DriftRTSPPlayer.h"
NS_ASSUME_NONNULL_BEGIN

@interface DriftViewFinderViewController : UIViewController<UIAlertViewDelegate>
{
    float lastFrameTime;
}

@property (nonatomic, strong) DriftRTSPPlayer *video;
- (IBAction)shutterCmd:(id)sender;
- (IBAction)stopContShutter:(id)sender;
- (IBAction)startRec:(id)sender;
- (IBAction)stopRec:(id)sender;

- (IBAction)splitRecord:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *splitRecButton;
@property (weak, nonatomic) IBOutlet UIImageView *rtspView;

- (IBAction)reloadViewFinder:(id)sender;
- (IBAction)closeViewFinderView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *returnStatusTextLabel;
@end

NS_ASSUME_NONNULL_END
