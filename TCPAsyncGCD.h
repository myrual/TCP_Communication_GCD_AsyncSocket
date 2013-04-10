//
//  TCPAsyncGCD.h

//  Created by myrual on 12-Aug-10.
//  BSD license
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "SpacemanBlocks.h"

@interface TCPAsyncGCD : NSObject
{
    __block SMDelayedBlockHandle _delayedBlockHandle;
}

typedef void (^GCDVoidBlock)();
typedef void (^GCDReadSuccessBlock)(NSData *);
typedef BOOL (^GCDReadFilterBlock)(NSData *);


@property (nonatomic) BOOL Connected;
@property (nonatomic) NSTimeInterval timeOut;
@property (nonatomic, strong) GCDVoidBlock ConnectTimeout;
@property (nonatomic, strong) GCDVoidBlock ConnectSuccess;
@property (nonatomic, strong) GCDVoidBlock WriteTimeout;
@property (nonatomic, strong) GCDVoidBlock WriteSuccess;
@property (nonatomic, strong) GCDVoidBlock ReadTimeout;
@property (nonatomic, strong) GCDReadSuccessBlock ReadSuccess;
@property (nonatomic, strong) GCDReadFilterBlock completeRead;
@property (nonatomic, strong) GCDAsyncSocket *mysocket;
@property (nonatomic, strong) NSMutableData *readCache;


-(void) ConnectHost:(NSString *)host
             toPort:(NSInteger)port
        withTimeout:(NSTimeInterval)inputMaxTimeout
            Success:(void (^)())Success
         TimeoutBlk:(void (^)())timeoutProcess;

-(void) Write:(NSData *)Content
      Success:(void (^)())Success
      TimeOut:(void (^)())timeoutProcess
maxTimeOutSec:(NSTimeInterval)inputMaxTimeout;

-(void) Write:(NSData *)Content
    withTimeout:(NSTimeInterval)inputMaxTimeout
        Success:(void(^)()) Success
   TimeoutBlk:(void(^)()) timeoutProcess;

-(void) ReadwithTimeout:(NSTimeInterval)inputMaxTimeout
             didFinished:(BOOL (^)(NSData *)) Filter
      Success:(void(^)(NSData *result)) Success
   TimeoutBlk:(void(^)()) timeoutProcess;
-(void) ReadwithTimeoutKeepLive:(NSTimeInterval)inputMaxTimeout didFinished:(BOOL (^)(NSData *))Filter Success:(void (^)(NSData *))Success TimeoutBlk:(void (^)())timeoutProcess;

-(void) continueRead;
-(void) continueRead4KeepSocketLive:(void (^)())timeOutBlock interval:(NSTimeInterval) interval;

-(void) disconnected;
-(void) installConnectionBrokenHandle:(void (^)())timeoutProcess;
@end
