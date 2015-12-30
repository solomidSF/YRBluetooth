//
//  YRBTServerDevice+Private.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/27/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTServerDevice+Private.h"

// Prefix
#import "Constants.h" // TODO:

@implementation YRBTServerDevice (Private)

@dynamic peripheral;

#pragma mark - Public

- (void)notifyConnectionStateUpdateDueToReceiveCharacteristicNotificationStateChange {
    !self.connectionStateCallback ? : self.connectionStateCallback(self, self.connectionState);
}

#pragma mark - Dynamic Properties

- (CBService *)internalService {
    return [self serviceForUUID:internalServiceUUID()];
}

- (CBCharacteristic *)sendCharacteristic {
    return [self characteristicWithUUID:sendToServerCharacteristicUUID()];
}

- (CBCharacteristic *)receiveCharacteristic {
    return [self characteristicWithUUID:receiveFromServerCharacteristicUUID()];
}

#pragma mark - Private

- (CBService *)serviceForUUID:(CBUUID *)uuid {
    for (CBService *service in self.peripheral.services) {
        if ([service.UUID isEqual:uuid]) {
            return service;
        }
    }
    
    return nil;
}

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)uuid {
    for (CBCharacteristic *characteristic in self.internalService.characteristics) {
        if ([characteristic.UUID isEqual:uuid]) {
            return characteristic;
        }
    }
    
    return nil;
}

@end