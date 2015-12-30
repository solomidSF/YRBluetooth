//
//  YRBTServerDevice+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/27/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import CoreBluetooth;

#import "YRBTServerDevice.h"

@interface YRBTServerDevice (Private)

/** Concrete instance of server. */
@property (nonatomic) CBPeripheral *peripheral;

@property (nonatomic, readonly) CBService *internalService;
@property (nonatomic, readonly) CBCharacteristic *sendCharacteristic;
@property (nonatomic, readonly) CBCharacteristic *receiveCharacteristic;

- (void)notifyConnectionStateUpdateDueToReceiveCharacteristicNotificationStateChange;

@end