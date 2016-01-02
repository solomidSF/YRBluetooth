//
//  ServerChatSession.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "ServerChatSession.h"

// Components
#import "YRBluetooth.h"

#import "Config.h"

@implementation ServerChatSession {
    YRBTServer *_server;
    
    id _observers;
}

#pragma mark - Lifecycle

+ (instancetype)sessionWithNickname:(NSString *)nickname {
    return [[self alloc] initWithNickname:nickname];
}

- (instancetype)initWithNickname:(NSString *)nickname {
    if (self = [super init]) {
        _server = [[YRBTServer alloc] initWithAppID:kChatAppID peerName:nickname];
        
        [self setupServer];
    }
    
    return self;
}

- (void)dealloc {
    [self endSession];
}

- (void)endSession {
    [_server invalidate];
}

#pragma mark - Observing

- (void)addObserver:(id<ServerChatSessionObserver>)observer {
    
}

- (void)removeObserver:(id<ServerChatSessionObserver>)observer {
    
}

#pragma mark - Private

- (void)setupServer {
    __typeof(self) __weak weakSelf = self;
    
    _server.deviceConnectCallback = ^(YRBTRemoteDevice *device) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            if (device.peerName.length > 0) {
                
            }
            
            device.nameChangeCallback = ^(YRBTRemoteDevice *device, NSString *newName) {
                // Notify all subscribed devices
            };
            // Notify
//            [_observers chatSession:strongSelf userDidConnect:<#(User *)#>];
        }
    };

    _server.deviceDisconnectCallback = ^(YRBTRemoteDevice *device) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            // Notify
            
//            [_observers chatSession:strongSelf userDidDisconnect:<#(User *)#>];
        }
    };
}

@end
