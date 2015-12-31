//
// _YRBTConnectionOperationStack.h
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
