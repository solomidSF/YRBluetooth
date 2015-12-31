//
// _YRBTDeviceStorage.m
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
