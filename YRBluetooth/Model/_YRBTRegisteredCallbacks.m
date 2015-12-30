//
//  _YRBTRegisteredCallbacks.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/26/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTRegisteredCallbacks.h"

@implementation _YRBTRegisteredCallbacks {
    NSMutableDictionary *_callbacksTable;
    
    _YRBTRemoteRequestCallbacks *_callbacksForUnknownOperation;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _callbacksTable = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public

- (void)registerCallbacks:(_YRBTRemoteRequestCallbacks *)callbacks
             forOperation:(NSString *)operation {
    _YRBTRemoteRequestCallbacks *existingCallbacks = _callbacksTable[operation];
    
    if (!existingCallbacks.isFinal) {
        _callbacksTable[operation] = callbacks;
    }
}

- (void)registerCallbacksForUnknownOperation:(_YRBTRemoteRequestCallbacks *)callback {
    _callbacksForUnknownOperation = callback;
}

- (_YRBTRemoteRequestCallbacks *)callbacksForOperationType:(NSString *)operationType {
    return _callbacksTable[operationType] ? _callbacksTable[operationType] : _callbacksForUnknownOperation;
}

- (void)invalidate {
    [_callbacksTable removeAllObjects];
}

@end
