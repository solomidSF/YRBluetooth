//
//  YRBTRemoteDevice.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/16/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

@class YRBTRemoteDevice;

typedef enum {
    kYRBTConnectionStateNotConnected,
    kYRBTConnectionStateConnecting,
    kYRBTConnectionStateConnectedWithoutCommunication,
    kYRBTConnectionStateConnected,
    kYRBTConnectionStateDisconnecting
} YRBTConnectionState;

typedef void (^YRBTConnectionStateChangedCallback) (__kindof YRBTRemoteDevice *device,
                                                    YRBTConnectionState newState);

typedef void (^YRBTRemoteDeviceNameChangedCallback) (__kindof YRBTRemoteDevice *device,
                                                     NSString *newPeerName);

@interface YRBTRemoteDevice : NSObject

@property (nonatomic, readonly) YRBTConnectionState connectionState;
@property (nonatomic, copy) YRBTConnectionStateChangedCallback connectionStateCallback;
@property (nonatomic, readonly) NSString *peerName;
@property (nonatomic, copy) YRBTRemoteDeviceNameChangedCallback nameChangeCallback;
@property (nonatomic, readonly) NSUUID *uuid;

@end
