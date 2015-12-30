//
//  YRBTRemoteDevice+Private.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/27/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Categories
#import "YRBTRemoteDevice+Private.h"

// Devices
#import "YRBTClientDevice.h"
#import "YRBTServerDevice.h"

@import CoreBluetooth;

@implementation YRBTRemoteDevice (Private)

@dynamic peerName;
@dynamic connectionState;

+ (__kindof YRBTRemoteDevice *)deviceForPeer:(__kindof CBPeer *)peer {
    if ([peer isKindOfClass:[CBCentral class]]) {
        return [YRBTClientDevice deviceForPeer:peer];
    } else if ([peer isKindOfClass:[CBPeripheral class]]) {
        return [YRBTServerDevice deviceForPeer:peer];
    }
    
    return nil;
}

@end
