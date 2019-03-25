//
//  FileUpload.m
//  DriftWirelessRemoteControl
//
//  Created by Channing_rong on 2019/3/20.
//  Copyright © 2019 Channing.rong. All rights reserved.
//

#import "FileUpload.h"

unsigned int uploadFlag;

@implementation FileUpload
static FileUpload *fileUpLoadinstance = nil;

- (void) initDataCommunication:(NSString *) ipAddress tcpPort:(NSInteger)tcpPortNo
{
    uploadFlag = 0;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, (unsigned int)tcpPortNo, &readStream, &writeStream);
    
    dataInStream = (__bridge NSInputStream *)readStream;
    dataOutStream = (__bridge  NSOutputStream *)writeStream;
    [dataInStream setDelegate:self];
    [dataOutStream setDelegate:self];
    [dataInStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [dataOutStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.wifiTCPConnectionStatus = 0;
    [dataInStream open];
    [dataOutStream open];
    
    NSLog(@"File Upload @ %@ : %lu OPEN", ipAddress, (long)tcpPortNo);
    [self.wifiParameters appendString:ipAddress];
    
}
- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
    switch (streamEvent)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"Data Connection with Camera: Open");
            //[self driftLogString:@"WiFi Connection With Camera Open" toFile:DriftLOGFILE];
            uploadFlag = 1;
            //Upload file here
            break;
        case NSStreamEventHasBytesAvailable:
            /* if (aStream == dataInStream) {
             uint8_t buffer[1024];
             NSInteger len;
             while ([dataInStream hasBytesAvailable]) {
             len = [dataInStream read:buffer maxLength:sizeof(buffer)];
             if (len > 0) {
             NSString *responseString = [[NSString alloc] initWithBytes:buffer
             length:len
             encoding:NSASCIIStringEncoding];
             if (nil != responseString) {
             if (uploadFlag) {
             NSLog(@"Start Data Transfer from Camera >");
             uploadFlag = 0;
             }
             }
             }
             }
             }*/
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"Unable to connect to Data Port 8787!");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"Closing Connection");
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            aStream = nil;
            break;
            
        default:
            break;
    }
    
}
+ (FileUpload *) fileUploadInstance{
    @synchronized (self)
    {
        if (!fileUpLoadinstance)
        {
            fileUpLoadinstance = [[FileUpload alloc] init];
        }
        return fileUpLoadinstance;
    }
    return  nil;
}
- (void) putFileToCamera: (NSString *)fileName :(NSInteger)fileSize :(NSString *)md5sum :(NSInteger)offset
{
    
    NSArray     *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask, YES);
    NSString    *documentsDirectory = [paths objectAtIndex:0];
    //NSFileManager   *manager = [NSFileManager defaultManager];
    NSString *fileNameWithPath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,fileName];
    //openFile
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:fileNameWithPath];
    if (offset > 0)
        [file seekToFileOffset:(unsigned long long)offset];
    else
        offset = 0;
    
    NSData *newData = [file readDataToEndOfFile];
    int index = 0;
    int totalLen =(int) [newData length];
    uint8_t buffer[1024];
    uint8_t *readBytes = (uint8_t *)[newData bytes];
    while (index < totalLen) {
        if ([dataOutStream hasSpaceAvailable]) {
            int indexLen = (1024>(totalLen-index))?(totalLen-index):1024;
            (void)memcpy(buffer, readBytes, indexLen);
            
            int written = (int)[dataOutStream write:buffer maxLength:indexLen];
            
            if (written < 0 ){
                break;
            }
            index += written;
            readBytes += written;
        }
    }
    
    NSLog(@"FileUpload Done");
    [file closeFile];
    [dataOutStream close];
    [dataInStream close];
}
- (void) closeTCPConnection
{
    [dataOutStream close];
    [dataInStream close];
    dataInStream = nil;
    dataOutStream = nil;
}
@end
