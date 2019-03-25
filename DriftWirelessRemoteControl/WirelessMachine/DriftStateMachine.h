//
//  DriftStateMachine.h
//  DriftRemoteCam
//
//  Created by Channing.rong
//  Copyright (c) 2019 Drift Innovication ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "FileDownload.h"
#import "FileUpload.h"
#import "Constants.h"

@interface DriftStateMachine : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate, NSStreamDelegate>
{
    NSInputStream  *inputStream;
    NSOutputStream *outputStream;
    NSMutableArray *messages;
}

//Common-----------------------------
+ (DriftStateMachine *) getInstance;

@property (nonatomic, strong) NSNumber *sessionToken;

@property (nonatomic, strong) NSMutableString *lastCommand;
@property (nonatomic, strong) NSMutableString *currentCommand;
@property (nonatomic) NSMutableString *typeObject;
@property (nonatomic) NSMutableString *paramObject;
@property (nonatomic) NSInteger offsetObject;
@property (nonatomic) NSInteger  sizeToDlObject;
@property (nonatomic) NSString  *md5SumObject;
@property (nonatomic) NSInteger  fileAttributeValue;
@property (nonatomic) NSInteger commandReturnValue;

@property (nonatomic, strong) NSMutableArray *parameterNameList;
@property (nonatomic) NSInteger  currentParamIndex;
@property (nonatomic, strong) NSString *buttonTitleName;
@property (nonatomic, strong) NSMutableArray *optionParameterNameList;
@property (nonatomic) NSInteger optionCurrentParamIndex;
@property (nonatomic, strong) NSString *optionButtonTitleName;
@property (nonatomic) NSString *permissionFlag;

@property (nonatomic) NSInteger networkModeBle; // 0=BLE disabled 1=Selected BLE as network link
@property (nonatomic) NSInteger networkModeWifi; // 0=wifi Disabled 1=selected Wifi as network Link
@property (nonatomic) NSInteger wifiBleComboMode; // 0=disabled 1=wifi+bleMode

@property (nonatomic, copy) NSString *customCommandString;
@property (nonatomic, copy) NSString *playbackFile;
@property (nonatomic, copy) NSString *presentWorkingDirPath;


@property (nonatomic) NSInteger notificationCount;
- (unsigned int) connectToCamera;
- (unsigned int) disconnectToCamera;

- (void) sendCustomJSONCommand: (NSString *)customJSONText;
- (void) getDeviceInformation;
- (void) takePhoto;
- (void) cameraRecordStart;
- (void) cameraRecordStop;
- (void) cameraRecordingTime;
- (void) cameraSplitRecording;
- (void) cameraStopViewFinder;
- (void) cameraResetViewFinder;
- (void) cameraAppStatus;
- (void) getCurrentSettings;
- (void) stopContPhotoSession;
- (void) getZoomInfo: (NSString *)zoomType;
- (void) setStreamBitrate:(NSString *)bitRate;
- (void) getBatteryLevelInfo;

//File Operation Commands
- (void) cameraStorageSpace;
- (void) cameraFreeSpace;
- (void) presentWorkingDir;
- (void) listAllFiles;
- (void) cameraChangeToFolder: (NSString *)inputTextVal;
- (void) mediaInfo: (NSString *)inputTextVal;
- (void) cameraFileDownload: (NSString *)inputTextVal :(NSString *)offsetInput :(NSString *)sizeToDownload;
- (void) cameraStopFileDownload: (NSString * )inputTextVal;
- (void) fileToRemove: (NSString *)inputTextval;
- (void) numberOfFilesInFolder: (NSString *)fileType;
- (void) formatSDmedia: (NSString *) drive;
- (void) setFileAsRO: (NSString *)fileName;
- (void) setFileAsRW: (NSString *)fileName;
- (void) uploadFileToCamera:(NSString *)fileName :(NSString *)fileSize :(NSString *)md5sum :(NSString *)offset;

//- (void) getFile: (NSString *)fileName :(NSString *)offset :(NSString *)fileDownloadSize;

- (void) showCameraDebugCmd;
//Get Settings
- (NSString *) newTitle;
- (void) getSettingValue: (NSString *)inputTextVal;
//Set Settings
- (NSString *) newOptionTitle;
- (void) getOptionsForValue: (NSString *)inputTextVal;
- (void) setCameraParameterValue: (NSString *)parName  :(NSString *)optValue;
//BLE-----------------------------
@property (nonatomic) BOOL cameraBleMode; // YES = connected NO= disconnected
@property (nonatomic) BOOL bleMode; // 0 = CentralManager unInit  1=CM init
@property (nonatomic) BOOL bleScanFlag; // NO=disable scanning YES=EnableScanning
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral     *activePeripheral;
@property (nonatomic, strong) CBCharacteristic *sendCharacteristics, *readCharacteristics;

@property (nonatomic, strong) NSMutableArray *peripheralNameList;
@property (nonatomic, strong) NSMutableArray *peripheralList;


- (void) cleanup:(CBPeripheral *)activePeripheral;
- (void) notifyViewController;
- (void) notifyServiceCharacteristicViewController;
- (void) initBleManager;
- (void) startBleScan;
- (void) stopBleScan;
- (void) rescanBle;
- (void) connectToBlePeripheral: (CBPeripheral *)selectedP;
- (void) disconnectBlePeripheral;
- (NSData *) dataWithHexString:(NSString *)myString;
- (NSString *) hexStringWithData:(NSData *)data;
- (void) sendJSONCommand: (NSString *) jsonCmd;
- (void) readValue;
//TODO
//- (void) startSessionBle;
//- (void) stopSessionBle;

//Wifi-----------------------------
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, strong) NSMutableString *wifiIPParameters;
@property (nonatomic, strong) NSMutableString *notifyMsg;
@property (nonatomic, strong) NSMutableArray  *notifyFileList;
@property (atomic, strong) NSNumber *connected;

- (void) initNetworkCommunication: (NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo;

//API4.x
- (void) setClientInfo : (NSString *)clientIPAddr :(NSString *)clientTransportType;
- (void) responseTimer;
- (void) resetLogFile:(NSString *)  fileToReset;

//Wifi Settings
- (void) getWifiSettings;
- (void) setWifiSettings: (NSString *)wifiSettingsString;
- (void) getWifiStatus;
- (void) stopWifi;
- (void) startWifi;
- (void) reStartWifi;
//Session Holder
- (void) keepSessionActive;
@property (nonatomic) BOOL enableSessionHolder;

- (NSString *)customString;
@end
