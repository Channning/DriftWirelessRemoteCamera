//
//  DriftLogViewController.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriftStateMachine.h"

NS_ASSUME_NONNULL_BEGIN

@interface DriftLogViewController : UIViewController
{
    IBOutlet UITextView  *textView;
}
- (IBAction)closeLogView:(id)sender;

- (IBAction)moveToEnd:(id)sender;
- (IBAction)resetLog:(id)sender;
@end

NS_ASSUME_NONNULL_END
