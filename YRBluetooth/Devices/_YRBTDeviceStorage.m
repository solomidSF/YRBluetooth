//
//  _BTServiceDeviceStorage.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/1/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import CoreBluetooth;

// Model
#import "_YRBTDeviceStorage.h"
#import "YRBTRemoteDevice+Private.h"

@implementation _YRBTDeviceStorage {
    NSMutableDictionary *_devicesTable;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _devicesTable = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public

- (__kindof YRBTRemoteDevice *)deviceForPeer:(CBPeer *)peer {
    __kindof YRBTRemoteDevice *device = _devicesTable[peer.identifier.UUIDString];
    
    if (!device) {
        device = [YRBTRemoteDevice deviceForPeer:peer];
        
        _devicesTable[peer.identifier.UUIDString] = device;
    }
    
    return device;
}

- (BOOL)hasDevice:(__kindof YRBTRemoteDevice *)device {
    __kindof YRBTRemoteDevice *candidate = _devicesTable[device.uuid.UUIDString];

    return device && (device == candidate);
}

#pragma mark - <NSObject>

- (NSString *)description {
    return [NSString stringWithFormat:@"%@. Devices: %@", [super description], _devicesTable];
}

@end
