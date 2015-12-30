//
//  _BTServiceDeviceStorage.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/1/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

@class CBPeer;
@class YRBTRemoteDevice;

/**
 *  Class that makes association between UUID and YRBTRemoteDevice.
 */
@interface _YRBTDeviceStorage : NSObject

- (__kindof YRBTRemoteDevice *)deviceForPeer:(CBPeer *)peer;
- (BOOL)hasDevice:(__kindof YRBTRemoteDevice *)device;

@end
