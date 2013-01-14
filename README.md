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
        
        
        
        
        
        
License
=========================

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.      
