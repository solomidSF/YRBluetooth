//
//  YRBTRemoteRequest.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/13/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

// Operations
#import "YRBTRemoteMessageRequest.h"

// Services
#import "_YRBTStreamingService.h"

// Messaging
#import "_YRBTMessageBuffer.h"

// Obj-C
#import <objc/runtime.h>

@interface YRBTRemoteMessageRequest ()

@property (nonatomic, weak) _YRBTStreamingService *streamingService;
@property (nonatomic) YRBTRemoteMessageRequestStatus status;
@property (nonatomic) __kindof YRBTRemoteDevice *sender;
@property (nonatomic, readonly) _YRBTMessageBuffer *buffer;
@property (nonatomic) uint32_t bytesReceived;

@end

@implementation YRBTRemoteMessageRequest

#pragma mark - Dynamic Properties

- (_YRBTMessageBuffer *)buffer {
	_YRBTMessageBuffer *buffer = objc_getAssociatedObject(self, &@selector(buffer));
	
	if (!buffer) {
		buffer = [_YRBTMessageBuffer new];
		objc_setAssociatedObject(self, &@selector(buffer), buffer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return buffer;
}

- (YRBTMessage *)requestMessage {
	return self.buffer.message;
}

- (NSString *)operationName {
	return self.buffer.operationName;
}

- (BOOL)wantsResponse {
	return self.buffer.header.wantsResponse;
}

- (uint32_t)totalBytesToReceive {
	return self.buffer.header.messageSize;
}

#pragma mark - Public

- (void)cancel {
	if (self.status == kYRBTRemoteMessageRequestStatusReceiving) {
		[self.streamingService cancelRemoteRequest:self];
	}
}

@end
