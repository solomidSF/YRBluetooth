//
// YRBTServer.m
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

@import CoreBluetooth;

// Model
#import "YRBTServer.h"
#import "YRBTMessageOperation+Private.h"

// Services
#import "_YRBTStreamingService.h"

// PrivateModel
#import "_YRBTRegisteredCallbacks.h"
#import "_YRBTErrorService.h"

#import "_YRBTDeviceStorage.h"

// Messaging
#import "_YRBTMessaging.h"

// Categories
#import "CoreBluetooth+YRBTPrivate.h"

// PrivateCategories
#import "YRBTPeer+Private.h"
#import "YRBTRemoteDevice+Private.h"
#import "YRBTClientDevice+Private.h"

// Imports
#import "BTPrefix.h"

@interface YRBTServer (Protocols)
<
_YRBTSendingStreamDelegate,
_YRBTReceivingStreamDelegate,
CBPeripheralManagerDelegate
>
@end

@implementation YRBTServer {
    CBPeripheralManager *_nativePeripheralManager;
    
    _YRBTDeviceStorage *_storage;
    _YRBTStreamingService *_streamingService;
    YRBTWriteCompletionHandler _currentWriteCompletion;

    BOOL _didPerformInitialSetup;

    CBMutableService *_internalService;
    CBMutableCharacteristic *_sendCharacteristic;
    CBMutableCharacteristic *_receiveCharacteristic;
}

#pragma mark - Lifecycle

- (instancetype)initWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName {
    if (self = [super initWithAppID:appID
                           peerName:peerName]) {
        _nativePeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                           queue:nil
                                                                         options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES}];
        [_nativePeripheralManager addObserver:self
                                   forKeyPath:@"isAdvertising"
                                      options:NSKeyValueObservingOptionNew
                                      context:NULL];
        
        _storage = [_YRBTDeviceStorage new];

        _streamingService = [_YRBTStreamingService streamingServiceWithStorage:_storage];
        
        _streamingService.sendingDelegate = self;
        _streamingService.receivingDelegate = self;
        
        [self registerCallbacksForInternalOperations];
    }
    
    return self;
}

- (void)dealloc {
    [_nativePeripheralManager removeObserver:self forKeyPath:@"isAdvertising"];
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Dynamic Properties

- (NSArray <YRBTClientDevice *> *)connectedDevices {
    NSMutableArray *connectedDevices = [NSMutableArray new];

    for (CBCentral *central in _sendCharacteristic.subscribedCentrals) {
        [connectedDevices addObject:[_storage deviceForPeer:central]];
    }
    
    return [NSArray arrayWithArray:connectedDevices];
}

- (YRBTBluetoothState)bluetoothState {
    CBPeripheralManagerState realState = _nativePeripheralManager.state;
    
    switch (realState) {
        case CBPeripheralManagerStateUnknown:
            return kYRBTBluetoothStateUnknown;
        case CBPeripheralManagerStateResetting:
            return kYRBTBluetoothStateResetting;
        case CBPeripheralManagerStatePoweredOff:
            return kYRBTBluetoothStatePoweredOff;
        case CBPeripheralManagerStatePoweredOn:
            return kYRBTBluetoothStatePoweredOn;
        case CBPeripheralManagerStateUnauthorized:
            return kYRBTBluetoothStateUnauthorized;
        case CBPeripheralManagerStateUnsupported:
            return kYRBTBluetoothStateUnsupported;
        default:
            return kYRBTBluetoothStateUnknown;
    }
}

- (BOOL)isBroadcasting {
    return _nativePeripheralManager.isAdvertising;
}

#pragma mark - Sending

- (YRBTMessageOperation *)sendMessage:(YRBTMessage *)msg
                        operationName:(NSString *)operationName
                             toClient:(YRBTClientDevice *)client
                      withSuccessSend:(YRBTSuccessSendCallback)success
                     responseCallback:(YRBTResponseCallback)response
                      sendingProgress:(YRBTProgressCallback)sendingProgress
                    receivingProgress:(YRBTProgressCallback)receivingProgress
                              failure:(YRBTOperationFailureCallback)failure {
    NSAssert(operationName.length > 0, @"[YRBluetooth]: You must specify operation name.");

    return [self sendMessage:msg
               operationName:operationName
                   toDevices:@[client]
             withSuccessSend:success
            responseCallback:response
             sendingProgress:sendingProgress
           receivingProgress:receivingProgress
                     failure:failure];
}

- (YRBTMessageOperation *)broadcastMessage:(YRBTMessage *)message
                             operationName:(NSString *)operationName
                                 toClients:(NSArray <YRBTClientDevice *> *)clients
                               withSuccess:(YRBTSuccessSendCallback)success
                           sendingProgress:(YRBTProgressCallback)sendingProgress
                                   failure:(YRBTOperationFailureCallback)failure {
    NSAssert(operationName.length > 0, @"[YRBluetooth]: You must specify operation name.");
    
    return [self sendMessage:message
               operationName:operationName
                   toDevices:clients
             withSuccessSend:success
            responseCallback:NULL
             sendingProgress:sendingProgress
           receivingProgress:NULL
                     failure:failure];
}

- (void)sendFastMessage:(YRBTMessage *)message
              toDevices:(NSArray <YRBTClientDevice *> *)devices
            successSend:(YRBTSuccessSendCallback)successSend
               progress:(YRBTProgressCallback)progress
                failure:(YRBTOperationFailureCallback)failure {
    [self sendMessage:message
        operationName:nil
            toDevices:devices
      withSuccessSend:successSend
     responseCallback:NULL
      sendingProgress:progress
    receivingProgress:NULL
              failure:failure];
}

- (YRBTMessageOperation *)sendMessage:(YRBTMessage *)msg
                        operationName:(NSString *)operationName
                            toDevices:(NSArray <YRBTClientDevice *> *)devices
                      withSuccessSend:(YRBTSuccessSendCallback)success
                     responseCallback:(YRBTResponseCallback)response
                      sendingProgress:(YRBTProgressCallback)sendingProgress
                    receivingProgress:(YRBTProgressCallback)receivingProgress
                              failure:(YRBTOperationFailureCallback)failure {
    // Filter devices which can receive given message.
    devices = [devices filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(YRBTClientDevice *device,
                                                                                         NSDictionary *bindings) {
        return device.connectionState == kYRBTConnectionStateConnected && [_storage hasDevice:device];
    }]];

    uint16_t minMTU = UINT16_MAX;
    
    for (YRBTClientDevice *device in devices) {
        minMTU = MIN(device.central.maximumUpdateValueLength, minMTU);
        
        if (!device.didPerformHandshake) {
            [self requestNameForDevice:device];
        }
    }
    
    minMTU = (minMTU == UINT16_MAX) ? 0 : minMTU;
    
    YRBTMessageOperation *operation = [YRBTMessageOperation operationWithMessage:msg
                                                                             MTU:minMTU
                                                                   operationName:operationName
                                                                       receivers:devices
                                                                     successSend:success
                                                                        response:response
                                                                 sendingProgress:sendingProgress
                                                               receivingProgress:receivingProgress
                                                                         failure:failure];
    
    if (devices.count > 0) {
        [_streamingService scheduleOperation:operation];
        
        return operation;
    } else {
        operation.status = kYRBTMessageOperationStatusFailed;
        
        operation.failureCallback ? : operation.failureCallback(operation,
                                                                [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeNoReceivers]);
        
        return operation;
    }
}

- (void)cancelOperation:(YRBTMessageOperation *)operation {
    [_streamingService cancelOperation:operation];
}

#pragma mark - Broadcasting

- (void)startBroadcasting {
    if (!_nativePeripheralManager.isAdvertising) {
        BTDebugMsg(@"Will start broadcasting with %@ name", self.peerName ? self.peerName : @"Unknown device");
        [_nativePeripheralManager startAdvertising:@{
             CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:self.appID]],
             CBAdvertisementDataLocalNameKey : self.peerName.length > 0 ? self.peerName : @"Unknown device"
        }];
    } else {
        BTDebugMsg(@"Already broadcasting! Ignoring.");
    }
}
- (void)stopBroadcasting {
    BTDebugMsg(@"");
    if (_nativePeripheralManager.isAdvertising) {
        [_nativePeripheralManager stopAdvertising];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([object isEqual:_nativePeripheralManager] &&
        [keyPath isEqualToString:@"isAdvertising"]) {
        !self.broadcastingStateChanged ? : self.broadcastingStateChanged(_nativePeripheralManager.isAdvertising);
    }
}

#pragma mark - Private

- (void)registerCallbacksForInternalOperations {
    // TODO:
}

- (void)requestNameForDevice:(YRBTClientDevice *)device {
    NSLog(@"[YRBTServer]: Trying to request name for %@", device);
    if (!device.didPerformHandshake && !device.isPerformingHandshake) {
        NSLog(@"[YRBTServer]: Will request device name for %@", device);
        device.isPerformingHandshake = YES;
        
        YRBTResponseCallback responseCallback = ^(YRBTMessageOperation *operation, YRBTMessage *receivedMessage) {
            device.peerName = [receivedMessage stringValue];
            device.didPerformHandshake = YES;
            device.isPerformingHandshake = NO;
        };
        
        YRBTOperationFailureCallback failureCallback = ^(YRBTMessageOperation *operation, NSError *error) {
            device.isPerformingHandshake = NO;
        };
        
        [self sendMessage:nil
            operationName:@"_YRBTDeviceName" // TODO: Const
                 toClient:device
          withSuccessSend:NULL
         responseCallback:responseCallback
          sendingProgress:NULL
        receivingProgress:NULL
                  failure:failureCallback];
    }
}

- (void)createInternalService {
    NSLog(@"[YRBTServer]: Creating main service..");
    _internalService = [CBMutableService yrbt_internalService];
    _sendCharacteristic = [CBMutableCharacteristic yrbt_sendCharacteristic];
    _receiveCharacteristic = [CBMutableCharacteristic yrbt_receiveCharacteristic];

    _internalService.characteristics = @[_sendCharacteristic, _receiveCharacteristic];
    
    [_nativePeripheralManager addService:_internalService];
}

/** Parses messages received from CBCentral. */
- (void)parseReceivedWriteRequests:(NSArray *)writeRequests {
    if (writeRequests.count > 1) {
        // TODO: Not tested. Couldn't reproduce more than 1 write request.
        NSLog(@"[YRBluetooth]: <WARNING> Got more than 1 write request!");
    }
    
    CBATTError resultingError = CBATTErrorSuccess;
    
    // Enumerate through requests and pass data to streaming service.
    for (CBATTRequest *request in writeRequests) {
        BOOL didParseData = [_streamingService handleReceivedData:request.value
                                                          forPeer:request.central
                                                   characteristic:request.characteristic
                                                          cbError:nil];
        
        if (!didParseData) {
            resultingError = CBATTErrorInvalidPdu;
        }
    }
    
    [_nativePeripheralManager respondToRequest:[writeRequests firstObject]
                                    withResult:resultingError];
}

#pragma mark - Cleanup

- (void)invalidate {
    [_streamingService invalidate];
    _currentWriteCompletion = NULL;
    
    [super invalidate];
}

- (void)invalidateWithError:(NSError *)error {
    BTDebugMsg(@"Will invalidate ALL data with error: %@", error);
    [_streamingService invalidateWithError:error];
    _currentWriteCompletion = NULL;    
}

#pragma mark - _YRBTSendingStreamDelegate

- (int16_t)sendingStreamService:(_YRBTStreamingService *)service
             minimalMTUForPeers:(NSArray *)peers {
    int16_t minMTU = INT16_MAX;
    
    for (CBCentral *peer in peers) {
        if (peer.maximumUpdateValueLength < minMTU) {
            minMTU = (int16_t)peer.maximumUpdateValueLength;
        }
    }

    return (minMTU == INT16_MAX) ? 0 : minMTU;
}

- (void)streamingService:(_YRBTStreamingService *)service shouldSendChunk:(_YRBTChunk *)chunk
            forOperation:(YRBTMessageOperation *)operation completionHandler:(YRBTWriteCompletionHandler)completion {
    _currentWriteCompletion = completion;
    
    BOOL didUpdate = [_nativePeripheralManager updateValue:[chunk packedChunkData]
                                         forCharacteristic:_sendCharacteristic
                                      onSubscribedCentrals:[operation.receivers valueForKey:@"central"]];
    
    if (didUpdate) {
        BTDebugMsg(@"[YRBTServer]: Did send chunk %@ for operation: %@", chunk, operation);
        !_currentWriteCompletion ? : _currentWriteCompletion(YES, nil);
        _currentWriteCompletion = NULL;
    } else {
        // Will wait for peripheral:readyToUpdateSubscribers: call.
        BTDebugMsg(@"[YRBTServer]: Failed to send chunk %@ for operation: %@", chunk, operation);
    }
}

#pragma mark - _YRBTReceivingStreamDelegate

- (_YRBTRemoteRequestCallbacks *)streamingService:(_YRBTStreamingService *)service
			  registeredCallbacksForOperationName:(NSString *)operationName {
	return [self.callbacks callbacksForOperationType:operationName];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    BTDebugMsg(@"%s. STATE IS : %d", __FUNCTION__, (int32_t)peripheral.state);
    
    !self.bluetoothStateChanged ? : self.bluetoothStateChanged(self.bluetoothState);

    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        if (!_didPerformInitialSetup) {
            [self createInternalService];
            
            _didPerformInitialSetup = YES;
        }
    } else {
        [self invalidateWithError:[_YRBTErrorService buildErrorForCode:kYRBTErrorCodeBluetoothOff]];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error {
    if (error) {
        NSAssert(NO, @"[YRBluetooth]: <FATAL> Failed to start advertising! Error: %@", error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
            didAddService:(CBService *)service
                    error:(NSError *)error {
    NSLog(@"[YRBTServer]: Did add service: %@. Error: %@", service, error);

    if (error) {
        NSAssert(NO, @"[YRBluetooth]: <FATAL> Couldn't instantiate communication channel on server side! Error: %@", error);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central
                                       didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID yrbt_sendCharacteristicUUID]]) {
        // Client did connect to us.
        YRBTClientDevice *device = [_storage deviceForPeer:central];
        
        device.connectionState = kYRBTConnectionStateConnected;
 
        // TODO: Check/Test/Integrate into component.
        [peripheral setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow
                                     forCentral:central];
        
        BTDebugMsg(@"[YRBTServer]: %@ did connect!", device);
        
        if (!device.didPerformHandshake) {
            [self requestNameForDevice:device];
        }
        
        !self.deviceConnectCallback ? : self.deviceConnectCallback(device);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central
                                   didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    if ([characteristic.UUID isEqual:[CBUUID yrbt_sendCharacteristicUUID]]) {
        BTDebugMsg(@"[YRBTServer]: %@ did disconnect.", [_storage deviceForPeer:central]);
        YRBTClientDevice *device = [_storage deviceForPeer:central];
 
        device.didPerformHandshake = NO;
        device.connectionState = kYRBTConnectionStateNotConnected;
        
        !self.deviceDisconnectCallback ? : self.deviceDisconnectCallback(device);

        [_streamingService handlePeerDisconnected:central];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    BTDebugMsg(@"[YRBluetooth]: <WARNING> YRBTServer doesn't support read request for dynamic characteristics!");
    
    [peripheral respondToRequest:request
                      withResult:CBATTErrorReadNotPermitted];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    [self parseReceivedWriteRequests:requests];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    if (_streamingService.pendingChunk &&
        _streamingService.pendingOperation) {

        NSArray *receivers = [[_streamingService.pendingOperation receivers] valueForKey:@"central"];
        
        BOOL didUpdate = [_nativePeripheralManager updateValue:[_streamingService.pendingChunk packedChunkData]
                                             forCharacteristic:_sendCharacteristic
                                          onSubscribedCentrals:receivers];
        
        if (didUpdate) {
            BTDebugMsg(@"Did send chunk![ReadyToUpdate]");
            
            !_currentWriteCompletion ? : _currentWriteCompletion(YES, nil);
            _currentWriteCompletion = NULL;
        } else {
            // Will wait for peripheral:readyToUpdateSubscribers: call.
            BTDebugMsg(@"Failed to send chunk![ReadyToUpdate]");
        }
    } else {
        BTDebugMsg(@"No pending chunks to be sent!");
    }
}

@end