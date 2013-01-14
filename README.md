TCP_Communication_GCD_AsyncSocket
=================================

an TCP communication lib based on cocoaasync GCD. https://github.com/robbiehanson/CocoaAsyncSocket

### Help to finish following task with one object:   ###
1. connect to an server
2. write data
3. read data from server and check whether enough data has been read


### example ###



    TCPSocket = [[TCPAsyncGCD alloc] init];
    [TCPSocket ConnectHost:@"host" toPort:443 withTimeout:10 Success:^(){
        NSLog(@"connect success");
        [TCPSocket Write:data2write Success:^(){
            NSLog(@"data write success");
            [TCPSocket ReadwithTimeout:10 didFinished:^(NSData *gotData){
				NSlog@"still need to read"
                return NO;
            }
                                      Success:^(NSData *gotData){
                                          [self.myTCPSocket continueRead];
                                          
                                      }
                                   TimeoutBlk:10];
        }
                        TimeOut: 10
                  maxTimeOutSec:10];    }TimeoutBlk:^(){
            ;
        }];