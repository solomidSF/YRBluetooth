//
// CoreBluetooth+YRBTPrivate.m
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
#import "CoreBluetooth+YRBTPrivate.h"

// Imports
#import "_YRBTInternal.h"

@implementation CBUUID (YRBTPrivate)

+ (instancetype)yrbt_internalServiceUUID {
    return [CBUUID UUIDWithString:kInternalServiceUUID];
}

+ (instancetype)yrbt_sendCharacteristicUUID {
    return [CBUUID UUIDWithString:kSendCharacteristicUUID];
}

+ (instancetype)yrbt_receiveCharacteristicUUID {
    return [CBUUID UUIDWithString:kReceiveCharacteristicUUID];
}

@end

@implementation CBService (YRBTPrivate)

@end

@implementation CBMutableService (YRBTPrivate)

+ (instancetype)yrbt_internalService {
    return [[CBMutableService alloc] initWithType:[CBUUID yrbt_internalServiceUUID]
                                          primary:YES];
}

@end

@implementation CBMutableCharacteristic (YRBTPrivate)

+ (instancetype)yrbt_sendCharacteristic {
    CBCharacteristicProperties properties = CBCharacteristicPropertyIndicate | CBCharacteristicPropertyIndicateEncryptionRequired;
    CBAttributePermissions permissions = CBAttributePermissionsReadable | CBAttributePermissionsReadEncryptionRequired;
    
    return [[CBMutableCharacteristic alloc] initWithType:[CBUUID yrbt_sendCharacteristicUUID]
                                              properties:properties
                                                   value:nil
                                             permissions:permissions];
}

+ (instancetype)yrbt_receiveCharacteristic {
    return [[CBMutableCharacteristic alloc] initWithType:[CBUUID yrbt_receiveCharacteristicUUID]
                                              properties:CBCharacteristicPropertyWrite
                                                   value:nil
                                             permissions:CBAttributePermissionsWriteable];
}

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
