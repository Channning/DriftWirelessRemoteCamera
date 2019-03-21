//
//  ViewController.m
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import "ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.conStatusLabel.text = [NSString stringWithFormat:@""];
    if (self.cameraIPAddress != NULL)
    {
        self.defaultIP = [[NSMutableArray alloc] init];
        [self.defaultIP addObject:@"192.168.42.1"];
        self.cameraIPAddress.text = [self.defaultIP objectAtIndex:0];
        NSLog(@"Default IPAddress %@", [self.defaultIP objectAtIndex:0]);
    }
    else
    {
        self.cameraIPAddress.text = @"192.168.42.1";
    }
    [self.cameraControlPanelButton setHidden:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noConnectionStatus:)
                                                 name:noConnectionStatusNotification
                                               object:[ambaStateMachine getInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatus:)
                                                 name:connectionStatusNotification
                                               object:[ambaStateMachine getInstance]];
    
}


- (void) connectionStatus:(NSNotificationCenter *)notificationParam {
    [self.tcpConnectButton setHidden:YES];
    [self.tcpConnectButton setEnabled:NO];
    self.conStatusLabel.text = [NSString stringWithFormat:@"TCP Connection: OK" ];
    
    
    [self.cameraControlPanelButton setHidden:NO];
    [self.cameraControlPanelButton setEnabled:YES];
}

- (void) noConnectionStatus:(NSNotificationCenter *)notificationParam
{
    NSLog(@"Camera Not Answering Connection Request");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection To Camera: Lost" message:@"Please Check the Wifi Setting and Try Again" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert addAction:cancelAct];
    [self presentViewController:alert animated:YES completion:^{}];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) connectToCamera:(id)sender
{
    if ([self isDriftCameraIPAddress:[self fetchSSIDName]])
    {
        [[ambaStateMachine getInstance] initNetworkCommunication:self.cameraIPAddress.text tcpPort: 7878];
    }
    else
    {
        //以下代码为私有接口，请勿用在上架版本
        NSURL*url=[NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
            {
                //iOS10.0以上  使用的操作
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else
            {
                //iOS10.0以下  使用的操作
                [[UIApplication sharedApplication] openURL:url];
            }
        }

    }
    
    
    
}

- (IBAction)textFieldReturn : (id)sender
{
    //Done/Return Press = hide keyboard
    [sender resignFirstResponder];
}


//fetch current ssid info
- (NSString *)fetchSSIDName
{

    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    NSString *ssidName = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //DLog(@"%@ => %@", ifnam, info);
        //DLog(@"SSID: %@", (NSString *)CFDictionaryGetValue ((__bridge CFDictionaryRef)(info), kCNNetworkInfoKeySSID));
        if([info count])
        {
            ssidName = (NSString *)CFDictionaryGetValue ((__bridge CFDictionaryRef)(info), kCNNetworkInfoKeySSID);
            if (info && [info count]) { break; }
        }
    }
    return ssidName;

}
- (BOOL)isDriftCameraIPAddress:(NSString *)ssid
{
    if([ssid hasPrefix:@"Compass"] || [ssid hasPrefix:@"Ghost"] || [ssid hasPrefix:@"X1"] || [ssid hasPrefix:@"Stealth"] || [ssid hasPrefix:@"GHOST 4K"] || [ssid hasPrefix:@"GHOST X"] || [ssid hasPrefix:@"GHOST XL"])
        return YES;
    else
        return NO;
}


@end
