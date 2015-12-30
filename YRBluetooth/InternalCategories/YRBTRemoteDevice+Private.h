//
//  YRBTRemoteDevice+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/27/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTRemoteDevice.h"

@class CBPeer;

@interface YRBTRemoteDevice (Private)

@property (nonatomic) YRBTConnectionState connectionState;
@property (nonatomic) NSString *peerName;

+ (__kindof YRBTRemoteDevice *)deviceForPeer:(__kindof CBPeer *)peer;

@end
