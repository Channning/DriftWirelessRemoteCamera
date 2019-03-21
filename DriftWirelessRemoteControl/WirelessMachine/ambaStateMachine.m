//
//  ambaStateMachine.m
//  AmbaRemoteCam
//
//  Created by (Ram Kumar) Ambarella
//  Copyright (c) 2014 Ambarella. All rights reserved.
//

#import "ambaStateMachine.h"
#import "DriftCameraCommandsViewController.h"

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
NSString *pwdKey = @"pwd";

//BiDirectional Key
NSString *paramKey = @"param";

//NSString *paramSizeKey = @"param_size";

//CommandStrings

NSString *startSessionCmd   = @"StartSession";
NSString *stopSessionCmd    = @"StopSession";
NSString *recordStartCmd    = @"RecStart";
NSString *recordStopCmd     = @"RecStop";
NSString *shutterCmd        = @"Shutter";
NSString *deviceInfoCmd     = @"deviceInfoCmd";
NSString *batteryLevelCmd   = @"batteryLevelCmd";
NSString *stopContPhotoSessionCmd = @"stopContPhotoSessionCmd";
NSString *recordingTimeCmd  = @"RecordingTime";
NSString *splitRecordingCmd = @"RecordingSplit";
//NSString *getConfigCmd      = @"GenerateConfig";
NSString *stopVFCmd         = @"StopVF";
NSString *resetVFCmd        = @"ResetVF";
NSString *zoomInfoCmd       = @"zoomInfo";
NSString *setBitRateCmd     = @"BitRate";
NSString *startEncoderCmd   = @"StartEncoder";
NSString *changeSettingCmd  = @"ChangeSetting";
NSString *appStatusCmd      = @"uItronStat";
NSString *storageSpaceCmd   = @"storageSpace";
NSString *presentWorkingDirCmd = @"pwd";
NSString *listAllFilesCmd   = @"listAllFiles";
NSString *numberOfFilesInFolderCmd = @"numberOfFilesInFolderCmd";
NSString *changeToFolderCmd = @"changeFolder";
NSString *mediaInfoCmd      = @"mediaInfo";
NSString *getFileCmd        = @"getFile";
NSString *putFileCmd        = @"putFile";
NSString *stopGetFileCmd    = @"stopGetFile";
NSString *removeFileCmd     = @"removeFile";
NSString *fileAttributeCmd  = @"fileAttributeCmd";
NSString *formatSDMediaCmd  = @"formatSDMediaCmd";
NSString *allSettingsCmd    = @"allSettings";
NSString *getSettingValueCmd = @"getSettingValue";
NSString *getOptionsForValueCmd = @"getOptionsForValue";
NSString *setCameraParameterCmd = @"setCameraParamValue";
NSString *sendCustomJSONCmd = @"sendCustomJSONCmd";
NSString *setClientInfoCmd  = @"setClientInfoCmd";
NSString *getWifiSettingsCmd = @"getWifiSettingsCmd";
NSString *setWifiSettingsCmd = @"setWifiSettingsCmd";
NSString *getWifiStatusCmd   = @"getWifiStatusCmd";
NSString *stopWifiCmd        = @"stopWifiCmd";
NSString *startWifiCmd       = @"startWifiCmd";
NSString *reStartWifiCmd     = @"reStartWifiCmd";
NSString *querySessionCmd    = @"querySessionCmd";
NSString *AMBALOGFILE    = @"AmbaRemoteCam.txt";



//command code thats msg_id number as per amba document
const unsigned int appStatusMsgId       = 1;
const unsigned int getSettingValueMsgId = 1;
const unsigned int setCameraParameterMsgId = 2;
const unsigned int allSettingsMsgId     = 3;
const unsigned int formatSDMediaMsgId   = 4;
const unsigned int storageSpaceMsgId    = 5;
const unsigned int numberOfFilesInFolderId = 6;
const unsigned int notificationMsgId    = 7;
const unsigned int getOptionsForValueMsgId = 9;
const unsigned int deviceInfoMsgId      = 11;
const unsigned int batteryLevelMsgId    = 13;
const unsigned int zoomInfoMsgId        = 15;
const unsigned int setBitRateMsgId      = 16;


const unsigned int startSessionMsgId    = 257;
const unsigned int stopSessionMsgId     = 258;
const unsigned int resetVFMsgId         = 259;
const unsigned int stopVFMsgId          = 260;
const unsigned int setClientInfoMsgId   = 261;


const unsigned int recordStartMsgId     = 513;
const unsigned int recordStopMsgId      = 514;
const unsigned int recordingTimeMsgId   = 515;
const unsigned int splitRecordingMsgId  = 516;

const unsigned int shutterMsgId         = 769;
const unsigned int stopContPhotoSessionMsgId = 770;
const unsigned int mediaInfoMsgId       = 1026;
const unsigned int fileAttributeMsgId   = 1027;

const unsigned int removeFileMsgId      = 1281;
const unsigned int listAllFilesMsgId    = 1282;
const unsigned int changeToFolderMsgId  = 1283;
const unsigned int presentWorkingDirMsgId = 1284;
const unsigned int getFileMsgId         = 1285;
const unsigned int putFileMsgId         = 1286;
const unsigned int stopGetFileMsgId     = 1287;

const unsigned int reStartWifiMsgId     = 1537;
const unsigned int setWifiSettingsMsgId = 1538;
const unsigned int getWifiSettingsMsgId = 1539;
const unsigned int stopWifiMsgId        = 1540;
const unsigned int startWifiMsgId       = 1541;
const unsigned int getWifiStatusMsgId   = 1542;
const unsigned int querySessionHolderMsgId = 1793;

const unsigned int sendCustomJSONMsgID = 99999999; //Select some random number for custom cmd.
////
unsigned int STATUS_FLAG;
unsigned int recvResponse;
NSTimer   *jsonTimer;
NSMutableString *tmpString;
@implementation ambaStateMachine

@synthesize sessionToken, lastCommand, currentCommand, typeObject, paramObject, parameterNameList, currentParamIndex;
@synthesize offsetObject, sizeToDlObject,fileAttributeValue,md5SumObject;
@synthesize buttonTitleName, optionParameterNameList, optionCurrentParamIndex, optionButtonTitleName, permissionFlag;

@synthesize cameraBleMode,  bleMode, bleScanFlag;
@synthesize manager, activePeripheral, sendCharacteristics,readCharacteristics, peripheralNameList, peripheralList;

@synthesize wifiIPParameters, wifiTCPConnectionStatus,connected;
@synthesize inputStream, outputStream, messages, notifyMsg, notifyFileList;
@synthesize networkModeBle, networkModeWifi, wifiBleComboMode;
@synthesize commandReturnValue;

@synthesize notificationCount, customCommandString,playbackFile,presentWorkingDirPath;
@synthesize enableSessionHolder;

static ambaStateMachine *instance = nil;


- (id) init
{
    self = [super init];
    if (self) {
        NSLog(@"Ambarella BLE Backend Init");
    }
    sessionToken = nil;
    bleScanFlag = NO;
    self.networkModeWifi = 0;
    self.networkModeBle = 0;
    self.wifiBleComboMode = 0;
    [self createAmbaRemoteCamLogDir];
    tmpString = [[NSMutableString alloc] init];
    self.wifiIPParameters = [[NSMutableString alloc] init];
    self.notificationCount = 0;
    recvResponse = 1;
    self.enableSessionHolder = YES;
    return  self;
}

- (void) createAmbaRemoteCamLogDir
{
    //First Create Documentation Directory if it doesnt exit
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES)[0];
    
    NSString *dirName = [docDir stringByAppendingPathComponent:@"/"];
    
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dirName isDirectory:&isDir])
    {
        if([fm createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:nil error:nil])
            NSLog(@"Directory Created");
        else
            NSLog(@"Directory Creation Failed");
    }
    else
        NSLog(@"Directory Already Exist");
    NSLog( @" LOG Directory Path: %@",dirName);
    NSDate *myDate = [[NSDate alloc] init];
    NSLog(@"Current Date: %@",myDate);
    
}

- (void) ambaLogString: (NSString *)content toFile:(NSString *)logFileName
{
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:logFileName];
    //NSLog(@"Writing to File ======>: %@",filePath);
    NSFileManager   *fsManager = [NSFileManager defaultManager];
    if ( [fsManager fileExistsAtPath:filePath]) {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[@"\n\n" dataUsingEncoding:NSUTF8StringEncoding]]; //Add a New Line before we append data
        [myHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
    } else {
        if ( [fsManager createFileAtPath:filePath  contents:nil attributes:nil] ) {
            NSLog(@"creating Missing Log File: %@", filePath);
            //Now Write contents to file
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            
        } else {
            NSLog(@"Failed to Create Log File");
        }
    }
}

- (void) resetLogFile:(NSString *)  fileToReset
{
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    NSString    *filePath = [documentsDirectory stringByAppendingPathComponent:fileToReset];
    
    NSFileManager   *fsManager = [NSFileManager defaultManager];
    if ( [fsManager removeItemAtPath:filePath error:nil] ) {
        NSLog(@"LogFile: deleated!!!");
        //Create an new Log file
        [fsManager createFileAtPath:filePath contents:nil attributes:nil];
    } else {
        NSLog(@"Failed to delete/reset the log file!!!!");
    }
    /*
    if ( [fsManager fileExistsAtPath:filePath]) {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [myHandle writeData:[@"\n\n" dataUsingEncoding:NSUTF8StringEncoding]]; //Add a New Line before we append data
        [myHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
    } else {
        if ( [fsManager createFileAtPath:filePath  contents:nil attributes:nil] ) {
            NSLog(@"creating Missing Log File: %@", filePath);
            //Now Write contents to file
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
            
        } else {
            NSLog(@"Failed to Create Log File");
        }
    }*/
}



+ (ambaStateMachine *)getInstance
{
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[ambaStateMachine alloc] init];
        }
        return instance;
    }
    return  nil;
}
//===============================BLE Section Start==================================

//Bring Up CoreBluetooth
- (void) initBleManager
{
    self.manager  = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSLog(@"CBCentralManager: Init");
    // Calls centralManagerDidUpdateState :
}
- (void) startBleScan
{
    self.bleScanFlag = YES;
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    NSLog(@"Scanning...........");
}

- (void) stopBleScan
{
    self.bleScanFlag = NO;
    [self.manager stopScan];
    NSLog(@"BLE Scan: STOP");
}

- (void) rescanBle
{
    NSLog(@"Rescan for BLE Peripherals");
    [self.manager stopScan];
    [self.peripheralNameList removeAllObjects];
    [self.peripheralList removeAllObjects];
    [self notifyViewController];
    //[self.manager scanForPeripheralsWithServices:nil options:nil];
    [self.manager scanForPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:AMBA_RAPTOR1_SERVICE_UUID], nil] options:nil];
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Central Manager: PowerOn");
            //Now we are ready for scanning
            self.bleMode = YES;
            self.cameraBleMode = NO;
            self.bleScanFlag = YES;
            self.networkModeBle = 1;
            self.networkModeWifi = 0;
            lastCommand    = nil;
            currentCommand = nil;
            sessionToken = [NSNumber numberWithInteger:0];
            [self.manager scanForPeripheralsWithServices:nil options:nil];
            // calls didDiscoverPeripheral if peripheral is found
            break;
            
        default:
            NSLog(@"centralManager Change State: ");
            break;
    }
}
- (void) centralManager: (CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@" Discovered peripheral with Name:RSSI %@ : %@", peripheral.name, RSSI);
    NSLog(@" With UUID :  %@",peripheral.identifier.UUIDString);
    if ( [peripheral.name length]) {
        if (!(self.peripheralNameList) && !(self.peripheralList)) {
            
            self.peripheralNameList = [[NSMutableArray alloc] init];
            self.peripheralList = [[NSMutableArray alloc] init];
            
            
            [self.peripheralNameList addObject:peripheral.name];
            [self.peripheralList addObject:peripheral];
            
        } else {
            
            if ( ![self.peripheralNameList containsObject:peripheral.name]) {
                
                [self.peripheralNameList addObject:peripheral.name];
                [self.peripheralList addObject:peripheral];
                
            } else {
                
                //[self.peripheralNameList addObject:peripheral.name];
                //[self.peripheralList addObject:peripheral];
            }
        }
    }/* //Debug list all objects in peripheralList
      int i;
      for ( i = 0 ; i < [self.peripheralList count]; i++) {
      NSLog(@"List of peripherals:%d . %@",i,self.peripheralList[i]);
      } */
    //Send Notification to Update the UIViewController
    [self notifyViewController];
}

- (void) notifyViewController
{
    NSDictionary *notificationDict = [[NSDictionary alloc] init];
    NSNotification *notificationObject = [NSNotification
                                          notificationWithName:foundNewPeripheralNotification
                                          object:self
                                          userInfo:notificationDict];
    self.notificationCount = 1;
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
    
}
- (void) notifyServiceCharacteristicViewController
{
    NSDictionary *notificationDict = [[NSDictionary alloc] init];
    NSNotification *notificationObject = [NSNotification
                                          notificationWithName:foundUUIDNotification
                                          object:self
                                          userInfo:notificationDict];
    self.notificationCount = 1;
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}
- (void) notifyProgressBarView
{
    NSDictionary *notificationDict = [[NSDictionary alloc] init];
    NSNotification *notificationObject = [NSNotification
                                          notificationWithName:progressBarNotification
                                          object:self
                                          userInfo:notificationDict];
    self.notificationCount = 1;
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

- (void) connectToBlePeripheral: (CBPeripheral *)selectedP
{
    [self.manager connectPeripheral:selectedP  options:nil];
    //Calls didConnectPeripheral or didFailToConnectPeripheral
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.activePeripheral = peripheral;
    self.cameraBleMode = YES;
    [self.peripheralList removeAllObjects];
    [self.peripheralNameList removeAllObjects];
    
    [self.peripheralNameList addObject:self.activePeripheral.name];
    [self.peripheralList addObject:self.activePeripheral];
    
    //Notify tableview to display the connected Peripheral Name
    [self notifyViewController];
    
    NSLog(@"BLE Peripheral : %@ : Connected", self.activePeripheral.name);
    [self ambaLogString:@"BLE Connection With Camera Open" toFile:AMBALOGFILE];
    //Stop Scanning on Connect after we connected
    [self.manager stopScan];
    
    //set the peripheral delegate to self to ensure we receive the appropriate callbacks
    peripheral.delegate = self;
    
    //Notify ProgressBar
    [self notifyProgressBarView];
    //Discover all the Primary Services
    [peripheral discoverServices:nil]; //scan for all Services send option Nil or specify the UUID
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:AMBA_RAPTOR1_SERVICE_UUID]]];
}
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)blePeripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to peripheral: %@",blePeripheral.name);
    [self cleanup:(CBPeripheral *) blePeripheral];
    self.cameraBleMode = NO;
    self.bleScanFlag = YES;
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self cleanup:self.activePeripheral];
        return;
    }
    NSLog(@"Discovered Primary Services:");
    for (CBService *service in peripheral.services) {
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:AMBA_RAPTOR1_SERVICE_UUID]]) {
            NSLog(@"Amba Service: %@",service);
            // Found AMBA_SERVICE_UUID next discover Chars for AMBA_SERVICE_UUID
            [peripheral discoverCharacteristics:nil forService:service];
            //Notify the progressBar
            
            [self notifyProgressBarView];
        }
    }
}
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self cleanup:self.activePeripheral];
        return;
    }
    NSLog(@"Discover Characteristics for Service UUID: %@",AMBA_RAPTOR1_SERVICE_UUID);
    for (CBCharacteristic *chars in service.characteristics) {
        
        if ([chars.UUID isEqual:[CBUUID UUIDWithString: AMBA_JSON_SEND_CHARCTERISTIC]]) {
            [peripheral setNotifyValue:YES forCharacteristic:chars];
            //NSLog(@"Discovered Characteristics: %@",chars);
            NSLog(@"characteristic.UUID =====> %@", chars.UUID);
            //NSLog(@"characteristic.properties =====> %u", chars.properties);
            NSLog(@"characteristic.description =====> %@", chars.description);
            self.sendCharacteristics = chars;
            //Notify the progressBar
            [self notifyProgressBarView];
        }
        else if ([chars.UUID isEqual:[CBUUID UUIDWithString:AMBA_JSON_RECV_CHARCTERISTIC]]) {
            [peripheral setNotifyValue:YES forCharacteristic:chars];
            //NSLog(@"Discovered Characteristics: %@",chars);
            NSLog(@"characteristic.UUID =====> %@", chars.UUID);
            //NSLog(@"characteristic.properties =====> %u", chars.properties);
            NSLog(@"characteristic.value ====> %@", chars.value);
            NSLog(@"characteristic.description =====> %@", chars.description);
            self.readCharacteristics = chars;
            //Send Notification to serviceCharacteristicsViewController to display the UUIDs
            //Notify the progressBar
            [self notifyProgressBarView];
            [self notifyServiceCharacteristicViewController];
            self.connected = [NSNumber numberWithBool:TRUE];
        }
        else
        {
            NSLog(@"characteristic.UUID =====> %@ <====", chars.UUID);
        }
    }
}

- (void) disconnectBlePeripheral
{
    if (self.cameraBleMode) {
        if (self.activePeripheral != nil) {
            NSLog(@"CleanUp before Disconnect");
            [self cleanup:self.activePeripheral];
            [self.manager cancelPeripheralConnection:self.activePeripheral];
        } else {
            [self.manager cancelPeripheralConnection:self.activePeripheral];
        }
    }
}
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected with device: %@",self.activePeripheral.name);
    self.activePeripheral = nil;
    //start Scanning again
    [self.peripheralNameList removeAllObjects];
    [self.peripheralList removeAllObjects];
    [self notifyViewController];
    self.cameraBleMode = NO;
    //rescan for peripherals again
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    
}
- (void) cleanup : (CBPeripheral *) blePeripheral
{
    // Do not do any thing is we are not connected
    // if (!blePeripheral.isConnected) { //removed in iOS7 onwards
    if (blePeripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    //see if we are subscribed to a characteristic on the peripheral
    if(blePeripheral.services != nil)
    {
        for (CBService *service in blePeripheral.services) {
            if (service.characteristics != nil) {
                for ( CBCharacteristic *characteristic in service.characteristics) {
                    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:AMBA_JSON_SEND_CHARCTERISTIC]]) {
                        if ( characteristic.isNotifying ) {
                            [blePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            //return;
                        }
                    }
                }
            }
        }
    }
    NSLog(@"-=-=-=-=-=-=Sending BLE Disconnect=-=-=-=-=-=-=-=");
    [self.manager cancelPeripheralConnection:blePeripheral];
    //start Scanning and Notify ViewController
    self.activePeripheral = nil;
    self.cameraBleMode = NO;
    [self.peripheralNameList removeAllObjects];
    [self.peripheralList removeAllObjects];
    
    //[self startBleScan];
}
//------------ BLE Read / Write --------------------
//Data With HexString
- (NSData *) dataWithHexString:(NSString *)myString
{
    NSString *string = myString;
    if ( [myString hasPrefix:@"0x"]) {
        string = [myString substringFromIndex:2];
    }
    if ( [string length]%2 ) return nil;
    
    NSMutableData *result = [NSMutableData data];
    NSRange snipRange = NSMakeRange(0,2);
    while (snipRange.location < [string length]) {
        NSString *subString = [string substringWithRange:snipRange];
        unsigned int tempInt = 0;
        NSScanner *scanner = [[NSScanner alloc] initWithString:subString];
        
        if (![scanner scanHexInt:&tempInt]) {
            return  nil;
        }
        char tempChar = (char)tempInt;
        [result appendBytes:&tempChar length:1];
        snipRange.location += 2;
    }
    return result;
}


- (NSString *) hexStringWithData:(NSData *)data
{
    //Return hex string of NSData. empty string if data is empty
    const unsigned char *dataBuffer = (const unsigned char *) [data bytes];
    if (!dataBuffer) {
        return [NSString string];
    }
    
    int dataLength  = [data length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength ; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02x",(unsigned int)dataBuffer[i]]];
    }
    return [NSString stringWithString:hexString];
}

// Fragment JSON command to size of 20 bytes long, convert the fragment to  hex string
// and send to camera write Characteristic
- (void) sendJSONCommand : (NSString *) jsonCmd
{
    
    NSString *jsonCommand = jsonCmd;
    NSLog(@"JSON Command: %@", jsonCommand);
    //NSString *startSession = @"{\"msg_id\" : 257, \"token\":0}";  //{'msg_id' : 257, 'token':0}
    
    for ( int i = 0 ; i < [jsonCommand length] ; i=i+10) {
        if (  ([jsonCommand length] -i) > 10) { //([hexStr length] - i) > 20) {
            NSString *tmpString = [jsonCommand substringWithRange:NSMakeRange(i,10)];
            NSString *hexString = [NSString stringWithFormat:@"%@",[NSData dataWithBytes:[tmpString cStringUsingEncoding:NSUTF8StringEncoding]
                                                                                  length:strlen([tmpString cStringUsingEncoding:NSUTF8StringEncoding])]];
            for(NSString * toRemove in [NSArray arrayWithObjects:@"<",@">",@" ", nil])
                hexString = [hexString stringByReplacingOccurrencesOfString:toRemove withString:@""];
            
            
            [self.activePeripheral writeValue: [self dataWithHexString:hexString]  //[NSData datawithHexString:tmpString]
                            forCharacteristic:self.sendCharacteristics
                                         type:CBCharacteristicWriteWithResponse];
        } else {
            NSString *tmpString = [jsonCommand substringWithRange:NSMakeRange(i,([jsonCommand length] - i))];
            NSString *hexString = [NSString stringWithFormat:@"%@",[NSData dataWithBytes:[tmpString cStringUsingEncoding:NSUTF8StringEncoding]
                                                                                  length:strlen([tmpString cStringUsingEncoding:NSUTF8StringEncoding])]];
            for(NSString * toRemove in [NSArray arrayWithObjects:@"<",@">",@" ", nil])
                hexString = [hexString stringByReplacingOccurrencesOfString:toRemove withString:@""];
            
            
            [self.activePeripheral writeValue: [self dataWithHexString:hexString]  //[NSData datawithHexString:tmpString]
                            forCharacteristic:self.sendCharacteristics
                                         type:CBCharacteristicWriteWithResponse];
        }
    }
    
}

//Recv on writing [peripheral writeValue: forCharacteristic: type] will update "didUpdateValueForCharacteristic"
//Make sure to set the setNotificationValue: YES when we scan for the characteristics

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString *stringResponse;
    if (!error) {
        stringResponse = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"::Remote Camera Return::%@",stringResponse);
    }
    //
    ////[self messageReceived:stringResponse];
    //Json Parsing : If the data sent from Peripheral is large then noticed the characteristic.value
    // returns in multiple calls ( we double check we got all the data before we call messageReceived )
    //------handle Packet Framented return from camera
    //TODO: Implement timeout if the string does'nt make it to App
    NSData *data = [stringResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    //Store the value in a global and append data string in next call check before we call messageReceived
    if (!jsonResponse) {
        [tmpString appendString:stringResponse];
        
        //NSLog(@":::::::-> %@",tmpString);
        NSLog(@"Appending pkt Fragmented Data-> %@",tmpString);

        
        data = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
        jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:nil];
        if (jsonResponse){
            [self messageReceived:tmpString];
            //reset the tmpString to nothing
            tmpString = [NSMutableString stringWithFormat:@""];
        }
    } else {
        [self messageReceived:stringResponse];
    } /*
    if ([[jsonResponse objectForKey:@"rval"] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]] &&
        [[jsonResponse objectForKey:@"msg_id"] isEqualToNumber:[NSNumber numberWithUnsignedInteger:257]]){
        //NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        //tmpArray =
        sessionToken = [jsonResponse objectForKey:@"param"];
        NSLog(@"Session TokenID %@", sessionToken);
    }
    if ([[jsonResponse objectForKey:@"rval"] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]] &&
        [[jsonResponse objectForKey:@"msg_id"] isEqualToNumber:[NSNumber numberWithUnsignedInteger:258]]){
        //reset TokenID
        sessionToken = nil;
    }*/
    
}
//Recv
- (void) readValue
{
    [self.activePeripheral readValueForCharacteristic:self.readCharacteristics];
}
//===============================WiFI Part========================================

- (void) initNetworkCommunication:(NSString *) ipAddress tcpPort:(NSInteger)tcpPortNo
{
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge  NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.wifiTCPConnectionStatus = 0;
    [inputStream open];
    [outputStream open];
    
    lastCommand    = nil;
    currentCommand = nil;
    sessionToken = [NSNumber numberWithInteger:0];
    NSLog(@"To Connect Camera %@ : %lu", ipAddress, (long)tcpPortNo);
    //[self.wifiIPParameters appendString:ipAddress];
    self.wifiIPParameters = [NSMutableString stringWithFormat:@"%@",ipAddress];
    self.networkModeWifi = 1;
    self.networkModeBle = 0;
}
-(void) responseTimer {
    if (recvResponse) {
        NSLog(@"Command Response Complete.");
        if (jsonTimer)
            [jsonTimer invalidate];
    } else {
        NSLog(@"30 Sec time out: Fail to recv command response from camera!!!!!");
        //if received incomplete JSON String then discard it and pop and notification to user
        tmpString = [NSMutableString stringWithFormat:@""];
        
        //Notify User
        notifyMsg = (NSMutableString *)@"!!!!TimeOut:30Sec: FAIL to recv Command from Camera !!!!";
        //notifyMsg = (NSMutableString *)message;
        NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          notifyMsg, typeKey, nil];
        //message, typeKey, nil];
        NSNotification *notificationObject = [NSNotification notificationWithName:cameraSeveredNotification
                                                                           object:self
                                                                         userInfo:notificationDict];
        self.notificationCount = 1;
        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        if (jsonTimer)
            [jsonTimer invalidate];
    }
    NSLog(@"---------------TimeOut Timer executed------------");
}

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
    /* Reference NSStreamEvent enum:
     
     typedef enum {
     NSStreamEventNone = 0,
     NSStreamEventOpenCompleted = 1 << 0,
     NSStreamEventHasBytesAvailable = 1 << 1,
     NSStreamEventHasSpaceAvailable = 1 << 2,
     NSStreamEventErrorOccurred = 1 << 3,
     NSStreamEventEndEncountered = 1 << 4
     };
     
     */
    //NSLog(@"stream event %lu", streamEvent);
    switch (streamEvent)
    {
        case NSStreamEventOpenCompleted:            
            NSLog(@"Connection with Camera: Open");
            self.wifiTCPConnectionStatus = 1;//connected
            [self ambaLogString:@"WiFi Connection With Camera Open" toFile:AMBALOGFILE];
            if (self.wifiTCPConnectionStatus == 1) {
                
                //send notification to wifiViewController for segue
                NSDictionary *notificationDict = [[NSDictionary alloc] init];
                NSNotification *notificationObject = [NSNotification  notificationWithName:connectionStatusNotification
                                                                                    object:self
                                                                                  userInfo: notificationDict ];
                [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
            }
            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream) {
                uint8_t buffer[1024];
                NSInteger len;
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *responseString = [[NSString alloc] initWithBytes:buffer
                                                                            length:len
                                                                          encoding:NSASCIIStringEncoding];
                        
                        //------handle Packet Framented return from camera
                        //TODO: Implement timeout if the string does'nt make it to App
                        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                     options:kNilOptions
                                                                                       error:nil];
                        //Store the value in a global and append data string in next call check before we call messageReceived
                        if (!jsonResponse) {
                            [tmpString appendString:responseString];
                            
                            NSLog(@"Appending pkt Fragmented Data-> %@",tmpString);
                            
                            
                            data = [tmpString dataUsingEncoding:NSUTF8StringEncoding];
                            jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:nil];
                            if (jsonResponse){
                                recvResponse = 1;
                                [self messageReceived:tmpString];
                                //reset the tmpString to nothing
                                tmpString = [NSMutableString stringWithFormat:@""];
                                if (jsonTimer)
                                    [jsonTimer invalidate];
                            }
                        } else {
                            recvResponse = 1;
                            if (jsonTimer)
                                [jsonTimer invalidate];
                            
                            [self messageReceived:responseString];
                        }
                        //------packet Fragmented return
                        //if (nil != responseString) {
                        //    NSLog(@"Server Resp: %@", responseString);
                        //    [self messageReceived:responseString];
                        //}
                    }
                }
            }
            break;
        case NSStreamEventErrorOccurred:
        {
            NSLog(@"Can not connect to host!");
            [self ambaLogString:@"Can not connect to host!" toFile:AMBALOGFILE];
            wifiTCPConnectionStatus = 0;
            NSDictionary *notificationDict = [[NSDictionary alloc] init];
            NSNotification *notificationObject = [NSNotification  notificationWithName:noConnectionStatusNotification
                                                                                object:self
                                                                              userInfo: notificationDict ];
            self.notificationCount = 1;
            [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
            //Invalidate the timer.
            if (jsonTimer)
                [jsonTimer invalidate];
            
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            NSLog(@"Error Writing to Network Stream!");
            [self ambaLogString:@"Error Writing to Network Stream!" toFile:AMBALOGFILE];
            wifiTCPConnectionStatus = 0;
            NSDictionary *notificationDict = [[NSDictionary alloc] init];
            NSNotification *notificationObject = [NSNotification  notificationWithName:noConnectionStatusNotification
                                                                                object:self
                                                                              userInfo: notificationDict ];
            self.notificationCount = 1;
            [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        }
            break;
            
        default:
            //NSLog(@"UnKnown Event:");
            break;
    }
    
}
// Common---------------------------------------------------------------------------
- (void) sendCustomCmdToCamera:(unsigned int)commandCode
{
    //NSError *writeError = nil;
    NSInteger bytesWritten = 0;
    if ( commandCode == 99999999)
    {
        if ( self.networkModeWifi == 1) {
            if (wifiTCPConnectionStatus == 0) {
                //Connection was lost and there is no reason to send command to server
                // Prevent stuck APP View
                NSLog(@"Connection was lost to write JSON on to CFStreamOut");
            } else {
                NSData *data = [[NSData alloc] initWithData: [self.customCommandString dataUsingEncoding:NSASCIIStringEncoding]];
                bytesWritten = [outputStream write:[data bytes] maxLength:[data length]];
                //[NSJSONSerialization writeJSONObject:commandDict toStream:outputStream
                 //                                           options:kNilOptions error:&writeError];
                if( bytesWritten <= 0) {
                    NSLog(@"Error Writing JSON to outStream");
                }
                NSLog(@"Command Sent %@", self.customCommandString);
                [self ambaLogString:@"JSON Command To Camera: " toFile:AMBALOGFILE];
                [self ambaLogString:self.customCommandString toFile:AMBALOGFILE];
                self.customCommandString = @"";
            }
        }
        if (self.networkModeBle == 1) {
            if (self.cameraBleMode == NO) {
                // ble connection lost: Skip sending command
                NSLog(@"Connection With BLE Peripheral was lost");
            } else {
                // Send Via BLE connection
                NSString *customDataString =  [NSString stringWithFormat:@"%@",self.customCommandString];
                NSDictionary *dic = @{
                                      @"router_ssid":@"LTETEST",
                                      @"router_password":@"foream.web",
                                      @"stream_resolution":@"1080P",
                                      @"stream_bitrate":@3500000,
                                      @"rtmp_url":@"rtmp://115.231.182.113:1935/livestream/r8j4pabc",
                                      tokenKey:sessionToken,
                                      msgIdKey:@32
                                      };
                customDataString = [self convertJsonDictToString:dic];
                [self sendJSONCommand:customDataString];
                [self ambaLogString:@"JSON Command To Camera: " toFile:AMBALOGFILE];
                [self ambaLogString:customDataString toFile:AMBALOGFILE];
                self.customCommandString = @"";
            }
        }
        
    }
}
- (void) sendCmdToCamera:(unsigned int)commandCode
{
    NSDictionary *commandDict;
    
    if ( commandCode == 1 ||
         commandCode == 5 ||
         commandCode == 6 ||
         commandCode == 15
        ) { //commands with "type" only
         commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       typeObject, typeKey,
                       nil];
        
    } else if (commandCode == 1538 ||
               commandCode == 1283 ||
               commandCode == 1026 ||
               commandCode == 1287 ||
               commandCode == 1281 ||
               commandCode == 16   ||
               commandCode == 9    ||
               commandCode == 4 )   { //commands with "param" only
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       paramObject, paramKey,
                       nil];
    } else if (commandCode == 1285 ) {//special cases
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger: offsetObject], offsetKey,
                       [NSNumber numberWithUnsignedInteger:  sizeToDlObject ], featchSizeKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       nil];
    }else if (commandCode ==1286) //special case
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger: offsetObject], offsetKey,
                       [NSNumber numberWithUnsignedInteger:  sizeToDlObject ], @"size",
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       md5SumObject, @"md5sum",
                       nil];
    } else if (commandCode == 1793) //special case SessionHolder
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       nil];
        
    }else if (commandCode == 2 ||
              commandCode == 261)
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       paramObject, paramKey,
                       typeObject, typeKey,
                       nil];
    } else if ( commandCode == 1027)
    {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       paramObject, paramKey,
                       [NSNumber numberWithUnsignedInteger:fileAttributeValue], typeKey,
                       nil];
    }
    else {
        commandDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                       sessionToken, tokenKey,
                       [NSNumber numberWithUnsignedInteger:commandCode], msgIdKey,
                       nil];
    }
    NSError *writeError = nil;
    NSInteger bytesWritten = 0;
    //WIFI
    if ( self.networkModeWifi == 1) {
        if (wifiTCPConnectionStatus == 0) {
            //Connection was lost and there is no reason to send command to server
            // Prevent stuck APP View
            NSLog(@"Connection was lost to write JSON on to CFStreamOut");
        } else {
            NSLog(@"kc test: come to bytesWritten = [NSJSONSerialization");
            bytesWritten = [NSJSONSerialization writeJSONObject:commandDict toStream:outputStream
                                                    options:kNilOptions error:&writeError];
            NSLog(@"kc test: finish to bytesWritten = [NSJSONSerialization");
            if( bytesWritten <= 0) {
                NSLog(@"Error Writing JSON to outStream");
            }
            NSLog(@"kc test: come to jsonDataString =  [self convertJ");
            NSString *jsonDataString =  [self convertJsonDictToString:commandDict];
            NSLog(@"kc test: ready jsonDataString =  [self convertJ");
            NSLog(@"Command Sent %@", jsonDataString);
            [self ambaLogString:@"JSON Command To Camera: " toFile:AMBALOGFILE];
            [self ambaLogString:jsonDataString toFile:AMBALOGFILE];
        }
    }
    //BLE
    if (self.networkModeBle == 1) {
        if (self.cameraBleMode == NO) {
            // ble connection lost: Skip sending command
            NSLog(@"Connection With BLE Peripheral was lost");
        } else {
            // Send Via BLE connection
            NSString *jsonDataString =  [self convertJsonDictToString:commandDict];
            
            [self sendJSONCommand:jsonDataString];
            [self ambaLogString:@"JSON Command To Camera: " toFile:AMBALOGFILE];
            [self ambaLogString:jsonDataString toFile:AMBALOGFILE];
        }
    }
    //Set 30 sec timer out to get the command response from camera
    //recvResponse = 0 waiting for camera response
    //recvResponse = 1 got complete JSON response from Camera
    recvResponse = 0;
    jsonTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(responseTimer) userInfo:nil repeats:NO];
}

- (NSString *)convertJsonDictToString:(NSDictionary *)json
{
    NSError *error = nil;
    
    if(json !=  nil)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json
                                                           options:kNilOptions
                                                             error:&error];
        
        NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        if([jsonData length] > 0 && error == nil)
        {
            NSLog(@"Command Sent to Camera %@", jsonDataString);
            return jsonDataString;
        }
    }
    return @"Error in Json";
    
}
- (void) messageReceived:(NSString *)message
{
    
    recvResponse = 1;
    
    NSDictionary *replyDictionary = [self convertStringToDictionary:message];
    
    notifyMsg = (NSMutableString *)message;
    //NSLog(@"messageReceived for command : %@",_notifyMsg);
    
    [self ambaLogString:@"Camera JSON response :" toFile:AMBALOGFILE];
    
    [self ambaLogString:message toFile:AMBALOGFILE];
    
    
    
    if ([[replyDictionary objectForKey:msgIdKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:notificationMsgId/*manualOperationMsgID*/]])
    {
        NSLog(@"!!!GOT NOTIFICATION MSG From Camera!!!");
        notifyMsg = (NSMutableString *)@"";
        notifyMsg = (NSMutableString *)message;
        NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          notifyMsg, typeKey, nil];
                                          //message, typeKey, nil];
        NSNotification *notificationObject = [NSNotification notificationWithName:cameraSeveredNotification
                                                                           object:self
                                                                         userInfo:notificationDict];
        self.notificationCount = 1;
        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        //close session if there is a camera's sends a Power_off notification message
        //if (! ( [message rangeOfString:@"cam_off"].location == NSNotFound)){
        //    NSLog(@"Camera Sent Power Off Notification!!!!!");
        //   [self ambaLogString:@"Camera Power Down ---> sending disconnect" toFile:AMBALOGFILE];
        //    [self disconnectToCamera];
        //}
        //close the data Port on success download
        if ( !([notifyMsg rangeOfString:@"get_file_complete"].location == NSNotFound) ) {
            [[FileDownload fileDownloadInstance] closeFileDownloadConnection];
            self.commandReturnValue = 0;
            NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              notifyMsg, typeKey, nil];
            NSNotification *notificationObject = [NSNotification notificationWithName:updateCommandReturnStatusNotification
                                                                               object:self
                                                                             userInfo:notificationDict];
            self.notificationCount = 1;
            [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
            
        }
        
    }
    else if (([[replyDictionary objectForKey:msgIdKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:querySessionHolderMsgId]
               ]))
    {
        self.notificationCount = 1;

        notifyMsg = (NSMutableString *)message;
        NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          notifyMsg, typeKey, nil];
        NSNotification *notificationObject = [NSNotification notificationWithName:querySessionHolderNotification
                                                                           object:self
                                                                         userInfo:notificationDict];
        
        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:startSessionCmd])
    {
        [self responseToStartSession:replyDictionary];
    }
    else if ([currentCommand isEqualToString:stopSessionCmd])
    {
        [self responseToStopSession:replyDictionary];
    }
    else if ([currentCommand isEqualToString:recordStartCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:recordStopCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:shutterCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:deviceInfoCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:batteryLevelCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:stopContPhotoSessionCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:recordingTimeCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:splitRecordingCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:stopVFCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ([currentCommand isEqualToString:resetVFCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:appStatusCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:zoomInfoCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:setBitRateCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:storageSpaceCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:presentWorkingDirCmd])
    {
        [self  setPWDPath:message];
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:listAllFilesCmd])
    {
        
        [self updateFileListing:replyDictionary];
        [self responseToShowLog:replyDictionary];
    }
    
    else if ( [currentCommand isEqualToString:numberOfFilesInFolderCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:changeToFolderCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:mediaInfoCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:getFileCmd])
    {
        //[self responseToShowLog:replyDictionary];
        [self respondsToFileDownload:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:putFileCmd])
    {
        //[self responseToShowLog:replyDictionary];
        [self respondsToFileUpload:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:stopGetFileCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:removeFileCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:removeFileCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:fileAttributeCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString:allSettingsCmd])
    {
        [self responseToGetAllSettings:message];
    }
    else if ( [currentCommand isEqualToString:getSettingValueCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if  ( [currentCommand isEqualToString: getOptionsForValueCmd])
    {
        [self responseToGetOptionsSettings:message];
    }
    else if ( [currentCommand isEqualToString: setCameraParameterCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: sendCustomJSONCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: setClientInfoCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: getWifiSettingsCmd])
    {
        [self updateWifiItemListing:replyDictionary];
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: setWifiSettingsCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: getWifiStatusCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: stopWifiCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: startWifiCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: reStartWifiCmd])
    {
        [self responseToShowLog:replyDictionary];
    }
    else if ( [currentCommand isEqualToString: querySessionCmd])
    {
        [self responseToShowLog:replyDictionary];
        [self responseToQuerySessionLog:replyDictionary];
    }
    /* TODO : complete the message responses */
    else {
        NSLog(@"messageReceived: msg Id did not match any command");
    }
}

- (void) responseToQuerySessionLog :(NSDictionary *)responseDict
{
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        NSLog(@"Session Was Retained: ");
        [self ambaLogString:@"----- Session Was Retained ----\n" toFile: AMBALOGFILE];
    } else {
        NSLog(@"Session Retain Time Out");
        self.connected = [NSNumber numberWithBool:FALSE];
        [self ambaLogString:@"----- Session Closed ----\n" toFile: AMBALOGFILE];
        STATUS_FLAG = 0;
        if (networkModeBle) {
            networkModeBle = 0;
            self.cameraBleMode = NO;
            [self cleanup:self.activePeripheral];
        } else {
            networkModeWifi = 0;
        }
        //reset the session Token on success disconnect
        self.sessionToken = 0;
        //[NSThread sleepForTimeInterval:1.0];
        ////////exit(0);
    }
}
- (void) responseToShowLog:(NSDictionary *)responseDict
{
    NSLog(@"JSON Reponse:%@", responseDict);
    //Update UI Lable String With Success or Fail
    self.commandReturnValue = [[responseDict objectForKey:rvalKey] integerValue];
    NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      notifyMsg, typeKey, nil];
    NSNotification *notificationObject = [NSNotification notificationWithName:updateCommandReturnStatusNotification
                                                                       object:self
                                                                     userInfo:notificationDict];
    self.notificationCount = 1;
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
    recvResponse = 1;
    if (jsonTimer) {
        [jsonTimer invalidate];
        NSLog(@"StopJasonTimer:");
    }
}

- (void) updateFileListing:(NSDictionary *)responseDict
{
    NSLog(@"JSON Reponse:%@", responseDict);
    //Update UI Lable String With Success or Fail
    self.commandReturnValue = [[responseDict objectForKey:rvalKey] integerValue];
    NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      notifyMsg, typeKey, nil];
    NSNotification *notificationObject = [NSNotification notificationWithName:updateFileListReturnStatusNotification
                                                                       object:self
                                                                     userInfo:notificationDict];
    //self.notificationCount = 1;
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

- (void) updateWifiItemListing:(NSDictionary *)responseDict
{
    NSLog(@"JSON Reponse:%@", responseDict);
    //Update UI Lable String With Success or Fail
    self.notificationCount = 1;

    self.commandReturnValue = [[responseDict objectForKey:rvalKey] integerValue];
    NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      notifyMsg, typeKey, nil];
    NSNotification *notificationObject = [NSNotification notificationWithName:updateWifiListNotification
                                                                       object:self
                                                                     userInfo:notificationDict];
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

- (void) respondsToFileDownload:(NSDictionary *)responseDict
{
    
    NSLog(@"JSON Response %@",responseDict);
    
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        //Start Data Transfer Port
       //[[fileDownload fileDownloadInstance] initDataCommunication:self.wifiIPParameters tcpPort: 8787 fileName:paramObject];
        NSLog(@"Downloading file on Port 8787 ");
    }
    else {
        NSLog(@"!!!!!!Unable to Download!!!!!");
        [self responseToShowLog:responseDict];
        [[FileDownload fileDownloadInstance] closeTCPConnection];
    }
    
}
- (void) respondsToFileUpload:(NSDictionary *)responseDict
{
    
    NSLog(@"JSON Response %@",responseDict);
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        //Start Data Transfer Port
        //[[fileDownload fileDownloadInstance] initDataCommunication:self.wifiIPParameters tcpPort: 8787 fileName:paramObject];
       // [[fileUpload fileUploadInstance] initDataCommunication:self.wifiIPParameters tcpPort:8787];
        [[FileUpload fileUploadInstance] putFileToCamera: paramObject
                                                        : sizeToDlObject
                                                        : md5SumObject
                                                        : offsetObject];
    }
    else {
        NSLog(@"!!!!!!Unable to Upload File!!!!!");
        [self responseToShowLog:responseDict];
        [[FileUpload fileUploadInstance]  closeTCPConnection];
    }
    
}
- (NSDictionary *)convertStringToDictionary:(NSString *)jsonInString
{
    
    jsonInString = [[jsonInString stringByReplacingOccurrencesOfString:@"{" withString:@""]
                    stringByReplacingOccurrencesOfString:@"}" withString:@""];
    
    
    NSMutableDictionary *convertedDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *keyValuePairArray = [jsonInString componentsSeparatedByString:@","];
    
    for(NSUInteger arrayInd = 0; arrayInd < MIN([keyValuePairArray count], 3); arrayInd++)
    {
        NSArray *singleKeyValuePair = [[keyValuePairArray objectAtIndex:arrayInd] componentsSeparatedByString:@":"];
        NSString *keyParam = [singleKeyValuePair objectAtIndex:0];
        keyParam = [keyParam stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        keyParam = [keyParam stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSString *valueParamString = [singleKeyValuePair objectAtIndex:1];
        NSNumber *valueParamNumber = [[NSNumber alloc] init];
        
        NSArray *tmpParamKeyParamArray = [[NSArray alloc] init];
        
        // if not "param:"
        if (![keyParam isEqualToString:paramKey])
        {
            valueParamNumber = [NSNumber numberWithInt:[valueParamString intValue]]; //  = [formatter numberFromString:valueParamString];
        }
        
        // if "param:"
        else
        {
            valueParamString = [[valueParamString stringByReplacingOccurrencesOfString:@"[" withString:@""]
                                stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            NSLog(@"Number of Chars %d", (unsigned int)valueParamString.length);
            
            tmpParamKeyParamArray = [valueParamString componentsSeparatedByString:@","];
            
            // See if single number
            if([tmpParamKeyParamArray count] == 1)
            {
                valueParamNumber = [NSNumber numberWithInt:[valueParamString intValue]];
            }
        }
        
        if (![keyParam isEqualToString:paramKey])
        {
            [convertedDictionary setObject:valueParamNumber forKey:keyParam];
        }
        // if "param:"
        else
        {
            // if just a number, then set to number
            if ([tmpParamKeyParamArray count] == 1)
            {
                [convertedDictionary setObject:valueParamNumber forKey:keyParam];
            }
            // else set it to string (AMBAXXX.jpg)
            else
            {
                [convertedDictionary setObject:valueParamString forKey:keyParam];
            }
        }
    } // for(NSUI...
    
    NSDictionary *returnDictionary = [convertedDictionary copy];
    
    // Print out for debugging
    
    NSEnumerator *enumerator = [returnDictionary keyEnumerator];
    NSString *key;
    while (key = [ enumerator nextObject])
    {
        NSLog(@"%@, %@", key, [returnDictionary objectForKey:key]);
    }
    
    return returnDictionary;
}

//resp

- (void) responseToStartSession:(NSDictionary *)responseDict
{
    NSLog(@"Response to StartSession received");
    NSLog(@"rval %@", (NSNumber *)[responseDict objectForKey:rvalKey]);
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        sessionToken = [responseDict objectForKey:paramKey];
        
        //[self stopVF];
        
        
        NSLog(@"Start Session success");
        // Trigger Notification Now This Connected
        self.connected = [NSNumber numberWithBool:TRUE];
        
        NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          self.connected, connValueInfoKey,
                                          lastCommand, prevCmdInfoKey,
                                          currentCommand, currentCmdInfoKey,
                                          [responseDict objectForKey:rvalKey], returnValueInfoKey,
                                          nil];
        
        NSNotification *notificationObject = [NSNotification
                                              notificationWithName:changeInConnectionStatusNotification
                                              object:self
                                              userInfo:notificationDict];
        self.notificationCount = 1;
        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        STATUS_FLAG = 0;
        //Update prameterList
        [self getCurrentSettings];
    }
    // send an error message about camera refusing a lock
    else
    {
        NSLog(@"Camera refuses to Start Session");
        NSDictionary *notificationDict = [[NSDictionary alloc] init];
        NSNotification *notificationObject = [NSNotification notificationWithName:startSessionRefusalNotification
                                                                           object:self
                                                                         userInfo:notificationDict];
        self.notificationCount = 1;
        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
        STATUS_FLAG = 1;
    }
}
- (void)responseToStopSession:(NSDictionary *)responseDict
{
    NSLog(@"Response to Stop Session received");
    NSLog(@":::: %@",responseDict);
    if ([[responseDict objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]])
    {
        //NSLog(@"Just before changing value %@", self.connected);
        // Trigger Notification
        self.connected = [NSNumber numberWithBool:FALSE];
        
        //NSLog(@"Just after changing value %@", self.connected);
        [self ambaLogString:@"----- Session Closed ----\n" toFile: AMBALOGFILE];
        STATUS_FLAG = 0;
        if (networkModeBle) {
            networkModeBle = 0;
            self.cameraBleMode = NO;
            [self cleanup:self.activePeripheral];
        } else {
            networkModeWifi = 0;
        }
        //reset the session Token on success disconnect
        self.sessionToken = 0;
        //[NSThread sleepForTimeInterval:1.0];
        
        exit(0);
    }
    else {
        STATUS_FLAG = 1;
        NSLog(@"!!!!!!Unable to Disconnect!!!!!");
    }
    
}

-(void) responseToGetAllSettings:(NSString *)message
{
    // NOTE: DO not missinterpret JSON Format with Key:Value
    // Correct way to convert a string to json is
    // Convert the string to NSData and then use NSJSONSerialization ... as below
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    //NSLog(@" -----> %@",[jsonResponse objectForKey:paramKey]);
    if ([[jsonResponse objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]]){
        NSMutableArray  *tmpArray = [[NSMutableArray alloc] init];
        tmpArray = [jsonResponse objectForKey:paramKey];
        //NSMutableDictionary  *newString = [[NSMutableDictionary alloc] init];
        //NSLog( @"-=-=-=-=-=-%@",tmpArray);
        NSMutableArray *newArray = [[NSMutableArray alloc] init];
        int idx;
        idx = (int)[tmpArray count];
        
        // for (NSDictionary *item in tmpArray) {
        for ( int i =0; i < idx; i++) {
            //NSLog(@"Print item: %@",item);
            [newArray addObject:[[tmpArray objectAtIndex:i] allKeys] ];//[item allKeys]];
            //NSLog(@"Finaalarray %@",newArray);
        }
        
        //NSLog(@"Finaal array %@",newArray);//self.parameterNameList);
        parameterNameList = newArray;
        //NSLog(@"***** %@",_parameterNameList);
    } else { // Fill dummy elements to the array
        [parameterNameList addObject:nil];
        [parameterNameList addObject:nil];
    }
}
- (void) responseToGetOptionsSettings: (NSString * )message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    if ([[jsonResponse objectForKey:rvalKey] isEqualToNumber:[NSNumber numberWithUnsignedInteger:0]]){
        NSMutableArray  *tmpArray = [[NSMutableArray alloc] init];
        tmpArray = [jsonResponse objectForKey:optionsKey]; // JSON response for "options" is an Array
        
        optionParameterNameList = tmpArray;
        //NSLog(@"***** %@",_optionParameterNameList);
        permissionFlag = [jsonResponse objectForKey:permissionKey];
        NSLog(@"PermissionFlag# %@",permissionFlag);
    } else {
        //[optionParameterNameList addObject:@"N/A"];
        [optionParameterNameList addObject:@"N/A"];
        permissionFlag = @"readonly";
        //_optionCurrentParamIndex = 1;
    }
}
- (void) setPWDPath:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:nil];
    self.presentWorkingDirPath = [jsonResponse objectForKey:pwdKey];
}

// Start Session
- (unsigned int)connectToCamera
{
    STATUS_FLAG = 1;
    [self startSession];
    NSLog(@"Session Status Flag = %u", STATUS_FLAG);
    return STATUS_FLAG;
}
- (void)startSession
{
    NSDate *myDate = [[NSDate alloc] init];
    NSString *dateString = [[NSString alloc] initWithFormat: @"%@", myDate];
    [self ambaLogString:dateString toFile:AMBALOGFILE];
    
    NSLog(@"StartSession executed");
    NSLog(@"The connection status is %@", self.connected);
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *)startSessionCmd;
    
    [self sendCmdToCamera:startSessionMsgId];
}
//-- Close Session
- (unsigned int)disconnectToCamera
{
    //reset DISCONNECT_FLAG
    STATUS_FLAG = 0;
    [self stopSession];
    return STATUS_FLAG;
}
- (void)stopSession
{
    NSLog(@"Stop Session executed");
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *)stopSessionCmd;
    
    [self sendCmdToCamera:stopSessionMsgId];
}
// takePhoto
- (void) takePhoto
{
    [self shutter];
}
- (void)shutter
{
    NSLog(@"Shutter CMD executed");
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *)shutterCmd;
    
    [self sendCmdToCamera:shutterMsgId];
}
- (void) getDeviceInformation
{
    NSLog(@"Device Log:");
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *)deviceInfoCmd;
    
    [self sendCmdToCamera:deviceInfoMsgId];
}
- (void) getBatteryLevelInfo
{
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *)batteryLevelCmd;
    
    [self sendCmdToCamera:batteryLevelMsgId];
}
- (void) stopContPhotoSession
{
    NSLog(@"Stop Cont.. Photo Session");
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *)stopContPhotoSessionCmd;
    
    [self sendCmdToCamera:stopContPhotoSessionMsgId];
}
// Start recording
- (void) cameraRecordStart
{
    [self record];
}
-(void) record
{
    NSLog(@"Record Start CMD executed");
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *)recordStartCmd;
    [self sendCmdToCamera:recordStartMsgId];
}
// Start recording
- (void) cameraRecordStop
{
    [self recordStop];
}
- (void) recordStop
{
    NSLog(@"Record Stop CMD executed");
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *)recordStopCmd;
    [self sendCmdToCamera:recordStopMsgId];
}
// Recording Time
- (void) cameraRecordingTime
{
    [self recordingTime];
}
- (void) recordingTime
{
    NSLog(@"Record Time CMD executed");
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *)recordingTimeCmd;
    [self sendCmdToCamera:recordingTimeMsgId];
}
// Split Recording
- (void) cameraSplitRecording
{
    [self splitRecording];
}
- (void) splitRecording
{
    NSLog(@"Force Split Recording");
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *)splitRecordingCmd;
    [self sendCmdToCamera:splitRecordingMsgId];
}

//-- stop VF
- (void) cameraStopViewFinder
{
    [self stopVF];
}
- (void) stopVF
{
    NSLog(@"StopVF CMD executed");
    lastCommand    = currentCommand;
    currentCommand = (NSMutableString *) stopVFCmd;
    
    [self sendCmdToCamera:stopVFMsgId];
}
// -- Reset VF
- (void) cameraResetViewFinder
{
    [self resetVF];
}
- (void) resetVF
{
    NSLog(@"resetVF CMD Executed");
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) resetVFCmd;
    [self sendCmdToCamera: resetVFMsgId];
}
// App Status
- (void) cameraAppStatus
{
    [self status];
}
- (void) status
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) appStatusCmd;
    typeObject = (NSMutableString *)@"app_status";
    [self sendCmdToCamera: appStatusMsgId];
}
//-- DEbug: Notify Last Command Response
- (void) showCameraDebugCmd
{
    [self sendLastCommandJSONResponse];
}
- (void) sendLastCommandJSONResponse
{/*
  NSLog(@"DBG::::::%@",_notifyMsg);
  NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:_notifyMsg, rvalKey, nil];
  NSNotification *notificationObject = [NSNotification
  notificationWithName:jsonDebugNotification
  object:self
  userInfo:notificationDict];
  [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
  */
    NSDictionary *notificationDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      notifyMsg, typeKey, nil];
    NSNotification *notificationObject = [NSNotification notificationWithName:jsonDebugNotification
                                                                       object:self
                                                                     userInfo:notificationDict];
    self.notificationCount = 1;
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
    
}
- (void) getZoomInfo: (NSString *)zoomType
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *)zoomInfoCmd;
    typeObject = (NSMutableString *)zoomType;
    [self sendCmdToCamera: zoomInfoMsgId];
}
- (void) setStreamBitrate:(NSString *)bitRate
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *)setBitRateCmd;
    paramObject = (NSMutableString *)bitRate;
    [self sendCmdToCamera: setBitRateMsgId];
}
// Total Storage Space
- (void) cameraStorageSpace
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) storageSpaceCmd;
    typeObject = (NSMutableString *) @"total";
    [self sendCmdToCamera: storageSpaceMsgId];
}
- (void) cameraFreeSpace
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) storageSpaceCmd;
    typeObject = (NSMutableString *) @"free";
    [self sendCmdToCamera: storageSpaceMsgId];
}
- (void) presentWorkingDir
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) presentWorkingDirCmd;
    [self sendCmdToCamera: presentWorkingDirMsgId];
}
- (void) numberOfFilesInFolder: (NSString *) fileTypeText
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) numberOfFilesInFolderCmd;
    typeObject = (NSMutableString *) fileTypeText;
    [self sendCmdToCamera: numberOfFilesInFolderId];
}

- (void) listAllFiles
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) listAllFilesCmd;
    [self sendCmdToCamera: listAllFilesMsgId];
    //TODO :IGNORING: There is an optional param value which can be set for path/creation date/size display in return
    //refer to spec for further details
    

}

- (void) cameraChangeToFolder: (NSString *)inputTextVal
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) changeToFolderCmd;
    paramObject = (NSMutableString *)inputTextVal;
    [self sendCmdToCamera: changeToFolderMsgId];
}
- (void) mediaInfo:(NSString *)inputTextVal
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) mediaInfoCmd;
    paramObject = (NSMutableString *) inputTextVal;
    [self sendCmdToCamera: mediaInfoMsgId];
    // Todo: ignore Type in command that specify the output in ms or sec.
}

- (void) cameraFileDownload:(NSString *)inputTextVal :(NSString *)offsetInput :(NSString *)sizeToDownload
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) getFileCmd;
    paramObject = (NSMutableString *) inputTextVal;
    offsetObject = [offsetInput intValue];
    sizeToDlObject = [sizeToDownload intValue];
    //[self sendCmdToCamera: getFileMsgId];
    [[FileDownload fileDownloadInstance] initDataCommunication:self.wifiIPParameters tcpPort: 8787 fileName:paramObject];
    [self performSelector:@selector(amba_get_file) withObject:nil afterDelay:1.0];
    //implement offset and fetchSize
}

- (void) amba_get_file {
    NSLog(@"do: Fetch File from Camera");
    [self sendCmdToCamera: getFileMsgId];
}

- (void) cameraStopFileDownload:(NSString *)inputTextVal
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) stopGetFileCmd;
    paramObject = (NSMutableString *) inputTextVal;
    [self sendCmdToCamera: stopGetFileMsgId];
    //implement offset and fetchSize
}

//Upload File
- (void) uploadFileToCamera:(NSString *)fileName :(NSString *)fileSize :(NSString *)md5sum :(NSString *)offset
{
    
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) putFileCmd;
    paramObject = (NSMutableString *) fileName;
    offsetObject = [offset intValue];
    sizeToDlObject = [fileSize intValue];
    md5SumObject = md5sum;
    [self sendCmdToCamera: putFileMsgId];
    [[FileUpload fileUploadInstance] initDataCommunication:self.wifiIPParameters tcpPort:8787];
}

- (void)fileToRemove: (NSString *)inputTextVal
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) removeFileCmd;
    paramObject = (NSMutableString *) inputTextVal;
    [self sendCmdToCamera: removeFileMsgId];
}

- (void) setFileAsRO: (NSString *)fileName
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) fileAttributeCmd;
    paramObject = (NSMutableString *) fileName;
    fileAttributeValue = [@"1" intValue];
    [self sendCmdToCamera: fileAttributeMsgId];
}
- (void) setFileAsRW: (NSString *)fileName
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) fileAttributeCmd;
    paramObject = (NSMutableString *) fileName;
    fileAttributeValue = [@"0" intValue];
    [self sendCmdToCamera: fileAttributeMsgId];
}

- (void) formatSDmedia: (NSString *) drive
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) formatSDMediaCmd;
    paramObject = (NSMutableString *) drive;
    [self sendCmdToCamera: formatSDMediaMsgId];
}
- (void) getCurrentSettings
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) allSettingsCmd;
    [self sendCmdToCamera: allSettingsMsgId];
    
}

- (NSString *) newTitle
{
    //NSLog(@"###### %lu",(unsigned long)[self.parameterNameList count]);
    
    // NSLog(@"-------------- %@",[_parameterNameList objectAtIndex:0]);
    buttonTitleName = [parameterNameList objectAtIndex:currentParamIndex];
    
    if ( currentParamIndex == ( (unsigned long)[parameterNameList count] -1) ) {
        currentParamIndex = 0;
    } else {
        currentParamIndex = currentParamIndex + 1;
    }
    //NSLog( @":_:_:_: %ld---  %@",(long)_currentParamIndex,_buttonTitleName);
    return buttonTitleName;
}
- (NSString *) newOptionTitle
{
    optionButtonTitleName = [optionParameterNameList objectAtIndex:optionCurrentParamIndex];
    if (optionCurrentParamIndex == ( (unsigned long)[optionParameterNameList count] -1) ) {
        optionCurrentParamIndex = 0;
    } else {
        optionCurrentParamIndex = optionCurrentParamIndex + 1;
    }
    return optionButtonTitleName;
}

- (void) getSettingValue: (NSString *)inputTextVal
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) getSettingValueCmd;
    typeObject = (NSMutableString *)inputTextVal;
    [self sendCmdToCamera: getSettingValueMsgId];
}
-(void) getOptionsForValue: (NSString *)inputTextVal
{
    if ([inputTextVal isEqualToString: @"app_status"]) {
        optionParameterNameList = (NSMutableArray* )@"N/A"; //App Status is special Case and its options are Not Applicable
    } else {
        //reset Array Index to start
        optionCurrentParamIndex = 0;
        lastCommand = currentCommand;
        currentCommand = (NSMutableString *) getOptionsForValueCmd;
        paramObject = (NSMutableString *) inputTextVal;
        [self sendCmdToCamera: getOptionsForValueMsgId];
        //reset Array Index to start
        optionCurrentParamIndex = 0;
    }
}
//Set camera Parameter
- (void) setCameraParameterValue: (NSString *)parName  :(NSString *)optValue
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) setCameraParameterCmd;
    typeObject = (NSMutableString *)parName;
    paramObject = (NSMutableString *)optValue;
    [self sendCmdToCamera: setCameraParameterMsgId];
}
/*
- (void) getFile: (NSString *)fileName :(NSString *)offset :(NSString *)fileDownloadSize
{
    
}*/
- (void) sendCustomJSONCommand: (NSString *)customJSONText
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) sendCustomJSONCmd;
    self.customCommandString = [NSString stringWithFormat:@"%@",customJSONText];
    [self sendCustomCmdToCamera: sendCustomJSONMsgID];
}

- (void) setClientInfo : (NSString *)clientIPAddr :(NSString *)clientTransportType
{
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) setClientInfoCmd;
    typeObject = (NSMutableString *)clientTransportType;
    paramObject = (NSMutableString *)clientIPAddr;
    [self sendCmdToCamera: setClientInfoMsgId];
}

//Wifi Settings
- (void) getWifiSettings {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) getWifiSettingsCmd;
    [self sendCmdToCamera: getWifiSettingsMsgId];
    
}
- (void) setWifiSettings: (NSString *)wifiSettingsString {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) setWifiSettingsCmd;
    paramObject = (NSMutableString *)wifiSettingsString;
    [self sendCmdToCamera: setWifiSettingsMsgId];
}

- (void) getWifiStatus {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) getWifiStatusCmd;
    [self sendCmdToCamera: getWifiStatusMsgId];
    
}
- (void) stopWifi {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) stopWifiCmd;
    [self sendCmdToCamera: stopWifiMsgId];
    
}
- (void) startWifi {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) startWifiCmd;
    [self sendCmdToCamera: startWifiMsgId];
}

- (void) reStartWifi {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) reStartWifiCmd;
    [self sendCmdToCamera: reStartWifiMsgId];
}

- (void) keepSessionActive {
    lastCommand = currentCommand;
    currentCommand = (NSMutableString *) querySessionCmd;
    [self sendCmdToCamera:querySessionHolderMsgId];
}

- (NSString *)customString {
    NSDictionary *dic = @{
                          @"router_ssid":@"LTETEST",
                          @"router_password":@"foream.web",
                          @"stream_resolution":@"1080P",
                          @"stream_bitrate":@3500000,
                          @"rtmp_url":@"rtmp://115.231.182.113:1935/livestream/r8j4pabc",
                          tokenKey:sessionToken,
                          msgIdKey:@32
                          };
    NSString *customDataString = [self convertJsonDictToString:dic];
    return customDataString;
}

@end
