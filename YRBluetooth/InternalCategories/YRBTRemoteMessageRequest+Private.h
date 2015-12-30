//
//  YRBTRemoteMessageRequest+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/16/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

// Operations
#import "YRBTRemoteMessageRequest.h"

// Services
#import "_YRBTStreamingService.h"

// Messaging
#import "_YRBTMessageBuffer.h"
#import "_YRBTMessagingTypes.h"

@interface YRBTRemoteMessageRequest (PrivateInterface)

@property (nonatomic, readonly) message_id_t messageID;

- (instancetype)initWithHeaderChunk:(_YRBTHeaderChunk *)headerChunk
							 sender:(__kindof YRBTRemoteDevice *)sender;

@end

@interface YRBTRemoteMessageRequest (Mutable)

@property (nonatomic, weak) _YRBTStreamingService *streamingService;
@property (nonatomic) YRBTRemoteMessageRequestStatus status;
@property (nonatomic) __kindof YRBTRemoteDevice *sender;
@property (nonatomic) uint32_t bytesReceived;

@end

@interface YRBTRemoteMessageRequest (Timeout)

@property (nonatomic) NSTimer *timeoutTimer;

@end

@interface YRBTRemoteMessageRequest (Receiving)

@property (nonatomic, readonly) _YRBTMessageBuffer *buffer;

@end
