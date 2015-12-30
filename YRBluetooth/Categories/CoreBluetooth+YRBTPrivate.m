//
//  CoreBluetooth+YRBTPrivate.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 3/2/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "CoreBluetooth+YRBTPrivate.h"

@implementation CBService (YRBTPrivate)

@end

@implementation CBPeripheralManager (YRBTPrivate)

- (NSString *)yrbt_peripheralHumanReadableState {
    return @[@"Unknown",
             @"Resetting...",
             @"Unsupported",
             @"Unauthorized",
             @"Powered off",
             @"Powered on"][self.state];
}

@end

@implementation CBCentralManager (YRBTPrivate)

- (NSString *)yrbt_centralHumanReadableState {
    return @[@"Unknown state",
             @"Resetting...",
             @"Unsupported",
             @"Unauthorized",
             @"Powered off",
             @"Powered on"][self.state];
}

@end
