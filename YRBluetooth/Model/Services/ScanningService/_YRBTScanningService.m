//
// _YRBTScanningService.m
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

// High Level Abstractions
#import "YRBTClient.h"

// Services
#import "_YRBTScanningService.h"
#import "_YRBTErrorService.h"

// Model
#import "YRBTRemoteDevice+Private.h"
#import "YRBTServerDevice+Private.h"

#import "BTPrefix.h"

// Runtime
#import <objc/runtime.h>

static void const *kDiscoveryTimerDummyKey = &kDiscoveryTimerDummyKey;

@implementation _YRBTScanningService {
    CBCentralManager *_centralManager;
    _YRBTDeviceStorage *_storage;
    CBUUID *_appUUID;
    
    YRBTScanningState _scanningState;
    
    // ==== Timed scan variables ==== //
    NSMutableArray *_foundDevices;
    NSUInteger _maxDeviceCount;
    YRBTFoundDevicesCallback _foundDevicesCallback;
    YRBTFailureCallback _foundDevicesFailureCallback;
    NSTimer *_scanTimer;
    // ========
    
    // ==== Continious scan variables ==== //
    YRBTContiniousScanCallback _continiousScanCallback;
    YRBTFailureCallback _continiousFailureCallback;
    
    NSMutableArray <YRBTServerDevice *> *_repeatedlyFoundDevices;
    // ========
}

#pragma mark - Lifecycle

+ (instancetype)scanningServiceForClient:(YRBTClient *)client
                          centralManager:(CBCentralManager *)manager
                           deviceStorage:(_YRBTDeviceStorage *)storage
                                   appID:(CBUUID *)uuid {
    return [[self alloc] initWithClient:client
                         centralManager:manager
                                storage:storage
                                  appID:uuid];
}

- (instancetype)initWithClient:(YRBTClient *)client
                centralManager:(CBCentralManager *)manager
                       storage:(_YRBTDeviceStorage *)storage
                         appID:(CBUUID *)uuid {
    if (self = [super init]) {
        _client = client;
        
        _centralManager = manager;
        _storage = storage;
        _appUUID = uuid;
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [self invalidate];
}

#pragma mark - Dynamic Properties

- (BOOL)isScanning {
    return self.scanningState != kYRBTScanningStatePending;
}

#pragma mark - Scanning

- (void)scanForDevicesWithContiniousCallback:(YRBTContiniousScanCallback)callback
                                     failure:(YRBTFailureCallback)failure {
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        [self invalidate];
        BTDebugMsg(@"[_YRBTScanningService]: Will start scanning for devices continiously.");

        _scanningState = kYRBTScanningStateScanningContinuously;
        
        _continiousScanCallback = callback;
        _continiousFailureCallback = failure;
        _repeatedlyFoundDevices = [NSMutableArray array];
        
        [_centralManager scanForPeripheralsWithServices:@[_appUUID]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
        
        !_continiousScanCallback ? : _continiousScanCallback([_repeatedlyFoundDevices copy]);
    } else {
        BTDebugMsg(@"[_YRBTScanningService]: Can't start scanning, BT state is not powered on. %d", (int32_t)_centralManager.state);
        !failure ? : failure([_YRBTErrorService buildErrorForBluetoothState:self.client.bluetoothState]);
    }
}

- (void)timedScanForDevicesWithTimeout:(NSTimeInterval)timeout
                        maxDeviceCount:(NSUInteger)maxDevices
                   withSuccessCallback:(YRBTFoundDevicesCallback)success
                           withFailure:(YRBTFailureCallback)failure {
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        [self invalidate];
        BTDebugMsg(@"Will start scanning for devices.");

        _scanningState = kYRBTScanningStateScanning;
        
        _foundDevices = [NSMutableArray array];
        _maxDeviceCount = maxDevices;
        _foundDevicesCallback = success;
        _foundDevicesFailureCallback = failure;
        
        _scanTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                      target:self
                                                    selector:@selector(scanningFinished:)
                                                    userInfo:nil
                                                     repeats:NO];
        
        [_centralManager scanForPeripheralsWithServices:@[_appUUID]
                                                options:nil];
        
        if (maxDevices == 0) {
            [self scanningFinished:nil];
        }
    } else {
        BTDebugMsg(@"ERROR, BT NOT AVAILABLE!");
        !failure ? : failure([_YRBTErrorService buildErrorForBluetoothState:self.client.bluetoothState]);
    }
}

- (void)stopScanning {
    [self invalidate];
}

#pragma mark - Convenience Methods

- (void)handleDidDiscoverPeripheral:(CBPeripheral *)peripheral
                   advertismentData:(NSDictionary *)advertData
                               RSSI:(NSNumber *)RSSI {
    BTDebugMsg(@"Peripheral discovered. Name: %@. Raw perph data: %@, advertisment: %@, RSSI : %@",
               peripheral.name, peripheral, advertData, RSSI);
    
    NSString *peripheralName = advertData[CBAdvertisementDataLocalNameKey];
    YRBTServerDevice *device = [_storage deviceForPeer:peripheral];
    
    if (peripheralName.length > 0) {
        device.peerName = peripheralName;
    }

    // If current discovery packet didn't contain peripheral name, but device was discovered earlier with it - process further.
    if (device.peerName.length == 0) {
        return;
    }
    
    switch (_scanningState) {
        case kYRBTScanningStatePending:
            NSAssert(NO, @"Bluetooth scanning state is not supposed to be pending while scan callback fired.");
            break;
        case kYRBTScanningStateScanning:
            if (![[_foundDevices valueForKey:@"peripheral"] containsObject:peripheral]) {
                [_foundDevices addObject:device];
                
                if (_foundDevices.count >= _maxDeviceCount) {
                    [self scanningFinished:nil];
                }
            } else {
                BTDebugMsg(@"Device already detected in current search.");
            }
            
            break;
        case kYRBTScanningStateScanningContinuously: {
            if (![[_repeatedlyFoundDevices valueForKey:@"peripheral"] containsObject:peripheral]) {
                [_repeatedlyFoundDevices addObject:device];
            }

            [self restartDiscoveryTimeoutForDevice:device];
            
            !_continiousScanCallback ? : _continiousScanCallback([_repeatedlyFoundDevices copy]);

            break;
        }
    }
}

#pragma mark - Cleanup

- (void)invalidate {
    BTDebugMsg(@"[_YRBTScanningService]: Cleaning up components for scanning.");
    // Timed scanning
    [_scanTimer invalidate];
    _foundDevices = nil;
    _maxDeviceCount = NSIntegerMax;
    _foundDevicesCallback = nil;
    _foundDevicesFailureCallback = nil;
    
    // Continious scanning
    _continiousScanCallback = NULL;
    _continiousFailureCallback = NULL;
    
    for (YRBTServerDevice *device in _repeatedlyFoundDevices) {
        [self invalidateDiscoveryTimeoutForDevice:device];
    }
    
    _repeatedlyFoundDevices = nil;
    
    _scanningState = kYRBTScanningStatePending;
    
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        // Otherwise it will crash.
        [_centralManager stopScan];
    }
}

- (void)invalidateWithError:(NSError *)error {
    // Timed scanning
    [_scanTimer invalidate];
    
    _foundDevicesCallback = NULL;
    !_foundDevicesFailureCallback ? : _foundDevicesFailureCallback(error);
    _foundDevicesFailureCallback = NULL;
    _foundDevices = nil;
    _maxDeviceCount = NSIntegerMax;
    
    // Continious scanning
    _continiousScanCallback = NULL;
    !_continiousFailureCallback ? : _continiousFailureCallback(error);
    _continiousFailureCallback = NULL;

    for (YRBTServerDevice *device in _repeatedlyFoundDevices) {
        [self invalidateDiscoveryTimeoutForDevice:device];
    }

    _repeatedlyFoundDevices = nil;
    
    _scanningState = kYRBTScanningStatePending;
    
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        // Otherwise it will crash.
        [_centralManager stopScan];
    }
}

#pragma mark - Callbacks

- (void)scanningFinished:(NSTimer *)timer {
    BTDebugMsg(@"[_YRBTScanningService]: Finished timed scan! Found %d devices.", (int32_t)_foundDevices.count);
    !_foundDevicesCallback ? : _foundDevicesCallback(_foundDevices);
    
    [self invalidate];
}

#pragma mark - Discovery Timeout

- (void)restartDiscoveryTimeoutForDevice:(YRBTServerDevice *)device {
    [self invalidateDiscoveryTimeoutForDevice:device];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                      target:self
                                                    selector:@selector(handleDiscoveryTimeout:)
                                                    userInfo:device
                                                     repeats:NO];
    
    objc_setAssociatedObject(device, kDiscoveryTimerDummyKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)invalidateDiscoveryTimeoutForDevice:(YRBTServerDevice *)device {
    NSTimer *timer = objc_getAssociatedObject(device, kDiscoveryTimerDummyKey);
    
    [timer invalidate];
    
    objc_setAssociatedObject(device, kDiscoveryTimerDummyKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)handleDiscoveryTimeout:(NSTimer *)timer {
    YRBTServerDevice *device = timer.userInfo;
    [self invalidateDiscoveryTimeoutForDevice:device];
    
    BTDebugMsg(@"[_YRBTScanningService]: Discovery timeout for %@", device);
    
    [_repeatedlyFoundDevices removeObject:device];
    
    NSAssert(self.scanningState == kYRBTScanningStateScanningContinuously,
             @"[_YRBTScanningService]: Received discovery timeout for device: %@, but scanning state is incorrect!",
             device);
    
    !_continiousScanCallback ? : _continiousScanCallback([_repeatedlyFoundDevices copy]);
}

@end