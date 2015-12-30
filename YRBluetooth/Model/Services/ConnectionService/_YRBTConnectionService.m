//
//  _YRBTConnectionServices.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Services
#import "_YRBTConnectionService.h"
#import "_YRBTConnectionOperation.h"
#import "_YRBTConnectionOperationStack.h"
#import "_YRBTErrorService.h"

// Model
#import "YRBTServerDevice+Private.h"

// TODO:
#import "BTPrefix.h"
#import "Constants.h"

@interface _YRBTConnectionService ()
<
TimeoutDelegate
>
@end

// TODO: Refactr a bit.
@implementation _YRBTConnectionService {
    CBCentralManager *_centralManager;
    NSMutableOrderedSet *_connectedDevices;
    
    _YRBTDeviceStorage *_storage;
    
    _YRBTConnectionOperationStack *_operationStack;
}

#pragma mark - Init

+ (instancetype)connectionServiceForCentralManager:(CBCentralManager *)manager
                                     deviceStorage:(_YRBTDeviceStorage *)storage {
    return [[self alloc] initWithCentralManager:manager
                                        storage:storage];
}

- (instancetype)initWithCentralManager:(CBCentralManager *)manager
                               storage:(_YRBTDeviceStorage *)storage {
    if (self = [super init]) {
        _centralManager = manager;
        _storage = storage;

        _connectedDevices = [NSMutableOrderedSet new];
        _operationStack = [_YRBTConnectionOperationStack new];
        _operationStack.timeoutDelegate = self;
        
        BTDebugMsg(@"[_YRBTConnectionService]: Initializing..");
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [self invalidate];
}

#pragma mark - Dynamic Properties

- (NSArray *)connectedDevices {
    return [_connectedDevices array];
}

#pragma mark - Connection

- (void)connectServer:(YRBTServerDevice *)server
          withSuccess:(YRBTSuccessfulConnectionCallback)success
              failure:(YRBTFailureWithDeviceCallback)failure {
    BTDebugMsg(@"[_YRBTConnectionService]: Will try to connect server: %@", server);
    
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        if (server && ![_storage hasDevice:server]) {
            NSAssert(NO, @"[YRBluetooth]: <WARNING> You didn't specify device which should be connected or you're trying to use device from another session. Ignoring (Connection request)");            
            return;
        }
        
        switch (server.connectionState) {
            case kYRBTConnectionStateNotConnected:
                [_centralManager connectPeripheral:server.peripheral
                                           options:@{
                                                     CBConnectPeripheralOptionNotifyOnConnectionKey : @YES,
                                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES,
                                                     CBConnectPeripheralOptionNotifyOnNotificationKey : @YES,
                                                     }];
                
                break;
            case kYRBTConnectionStateConnecting:
            case kYRBTConnectionStateConnectedWithoutCommunication:
                // Do nothing. We simply add connection request to our operations container.
                break;
            case kYRBTConnectionStateConnected: {
                // If we are already connected - call success block asynchronously, because this is the way we communicate.
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Double check if we're still connected.
                    // Because we can for example be in this method and then bt off.
                    // Bt callback will be scheduled on main queue.
                    // Then we control flow gets here and we schedule success callback.
                    // So now its connectToServer:->bt_off_event->successfuly connected.
                    // It's wrong, so we need to double check if we are still connected before calling success.
                    if (server.connectionState == kYRBTConnectionStateConnected) {
                        !success ? : success(server);
                    } else {
                        // Try to satisfy user request again.
                        [self connectServer:server
                                withSuccess:success
                                    failure:failure];
                    }
                });
                return;
            }
            case kYRBTConnectionStateDisconnecting: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Try to satisfy user request again.
                    [self connectServer:server
                            withSuccess:success
                                failure:failure];
                });
                return;
            }
        }

        _YRBTConnectionOperation *operation = [_YRBTConnectionOperation operationWithServerDevice:server
                                                                                  successCallback:success
                                                                                  failureCallback:failure];
        [_operationStack addOperation:operation];
    } else {
        BTDebugMsg(@"[_YRBTConnectionService]: Can't connect to server: %@, because bluetooth is not on. %d",
                   server,
                   (int32_t)_centralManager.state);
        !failure ? : failure(server, [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeBluetoothOff]);
    }
}

- (void)disconnectFromServer:(YRBTServerDevice *)server {
    BTDebugMsg(@"[_YRBTConnectionService]: Will disconnect from device %@", server.peripheral);
    [_centralManager cancelPeripheralConnection:server.peripheral];
}

#pragma mark - Cleanup

- (void)invalidate {
    BTDebugMsg(@"[_YRBTConnectionService]: Will invalidate. Current connected devices: %d. Pending connection operations: %d. Total peripherals awaiting to connect: %d",
               (int32_t)_connectedDevices.count,
               (int32_t)[_operationStack operations].count,
               (int32_t)[_operationStack peripherals].count);
    
    for (CBPeripheral *peripheral in [_operationStack peripherals]) {
        // Set all pending peripheral devices state to non-connected.
        [_centralManager cancelPeripheralConnection:peripheral];
    }
    
    [_operationStack invalidate];
    [_connectedDevices removeAllObjects];
}

- (void)invalidateWithError:(NSError *)error {
    BTDebugMsg(@"[_YRBTConnectionService]: Will invalidate with error %@. Current connected devices: %d. Pending connection operations: %d. Total peripherals awaiting to connect: %d",
               error,
               (int32_t)_connectedDevices.count,
               (int32_t)[_operationStack operations].count,
               (int32_t)[_operationStack peripherals].count);

    for (CBPeripheral *peripheral in [_operationStack peripherals]) {
        [self notifyFailureForPeripheralAndDisconnect:peripheral
                                            withError:error];
    }
    
    [_operationStack invalidate];
    [_connectedDevices removeAllObjects];
}

#pragma mark - Convenience Methods

- (void)handleDidConnectPeripheral:(CBPeripheral *)peripheral {    
    YRBTServerDevice *device = [_storage deviceForPeer:peripheral];
    
    [_connectedDevices addObject:device];
    
    [device.peripheral discoverServices:@[internalServiceUUID()]];
    
    BTDebugMsg(@"[_YRBTConnectionService]: Did connect to server: %@. Current connection operations for it: %d.",
               device,
               (int32_t)[_operationStack operationsForPeripheral:peripheral].count);
}

- (void)handleDidFailToConnectPeripheral:(CBPeripheral *)peripheral
                             withCBError:(NSError *)error {
    BTDebugMsg(@"[_YRBTConnectionService]: Failed to establish connection to server: %@", [_storage deviceForPeer:peripheral]);
    NSError *resultingError = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeFailedToConnect];
    
    [self notifyFailureForPeripheralAndDisconnect:peripheral
                                        withError:resultingError];
}

- (void)handleDidDisconnectPeripheral:(CBPeripheral *)peripheral
                          withCBError:(NSError *)error {
    YRBTServerDevice *disconnectingDevice = [_storage deviceForPeer:peripheral];
    BTDebugMsg(@"[_YRBTConnectionService]: Disconnected from device: %@. Error: %@", disconnectingDevice, error);
    
    // Notify all connection establishing waiters about failure.
    NSError *resultingError = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeDisconnected];
    
    if (error) {
        // According to documentation error will be filled in if we didn't call cancelPeripheralConnection:
        [self notifyFailureForPeripheralAndDisconnect:peripheral
                                            withError:resultingError];
    }
    
    [_connectedDevices removeObject:disconnectingDevice];
}

- (void)handlePeripheral:(CBPeripheral *)peripheral didInvalidateServices:(NSArray *)services {
    BTDebugMsg(@"[_YRBTConnectionService]: Server %@ invalidated %@ services.", [_storage deviceForPeer:peripheral], services);

    if ([[services valueForKey:@"UUID"] containsObject:internalServiceUUID()]) {
        [self notifyFailureForPeripheralAndDisconnect:peripheral
                                            withError:[_YRBTErrorService buildErrorForCode:kYRBTErrorCodeDisconnected]];
    }
}

- (void)handlePeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSArray *)services
                                                                cbError:(NSError *)error {
    BTDebugMsg(@"[_YRBTConnectionService]: Did discover services callback. Services discovered: %d. Error: %@",
               (int32_t)peripheral.services.count,
               error);
    
    if (!error) {
        // Now we need to discover our internal characteristics for communication.
        // We only have 1 service that has several characteristics to communicate with device.
        for (CBService *service in peripheral.services) {
            // Ignore any service that may exist (though this should never happen).
            if ([service.UUID isEqual:internalServiceUUID()]) {
                [peripheral discoverCharacteristics:@[sendToServerCharacteristicUUID(),
                                                      receiveFromServerCharacteristicUUID(),
                                                      internalCommandsCharacteristicUUID()]
                                         forService:service];
                break;
            }
        }
    } else {
        NSError *resultingError = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeFailedToConnect];
        
        [self notifyFailureForPeripheralAndDisconnect:peripheral
                                            withError:resultingError];
    }
}

- (void)handlePeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristics:(NSArray *)characteristics
                                                                    forService:(CBService *)service
                                                                       cbError:(NSError *)error {
    BTDebugMsg(@"[_YRBTConnectionService]: Did discover %d characteristics callback. Error: %@.",
               (int32_t)service.characteristics.count, error);
    
    if ([service.UUID isEqual:internalServiceUUID()] && !error) {
        NSAssert(service.characteristics.count >= 2, @"Internal service should have more than 2 characteristics to send data to server and to receive data from it.");
        YRBTServerDevice *device = [_storage deviceForPeer:peripheral];
        NSAssert(device.receiveCharacteristic, @"Receive characteristic must be present in order to establish communication channel!");
        NSAssert(device.sendCharacteristic, @"Send characteristic must be present in order to establish communication channel!");

        NSError *resultingError = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeFailedToEstablishCommunicationChannel];
        
        [self notifyFailureForPeripheralAndDisconnect:peripheral
                                            withError:resultingError];
    }
    
    if (!error) {
        // Connection has been made. Now we will subscribe for channel in which we will receive data from server.
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:receiveFromServerCharacteristicUUID()] &&
                characteristic.properties & CBCharacteristicPropertyIndicate) {
                [peripheral setNotifyValue:YES
                         forCharacteristic:characteristic];
            }
        }
    } else {
        NSError *resultingError = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeFailedToEstablishCommunicationChannel];
        
        [self notifyFailureForPeripheralAndDisconnect:peripheral
                                            withError:resultingError];
    }
}

- (void)handlePeripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
                                                                                        cbError:(NSError *)error {
    if ([characteristic.UUID isEqual:receiveFromServerCharacteristicUUID()]) {
        YRBTServerDevice *device = [_storage deviceForPeer:peripheral];
        
        [device notifyConnectionStateUpdateDueToReceiveCharacteristicNotificationStateChange];
        
        if ([device canReceiveMessages]) {
            [self notifySuccessForPeripheral:peripheral];
        } else {
            NSError *resultingError = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeFailedToEstablishCommunicationChannel];
            
            [self notifyFailureForPeripheralAndDisconnect:peripheral
                                                withError:resultingError];
        }
    }
}

#pragma mark - Private

- (void)notifySuccessForPeripheral:(CBPeripheral *)peripheral {
    NSArray *operations = [_operationStack operationsForPeripheral:peripheral];
    [_operationStack removeOperations:operations];
    
    for (_YRBTConnectionOperation *operation in operations) {
        !operation.successCallback ? : operation.successCallback([_storage deviceForPeer:peripheral]);
    }
}

- (void)notifyFailureForPeripheralAndDisconnect:(CBPeripheral *)peripheral
                                      withError:(NSError *)error {
    YRBTServerDevice *device = [_storage deviceForPeer:peripheral];
    BTDebugMsg(@"[_YRBTConnectionService]: Will notify failure: %@ and will disconnect from: %@", error, device);
        
    NSArray *operations = [_operationStack operationsForPeripheral:peripheral];
    [_operationStack removeOperations:operations];
    
    if (device.receiveCharacteristic) {
        [peripheral setNotifyValue:NO forCharacteristic:device.receiveCharacteristic];
    }

    if (peripheral.state != CBPeripheralStateDisconnected) {
        [_centralManager cancelPeripheralConnection:peripheral];
    }
    
    for (_YRBTConnectionOperation *operation in operations) {
        !operation.failureCallback ? : operation.failureCallback(operation.serverDevice, error);
    }
}

#pragma mark - TimeoutDelegate

- (void)operationStack:(_YRBTConnectionOperationStack *)stack receivedConnectionTimeoutForPeripheral:(CBPeripheral *)peripheral {
    BTDebugMsg(@"[_YRBTConnectionService]: Received connection timeout for server: %@!", [_storage deviceForPeer:peripheral]);
    
    [self notifyFailureForPeripheralAndDisconnect:peripheral
                                        withError:[_YRBTErrorService buildErrorForCode:kYRBTErrorCodeConnectionTimeout]];
}

@end
