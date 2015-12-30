//
//  YRBTRemoteMessageRequest+Private.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/16/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

// Operations
#import "YRBTRemoteMessageRequest+Private.h"

// Obj-C
#import <objc/runtime.h>

@implementation YRBTRemoteMessageRequest (PrivateInterface)

#pragma mark - Init

- (instancetype)initWithHeaderChunk:(_YRBTHeaderChunk *)headerChunk
							 sender:(__kindof YRBTRemoteDevice *)sender {
	if (self = [super init]) {
		self.sender = sender;
		
		[self.buffer appendChunk:headerChunk];
	}
	
	return self;
}

#pragma mark - Dynamic Properties

- (message_id_t)messageID {
	return self.buffer.header.messageID;
}

@end

@implementation YRBTRemoteMessageRequest (Mutable)

@dynamic status;
@dynamic streamingService;
@dynamic sender;
@dynamic bytesReceived;

@end

@implementation YRBTRemoteMessageRequest (Timeout)

#pragma mark - Dynamic Properties

- (void)setTimeoutTimer:(NSTimer *)timeoutTimer {
	objc_setAssociatedObject(self, &@selector(timeoutTimer), timeoutTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)timeoutTimer {
	return objc_getAssociatedObject(self, &@selector(timeoutTimer));
}

@end

@implementation YRBTRemoteMessageRequest (Receiving)

@dynamic buffer;

@end
