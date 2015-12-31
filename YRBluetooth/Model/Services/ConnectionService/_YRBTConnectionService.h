//
// _YRBTConnectionServices.h
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

@import Foundation;
@import CoreBluetooth;

#import "YRBluetoothTypes.h"
#import "_YRBTDeviceStorage.h"

@class YRBTServerDevice;

/**
 *  Class that is responsible for connection-related stuff.
 */
@interface _YRBTConnectionService : NSObject

/**
 *  Returns devices to which central is currently connected to.
 */
@property (nonatomic, readonly) NSArray <YRBTServerDevice *> *connectedDevices;

#pragma mark - Init

+ (instancetype)connectionServiceForCentralManager:(CBCentralManager *)manager
                                     deviceStorage:(_YRBTDeviceStorage *)storage;

#pragma mark - Connection

- (void)connectServer:(YRBTServerDevice *)server
          withSuccess:(YRBTSuccessfulConnectionCallback)success
              failure:(YRBTFailureWithDeviceCallback)failure;

- (void)disconnectFromServer:(YRBTServerDevice *)server;

#pragma mark - Cleanup

/**
 *  Invalidates all operations in connection service.
 */
- (void)invalidate;
- (void)invalidateWithError:(NSError *)error;

#pragma mark - Convenience Methods

// ==== Convenience methods that should be delegated here ==== //
- (void)handleDidConnectPeripheral:(CBPeripheral *)peripheral;

- (void)handleDidFailToConnectPeripheral:(CBPeripheral *)peripheral
                             withCBError:(NSError *)error;

- (void)handleDidDisconnectPeripheral:(CBPeripheral *)peripheral
                          withCBError:(NSError *)error;

- (void)handlePeripheral:(CBPeripheral *)peripheral didInvalidateServices:(NSArray *)services;

- (void)handlePeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSArray *)services
                 cbError:(NSError *)error;

- (void)handlePeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristics:(NSArray *)characteristics
                                                                    forService:(CBService *)service
                                                                       cbError:(NSError *)error;

- (void)handlePeripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
                                                                                        cbError:(NSError *)error;
// ========= //

@end