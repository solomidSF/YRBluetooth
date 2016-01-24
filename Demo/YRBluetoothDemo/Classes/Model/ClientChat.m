//
//  ClientChat.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/24/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "ClientChat.h"

// Categories
#import "Chat+Private.h"

// Components
#import "YRBluetooth.h"

@interface ClientChat ()
@property (nonatomic) User *creator;
@property (nonatomic) YRBTServerDevice *device;
@end

@implementation ClientChat

#pragma mark - Dynamic Properties

- (NSString *)name {
    return self.device.peerName;
}

- (ChatState)state {
    switch (self.device.connectionState) {
        case kYRBTConnectionStateNotConnected:
        case kYRBTConnectionStateDisconnecting:
            return kChatStateDisconnected;
        case kYRBTConnectionStateConnecting:
        case kYRBTConnectionStateConnectedWithoutCommunication:
            return kChatStateConnecting;
        case kYRBTConnectionStateConnected:
            return kChatStateConnected;
    };
}

@end
