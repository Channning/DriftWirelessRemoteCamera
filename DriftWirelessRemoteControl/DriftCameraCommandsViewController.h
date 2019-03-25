//
//  DriftCameraCommandsViewController.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Drift Innovacation Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>	

#import "DriftStateMachine.h"
#import "Constants.h"

#import <MediaPlayer/MediaPlayer.h>

#include <ifaddrs.h>
#include <arpa/inet.h>


@interface DriftCameraCommandsViewController : UIViewController <UITextViewDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton     *startSessionButton;
@property (nonatomic, retain) IBOutlet UIButton     *cameraCommandsButton;
@property (nonatomic, retain) IBOutlet UIButton     *fileOperationButton;
@property (nonatomic, retain) IBOutlet UIButton     *cameraSettingButton;

@property (nonatomic, retain) IBOutlet UIButton     *disconnectButton;
@property (nonatomic, retain) IBOutlet UIButton     *tcpConnectionFailButton;
@property (retain, nonatomic) IBOutlet UILabel      *returnStatusLabel;
@property (nonatomic)         IBOutlet UITextField  *customJSONTextField;
@property (retain, nonatomic) IBOutlet UIButton     *customJSONCmdButton;
@property (retain, nonatomic) IBOutlet UIButton     *wifiSettingsButton;

//API4.x Client Info
@property (retain, nonatomic) IBOutlet UITextField *clientIPAddrTextBox;
@property (retain, nonatomic) IBOutlet UISwitch *clientTransportSwitch;
@property (retain, nonatomic) IBOutlet UILabel *clientTransportType;
@property (retain, nonatomic) IBOutlet UIButton *setClientInfoButton;

- (IBAction)setClientInformation:(id)sender;
- (IBAction)toggleTransportSwitch:(id)sender;

//Camera Cmd Buttons
@property (nonatomic, retain) IBOutlet UIButton     *shutterButton;
@property (nonatomic, retain) IBOutlet UIButton     *startRecButton;
@property (nonatomic, retain) IBOutlet UIButton     *stopRecButton;
@property (nonatomic, retain) IBOutlet UIButton     *recordingDurationButton;
@property (nonatomic, retain) IBOutlet UIButton     *forceSplitRecording;
@property (nonatomic, retain) IBOutlet UIButton     *stopVFButton;
@property (nonatomic, retain) IBOutlet UIButton     *resetVFButton;
@property (nonatomic, retain) IBOutlet UIButton     *appStatusButton;
@property (retain, nonatomic) IBOutlet UIButton     *zoomTypeButton;
@property (retain, nonatomic) IBOutlet UIButton     *zoomInfoButton;
@property (retain, nonatomic) IBOutlet UITextField  *bitRateField;

//File Operations Buttons and Text Fields
@property (retain, nonatomic) IBOutlet UIButton *changeDirectoryButton;
@property (retain, nonatomic) IBOutlet UITextField *changeDirectory;
////@property (retain, nonatomic) IBOutlet UITextField *mediaInfoTextField;
@property (retain, nonatomic) IBOutlet UITextField *fileToDownloadField;
@property (retain, nonatomic) IBOutlet UITextField *fileDownLoadOffset;
@property (retain, nonatomic) IBOutlet UITextField *fileDownLoadSize;
////@property (retain, nonatomic) IBOutlet UITextField *fileToRemoveTextField;
@property (retain, nonatomic) IBOutlet UITextField *sdMediaName;
@property (retain, nonatomic) IBOutlet UIButton *roMediaAttributeButton;
@property (retain, nonatomic) IBOutlet UIButton *rwMediaAttributeButton;
@property (retain, nonatomic) IBOutlet UITableView *fileListTableView;
@property (nonatomic, retain) NSMutableArray  *fList; // List of files
@property (nonatomic, retain) NSString *selectedFile;
@property (retain, nonatomic) IBOutlet UIButton *mediaInfoButton;
@property (retain, nonatomic) IBOutlet UIButton *deleteFileButton;
@property (weak, nonatomic) IBOutlet UITableView *upLoadFileView;
@property (nonatomic, retain) NSArray  *fileListing; // List of files
@property (retain, nonatomic) IBOutlet UITextField *fileToUploadTextField;
@property (retain, nonatomic) IBOutlet UIButton *md5SumButton;
@property (retain, nonatomic) IBOutlet UIButton *fileUploadButton;
@property (retain, nonatomic) IBOutlet UITextField *uploadFileOffsetTextField;
@property (retain, nonatomic) IBOutlet UITextField *uploadFileSizeTextField;
@property (retain, nonatomic) IBOutlet UIButton *selectUploadFileButton;

- (void) listLocalFiles;
- (IBAction)deleteLocalFiles:(id)sender;

- (IBAction)listAppFiles:(id)sender;
- (IBAction)computeMd5Sum:(id)sender;
- (IBAction)uploadLocalFile:(id)sender;



//Log File Display


//Camera Settings Page
//Get Current Parameter value
@property (assign, nonatomic) IBOutlet UIButton *cameraParaName;
- (IBAction)cameraParamUp:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton  *getCameraParameterValueButton;
- (IBAction)getCameraParameterValue:(id)sender;


//Set Camera Paramter Name with Option value
@property (retain, nonatomic) IBOutlet UIButton *setCameraParamName;
- (IBAction)setCameraParamUp:(id)sender;
- (IBAction)updateParamOptionButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *updateParamOption;

@property (retain, nonatomic) IBOutlet UIButton *cameraParameterOptionValue;
- (IBAction)setOptionUp:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *setOptionUpButton;

@property (retain, nonatomic) IBOutlet UIButton *setCameraParameterValue;
- (IBAction)setCameraParameter:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *dateTextField;


//---------------------

//session Start Stop Commands
- (IBAction)connectToCamera:(id)sender;     //
- (IBAction)disconnectToCamera:(id)sender;  //
- (IBAction)customJSONCmd:(id)sender;

// Camera Commands
- (IBAction)getDeviceInfo:(id)sender;

- (IBAction)takePhoto:(id)sender;       //
- (IBAction)startRecording:(id)sender;  //
- (IBAction)stopRecording:(id)sender;   //
- (IBAction)recordingTime:(id)sender;   //
- (IBAction)splitRecording:(id)sender;  //
- (IBAction)stopViewFinder:(id)sender;
- (IBAction)resetViewFinder:(id)sender;
- (IBAction)cameraAppStatus:(id)sender;
- (IBAction)currentSettings:(id)sender;
- (IBAction)viewRTSPStream:(id)sender;
- (IBAction)zoomInfo:(id)sender;
- (IBAction)toggleZoomLable:(id)sender;
- (IBAction)setBitrate:(id)sender;
- (IBAction)getBatteryLevel:(id)sender;

// File Operations
- (IBAction)totalStorageSpace:(id)sender;
- (IBAction)totalFreeSpace:(id)sender;
- (IBAction)presentWorkingDir:(id)sender;
- (IBAction)allFilesList:(id)sender;

- (IBAction)changeDirectoryFromTableView:(id)sender;
- (IBAction)changeFolder:(id)sender;// :(NSString *)textInput;
- (IBAction)getMediaInfo:(id)sender;// :(NSString *)textInput;
- (IBAction)fileDownload:(id)sender;// :(NSString *)textInput;
- (IBAction)stopFileDownload:(id)sender;// :(NSString *)textInput;
- (IBAction)deleteFile:(id)sender;
- (IBAction)numberOfFiles:(id)sender;
- (IBAction)numberOfPhotoFiles:(id)sender;
- (IBAction)numberOfVideoFiles:(id)sender;
- (IBAction)formatSDCardMedia:(id)sender;
- (NSString *) md5HashOfPath:(NSString *)path;
- (IBAction)setPlayBackFileName:(id)sender;


//Part2
- (IBAction)setMediaReadOnly:(id)sender;
- (IBAction)setMediaReadWrite:(id)sender;
- (IBAction)loadFileList:(id)sender;
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
- (IBAction)viewLocalImage:(id)sender;
- (IBAction)viewLocalVideo:(id)sender;
@property (nonatomic, strong) IBOutlet MPMoviePlayerController *moviePlayer;



// Camera Settings

//Debug : Display the last command Response from Camera
- (IBAction)showDebug:(id)sender;


- (IBAction)textFieldReturn : (id)sender;



//wifi Settings
@property (strong, nonatomic) IBOutlet UITableView *wifiListTableView;

@property (nonatomic, retain) NSMutableArray  *wifiItemList; // List of all Wifi Parameters
@property (nonatomic, retain) NSString *selectedWifiParameter;
@property (retain, nonatomic) IBOutlet UITextField *selectedWifiParameterToEdit;

- (IBAction)getWifiSettings:(id)sender;
- (IBAction)setWifiSettings:(id)sender;
- (IBAction)getWifiStatus:(id)sender;
- (IBAction)stopWifi:(id)sender;
- (IBAction)startWifi:(id)sender;
- (IBAction)restartWifi:(id)sender;
- (IBAction)editTableRowValue:(id)sender;

@property (retain, nonatomic) IBOutlet UISwitch *driftQuerySessionHolderSwitch;

@end
