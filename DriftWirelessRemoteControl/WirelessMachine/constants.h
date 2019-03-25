//
//  constants.h
//  AmbaRemoteCam
//
//  Created by Channing.rong
//  Copyright (c) 2019 Drift Innovication ltd. All rights reserved.


#ifndef DriftRemoteCam_Constants_h
#define DriftRemoteCam_Constants_h


#define Drift_RAPTOR1_SERVICE_UUID             @"00000000-616D-6261-5F69-645F62617365"
#define Drift_JSON_SEND_CHARCTERISTIC          @"11111111-616d-6261-5f69-645f62617365"
#define Drift_JSON_RECV_CHARCTERISTIC          @"33333333-616d-6261-5f69-645f62617365"

#define DriftServerAddr  @"192.168.42.1"
#define jsonPort        7878

#define changeInConnectionStatusNotification  @"changeInConnectionStatusNotification"
#define cameraSeveredConnectionNotification   @"cameraSeveredConnectionNotification"
#define cameraSeveredNotification             @"cameraSeveredNotification"
#define jsonDebugNotification                 @"jsonDebugNotification"
#define updateCommandReturnStatusNotification @"updateCommandReturnStatusNotification"
#define unableToFindRTSPStreamNotification    @"unableToFindRTSPStreamNotification"
#define noConnectionStatusNotification        @"noConnectionStatusNotification"
#define connectionStatusNotification          @"connectionStatusNotification"

#define startSessionRefusalNotification       @"startSessionRefusalNotification"
#define shutterStatusNotification             @"shutterStatusNotification"
#define foundNewPeripheralNotification        @"foundNewPeripheralNotification"
#define foundUUIDNotification                 @"foundUUIDNotification"
#define progressBarNotification               @"progressBarNotification"

#define updateFileListReturnStatusNotification @"updateFileListReturnStatusNotification"
#define updateWifiListNotification             @"updateWifiListNotification"
#define recordStartStatusNotification         @"recordStartStatusNotification"
#define recordStopStatusNotification          @"recordStopStatusNotification"
#define connValueInfoKey                      @"statusKey"
#define prevCmdInfoKey                        @"prevCmd"
#define currentCmdInfoKey                     @"currentCmd"
#define returnValueInfoKey                    @"returnValue"

#define initialMode                        @"initialMode"
#define viewFinderMode                     @"viewFinderMode"
#define recordingMode                      @"recordingMode"
#define displayTakenPictureMode            @"displayTakenPictureMode"
#define sdBrowsingMode                     @"sdBrowsingMode"

#define waitingForReply                    @"waitingForReply"
#define readyToSendCommand                 @"readyToSendCommand"
#define querySessionHolderNotification     @"querySessionHolderNotification"

/*
NSString  *tokenKey     = @"token";
NSString  *msgIdKey     = @"msg_id";
NSString  *typeKey      = @"type";
//NSString  *paramKey     = @"param";
NSString  *offsetKey    = @"offset";
NSString  *featchSizeKey = @"fetch_size";
NSString *optionsKey    = @"options";

//Return keys
NSString *rvalKey = @"rval";
NSString *permissionKey = @"permission";

//BiDirectional Key
NSString *paramKey = @"param";

//NSString *paramSizeKey = @"param_size";

//CommandStrings

NSString *startSessionCmd   = @"StartSession";
NSString *stopSessionCmd    = @"StopSession";
NSString *recordStartCmd    = @"RecStart";
NSString *recordStopCmd     = @"RecStop";
NSString *shutterCmd        = @"Shutter";
NSString *recordingTimeCmd  = @"RecordingTime";
NSString *splitRecordingCmd = @"RecordingSplit";
//NSString *getConfigCmd      = @"GenerateConfig";
NSString *stopVFCmd         = @"StopVF";
NSString *resetVFCmd        = @"ResetVF";
NSString *startEncoderCmd   = @"StartEncoder";
NSString *changeSettingCmd  = @"ChangeSetting";
NSString *appStatusCmd      = @"uItronStat";
NSString *storageSpaceCmd   = @"storageSpace";
NSString *presentWorkingDirCmd = @"pwd";
NSString *listAllFilesCmd   = @"listAllFiles";
NSString *changeToFolderCmd = @"changeFolder";
NSString *mediaInfoCmd      = @"mediaInfo";
NSString *getFileCmd        = @"getFile";
NSString *stopGetFileCmd    = @"stopGetFile";
NSString *removeFileCmd     = @"removeFile";
NSString *allSettingsCmd    = @"allSettings";
NSString *getSettingValueCmd = @"getSettingValue";
NSString *getOptionsForValueCmd = @"getOptionsForValue";
NSString *setCameraParameterCmd = @"setCameraParamValue";
NSString *DriftLOGFILE    = @"DriftRemoteCam.txt";



//command code thats msg_id number as per Drift document
const unsigned int appStatusMsgId       = 1;
const unsigned int getSettingValueMsgId = 1;
const unsigned int setCameraParameterMsgId = 2;
const unsigned int allSettingsMsgId     = 3;
const unsigned int storageSpaceMsgId    = 5;
const unsigned int notificationMsgId    = 7;
const unsigned int getOptionsForValueMsgId = 9;


const unsigned int startSessionMsgId    = 257;
const unsigned int stopSessionMsgId     = 258;
const unsigned int resetVFMsgId         = 259;
const unsigned int stopVFMsgId          = 260;


const unsigned int recordStartMsgId     = 513;
const unsigned int recordStopMsgId      = 514;
const unsigned int recordingTimeMsgId   = 515;
const unsigned int splitRecordingMsgId  = 516;
const unsigned int shutterMsgId         = 769;
const unsigned int mediaInfoMsgId       = 1026;

const unsigned int removeFileMsgId      = 1281;
const unsigned int listAllFilesMsgId    = 1282;
const unsigned int changeToFolderMsgId  = 1283;
const unsigned int presentWorkingDirMsgId = 1284;
const unsigned int getFileMsgId         = 1285;
const unsigned int stopGetFileMsgId     = 1287;
 */
#endif
