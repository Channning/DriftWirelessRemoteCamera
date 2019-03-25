//
//  DriftCameraCommandsViewController.m
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Drift Innovacation Ltd. All rights reserved.
//

#import "DriftCameraCommandsViewController.h"


unsigned int notificationCount;
unsigned int cameraDateSettingFlag;
unsigned int zoomIdx;
unsigned int fileIndex;
unsigned int selectedRowIndexNumber;

@implementation DriftCameraCommandsViewController
//Session Page
@synthesize startSessionButton;//      = _startSessionButton;
@synthesize cameraCommandsButton;//    = _cameraCommandsButton;
@synthesize fileOperationButton;//     = _fileOperationButton;
@synthesize cameraSettingButton;//     = _cameraSettingButton;
@synthesize disconnectButton;//        = _disconnectButton;
@synthesize tcpConnectionFailButton;// = _tcpConnectionFailButton;
@synthesize cameraParaName;//          = _cameraParaName;
@synthesize setCameraParamName;//      = _setCameraParamName;
@synthesize cameraParameterOptionValue;// = _cameraParameterOptionValue;
@synthesize getCameraParameterValueButton;// = _getCameraParameterValueButton;
@synthesize setOptionUpButton;//       = _setOptionUpButton;
@synthesize updateParamOption;//       = _updateParamOption;
@synthesize wifiSettingsButton;
@synthesize dateTextField;
@synthesize zoomTypeButton, zoomInfoButton, bitRateField;
@synthesize roMediaAttributeButton, rwMediaAttributeButton;
@synthesize fList, selectedFile, mediaInfoButton,deleteFileButton,upLoadFileView,fileListing;
@synthesize fileToUploadTextField,imageView;
@synthesize md5SumButton, fileUploadButton, uploadFileOffsetTextField, uploadFileSizeTextField;
@synthesize customJSONCmdButton, customJSONTextField;
@synthesize clientIPAddrTextBox,clientTransportSwitch,clientTransportType,setClientInfoButton;
@synthesize moviePlayer, changeDirectoryButton;
@synthesize wifiItemList, wifiListTableView;
@synthesize selectedWifiParameter,selectedWifiParameterToEdit;
@synthesize driftQuerySessionHolderSwitch;


- (void) hideMainButtons
{
    //NSLog(@"DBG: %ld",(long)[DriftWifiRemoteControl getInstance].wifiTCPConnectionStatus );
    if ([DriftStateMachine getInstance].networkModeWifi == 1) {
        if ( [DriftStateMachine getInstance].wifiTCPConnectionStatus == 1 ) {
            //NSLog(@"TCP connection Is enabled");
            //[self hideMainButtons];
        } else {
            NSLog(@"TCP connection was failed");
            [self.tcpConnectionFailButton setHidden:NO];
            [self.tcpConnectionFailButton setEnabled:YES];
            [self.presentingViewController dismissViewControllerAnimated:NO
                                                         completion:nil];
        }
    }
    if ([DriftStateMachine getInstance].networkModeBle == 1) {
        if ([DriftStateMachine getInstance].cameraBleMode == NO) {
            NSLog(@"BLE connection was failed");
            [self.tcpConnectionFailButton setHidden:NO];
            [self.tcpConnectionFailButton setEnabled:YES];
            [self.presentingViewController dismissViewControllerAnimated:NO
                                                              completion:nil];
        }
    }
    [self.startSessionButton    setEnabled:YES];
    [self.cameraCommandsButton  setEnabled:NO];
    [self.fileOperationButton   setEnabled:NO];
    [self.cameraSettingButton   setEnabled:NO];
    [self.disconnectButton      setEnabled:NO];
    [self.roMediaAttributeButton setEnabled:NO];
    [self.rwMediaAttributeButton setEnabled:NO];
    [self.mediaInfoButton setEnabled:NO];
    [self.deleteFileButton setEnabled:NO];
    [self.customJSONCmdButton setEnabled:NO];
    [self.setClientInfoButton   setEnabled:NO];

}
- (void) enableMainButtons
{
    [self.startSessionButton    setEnabled:NO];
    [self.cameraCommandsButton  setEnabled:YES];
    [self.fileOperationButton   setEnabled:YES];
    [self.cameraSettingButton   setEnabled:YES];
    [self.disconnectButton      setEnabled:YES];
    [self.customJSONCmdButton   setEnabled:YES];
    [self.wifiSettingsButton setEnabled:YES];
    [self.startSessionButton setTitle: @"Enabled"  forState:UIControlStateNormal];
    //API4.x SetClient Info
    [self.setClientInfoButton   setEnabled:YES];
    //Update the Local Client Wifi IP address and fill the textBox
    [self updateLocalWifiIPaddress];
}

- (void) updateLocalWifiIPaddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *tmpAddrs = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        tmpAddrs = interfaces;
        while (tmpAddrs != NULL) {
            if (tmpAddrs->ifa_addr->sa_family == AF_INET) {
                //interface en0 is Wifi Interface name on iOS devices
                if ([[NSString stringWithUTF8String:tmpAddrs->ifa_name ] isEqualToString:@"en0" ]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)tmpAddrs->ifa_addr)->sin_addr)];
                }
            }
            tmpAddrs = tmpAddrs->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    
    self.clientIPAddrTextBox.text = address;
    self.clientIPAddrTextBox.enabled = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/*
- (id) init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDebugNotification)
                                                 name:@"testNotification"
                                               object:nil];
    return self;
}
- (void) receiveDebugNotification: (NSNotification *) notification
{
    if([[notification name] isEqualToString:@"testNotification"])
        NSLog(@"Success In recv Notification");
        
} */
- (void)viewDidLoad
{
    cameraDateSettingFlag = 0;
    zoomIdx = 0;
    fileIndex = 0;
    [super viewDidLoad];
    [self hideMainButtons];
    self.bitRateField.text = @"100";
    [self.zoomInfoButton setEnabled:NO];
    [self.getCameraParameterValueButton setEnabled:NO];
    [self.setCameraParameterValue setEnabled:NO];
    [self.setOptionUpButton setEnabled:NO];
    [self.updateParamOption setEnabled:NO];
    [self.wifiSettingsButton setEnabled:NO];
    
    //self.clientIPAddrTextBox.enabled = NO;
    //assert(self.tcpConnectionFailButton != nil);
    
    if ( [DriftStateMachine getInstance].wifiTCPConnectionStatus == 0 ) {
        [self.tcpConnectionFailButton setHidden:NO];
        [self.tcpConnectionFailButton setEnabled:YES];
    } else {
        [self.tcpConnectionFailButton setHidden:YES];
       
    }
    
//    self.customJSONTextField.text = [[DriftStateMachine getInstance] customString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(severedNotification:)
                                                 name:cameraSeveredNotification
                                               object:[DriftStateMachine getInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsonCommandDebug:)
                                                 name:jsonDebugNotification
                                               object:nil];
                                               //object:[DriftWifiRemoteControl getInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(connectedToRemoteCam:)
                                                 name: changeInConnectionStatusNotification
                                               object: [DriftStateMachine getInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disconnectedToRemoteCam:)
                                                 name:startSessionRefusalNotification
                                               object:[DriftStateMachine getInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateCommandReturnStatus:)
                                                 name: updateCommandReturnStatusNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateFileListReturnStatus:)
                                                 name: updateFileListReturnStatusNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(querySessionHolder:)
                                                 name:querySessionHolderNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateWifiListStatus:)
                                                 name: updateWifiListNotification
                                               object: nil];
    self.wifiItemList = [[NSMutableArray alloc] init];
    selectedRowIndexNumber = 0;

    
    self.fList = [[NSMutableArray alloc] init];
    
    [driftQuerySessionHolderSwitch addTarget:self action:@selector(changeSwitch) forControlEvents:UIControlEventValueChanged];
    
}

- (void) changeSwitch {
    if ([self.driftQuerySessionHolderSwitch isOn])
    {
        NSLog(@"Auto resend DRIFT_QUERY_SESSION_HOLDER  = ON");
        [DriftStateMachine getInstance].enableSessionHolder = YES;
    } else {
        NSLog(@"disable auto response DRIFT_QUERY_SESSION_HOLDER = OFF");
        [DriftStateMachine getInstance].enableSessionHolder = NO;
    }
}


- (void) querySessionHolder: (NSNotification *)notificationParam
{
    if ( ([ DriftStateMachine getInstance].notificationCount ) && ([DriftStateMachine getInstance].enableSessionHolder == NO)){
        
       UIAlertView *jsonDebugAlert = [[UIAlertView alloc] initWithTitle:@"Last Command Response:"
                                                                 message: [DriftStateMachine getInstance].notifyMsg
                                                                delegate:self
                                                       cancelButtonTitle:@"close"
                                                       otherButtonTitles:@"Retain Session", nil];
 
        [jsonDebugAlert show];

        [ DriftStateMachine getInstance].notificationCount = 0;
    } else { //Auto Replay to drift_qurty_session_holder
        [[DriftStateMachine getInstance ] keepSessionActive];

    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"Notification Alert Selected");
    } else {
        NSLog(@"Retain Current Session");
        [[DriftStateMachine getInstance ] keepSessionActive];
    }
}
-(void) viewWillAppear:(BOOL)animated
{
    self.changeDirectory.text = @"/tmp/SD0/DCIM/";
    self.fileToDownloadField.text = @"/tmp/SD0/DCIM/";
    ////self.mediaInfoTextField.text =@"/tmp/fuse_d/DCIM/100MEDIA/";
    ////self.fileToRemoveTextField.text = @"/tmp/fuse_d/DCIM/100MEDIA/";
    self.fileDownLoadOffset.text = @"0";
    self.fileDownLoadSize.text = @"0";
    self.sdMediaName.text = @"D:";
    self.uploadFileOffsetTextField.text = @"0";
    self.uploadFileSizeTextField.text = @"0";
    [self.md5SumButton setEnabled:NO];
    [self.fileUploadButton setEnabled:NO];
    //File Browse:
    ////self.dateTextField = [[UITextField alloc] initWithFrame:CGRectMake(26,248, 222, 30)];
    //self.dateTextField.borderStyle = UITextBorderStyleRoundedRect;
    //self.dateTextField.text = @"2015-01-22-13-10-33";
    //dateText.delegate = self;
    //[self.dateTextField setHidden:YES];
    //[self.dateTextField setEnabled:NO];
    ////self.dateTextField.hidden = YES;
    ////self.dateTextField.userInteractionEnabled = NO;

}

// Calculate Md5 Sum of  a file @ path:
- (NSString *)md5HashOfPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if ( [fm fileExistsAtPath:path isDirectory:nil])
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5( data.bytes, (CC_LONG)data.length, digest);
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
        
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        {
            [output appendFormat:@"%02x", digest[i]];
        }
        NSLog(@"MD5Sum of selected File: %@", output);
        self.returnStatusLabel.text  = output;
        return output;
    } else {
        return @"";
    }
}

- (IBAction)setPlayBackFileName:(id)sender {
    //[[DriftStateMachine getInstance] presentWorkingDir];
    if (self.selectedFile != nil) {
        [DriftStateMachine getInstance].playbackFile = self.selectedFile;
    }
}



- (IBAction)textFieldReturn : (id)sender
{
    //Done/Return Press = hide keyboard
    [sender resignFirstResponder];
}

- (void) connectedToRemoteCam:(NSNotificationCenter *)notificationParam
{
    NSLog(@"Connection to Drift remote camera done");
    
    [[[UIAlertView alloc] initWithTitle:@"Connection To Drift Remote Cam: "
                                message:@"Camera Control Session Status: Success"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    //Enable Buttons
    [self enableMainButtons];
}
- (void) disconnectedToRemoteCam:(NSNotificationCenter *)notificationParam
{
    NSLog(@"Start Session Failed !!!");
    
    [[[UIAlertView alloc] initWithTitle:@"Connection To Drift Remote Cam: "
                                message:@"Start Session: FAIL, Camera May Be in Manual Control Mode"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
    //Enable Buttons
    [self enableMainButtons];
    
}

- (void) severedNotification: (NSNotification *)notificationParam
{
    //NSLog(@"Camera Severed Notification:1");
    if ( [ DriftStateMachine getInstance].notificationCount ) {
        UIAlertView *severedConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Notification From Camera:"
                                                                     message: [DriftStateMachine getInstance].notifyMsg
                                                                    delegate:self
                                                           cancelButtonTitle:@"Close"
                                                           otherButtonTitles: nil];
        [severedConnectionAlert show];
        [DriftStateMachine getInstance].notificationCount = 0;
    }
}

- (void) jsonCommandDebug: (NSNotification *)notificationParam
{
    //NSLog(@"Camera Severed Notification:2");
    if ([ DriftStateMachine getInstance].notificationCount ){
        UIAlertView *jsonDebugAlert = [[UIAlertView alloc] initWithTitle:@"Last Command Response:"
                                                                 message: [DriftStateMachine getInstance].notifyMsg
                                                                delegate:self
                                                       cancelButtonTitle:@"Close"
                                                       otherButtonTitles: nil];
        [jsonDebugAlert show];
        //notificationCount = 0;
        [ DriftStateMachine getInstance].notificationCount = 0;
    }
}

- (void) updateCommandReturnStatus: (NSNotification *)notificationParam
{
    if ( [DriftStateMachine getInstance].commandReturnValue == 0 )
        self.returnStatusLabel.text = [NSString stringWithFormat:@"%@ SUCCESS",self.returnStatusLabel.text];
    else if ([DriftStateMachine getInstance].commandReturnValue < 0)
        self.returnStatusLabel.text = [NSString stringWithFormat:@"%@ FAIL",self.returnStatusLabel.text];
    
    if (self.selectedFile != nil) {
        //Update TableView to show updated file list on changeDirectory or file delete
        self.selectedFile = nil;
        [self updateFileListing];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)connectToCamera:(id)sender {
    if ( [[DriftStateMachine getInstance] connectToCamera] == 0) {
        [self enableMainButtons];
    } else {
        //TODO: Notification pop-up
        NSLog(@"Failed To connect to camera");
        [self hideMainButtons];
    }
}

- (IBAction)takePhoto:(id)sender {
    self.returnStatusLabel.text = @"Take Photo:";
    [[DriftStateMachine getInstance] takePhoto];
}

- (IBAction)startRecording:(id)sender {
    self.returnStatusLabel.text = @"Record:";
    [[DriftStateMachine getInstance] cameraRecordStart];
}

- (IBAction)stopRecording:(id)sender {
    self.returnStatusLabel.text = @"Stop Record:";
    [[DriftStateMachine getInstance] cameraRecordStop];
}

- (IBAction)recordingTime:(id)sender {
    self.returnStatusLabel.text = @"Get RecordingTime:";
    [[DriftStateMachine getInstance] cameraRecordingTime];
}

- (IBAction)splitRecording:(id)sender {
    self.returnStatusLabel.text = @"Split Recording:";
    [[DriftStateMachine getInstance] cameraSplitRecording];
}

- (IBAction)stopViewFinder:(id)sender {
    self.returnStatusLabel.text = @"Stop ViewFinder:";
    [[DriftStateMachine getInstance] cameraStopViewFinder];
}

- (IBAction)resetViewFinder:(id)sender {
    self.returnStatusLabel.text = @"Reset ViewFinder:";
    [[DriftStateMachine getInstance] cameraResetViewFinder];
}

- (IBAction)cameraAppStatus:(id)sender {
    self.returnStatusLabel.text = @"Camera APP Status:";
    [[DriftStateMachine getInstance] cameraAppStatus];
    [self reloadInputViews];
    [self hideMainButtons];
}

- (IBAction)disconnectToCamera:(id)sender {
    if ( [[DriftStateMachine getInstance] disconnectToCamera] == 0) {
        
        NSLog(@"====Session Closed====");
        
    } else {
        //TODO: pop out a notification that disconnect is failed
        NSLog(@"DISCONNECT FAIL: Unknown Reason");
        [[[UIAlertView alloc] initWithTitle:@"Session Disconnect"
                                                        message:@"Failed To disconnect"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil] show];
         NSLog(@"====Session Closed====-------------");
        [self shouldPerformSegueWithIdentifier:@"failedToDisconnect" sender:self];
    }

}
- (IBAction)totalStorageSpace:(id)sender {
    self.returnStatusLabel.text = @"Total Storage Space:";
    [[DriftStateMachine getInstance] cameraStorageSpace];
}

- (IBAction)totalFreeSpace:(id)sender {
    self.returnStatusLabel.text = @"Total Free Space:";
    [[DriftStateMachine getInstance] cameraFreeSpace];
}

- (IBAction)presentWorkingDir:(id)sender {
    self.returnStatusLabel.text = @"Camera Present Dir:";
    [[DriftStateMachine getInstance] presentWorkingDir];
}

- (IBAction)allFilesList:(id)sender {
    self.returnStatusLabel.text = @"List all Files     :";
    if (self.fList)
        [self.fList removeAllObjects];
    
    [[DriftStateMachine getInstance] listAllFiles];
}

- (IBAction)changeDirectoryFromTableView:(id)sender {
    //TODO: Enable Button only when a Field from TableView is selected
    self.returnStatusLabel.text = @"Change Directory:";
    if (self.selectedFile != nil) {
        [[DriftStateMachine getInstance] cameraChangeToFolder: self.selectedFile];
        NSLog(@"Change To Folder %@",self.selectedFile);//self.selectedFile);
        [self.roMediaAttributeButton setEnabled:NO];
        [self.rwMediaAttributeButton setEnabled:NO];
        [self.mediaInfoButton setEnabled:NO];
        [self.deleteFileButton setEnabled:NO];
        ////self.selectedFile = nil;
    }
    
}

- (IBAction)changeFolder:(id)sender  {
    self.returnStatusLabel.text = @"Change Folder:";
    //NSLog( @"Change to Folder : %@", self.changeDirectory.text);
    [[DriftStateMachine getInstance] cameraChangeToFolder: self.changeDirectory.text];
}

- (IBAction)getMediaInfo:(id)sender {// :(NSString *)textInputVal {
    self.returnStatusLabel.text = @"Get Media Info:";
    if (self.selectedFile != nil) {
        [[DriftStateMachine getInstance] mediaInfo: self.selectedFile];
        [self.mediaInfoButton setEnabled:NO];
        [self.roMediaAttributeButton setEnabled:NO];
        [self.rwMediaAttributeButton setEnabled:NO];
        [self.deleteFileButton setEnabled:NO];
        self.selectedFile = nil;        
    }
}

- (IBAction)fileDownload:(id)sender { //:(NSString *)textInputVal{
    if ([DriftStateMachine getInstance].networkModeWifi || [DriftStateMachine getInstance].wifiBleComboMode)
    {
        self.returnStatusLabel.text = @"File DownLoad:";
        [[DriftStateMachine getInstance] cameraFileDownload: self.fileToDownloadField.text
                                                          :self.fileDownLoadOffset.text
                                                          :self.fileDownLoadSize.text ];
    } else {
        self.returnStatusLabel.text = @"!!No Support for BLEMode!!";
    }
    
}


- (IBAction)stopFileDownload:(id)sender { //:(NSString *)textInputVal{
    self.returnStatusLabel.text = @"Stop FileDownload:";
    [[DriftStateMachine getInstance] cameraStopFileDownload: self.fileToDownloadField.text];
}

- (IBAction)numberOfFiles:(id)sender {
    self.returnStatusLabel.text = @"TotalNoFiles:";
    [[DriftStateMachine getInstance] numberOfFilesInFolder:(NSString *)@"total"];
}

- (IBAction)numberOfPhotoFiles:(id)sender {
    self.returnStatusLabel.text = @"NoPhotoFiles:";
    [[DriftStateMachine getInstance] numberOfFilesInFolder:(NSString *)@"photo"];
}

- (IBAction)numberOfVideoFiles:(id)sender {
    self.returnStatusLabel.text = @"NoVideoFiles:";
    [[DriftStateMachine getInstance] numberOfFilesInFolder:(NSString *)@"video"];
}

- (IBAction)formatSDCardMedia:(id)sender {
    self.returnStatusLabel.text = @"Format SD:";
    [[DriftStateMachine getInstance] formatSDmedia:(NSString *)self.sdMediaName.text];
}



- (IBAction)showDebug:(id)sender
{
    //notificationCount = 1;
    [[DriftStateMachine getInstance] showCameraDebugCmd];
    
}
- (IBAction)deleteFile:(id)sender {
    self.returnStatusLabel.text = @"File Delete:";
    if (self.selectedFile != nil) {
        [[DriftStateMachine getInstance] fileToRemove: self.selectedFile];
        [self.roMediaAttributeButton setEnabled:NO];
        [self.rwMediaAttributeButton setEnabled:NO];
        [self.mediaInfoButton setEnabled:NO];
        [self.deleteFileButton setEnabled:NO];
        //self.selectedFile = nil;
    }
}
- (IBAction) currentSettings:(id)sender{
    [[DriftStateMachine getInstance] getCurrentSettings];
}

- (IBAction)viewRTSPStream:(id)sender {
    self.returnStatusLabel.text = @"Reset ViewFinder:";
    //// -- getram22 -- ON A12 If reset vf and move to rtsp view will cause error "rtsp server" not found.
    ////[[DriftStateMachine getInstance] cameraResetViewFinder];
}

- (IBAction)zoomInfo:(id)sender {
    self.returnStatusLabel.text = @"ZooM Info:";
    [self.zoomInfoButton setEnabled:NO];
    [[DriftStateMachine getInstance] getZoomInfo:self.zoomTypeButton.titleLabel.text];
}

- (IBAction)toggleZoomLable:(id)sender {
    NSArray *zoomTypeArray = [NSArray arrayWithObjects:@"max",@"current",@"status", nil];
    
    [self.zoomTypeButton setTitle:[zoomTypeArray objectAtIndex:zoomIdx] forState:UIControlStateNormal];
    [self.zoomInfoButton setEnabled:YES];
    if (zoomIdx == 2)
        zoomIdx = 0;
    else
        zoomIdx = zoomIdx + 1;
}

- (IBAction)setBitrate:(id)sender {
    self.returnStatusLabel.text = @"SetStreamBitRate:";
    [[DriftStateMachine getInstance] setStreamBitrate:self.bitRateField.text];
}

- (IBAction)getBatteryLevel:(id)sender {
    self.returnStatusLabel.text = @"GetBatteryLevelInfo:";
    [[DriftStateMachine getInstance] getBatteryLevelInfo];
}
- (IBAction)cameraParamUp:(id)sender {
    //Enable Get Button
    [self.getCameraParameterValueButton setEnabled:YES];
    
    [[DriftStateMachine getInstance] newTitle];
    NSMutableArray *titleStr = (NSMutableArray *)[DriftStateMachine getInstance].buttonTitleName;
    [self.cameraParaName setTitle: [titleStr  objectAtIndex:0] forState:UIControlStateNormal] ;
}
- (IBAction)getCameraParameterValue:(id)sender {
    [[DriftStateMachine getInstance] cameraStopViewFinder];
    //NSLog(@" Get Button Title : %@ ", _cameraParaName.titleLabel.text);
    self.returnStatusLabel.text = @"Get Camera Setting:";
    [[DriftStateMachine getInstance] getSettingValue: (NSString *)self.cameraParaName.titleLabel.text ];
}
- (IBAction)setCameraParamUp:(id)sender {
    [[DriftStateMachine getInstance] newTitle];
    NSMutableArray *setTitleStr = (NSMutableArray *)[DriftStateMachine getInstance].buttonTitleName;
    [self.setCameraParamName setTitle: [setTitleStr objectAtIndex:0] forState: UIControlStateNormal];
    
    [self.cameraParameterOptionValue setTitle:@" --------^ " forState:UIControlStateNormal];
    [self.setCameraParameterValue setEnabled:NO];
    [self.setOptionUpButton setEnabled:NO];
    [self.updateParamOption setEnabled:YES];
}

- (IBAction)updateParamOptionButton:(id)sender {
    self.returnStatusLabel.text = @"";
    //stop streaming before set
    [[DriftStateMachine getInstance] cameraStopViewFinder];
    [DriftStateMachine getInstance].permissionFlag  = @"";
    if ([self.setCameraParamName.titleLabel.text isEqualToString:@"app_status"]) {
        //disable set Button and Update the Options Buttons with N/A
        [self.cameraParameterOptionValue setTitle:@"N/A" forState:UIControlStateNormal];
        [self.setCameraParameterValue setEnabled: NO];
        NSLog(@"---App Status---");
    } else if ([[DriftStateMachine getInstance].permissionFlag isEqualToString: @"readonly"]) {
        [self.setCameraParameterValue setEnabled: NO];
        NSLog(@"---read only---");

    }
    else {
        
        [[DriftStateMachine getInstance] getOptionsForValue: (NSString *) self.setCameraParamName.titleLabel.text];
        [self.setCameraParameterValue setEnabled: YES];
        [self.cameraParameterOptionValue setTitle:@" --------> " forState:UIControlStateNormal];
        [self.setCameraParameterValue setEnabled: NO];
        [self.setOptionUpButton setEnabled:YES];
        NSLog(@"---get options---");
    }
    
}


- (IBAction)setOptionUp:(id)sender {
    
    if ([self.setCameraParamName.titleLabel.text isEqualToString:@"app_status"]) {
        [self.cameraParameterOptionValue setTitle:@"N/A" forState:UIControlStateNormal];
        [self.setCameraParameterValue setEnabled: NO];
    }
    else if ([self.setCameraParamName.titleLabel.text isEqualToString:@"camera_clock"])
    {
        [self.cameraParameterOptionValue setTitle:@"specify the Date and SET" forState:UIControlStateNormal];
        [self.setCameraParameterValue setEnabled: YES];
        
        self.dateTextField.hidden = NO;
        self.dateTextField.userInteractionEnabled = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        self.dateTextField.text = [dateFormatter stringFromDate:[NSDate date]];
        //self.dateTextField.text = @"2015-01-22 13:10:33";
        //[self.dateTextField setHidden:NO];
        //[self.dateTextField setEnabled:YES];
        cameraDateSettingFlag  = 1;
    }
    else {
        [self.setCameraParameterValue setEnabled: YES];
        //NSLog(@"Update Options Button");
        [[DriftStateMachine getInstance] newOptionTitle];
        NSMutableArray *optionTitleStr = (NSMutableArray *)[DriftStateMachine getInstance].optionButtonTitleName;
        //NSLog( @"current Option %@",optionTitleStr);
        [self.cameraParameterOptionValue setTitle:(NSMutableString *)optionTitleStr  forState: UIControlStateNormal];
        //NSLog(@"Update Options Button--Done");
        if ( [[DriftStateMachine getInstance].permissionFlag isEqualToString: @"readonly"] ) {
            [self.setCameraParameterValue setEnabled: NO];
            self.returnStatusLabel.text = @"!!!! READ ONLY !!!!";
        }
    }
}
- (void) setCameraParameter: (id) sender
{
    if (cameraDateSettingFlag == 1) {
        self.returnStatusLabel.text = @"Setting Command:";
        self.cameraParameterOptionValue.titleLabel.text = self.dateTextField.text;
        [[DriftStateMachine getInstance] setCameraParameterValue: (NSString *)self.setCameraParamName.titleLabel.text
                                                               : (NSString *)self.dateTextField.text];
        cameraDateSettingFlag = 0;
        [self.dateTextField setEnabled:NO];
        [self.dateTextField setHidden:YES];
        [self.setCameraParameterValue setEnabled: NO];
    }
    else {
        self.returnStatusLabel.text = @"Setting Command:";
        [[DriftStateMachine getInstance] setCameraParameterValue: (NSString *)self.setCameraParamName.titleLabel.text
                                                               : (NSString *)self.cameraParameterOptionValue.titleLabel.text];
        [self.setCameraParameterValue setEnabled: NO];
    }
        
}

- (IBAction)setMediaReadOnly:(id)sender {
    if (self.selectedFile != nil) {
        self.returnStatusLabel.text = @"SetFileAsRO:";
        [[DriftStateMachine getInstance] setFileAsRO:self.selectedFile];
    }
    [self.roMediaAttributeButton setEnabled:NO];
    [self.rwMediaAttributeButton setEnabled:NO];
    [self.mediaInfoButton setEnabled:NO];
    [self.deleteFileButton setEnabled:NO];
    self.selectedFile = nil;
}

- (IBAction)setMediaReadWrite:(id)sender {
    if (self.selectedFile != nil) {
        self.returnStatusLabel.text = @"SetFileAsRW:";
        [[DriftStateMachine getInstance] setFileAsRW:self.selectedFile];
    }
    [self.roMediaAttributeButton setEnabled:NO];
    [self.rwMediaAttributeButton setEnabled:NO];
    [self.mediaInfoButton setEnabled:NO];
    [self.deleteFileButton setEnabled:NO];
    self.selectedFile = nil;
}
- (IBAction)loadFileList:(id)sender {
    [self updateFileListing];
}
- (void) updateFileListing
{
    if (self.fList)
        [self.fList removeAllObjects];
    [[DriftStateMachine getInstance] listAllFiles];
    ////[self.fList removeAllObjects];
}

- (void) updateFileListReturnStatus:(NSNotification *)notificationParam//(NSString *)test
{
    self.returnStatusLabel.text = @"File List Updated";
    //if ([DriftStateMachine getInstance].notificationCount == 1) {
    NSMutableString *tmpString = [DriftStateMachine getInstance].notifyMsg;
    NSData *data = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    NSMutableArray  *tmpArray = [[NSMutableArray alloc] init];
    tmpArray = (NSMutableArray *)[jsonResponse objectForKey:@"listing"];
    int idx;
    idx  = (int) [tmpArray count];
    for (int i=0;i<idx;i++){
        [self.fList addObject:[[tmpArray objectAtIndex:i] allKeys][0]];
        ////NSLog(@"Class:::: %@",NSStringFromClass([self.fList[i][0] class]));
    }
    //NSLog(@":::::::::%@:%d",self.fList,[self.fList count]);
    [self.fileListTableView reloadData];
    [DriftStateMachine getInstance].notificationCount = 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000 ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileListTableView"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fileListTableView"];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:13];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        cell.textLabel.text = [self.fList objectAtIndex:indexPath.row];
        
        return cell;
    } else if (tableView.tag == 1001){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wifiListTableView"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wifiListTableView"];
        }
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:13];
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
        cell.textLabel.text = [self.wifiItemList objectAtIndex:indexPath.row];
        
        return cell;
    } else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1000)
        return [self.fList count];
    else if (tableView.tag == 1001)
        return [self.wifiItemList count];
    else
        return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000 )
    {
        NSLog(@"Selected File: %@", [self.fList objectAtIndex:indexPath.row]);
        self.selectedFile = [self.fList objectAtIndex:indexPath.row];
        [self.roMediaAttributeButton setEnabled:YES];
        [self.rwMediaAttributeButton setEnabled:YES];
        [self.mediaInfoButton setEnabled:YES];
        [self.deleteFileButton setEnabled:YES];
    }
    if (tableView.tag == 1001)
    {
        NSLog(@"Selected wifi Param %@", [self.wifiItemList objectAtIndex:indexPath.row]);
        self.selectedWifiParameter = [self.wifiItemList objectAtIndex:indexPath.row];
        //Update the Edit TextField
        self.selectedWifiParameterToEdit.text = [self.wifiItemList objectAtIndex:indexPath.row];
        selectedRowIndexNumber = indexPath.row;
    }
}
- (IBAction)getDeviceInfo:(id)sender {
    self.returnStatusLabel.text = @"Fetch Device Info:";
    [[DriftStateMachine getInstance] getDeviceInformation];
}
//FileUpload
- (void) listLocalFiles
{
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
   // NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:@"DriftRemoteCam.txt"];
    NSFileManager   *manager = [NSFileManager defaultManager];
    NSLog(@"List of Files in Documents Folder: %@:%d",[manager contentsOfDirectoryAtPath:documentsDirectory
                                                                                       error:nil],
          [[manager contentsOfDirectoryAtPath:documentsDirectory
                                        error:nil] count]);
    self.fileToUploadTextField.text = [manager contentsOfDirectoryAtPath:documentsDirectory
                                                                   error:nil][fileIndex];
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",documentsDirectory,self.fileToUploadTextField.text] error:nil];
    unsigned long long fileSize = [fileAttributes fileSize];
    self.uploadFileSizeTextField.text = [NSString stringWithFormat:@"%llu",fileSize];
    //NSLog(@"Selected File Size: %llu", fileSize);
    self.returnStatusLabel.text = [NSString stringWithFormat:@"selected File Size:%llu",fileSize];
    
    fileIndex = fileIndex + 1;
    if (fileIndex == [[manager contentsOfDirectoryAtPath:documentsDirectory error:nil] count])
        fileIndex = 0;
    //else
    //    fileIndex = fileIndex + 1;
   /* self.imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",documentsDirectory,
                                                             [manager contentsOfDirectoryAtPath:documentsDirectory
                                                                                         error:nil][1]]]; */
}

- (IBAction)deleteLocalFiles:(id)sender {
    NSFileManager   *manager = [NSFileManager defaultManager];
    
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    //allfiles in the document dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    //filter the array for jpg files
    NSPredicate *jpgfltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"];
    NSArray *jpgFiles = [allFiles filteredArrayUsingPredicate:jpgfltr];
    
    NSPredicate *JPGfltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.JPG'"];
    NSArray *JPGFiles = [allFiles filteredArrayUsingPredicate:JPGfltr];
    // iterate the array and delete the files
    for (NSString *jpgFile in jpgFiles )
    {
        NSError *error = nil;
        NSString *fileToDel = [NSString stringWithFormat:@"/%@",jpgFile];

        [manager removeItemAtPath:[documentsDirectory stringByAppendingString:fileToDel] error:&error];
        
        NSLog(@"deleting :%@",[documentsDirectory stringByAppendingString:fileToDel] );
    }
    for (NSString *JPGFile in JPGFiles )
    {
        NSError *error = nil;
        NSString *fileToDel = [NSString stringWithFormat:@"/%@",JPGFile];
        
        [manager removeItemAtPath:[documentsDirectory stringByAppendingString:fileToDel] error:&error];
        
        NSLog(@"deleting :%@",[documentsDirectory stringByAppendingString:fileToDel] );
    }
    
    NSPredicate *mp4fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.mp4'"];
    NSArray *mp4Files = [allFiles filteredArrayUsingPredicate:mp4fltr];
    
    NSPredicate *MP4fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.MP4'"];
    NSArray *MP4Files = [allFiles filteredArrayUsingPredicate:MP4fltr];
    // iterate the array and delete the files
    for (NSString *mp4File in mp4Files )
    {
        NSError *error = nil;
        NSString *fileToDel = [NSString stringWithFormat:@"/%@",mp4File];
    
        [manager removeItemAtPath:[documentsDirectory stringByAppendingString:fileToDel] error:&error];
        NSLog(@"deleting :%@",[documentsDirectory stringByAppendingString:fileToDel] );

    }
    for (NSString *MP4File in MP4Files )
    {
        NSError *error = nil;
        NSString *fileToDel = [NSString stringWithFormat:@"/%@",MP4File];
        
        [manager removeItemAtPath:[documentsDirectory stringByAppendingString:fileToDel] error:&error];
        NSLog(@"deleting :%@",[documentsDirectory stringByAppendingString:fileToDel] );
        
    }
    fileIndex = 0;
}


- (IBAction)viewLocalImage:(id)sender {
    
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:self.fileToUploadTextField.text];//@"Drift.jpg"];
    
    NSLog(@"Selected Image for View: %@",filePath);

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,137,320,207)];
        imageView.image = [[UIImage alloc] initWithContentsOfFile:filePath];
        [self.view addSubview:imageView];
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(38,145,524,320)];
        imageView.image = [[UIImage alloc] initWithContentsOfFile:filePath];
        [self.view addSubview:imageView];
    }
    
}

- (IBAction)viewLocalVideo:(id)sender {
    
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:self.fileToUploadTextField.text];//@"Drift.mp4"];
    NSURL       *videoFileUrl = [NSURL fileURLWithPath:filePath];
    
    NSLog(@"Selected Local downloaded video : %@",filePath);
    //MPMoviePlayerController *moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:videoFileUrl];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoFileUrl];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        //[self.moviePlayer.view setFrame:CGRectMake(40, 197, 240, 160)];
        [self.moviePlayer.view setFrame:CGRectMake(0,137,320,207)];
    } else {
        [self.moviePlayer.view setFrame:CGRectMake(38,145,524,320)];
    }
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer setShouldAutoplay:NO]; // And other options you can look through the documentation.
    
    [self.view addSubview:self.moviePlayer.view];
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    [self.moviePlayer stop];
}

- (IBAction)listAppFiles:(id)sender {
    [self listLocalFiles];
    [self.md5SumButton setEnabled:YES];
}

- (IBAction)computeMd5Sum:(id)sender {
    if ( self.fileToUploadTextField.text != nil )
    {
        NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
        NSString    *documentsDirectory = [paths objectAtIndex:0];
        NSString    *filePath = [documentsDirectory
                                 stringByAppendingPathComponent:[NSString stringWithFormat:
                                                                 @"%@",self.fileToUploadTextField.text]];
        [self.md5SumButton setTitle: [self md5HashOfPath:filePath]  forState:UIControlStateNormal];
    }
    [self.fileUploadButton setEnabled:YES];
    [self.md5SumButton setEnabled:NO];
}

- (IBAction)uploadLocalFile:(id)sender {
    if ([DriftStateMachine getInstance].networkModeWifi || [DriftStateMachine getInstance].wifiBleComboMode)
    {     self.returnStatusLabel.text = @"UpLoadFileToCamera:";
        [[DriftStateMachine getInstance] uploadFileToCamera: self.fileToUploadTextField.text
                                                          :self.uploadFileSizeTextField.text
                                                          :self.md5SumButton.titleLabel.text
                                                          :self.uploadFileOffsetTextField.text];
        
        [self.fileUploadButton setEnabled:NO];
        [self.md5SumButton setEnabled:NO];
    } else {
        self.returnStatusLabel.text = @"!!Not Support In BLEMode!!";
        [self.fileUploadButton setEnabled:NO];
        [self.md5SumButton setEnabled:NO];
    }
}


- (IBAction)customJSONCmd:(id)sender {
    if ( [self.customJSONTextField.text length] != 0) {
        NSLog(@"Custom JSON Command: %@",self.customJSONTextField.text);
        [[DriftStateMachine getInstance] sendCustomJSONCommand: self.customJSONTextField.text];
    } else {
        NSLog(@"EMPTY String... Nothing to Send");
    }
}
- (IBAction)setClientInformation:(id)sender {
   /* if (self.clientTransportSwitch.on) {
        NSLog(@"Selected Transport : TCP");
        self.clientTransportType.text = (NSString *)@"UDP";
    } else  {
        NSLog(@"Selected Transport : UDP");
        self.clientTransportType.text = (NSString *)@"UDP";
    }*/
    self.clientTransportType.text = (NSString *)@"TCP";
    NSLog(@"SET_CLIEN_INFO %@:%@",self.clientIPAddrTextBox.text,self.clientTransportType.text);
    [[DriftStateMachine getInstance] setClientInfo: self.clientIPAddrTextBox.text
                                                 : self.clientTransportType.text];
}

- (IBAction)toggleTransportSwitch:(id)sender {
    /* Disable Toggle Transport as for now Only support TCP transportstream.
     
    if (self.clientTransportSwitch.on) {
        NSLog(@"Selected Transport : TCP");
        self.clientTransportType.text = (NSString *)@"TCP";
    } else  {
        NSLog(@"Selected Transport : UDP");
        self.clientTransportType.text = (NSString *)@"UDP";
    }
    */
}


- (void) updateWifiListStatus:(NSNotification *)notificationParam//(NSString *)test
{
    
    //if ([DriftStateMachine getInstance].notificationCount == 1) {
        NSMutableString *tmpString = [DriftStateMachine getInstance].notifyMsg;
        NSData *data = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
        NSMutableString  *tmpWifiString = [[NSMutableString alloc] init];
        tmpWifiString = (NSMutableString *)[jsonResponse objectForKey:@"param"];
    
    
        self.wifiItemList = (NSMutableArray *)[tmpWifiString componentsSeparatedByString:@"\n"];
    
        NSLog(@"List of Wifi Settings:=========== %@", self.wifiItemList);
        [self.wifiListTableView reloadData];
        [DriftStateMachine getInstance].notificationCount = 0;
    //}
    
}

- (IBAction)getWifiSettings:(id)sender {
    //Get All Wifi Settings and Update the Table View
    self.returnStatusLabel.text = @"Get WiFi Settings:";
    if (self.wifiItemList)
        [self.wifiItemList removeAllObjects];
    
    [[DriftStateMachine getInstance] getWifiSettings];
}

- (IBAction)setWifiSettings:(id)sender {
    //append items in wifiItemList with delimiter \n , apply the new string to camera
    self.returnStatusLabel.text = @"SetWifiSettings:";
    if ([self.wifiItemList count]) {
        NSMutableString *tmpString;
        tmpString = [[NSMutableString alloc] init];
        unsigned int idx;
        idx = [self.wifiItemList count];
        for (int i = 0; i < (idx - 1);i++) //using (idx - 1) to avoid multiple "\n" 's at string end
        {
            [tmpString appendString:self.wifiItemList[i]];
            [tmpString appendString:@"\n"];
        }
        //NSLog(@"NewString:%@", tmpString);
        [[DriftStateMachine getInstance] setWifiSettings:tmpString];
    }
}

- (IBAction)getWifiStatus:(id)sender {
    self.returnStatusLabel.text = @"getWifiStatus:";
    [[DriftStateMachine getInstance] getWifiSettings];
}

- (IBAction)stopWifi:(id)sender {
    //Pop Notification if we are on Wifi or Combo Modes
    self.returnStatusLabel.text = @"StopWifi:";
    [[DriftStateMachine getInstance] stopWifi];
}

- (IBAction)startWifi:(id)sender {
    self.returnStatusLabel.text = @"StartWifi:";
    [[DriftStateMachine getInstance] startWifi];
}

- (IBAction)restartWifi:(id)sender {
    //pop Notification if we are on wifi or Combo Modes
    self.returnStatusLabel.text = @"ReStartWifi:";
    [[DriftStateMachine getInstance] reStartWifi];
}

- (IBAction)editTableRowValue:(id)sender {
    self.wifiItemList[selectedRowIndexNumber] = self.selectedWifiParameterToEdit.text;
    [self.wifiListTableView reloadData];
    NSLog(@"array List after Update:%@",self.wifiItemList);
}




@end
