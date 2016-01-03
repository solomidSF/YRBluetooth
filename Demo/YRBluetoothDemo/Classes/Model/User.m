//
//  User.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "User.h"

// Components
#import "YRBluetooth.h"

@interface User ()
@property (nonatomic) BOOL hasName;
@property (nonatomic) __kindof YRBTRemoteDevice *device;
@end

@implementation User

#pragma mark - Dynamic Properties

- (NSString *)identifier {
    return [self.device.uuid UUIDString];
}

- (NSString *)name {
    return self.hasName ? @"Fetching name" : self.device.peerName;
}

- (BOOL)isConnected {
    return self.device.connectionState == kYRBTConnectionStateConnected;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return [self.device isEqual:[(User *)object device]];
    } else {
        return NO;
    }
}

@end
