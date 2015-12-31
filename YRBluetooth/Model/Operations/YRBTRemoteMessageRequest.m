//
// YRBTRemoteRequest.m
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
