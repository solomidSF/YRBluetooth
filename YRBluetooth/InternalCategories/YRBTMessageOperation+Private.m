//
//  YRBTMessageOperation+Private.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/15/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

// InternalCategories
#import "YRBTMessageOperation+Private.h"
#import "YRBTRemoteMessageRequest+Private.h"
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

+ (instancetype)cancelOperationForRemoteRequest:(YRBTRemoteMessageRequest *)request {
	YRBTMessage *cancelCommand = [YRBTMessage cancelMessageForOperationID:request.buffer.header.messageID
                                                                 isSender:NO];
	
	return [self operationWithFastCommand:cancelCommand
								receivers:@[request.sender]
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
