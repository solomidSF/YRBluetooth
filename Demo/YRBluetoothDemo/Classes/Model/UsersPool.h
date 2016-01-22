//
//  UsersPool.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Model
#import "User.h"

// Components
#import "YRBluetooth.h"

// TODO: Prob'ly not needed
@interface UsersPool : NSObject

- (User *)userForDevice:(__kindof YRBTRemoteDevice *)device;

@end
