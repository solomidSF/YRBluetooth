//
// YRBTMessageOperation+Private.m
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


// InternalCategories
#import "YRBTMessageOperation+Private.h"
#import "YRBTRemoteMessageOperation+Private.h"
#import "YRBTMessage+Private.h"

// Obj-C
#import <objc/runtime.h>

@implementation YRBTMessageOperation (Private)

@dynamic messageID;

+ (instancetype)cancelOperationForOperation:(YRBTMessageOperation *)operation {
    YRBTMessage *cancelCommand = [YRBTMessage cancelMessageForOperationID:operation.messageID
                                                                 isSender:!operation.isResponse];
    
    return [self operationWithFastCommand:cancelCommand
                                receivers:operation.receivers
                              successSend:NULL
                          sendingProgress:NULL
                                  failure:NULL];
}

+ (instancetype)cancelOperationForRemoteOperation:(YRBTRemoteMessageOperation *)operation {
    YRBTMessage *cancelCommand = [YRBTMessage cancelMessageForOperationID:operation.buffer.header.messageID
                                                                 isSender:NO];
    
    return [self operationWithFastCommand:cancelCommand
                                receivers:@[operation.sender]
                              successSend:NULL
                          sendingProgress:NULL
                                  failure:NULL];
}

@end

@implementation YRBTMessageOperation (Mutable)

@dynamic streamingService;
@dynamic status;
@dynamic mutableReceivers;
@dynamic bytesSent;
@dynamic totalBytesToSend;
@dynamic bytesReceived;

@end

@implementation YRBTMessageOperation (Receiving)

@dynamic buffer;

@end

@implementation YRBTMessageOperation (Multithreading)

- (void)setIsDeallocating:(BOOL)isDeallocating {
    objc_setAssociatedObject(self, &@selector(isDeallocating), @(isDeallocating), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDeallocating {
    return [objc_getAssociatedObject(self, &@selector(isDeallocating)) boolValue];
}

- (void)setIsDeallocatingSilently:(BOOL)isDeallocatingSilently {
    objc_setAssociatedObject(self, &@selector(isDeallocatingSilently), @(isDeallocatingSilently), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDeallocatingSilently {
    return [objc_getAssociatedObject(self, &@selector(isDeallocatingSilently)) boolValue];
}

@end

@implementation YRBTMessageOperation (Timeout)

- (void)setTimeoutTimer:(NSTimer *)timeoutTimer {
    objc_setAssociatedObject(self, &@selector(timeoutTimer), timeoutTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)timeoutTimer {
    return objc_getAssociatedObject(self, &@selector(timeoutTimer));
}

@end
