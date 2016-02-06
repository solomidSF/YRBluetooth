//
// _YRBTRegisteredCallbacks.m
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

#import "_YRBTRegisteredCallbacks.h"

@implementation _YRBTRegisteredCallbacks {
    NSMutableDictionary *_callbacksTable;
    
    _YRBTRemoteOperationCallbacks *_callbacksForUnknownOperation;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _callbacksTable = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public

- (void)registerCallbacks:(_YRBTRemoteOperationCallbacks *)callbacks
             forOperation:(NSString *)operation {
    _YRBTRemoteOperationCallbacks *existingCallbacks = _callbacksTable[operation];
    
    if (!existingCallbacks.isFinal) {
        _callbacksTable[operation] = callbacks;
    }
}

- (void)registerCallbacksForUnknownOperation:(_YRBTRemoteOperationCallbacks *)callbacks {
    _callbacksForUnknownOperation = callbacks;
}

- (_YRBTRemoteOperationCallbacks *)callbacksForOperationType:(NSString *)operationType {
    return _callbacksTable[operationType] ? _callbacksTable[operationType] : _callbacksForUnknownOperation;
}

- (void)invalidate {
    [_callbacksTable removeAllObjects];
}

@end
