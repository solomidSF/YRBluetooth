//
// YRBTClient.m
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

// Model
#import "YRBTClient.h"

// Services
#import "_YRBTServices.h"

#import "_YRBTMessaging.h"
#import "YRBTMessageOperation+Private.h"

// === TODO: Refactor ===
#import "YRBTServerDevice+Private.h"

// Internal model
#import "_YRBTRegisteredCallbacks.h"

#import "_YRBTDeviceStorage.h"

// InternalCategories
#import "YRBTPeer+Private.h"

// Prefix Refactor
#import "BTPrefix.h"
#import "Constants.h"
// ======================

@interface YRBTClient ()
<
_YRBTSendingStreamDelegate,
_YRBTReceivingStreamDelegate,
CBCentralManagerDelegate,
CBPeripheralDelegate
>
@end

@implementation YRBTClient {
    // Concrete managers
    CBCentralManager *_nativeCentralManager;
    
    // Storage
    _YRBTDeviceStorage *_storage;
    
    // Services
    _YRBTScanningService *_scanningService;
    _YRBTConnectionService *_connectionService;
    _YRBTStreamingService *_streamingService;
    
    YRBTWriteCompletionHandler _currentWriteCompletion;
}

#pragma mark - Init

- (instancetype)initWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName {
    if (self = [super initWithAppID:appID
                           peerName:peerName]) {
        _nativeCentralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                     queue:nil // TODO: v2.0 Maybe create own queue for that?
                                                                   options:@{CBCentralManagerOptionShowPowerAlertKey : @YES}];
        
        _storage = [_YRBTDeviceStorage new];
        
        // Initialize all services.
        _scanningService = [_YRBTScanningService scanningServiceForCentralManager:_nativeCentralManager
                                                                    deviceStorage:_storage
                                                                            appID:[CBUUID UUIDWithString:appID]];
        _connectionService = [_YRBTConnectionService connectionServiceForCentralManager:_nativeCentralManager
                                                                          deviceStorage:_storage];
        _streamingService = [_YRBTStreamingService streamingServiceWithStorage:_storage];
        
        _streamingService.sendingDelegate = self;
        _streamingService.receivingDelegate = self;
        
        // Register callbacks
        [self registerCallbacksForInternalOperations];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Dynamic Properties

- (NSArray *)connectedDevices {
    return _connectionService.connectedDevices;
}

- (BOOL)isScanning {
    return _scanningService.isScanning;
}

#pragma mark - Scanning

- (void)retrieveAvailableServerDevicesWithTimeout:(NSTimeInterval)timeoutValue
                                   maxDeviceCount:(NSUInteger)maxDeviceCount
                              withSuccessCallback:(YRBTFoundDevicesCallback)successCallback
                                  failureCallback:(YRBTFailureCallback)errorCallback {
    [_scanningService timedScanForDevicesWithTimeout:timeoutValue
                                      maxDeviceCount:maxDeviceCount
                                 withSuccessCallback:successCallback
                                         withFailure:errorCallback];
}

- (void)scanForDevicesWithCallback:(YRBTContiniousScanCallback)callback
                   failureCallback:(YRBTFailureCallback)failure {
    [_scanningService scanForDevicesWithContiniousCallback:callback
                                                   failure:failure];
}

- (void)stopScanningForDevices {
    [_scanningService stopScanning];
}

#pragma mark - Connecting/Disconnecting

- (void)connectToDevice:(YRBTServerDevice *)device
            withSuccess:(YRBTSuccessfulConnectionCallback)success
                failure:(YRBTFailureWithDeviceCallback)failure {
    if (![_storage hasDevice:device]) {
        // Fail quickly in debug builds.
        NSAssert(NO, @"[YRBluetooth]: <WARNING> You're trying to use device from another session. Ignoring (Connection request)");
        return;
    }
    
    if (!device.peripheral.delegate) {
        device.peripheral.delegate = self;
    }

    [_connectionService connectServer:device
                          withSuccess:success
                              failure:failure];
}

- (void)disconnectFromDevice:(YRBTServerDevice *)device {
    NSAssert(device && [_storage hasDevice:device], @"[YRBluetooth]: <WARNING> You didn't specify device to disconnect or you're trying to use device from another session. Ignoring (Disconnect request)");
    
    if ([_storage hasDevice:device]) {
        [_connectionService disconnectFromServer:device];
    }
}

#pragma mark - Sending

- (void)sendFastMessage:(YRBTMessage *)message
               toServer:(YRBTServerDevice *)server
            successSend:(YRBTSuccessSendCallback)successSend
               progress:(YRBTProgressCallback)progress
                failure:(YRBTOperationFailureCallback)failure {
    if (!server || ![_storage hasDevice:server]) {
        NSAssert(NO, @"[YRBluetooth]: <WARNING> You didn't specify device which will receive given message or you're trying to use device from another session. Ignoring");
        return;
    }
    
    YRBTMessageOperation *operation = [YRBTMessageOperation operationWithFastCommand:message
                                                                           receivers:@[server]
                                                                         successSend:successSend
                                                                     sendingProgress:progress
                                                                             failure:failure];
 
    if ([server canReceiveMessages]) {
        [_streamingService scheduleOperation:operation];
    } else {
        operation.status = kYRBTMessageOperationStatusFailed;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            
            if (server.connectionState == kYRBTConnectionStateNotConnected) {
                error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeNotConnected];
            } else {
                error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeCommunicationChannelNotEstablished];
            }
            
            !failure ? : failure(operation, error);
        });
    }
}

- (YRBTMessageOperation *)sendMessage:(YRBTMessage *)message
                             toServer:(YRBTServerDevice *)server
                        operationName:(NSString *)operationName
                          successSend:(YRBTSuccessSendCallback)successSendCallback
                             response:(YRBTResponseCallback)responseCallback
                      sendingProgress:(YRBTProgressCallback)sendingProgress
                    receivingProgress:(YRBTProgressCallback)receivingProgress
                              failure:(YRBTOperationFailureCallback)failure {
    if (!server || ![_storage hasDevice:server]) {
        NSAssert(NO, @"[YRBluetooth]: <WARNING> You didn't specify device which will receive given message or you're trying to use device from another session. Ignoring");
        // TODO: Create operation and fail it with no receivers error?
        return nil;
    }
    
    NSAssert(operationName.length > 0, @"[YRBluetooth]: Can't send message without operation name!");
    
    YRBTMessageOperation *operation = nil;
    
    operation = [YRBTMessageOperation operationWithMessage:message
                                                       MTU:self.MTU
                                             operationName:operationName
                                                 receivers:@[server]
                                               successSend:successSendCallback
                                                  response:responseCallback
                                           sendingProgress:sendingProgress
                                         receivingProgress:receivingProgress
                                                   failure:failure];
    
    if ([server canReceiveMessages]) {
        [_streamingService scheduleOperation:operation];
        
        return operation;
    } else {
        operation.status = kYRBTMessageOperationStatusFailed;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: Create separate method.
            NSError *error = nil;
            
            if (server.connectionState == kYRBTConnectionStateNotConnected) {
                error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeNotConnected];
            } else {
                error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeCommunicationChannelNotEstablished];
            }
            
            !failure ? : failure(operation, error);
        });
        
        return operation;
    }
}

- (void)cancelOperation:(YRBTMessageOperation *)operation {
    [_streamingService cancelOperation:operation];
}

#pragma mark - Private

- (void)registerCallbacksForInternalOperations {
    __typeof(self) __weak weakSelf = self;
    
    YRBTReceivedRemoteRequestCallback requestCallback = ^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                                                YRBTMessage *requestMessage,
                                                                                BOOL wantsResponse) {
        return [YRBTMessageOperation responseOperationForRemoteRequest:request
                                                              response:[YRBTMessage messageWithString:self.peerName]
                                                                   MTU:weakSelf.MTU
                                                           successSend:^(YRBTMessageOperation *operation) {
                                                               NSLog(@"Device name was sent!");
                                                           } sendingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                                                               NSLog(@"Device name progress: %d/%d", currentBytes, totalBytes);
                                                           } failure:^(YRBTMessageOperation *operation, NSError *error) {
                                                               NSLog(@"Failed to send device name: %@", error);
                                                           }];
    };
    
    _YRBTRemoteRequestCallbacks *callbacks = [_YRBTRemoteRequestCallbacks new];
    callbacks.receivedRequestCallback = requestCallback;
    callbacks.isFinal = YES;

    // TODO: Const string
    [self.callbacks registerCallbacks:callbacks forOperation:@"_YRBTDeviceName"];
}

/**
 *  Method cancels ALL operations currently running on client instance.
 */
- (void)invalidate {
    [_scanningService invalidate];
    [_connectionService invalidate];
    [_streamingService invalidate];
    
    _currentWriteCompletion = NULL;
    
    [super invalidate];
}

- (void)invalidateWithError:(NSError *)error {
    BTDebugMsg(@"Will invalidate ALL data with error: %@", error);
    [_scanningService invalidateWithError:error];
    [_connectionService invalidateWithError:error];
    [_streamingService invalidateWithError:error];
    
    _currentWriteCompletion = NULL;
}

#pragma mark - _YRBTSendingStreamDelegate

- (void)streamingService:(_YRBTStreamingService *)service didReceiveServiceCommand:(_YRBTInternalChunk *)commandChunk
				fromPeer:(CBPeer *)peer {
	// TODO: Create callback-based.    
}

- (void)streamingService:(_YRBTStreamingService *)service shouldSendChunk:(_YRBTChunk *)chunk
			forOperation:(YRBTMessageOperation *)operation completionHandler:(YRBTWriteCompletionHandler)completion {
	_currentWriteCompletion = completion;
	
	YRBTServerDevice *device = [operation.receivers firstObject];
	
    if ([device canReceiveMessages]) {
        [device.peripheral writeValue:[chunk packedChunkData]
                    forCharacteristic:device.sendCharacteristic
                                 type:CBCharacteristicWriteWithResponse];
    } else {
        // TODO: Create separate method.
        NSError *error = nil;
        
        if (device.connectionState == kYRBTConnectionStateNotConnected) {
            error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeNotConnected];
        } else {
            error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeCommunicationChannelNotEstablished];
        }
        
        !_currentWriteCompletion ? : _currentWriteCompletion(NO, error);
    }
}

#pragma mark - _YRBTReceivingStreamDelegate

- (_YRBTRemoteRequestCallbacks *)streamingService:(_YRBTStreamingService *)service
              registeredCallbacksForOperationName:(NSString *)operationName {
    return [self.callbacks callbacksForOperationType:operationName];
}

#pragma mark - <CBCentralManagerDelegate>

// TODO: In next versions use multicast delegate.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BTDebugMsg(@"[YRBTClient]: Central manager state changed: %d", (int32_t)central.state);
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        [self invalidateWithError:[_YRBTErrorService buildErrorForCode:kYRBTErrorCodeBluetoothOff]];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    [_scanningService handleDidDiscoverPeripheral:peripheral
                                 advertismentData:advertisementData
                                             RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [_connectionService handleDidConnectPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                                                                        error:(NSError *)error {
    [_connectionService handleDidFailToConnectPeripheral:peripheral
                                             withCBError:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [_connectionService handleDidDisconnectPeripheral:peripheral withCBError:error];
    [_streamingService handlePeerDisconnected:peripheral];
}

#pragma mark - <CBPeripheralDelegate>

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    [_connectionService handlePeripheral:peripheral didInvalidateServices:invalidatedServices];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [_connectionService handlePeripheral:peripheral
                     didDiscoverServices:peripheral.services
                                 cbError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
                                                                             error:(NSError *)error {
    [_connectionService handlePeripheral:peripheral didDiscoverCharacteristics:service.characteristics
                                                                    forService:service
                                                                       cbError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
                                                                        error:(NSError *)error {
    [_streamingService handleReceivedData:characteristic.value
                                  forPeer:peripheral
                           characteristic:characteristic
                                  cbError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                                                       error:(NSError *)error {
    !_currentWriteCompletion ? : _currentWriteCompletion(error == nil, error);
    _currentWriteCompletion = NULL;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
                                                                                    error:(NSError *)error {
    [_connectionService handlePeripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic
                                                                                        cbError:error];
}

@end
