//
//  User+Private.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "User+Private.h"

@implementation User (Private)

@dynamic device;
@dynamic hasName;

- (instancetype)initWithRemoteDevice:(__kindof YRBTRemoteDevice *)device {
    if (self = [super init]) {
        self.device = device;
        self.hasName = device.peerName.length > 0;
    }
    
    return self;
}

@end
