//
//  _YRBTScanningService.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Services
#import "_YRBTScanningService.h"
#import "_YRBTErrorService.h"

// Model
#import "YRBTRemoteDevice+Private.h"
#import "YRBTServerDevice+Private.h"

#import "Constants.h"
#import "BTPrefix.h"

@implementation _YRBTScanningService {
    CBCentralManager *_centralManager;
    _YRBTDeviceStorage *_storage;
    CBUUID *_appUUID;
    
    ScanningState _scanningState;
    
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
    
    NSMutableArray *_repeatedlyFoundDevices;
    // ========
}

#pragma mark - Lifecycle

+ (instancetype)scanningServiceForCentralManager:(CBCentralManager *)manager
                                   deviceStorage:(_YRBTDeviceStorage *)storage
                                           appID:(CBUUID *)uuid {
    return [[self alloc] initWithCentralManager:manager
                                        storage:storage
                                          appID:uuid];
}

- (instancetype)initWithCentralManager:(CBCentralManager *)manager
                               storage:(_YRBTDeviceStorage *)storage
                                 appID:(CBUUID *)uuid {
    if (self = [super init]) {
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
    return self.scanningState != kScanningStatePending;
}

#pragma mark - Scanning

- (void)scanForDevicesWithContiniousCallback:(YRBTContiniousScanCallback)callback
                                     failure:(YRBTFailureCallback)failure {
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        BTDebugMsg(@"[_YRBTScanningService]: Will start scanning for devices continiously.");
        
        [self invalidate];
        _scanningState = kScanningStateScanningContiniously;
        
        _continiousScanCallback = callback;
        _continiousFailureCallback = failure;
        _repeatedlyFoundDevices = [NSMutableArray array];
        
        [_centralManager scanForPeripheralsWithServices:@[_appUUID]
                                                options:nil];
    } else {
        BTDebugMsg(@"[_YRBTScanningService]: Can't start scanning, BT state is not powered on. %d", (int32_t)_centralManager.state);
        !failure ? : failure([_YRBTErrorService buildErrorForCode:kYRBTErrorCodeBluetoothOff]);
    }
}

- (void)timedScanForDevicesWithTimeout:(NSTimeInterval)timeout
                        maxDeviceCount:(NSUInteger)maxDevices
                   withSuccessCallback:(YRBTFoundDevicesCallback)success
                           withFailure:(YRBTFailureCallback)failure {
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        BTDebugMsg(@"Will start scanning for devices.");
        
        [self invalidate];
        _scanningState = kScanningStateScanning;
        
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
        !failure ? : failure([_YRBTErrorService buildErrorForCode:kYRBTErrorCodeBluetoothOff]);
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
    if (!peripheralName) {
        // Don't do anything if peripheral doesn't have local name.
        return;
    }
    
    YRBTServerDevice *device = [_storage deviceForPeer:peripheral];
    device.peerName = peripheralName;
    
    switch (_scanningState) {
        case kScanningStatePending:
            NSAssert(NO, @"Bluetooth scanning state is not supposed to be pending while scan callback fired.");
            break;
        case kScanningStateScanning:
            if (![[_foundDevices valueForKey:@"peripheral"] containsObject:peripheral]) {
                [_foundDevices addObject:device];
                
                if (_foundDevices.count >= _maxDeviceCount) {
                    [self scanningFinished:nil];
                }
            } else {
                BTDebugMsg(@"Device already detected in current search.");
            }
            
            break;
        case kScanningStateScanningContiniously: {
            if (![[_repeatedlyFoundDevices valueForKey:@"peripheral"] containsObject:peripheral]) {
                [_repeatedlyFoundDevices addObject:device];
                
                !_continiousScanCallback ? : _continiousScanCallback(device);
            }
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
    _repeatedlyFoundDevices = nil;
    
    _scanningState = kScanningStatePending;
    
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
    _repeatedlyFoundDevices = nil;
    
    _scanningState = kScanningStatePending;
    
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

@end