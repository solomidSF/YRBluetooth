//
//  _YRBTScanningService.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "YRBluetoothTypes.h"

// Model
#import "_YRBTDeviceStorage.h"

@class YRBTServerDevice;

typedef enum {
    kScanningStatePending,
    kScanningStateScanning,
    kScanningStateScanningContiniously
} ScanningState;

/**
 *  Class that is responsible for scanning.
 */
@interface _YRBTScanningService : NSObject

/**
 *  Returns current scanning state.
 */
@property (nonatomic, readonly) ScanningState scanningState;
@property (nonatomic, readonly) BOOL isScanning;

#pragma mark - Init

+ (instancetype)scanningServiceForCentralManager:(CBCentralManager *)manager
                                   deviceStorage:(_YRBTDeviceStorage *)storage
                                           appID:(CBUUID *)uuid;

#pragma mark - Scanning

- (void)scanForDevicesWithContiniousCallback:(YRBTContiniousScanCallback)callback
                                     failure:(YRBTFailureCallback)failure;

- (void)timedScanForDevicesWithTimeout:(NSTimeInterval)timeout
                        maxDeviceCount:(NSUInteger)maxDevices
                   withSuccessCallback:(YRBTFoundDevicesCallback)success
                           withFailure:(YRBTFailureCallback)failure;

- (void)stopScanning;

#pragma mark - Convenience Methods

- (void)handleDidDiscoverPeripheral:(CBPeripheral *)peripheral
                   advertismentData:(NSDictionary *)advertData
                               RSSI:(NSNumber *)RSSI;

#pragma mark - Cleanup

/**
 *  Invalidates all scanning operations.
 */
- (void)invalidate;
- (void)invalidateWithError:(NSError *)error;

@end
