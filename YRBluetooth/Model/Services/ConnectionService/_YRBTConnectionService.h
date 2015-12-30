//
//  _YRBTConnectionServices.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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