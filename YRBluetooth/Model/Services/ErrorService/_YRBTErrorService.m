//
//  _YRBTErrorService.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/23/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTErrorService.h"

#import "CoreBluetooth+YRBTPrivate.h"

@implementation _YRBTErrorService

+ (NSError *)buildErrorForCode:(YRBTErrorCode)code {
    static NSArray *errorDescriptions = nil;
    errorDescriptions = @[
                          @"Bluetooth is not enabled!",
                          @"Device isn't connected to server.",
                          @"Failed to establish communication channel.",
                          @"Failed to connect to server.",
                          @"Connection timeout.",
                          @"Disconnected from server.",
                          @"Failed to receive message.",
                          @"Failed to send message.",
                          @"Failed to receive message due to timeout.",
                          @"Failed to send message due to timeout.",
                          @"Failed to connect to server due to timeout."
                          ];
    
    return [NSError errorWithDomain:kYRBTErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey : errorDescriptions[code]}];
}

+ (NSError *)buildErrorForCentralState:(CBCentralManagerState)state {
    NSAssert(state != CBCentralManagerStatePoweredOn, @"[_YRBTErrorService]: Asked to build error for valid bluetooth state[ON]");

    NSString *readableState = @[@"unknown",
                                @"resetting...",
                                @"unsupported",
                                @"unauthorized",
                                @"powered off"][state];
    
    NSString *errorDescription = [NSString stringWithFormat:@"Bluetooth state is '%@'", readableState];
    
    return [NSError errorWithDomain:kYRBTErrorDomain
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
}

+ (NSError *)buildErrorForPeriphrealState:(CBPeripheralManagerState)state {
    NSAssert(state != CBPeripheralManagerStatePoweredOn, @"[_YRBTErrorService]: Asked to build error for valid bluetooth state[ON]");
    
    NSString *readableState = @[@"unknown",
                                @"resetting...",
                                @"unsupported",
                                @"unauthorized",
                                @"powered off"][state];
    
    NSString *errorDescription = [NSString stringWithFormat:@"Bluetooth state is '%@'", readableState];
    
    return [NSError errorWithDomain:kYRBTErrorDomain
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
}

@end
