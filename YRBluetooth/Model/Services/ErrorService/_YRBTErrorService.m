//
// _YRBTErrorService.m
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

#import "_YRBTErrorService.h"

#import "CoreBluetooth+YRBTPrivate.h"

@implementation _YRBTErrorService

+ (NSError *)buildErrorForCode:(YRBTErrorCode)code {
    static NSArray *errorDescriptions = nil;
#error Errors
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
