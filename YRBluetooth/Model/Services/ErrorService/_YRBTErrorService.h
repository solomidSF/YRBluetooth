//
//  _YRBTErrorService.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/23/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "YRBluetoothTypes.h"

@interface _YRBTErrorService : NSObject

+ (NSError *)buildErrorForCode:(YRBTErrorCode)code;
// TODO:
+ (NSError *)buildErrorForCentralState:(CBCentralManagerState)state;
+ (NSError *)buildErrorForPeriphrealState:(CBPeripheralManagerState)state;

@end
