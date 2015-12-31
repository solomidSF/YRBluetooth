//
// _YRBTConnectionOperationStack.m
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

// Services
#import "_YRBTConnectionOperationStack.h"
#import "_YRBTConnectionOperation.h"

// Devices
#import "YRBTServerDevice+Private.h"

static NSTimeInterval const kConnectionTimeoutInterval = 10.0f;

@implementation _YRBTConnectionOperationStack {
    NSMutableArray *_operations;
    NSMutableArray *_timers;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _operations = [NSMutableArray new];
        _timers = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Dynamic Properties

- (void)setStackType:(StackType)stackType {
    _stackType = stackType;
    
    if (_stackType == kStackTypeOnlyOne) {
        // TODO: v2.0
    }
}

#pragma mark - Managing Stack

- (void)addOperation:(_YRBTConnectionOperation *)operation {
    if ([self operationsForPeripheral:operation.serverDevice.peripheral].count == 0) {
        [_timers addObject:[NSTimer scheduledTimerWithTimeInterval:kConnectionTimeoutInterval
                                                            target:self
                                                          selector:@selector(connectionTimeout:)
                                                          userInfo:operation
                                                           repeats:NO]];
    }

    [_operations addObject:operation];
}

- (void)removeOperation:(_YRBTConnectionOperation *)operation {
    [_operations removeObject:operation];
    
    if ([self operationsForPeripheral:operation.serverDevice.peripheral].count == 0) {
        // We should invalidate timer for that peripheral.
        NSTimer *timerToRemove = nil;
        for (NSTimer *timer in _timers) {
            _YRBTConnectionOperation *timerOperation = timer.userInfo;
            if ([timerOperation.serverDevice.peripheral isEqual:operation.serverDevice.peripheral]) {
                [timer invalidate];
                timerToRemove = timer;
                break;
            }
        }
        
        if (timerToRemove) {
            [_timers removeObject:timerToRemove];
        }
    }
}

- (void)removeOperations:(NSArray *)operations {
    for (_YRBTConnectionOperation *operation in operations) {
        [self removeOperation:operation];
    }
}

- (void)invalidate {
    [_timers makeObjectsPerformSelector:@selector(invalidate)];
    
    [_timers removeAllObjects];
    [_operations removeAllObjects];
}

#pragma mark - Introspection

- (NSArray *)peripherals {
    NSMutableSet *peripherals = [NSMutableSet new];
    
    for (_YRBTConnectionOperation *operation in _operations) {
        [peripherals addObject:operation.serverDevice.peripheral];
    }
    
    return [peripherals allObjects];
}

- (NSArray *)operationsForPeripheral:(CBPeripheral *)peripheral {
    NSMutableArray *resultingArray = [NSMutableArray new];
    
    for (_YRBTConnectionOperation *operation in _operations) {
        if ([operation.serverDevice.peripheral isEqual:peripheral]) {
            [resultingArray addObject:operation];
        }
    }
    
    return resultingArray;
}

#pragma mark - Timer

- (void)connectionTimeout:(NSTimer *)timer {
    [_timers removeObject:timer];
    
    _YRBTConnectionOperation *operation = timer.userInfo;
    
    [self.timeoutDelegate operationStack:self receivedConnectionTimeoutForPeripheral:operation.serverDevice.peripheral];
}

@end
