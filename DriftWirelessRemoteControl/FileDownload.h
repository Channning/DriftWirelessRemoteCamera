//
//  FileDownload.h
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileDownload : NSObject<NSStreamDelegate>
{
    NSInputStream *dataInStream;
    NSOutputStream *dataOutStream;
}


@property (nonatomic, strong) NSInputStream *inputDataStream;
@property (nonatomic, strong) NSOutputStream *outputDataStream;
//@property (nonatomic, retain) NSMutableArray *messages;

@property (nonatomic, assign) NSInteger wifiTCPConnectionStatus; // 1=connected 0=unable to connect
@property (nonatomic, strong) NSMutableString *wifiParameters;
//@property (nonatomic, retain) NSMutableString *notifyMsg;
//@property (atomic, retain) NSNumber *connected;
@property (nonatomic, strong) NSFileManager *manager;
@property (nonatomic) NSFileHandle  *fileHandle;

- (void) initDataCommunication: (NSString *)ipAddress tcpPort:(NSInteger)tcpPortNo fileName:(NSString *)fileName;
+ (FileDownload *) fileDownloadInstance;
- (void) closeFileDownloadConnection;
- (void) closeTCPConnection;
@end

NS_ASSUME_NONNULL_END
