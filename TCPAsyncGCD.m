//
//  TCPAsyncGCD.m
//
//  Created by myrual on 12-Aug-10.
//  BSD license
//

#import "TCPAsyncGCD.h"

@implementation TCPAsyncGCD

@synthesize ConnectSuccess;
@synthesize ConnectTimeout;
@synthesize WriteSuccess;
@synthesize WriteTimeout;
@synthesize ReadSuccess;
@synthesize ReadTimeout;
@synthesize completeRead;
@synthesize mysocket;
@synthesize Connected;
@synthesize timeOut = _timeOut;
@synthesize readCache = _readCache;

-(id) init{
    id result = nil;
    result = [super init];
    if (result) {
        GCDAsyncSocket  *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        if (socket) {
            self.mysocket = socket;
            needToKeepSocketLiveAfterReadTimeout = NO;
            _readCache = nil;
        }
        else{
            result = nil;
        }
    }
    return result;
}


-(void) ConnectHost:(NSString *)host toPort:(NSInteger)port withTimeout:(NSTimeInterval)inputMaxTimeout Success:(void (^)())Success TimeoutBlk:(void (^)())timeoutProcess{
    NSError *err = nil;
    self.ConnectSuccess = Success;
    self.ConnectTimeout = timeoutProcess;
    self.timeOut = inputMaxTimeout;
    [self.mysocket connectToHost:host onPort:port withTimeout:self.timeOut error:&err];
}

-(void) Write:(NSData *)Content withTimeout:(NSTimeInterval)inputMaxTimeout Success:(void (^)())Success TimeoutBlk:(void (^)())timeoutProcess{
    self.WriteTimeout = timeoutProcess;
    self.WriteSuccess = Success;
    self.timeOut = inputMaxTimeout;
    self.completeRead = nil;
    [self.mysocket writeData:Content withTimeout:self.timeOut tag:1];
}

-(void) Write:(NSData *)Content Success:(void (^)())Success TimeOut:(void (^)())timeoutProcess maxTimeOutSec:(NSTimeInterval)inputMaxTimeout{
    [self Write:Content withTimeout:inputMaxTimeout Success:Success TimeoutBlk:timeoutProcess];
}

-(void) continueRead{
    needToKeepSocketLiveAfterReadTimeout = NO;
    [self.mysocket readDataWithTimeout:self.timeOut tag:1];
}
-(void) continueRead4KeepSocketLive:(void (^)())timeOutBlock interval:(NSTimeInterval) interval{
    needToKeepSocketLiveAfterReadTimeout = YES;
    self.timeOut = -1;
    [self delayBlock:interval withBlock:timeOutBlock];
    [self.mysocket readDataWithTimeout:self.timeOut tag:1];
}


-(void) ReadwithTimeout:(NSTimeInterval)inputMaxTimeout didFinished:(BOOL (^)(NSData *))Filter Success:(void (^)(NSData *))Success TimeoutBlk:(void (^)())timeoutProcess{
    self.ReadSuccess = Success;
    self.ReadTimeout = timeoutProcess;
    self.completeRead = Filter;
    self.timeOut = inputMaxTimeout;
    needToKeepSocketLiveAfterReadTimeout = NO;
    [self cancelBlock];
    [self.mysocket readDataWithTimeout:self.timeOut tag:1];
}
-(void) ReadwithTimeoutKeepLive:(NSTimeInterval)inputMaxTimeout didFinished:(BOOL (^)(NSData *))Filter Success:(void (^)(NSData *))Success TimeoutBlk:(void (^)())timeoutProcess{
    needToKeepSocketLiveAfterReadTimeout = YES;
    self.ReadSuccess = Success;
    self.completeRead = Filter;
    self.timeOut = KEEPLIVE_READ_TIMEOUT;
    [self cancelBlock];
    [self delayBlock:inputMaxTimeout withBlock:^(){
        [self.mysocket endCurrentRead];
        timeoutProcess();
    }];
    [self.mysocket readDataWithTimeout:-1 tag:1];
}

- (void)delayBlock:(NSTimeInterval) interval withBlock:(void (^)())timeoutProcess
{
    _delayedBlockHandle = perform_block_after_delay(interval, ^{
        // Work
        timeoutProcess();
        _delayedBlockHandle = nil;
    });
}

- (void)cancelBlock{
    if (nil != _delayedBlockHandle) {
        _delayedBlockHandle(YES);
    }
    _delayedBlockHandle = nil;
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    self.Connected = YES;

    self.ConnectSuccess();
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    if (self.completeRead) {
        if (self.readCache == nil) {
            self.readCache = [[NSMutableData alloc] init];
        }
        [self.readCache appendData:data];
        if (self.completeRead(self.readCache) == NO) {
            [self.mysocket readDataWithTimeout:self.timeOut tag:1];
        }else{
            if (_delayedBlockHandle) {
                [self cancelBlock];
            }
            if (self.ReadSuccess) {
                self.ReadSuccess(self.readCache);
            }
            self.readCache = nil;
        }
    }else{
        if (_delayedBlockHandle) {
            [self cancelBlock];
        }
        if (self.ReadSuccess) {
            self.ReadTimeout = nil;
            self.ReadSuccess(data);
        }
    }
}


/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    ;
}
/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    self.WriteSuccess();
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    ;
}

/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 *
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    if (needToKeepSocketLiveAfterReadTimeout) {
        return 1200;
    }
    self.ReadTimeout();
    return 0;
}

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 *
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 *
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    self.WriteTimeout();
    return 0;
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (self.ConnectTimeout) {
        self.ConnectTimeout();
    }
    self.Connected = NO;
}


-(void) disconnected{
    [self.mysocket disconnect];
}

-(void) installConnectionBrokenHandle:(void (^)())timeoutProcess{
    self.ConnectTimeout = timeoutProcess;
}
@end
