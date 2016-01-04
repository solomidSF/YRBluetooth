//
//  ServerChatSession.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "ServerChatSession.h"
#import "UsersPool.h"
#import "User+Private.h"

// Components
#import "YRBluetooth.h"

// Auxiliary
#import "Config.h"

static NSString *const kMessageOperation = @"MSG";
static NSString *const kMembersOperation = @"MEM";

@implementation ServerChatSession {
    YRBTServer *_server;
    
    id _observers;
    
    UsersPool *_usersPool;
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

- (void)addObserver:(id <ServerChatSessionObserver>)observer {
    
}

- (void)removeObserver:(id <ServerChatSessionObserver>)observer {
    
}

#pragma mark - Private

- (void)setupServer {
    _usersPool = [UsersPool new];
    
    __typeof(self) __weak weakSelf = self;
    
    _server.deviceConnectCallback = ^(YRBTRemoteDevice *device) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            
            device.nameChangeCallback = ^(YRBTRemoteDevice *device, NSString *newName) {
                User *user = [strongSelf->_usersPool userForDevice:device];
                user.hasName = YES;
                
                [strongSelf->_observers chatSession:strongSelf
                                  userDidChangeName:user];
                
                // TODO: Notify all remote devices
            };
            
            User *user = [strongSelf->_usersPool userForDevice:device];

            [strongSelf->_observers chatSession:strongSelf userDidConnect:user];
            
            // TODO: Notify all remote devices.
        }
    };

    _server.deviceDisconnectCallback = ^(YRBTRemoteDevice *device) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf->_observers chatSession:strongSelf userDidDisconnect:[strongSelf->_usersPool userForDevice:device]];
            
            // TODO: Notify all remote devices.
        }
    };
 
    // TODO: Register callbacks for 'new message' request.
    [_server registerWillReceiveRequestCallback:^(YRBTRemoteMessageRequest *request) {
        
    } didReceiveRequestCallback:^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                        YRBTMessage *requestMessage,
                                                        BOOL wantsResponse) {
        return nil;
    } receivingProgressCallback:^(uint32_t currentBytes, uint32_t totalBytes) {
        
    } failedToReceiveCallback:^(YRBTRemoteMessageRequest *request, NSError *error) {
        
    } forOperation:kMessageOperation];
    
    // TODO: Register callbacks for 'members' request.
    [_server registerWillReceiveRequestCallback:^(YRBTRemoteMessageRequest *request) {
        
    } didReceiveRequestCallback:^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                        YRBTMessage *requestMessage,
                                                        BOOL wantsResponse) {
        return nil;
    } receivingProgressCallback:^(uint32_t currentBytes, uint32_t totalBytes) {
        
    } failedToReceiveCallback:^(YRBTRemoteMessageRequest *request, NSError *error) {
        
    } forOperation:kMembersOperation];
}

@end
