//
//  ViewController.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ambaStateMachine.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *defaultIP;
@property (weak, nonatomic) IBOutlet UITextField *cameraIPAddress;
@property (nonatomic,weak) IBOutlet UIButton *tcpConnectButton;
@property (nonatomic,weak) IBOutlet UIButton *cameraControlPanelButton;
@property (nonatomic,weak) IBOutlet UILabel *conStatusLabel;

- (IBAction) connectToCamera:(id)sender;
- (IBAction) textFieldReturn:(id)sender;
@end

