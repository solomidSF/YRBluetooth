//
//  CoreBluetooth+YRBTPrivate.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 3/2/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import CoreBluetooth;

@interface CBService (YRBTPrivate)

@end

@interface CBMutableService (YRBTPrivate)

@end

@interface CBPeripheralManager (YRBTPrivate)

/**
 *  Returns human readable state of current BTLE accessory.
 */
- (NSString *)yrbt_peripheralHumanReadableState;

@end

@interface CBCentralManager (YRBTPrivate)

/**
 *  Returns human readable state of current BTLE accessory.
 */
- (NSString *)yrbt_centralHumanReadableState;

@end
