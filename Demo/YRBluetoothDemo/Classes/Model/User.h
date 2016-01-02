//
//  User.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Components
#import "YRBluetooth.h"

@interface User : NSObject

@property (nonatomic, readonly) YRBTRemoteDevice *device;

- (instancetype)initWithRemoteDevice:(__kindof YRBTRemoteDevice *)device;

@end
