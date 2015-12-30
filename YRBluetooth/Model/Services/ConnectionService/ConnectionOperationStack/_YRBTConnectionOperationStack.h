//
//  _YRBTConnectionOperationStack.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@protocol TimeoutDelegate;
@class _YRBTConnectionOperation;

typedef enum {
    kStackTypeStacking,
    kStackTypeOnlyOne,
} StackType;

/**
 *  Connection operation stack for connection service.
 *  Main purpose is to held operations.
 */
@interface _YRBTConnectionOperationStack : NSObject

/**
 *  Stack type defines how operations are stored.
 *  Currently only 2 stack types available:
 *  kStackTypeStacking - simply stacks all operations.
 *  kStackTypeOnlyOne - new operation replaces another.
 */
@property (nonatomic) StackType stackType;

/**
 *  Currently contained in operations.
 */
@property (nonatomic, readonly) NSArray *operations;

@property (nonatomic, weak) id <TimeoutDelegate> timeoutDelegate;

#pragma mark - Managing Stack

- (void)addOperation:(_YRBTConnectionOperation *)operation;
- (void)removeOperation:(_YRBTConnectionOperation *)operation;
- (void)removeOperations:(NSArray *)operations;

/**
 *  Removes all operations and all timeout timers.
 */
- (void)invalidate;

#pragma mark - Introspection

/**
 *  Returns array of CBPeripheral instances contained in stack.
 *  There can be several operations for one peripheral, this method returns that peripheral only ONCE.
 */
- (NSArray *)peripherals;

/**
 *  Returns currently contained operations for given peripheral.
 */
- (NSArray *)operationsForPeripheral:(CBPeripheral *)peripheral;

@end

@protocol TimeoutDelegate <NSObject>

- (void)operationStack:(_YRBTConnectionOperationStack *)stack receivedConnectionTimeoutForPeripheral:(CBPeripheral *)peripheral;

@end
