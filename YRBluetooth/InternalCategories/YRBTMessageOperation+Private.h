//
//  YRBTMessageOperation+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/15/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTMessageOperation.h"
#import "_YRBTMessageBuffer.h"
#import "_YRBTStreamingService.h"

@class YRBTRemoteMessageRequest;

@interface YRBTMessageOperation (Private)

@property (nonatomic, readonly) message_id_t messageID;

+ (instancetype)cancelOperationForOperation:(YRBTMessageOperation *)operation;
+ (instancetype)cancelOperationForRemoteRequest:(YRBTRemoteMessageRequest *)request;

@end

@interface YRBTMessageOperation (Mutable)

@property (nonatomic, weak) _YRBTStreamingService *streamingService;
@property (nonatomic) YRBTMessageOperationStatus status;
@property (nonatomic, readonly) NSMutableArray <YRBTRemoteDevice *> *mutableReceivers;

@property (nonatomic) uint32_t bytesSent;
@property (nonatomic) uint32_t totalBytesToSend;

@property (nonatomic) uint32_t bytesReceived;

@end

@interface YRBTMessageOperation (Receiving)

@property (nonatomic, readonly) _YRBTMessageBuffer *buffer;

@end

@interface YRBTMessageOperation (Multithreading)

@property (nonatomic) BOOL isDeallocating;
@property (nonatomic) BOOL isDeallocatingSilently;

@end

@interface YRBTMessageOperation (Timeout)

@property (nonatomic) NSTimer *timeoutTimer;

@end
