//
//  _YRBTConnectionOperationStack.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Services
#import "_YRBTConnectionOperationStack.h"
#import "_YRBTConnectionOperation.h"

// Devices
#import "YRBTServerDevice+Private.h"

// TODO:
static NSTimeInterval const kConnectionTimeoutInterval = 1010.0f;

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
