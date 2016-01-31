//
// YRBTServerDevice+Private.m
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Categories
#import "YRBTServerDevice+Private.h"
#import "CoreBluetooth+YRBTPrivate.h"

@implementation YRBTServerDevice (Private)

@dynamic peripheral;

#pragma mark - Public

- (void)notifyConnectionStateUpdateDueToReceiveCharacteristicNotificationStateChange {
    !self.connectionStateCallback ? : self.connectionStateCallback(self, self.connectionState);
}

#pragma mark - Dynamic Properties

- (CBService *)internalService {
    return [self serviceForUUID:[CBUUID yrbt_internalServiceUUID]];
}

- (CBCharacteristic *)sendCharacteristic {
    return [self characteristicWithUUID:[CBUUID yrbt_receiveCharacteristicUUID]];
}

- (CBCharacteristic *)receiveCharacteristic {
    return [self characteristicWithUUID:[CBUUID yrbt_sendCharacteristicUUID]];
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