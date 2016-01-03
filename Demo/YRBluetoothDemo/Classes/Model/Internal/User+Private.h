//
//  User+Private.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "User.h"

// Components
#import "YRBluetooth.h"

@interface User (Private)

@property (nonatomic) BOOL hasName;
@property (nonatomic) __kindof YRBTRemoteDevice *device;

- (instancetype)initWithRemoteDevice:(__kindof YRBTRemoteDevice *)device;

@end
