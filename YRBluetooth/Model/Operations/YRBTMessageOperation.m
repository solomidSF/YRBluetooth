//
// YRBTMessageOperation.m
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

#import "YRBTMessageOperation.h"

// Internal Categories
#import "YRBTRemoteMessageRequest+Private.h"

// Internal
#import "_YRBTStreamingService.h"
#import "_YRBTMessagingTypes.h"

// Obj-C
#import <objc/runtime.h>

NSTimeInterval const kYRBTDefaultTimeoutInterval = 10.0f;

@interface YRBTMessageOperation ()

@property (nonatomic, weak) _YRBTStreamingService *streamingService;
@property (nonatomic) message_id_t messageID;
@property (nonatomic) YRBTMessageOperationStatus status;
@property (nonatomic) NSMutableArray <__kindof YRBTRemoteDevice *> *mutableReceivers;
@property (nonatomic) uint32_t bytesSent;
@property (nonatomic) uint32_t totalBytesToSend;
@property (nonatomic) uint32_t bytesReceived;
@property (nonatomic, readonly) _YRBTMessageBuffer *buffer;

@end

@implementation YRBTMessageOperation

#pragma mark - Init

+ (instancetype)operationWithMessage:(YRBTMessage *)message
								 MTU:(uint16_t)MTU
					   operationName:(NSString *)operationName
						   receivers:(NSArray <YRBTRemoteDevice *> *)receivers
						 successSend:(YRBTSuccessSendCallback)successSendCallback
							response:(YRBTResponseCallback)responseCallback
					 sendingProgress:(YRBTProgressCallback)sendingProgressCallback
				   receivingProgress:(YRBTProgressCallback)receivingProgressCallback
							 failure:(YRBTOperationFailureCallback)failureCallback {
	return [[self alloc] initWithMessage:message
							   messageID:0
									 MTU:MTU
						   operationName:operationName
							   receivers:receivers
							  isResponse:NO
					useSuppliedMessageID:NO
							 successSend:successSendCallback
								response:responseCallback
						 sendingProgress:sendingProgressCallback
					   receivingProgress:receivingProgressCallback
								 failure:failureCallback];
}

+ (instancetype)responseOperationForRemoteRequest:(YRBTRemoteMessageRequest *)request
										 response:(YRBTMessage *)responseMessage
											  MTU:(uint16_t)MTU
									  successSend:(YRBTSuccessSendCallback)successSend
								  sendingProgress:(YRBTProgressCallback)progress
										  failure:(YRBTOperationFailureCallback)failure {
	return [[self alloc] initWithMessage:responseMessage
							   messageID:request.messageID
									 MTU:MTU
						   operationName:request.operationName
							   receivers:@[request.sender]
							  isResponse:YES
					useSuppliedMessageID:YES
							 successSend:successSend
								response:NULL
						 sendingProgress:progress
					   receivingProgress:NULL
								 failure:failure];
}

+ (instancetype)operationWithFastCommand:(YRBTMessage *)message
							   receivers:(NSArray <YRBTRemoteDevice *> *)receivers
							 successSend:(YRBTSuccessSendCallback)successSendCallback
						 sendingProgress:(YRBTProgressCallback)sendingProgressCallback
								 failure:(YRBTOperationFailureCallback)failureCallback {
	return [[self alloc] initWithMessage:message
							   messageID:0
									 MTU:0
						   operationName:nil
							   receivers:receivers
							  isResponse:NO
					useSuppliedMessageID:YES
							 successSend:successSendCallback
								response:NULL
						 sendingProgress:sendingProgressCallback
					   receivingProgress:NULL
								 failure:failureCallback];
}

- (instancetype)initWithMessage:(YRBTMessage *)message
					  messageID:(message_id_t)suppliedMessageID
							MTU:(uint16_t)MTU
				  operationName:(NSString *)operationName
					  receivers:(NSArray <YRBTRemoteDevice *> *)receivers
					 isResponse:(BOOL)isResponse
		   useSuppliedMessageID:(BOOL)useSuppliedMessageID
					successSend:(YRBTSuccessSendCallback)successSendCallback
					   response:(YRBTResponseCallback)responseCallback
				sendingProgress:(YRBTProgressCallback)sendingProgressCallback
			  receivingProgress:(YRBTProgressCallback)receivingProgressCallback
						failure:(YRBTOperationFailureCallback)failureCallback {
	NSAssert(receivers.count > 0, @"No destination provided for message.");
	
	if (responseCallback) {
		NSAssert(receivers.count == 1, @"[YRBluetooth]: Current bluetooth version doesn't support multisend-multiresponse");
	}

	static message_id_t messageID = 0;
	
	if (!useSuppliedMessageID) {
		messageID++;
	}

	if (self = [super init]) {
		_messageID = useSuppliedMessageID ? suppliedMessageID : messageID;
		
		_timeoutInterval = kYRBTDefaultTimeoutInterval;
		_MTU = MTU;
		
		_message = message;
		
		_operationName = operationName;
		_mutableReceivers = [receivers mutableCopy];
		
        _isResponse = isResponse;
        
		_sendCallback = successSendCallback;
		_responseCallback = responseCallback;
		_sendingProgressCallback = sendingProgressCallback;
		_receivingProgressCallback = receivingProgressCallback;
		_failureCallback = failureCallback;
	}
	
	return self;
}

#pragma mark - Dynamic Properties

- (NSArray <__kindof YRBTRemoteDevice *> *)receivers {
	return [_mutableReceivers copy];
}

- (uint32_t)totalBytesToReceive {
	return self.buffer.header.messageSize;
}

- (_YRBTMessageBuffer *)buffer {
	_YRBTMessageBuffer *buffer = objc_getAssociatedObject(self, &@selector(buffer));
	
	if (!buffer) {
		buffer = [_YRBTMessageBuffer new];
		objc_setAssociatedObject(self, &@selector(buffer), buffer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return buffer;
}

#pragma mark - Public

- (void)cancel {
	if (self.status == kYRBTMessageOperationStatusSending ||
		self.status == kYRBTMessageOperationStatusReceiving) {
		[self.streamingService cancelOperation:self];
	}
}

#pragma mark - NSObject

- (NSString *)description {
    static NSArray *readableStatus = nil;
    
    if (!readableStatus) {
        readableStatus = @[@"Waiting",
                           @"Sending",
                           @"Receiving",
                           @"Finished",
                           @"Failed",
                           @"Cancelled",
                           @"Cancelled by remote"];
    }
    
	NSString *formatString = @"%@ Status: %@. Operation Name: %@. Message: %@. Receivers: %@. Expect response: %@. Sent: %d/%d. Received: %d/%d";
	return [NSString stringWithFormat:formatString, [super description], readableStatus[self.status], self.operationName, self.message, self.receivers, self.responseCallback ? @"YES" : @"NO", self.bytesSent, self.totalBytesToSend, self.bytesReceived, self.totalBytesToReceive];
}

@end
