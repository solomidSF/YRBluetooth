//
//  YRBTMessageOperation.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/15/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "YRBluetoothTypes.h"
#import "YRBTMessage.h"
#import "YRBTRemoteDevice.h"
#import "YRBTRemoteMessageRequest.h"

@interface YRBTMessageOperation : NSObject

extern NSTimeInterval const kYRBTDefaultTimeoutInterval;

typedef enum {
    kYRBTMessageOperationStatusWaiting,
    kYRBTMessageOperationStatusSending,
    kYRBTMessageOperationStatusReceiving,
    kYRBTMessageOperationStatusFinished,
    kYRBTMessageOperationStatusFailed,
    kYRBTMessageOperationStatusCancelled,
	kYRBTMessageOperationStatusCancelledByRemote,
} YRBTMessageOperationStatus;

@property (nonatomic, readonly) YRBTMessageOperationStatus status;
@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic) uint16_t MTU;

@property (nonatomic, readonly) YRBTMessage *message;
@property (nonatomic, readonly) YRBTMessage *responseMessage;

@property (nonatomic, readonly) NSString *operationName;
@property (nonatomic, readonly) NSArray <__kindof YRBTRemoteDevice *> *receivers;

@property (nonatomic, readonly) uint32_t bytesSent;
@property (nonatomic, readonly) uint32_t totalBytesToSend;

@property (nonatomic, readonly) uint32_t bytesReceived;
@property (nonatomic, readonly) uint32_t totalBytesToReceive;

@property (nonatomic, copy) YRBTSuccessSendCallback sendCallback;
@property (nonatomic, copy) YRBTResponseCallback responseCallback;
@property (nonatomic, copy) YRBTProgressCallback sendingProgressCallback;
@property (nonatomic, copy) YRBTProgressCallback receivingProgressCallback;
@property (nonatomic, copy) YRBTOperationFailureCallback failureCallback;

/**
 *  Tells if given operation is a response for some request.
 */
@property (nonatomic, readonly) BOOL isResponse;

/**
 *  Initializer to create operation.
 *  @param message Message to send.
 *  @param operationName Operation name that identify message purposes.
 *  @param receivers    Array of YRBTRemoteDevice instances that should receive given message.
 Note: For client only 1 receiver allowed.
 This may or not may change in the future.
 *  @param successSendCallback Optional callback that would be called when message will be delivered to receivers.
 *  @param responseCallback  Optional callback that would contain response message.
 Note: sending for several devices doesn't support response feature.
 This also may change in future releases (if someone really needs it).
 *  @param sendingProgressCallback Optional callback that would tell current sending progress.
 *  @param receivingProgressCallback Optional callback that tells response receiving progress.
 *  @param failureCallback Optional callback that tells about failure during sending process.
 *  @return Returns operation that can be passed to peer for processing.
 */
+ (instancetype)operationWithMessage:(YRBTMessage *)message
                                 MTU:(uint16_t)MTU
                       operationName:(NSString *)operationName
                           receivers:(NSArray <YRBTRemoteDevice *> *)receivers
                         successSend:(YRBTSuccessSendCallback)successSendCallback
                            response:(YRBTResponseCallback)responseCallback
                     sendingProgress:(YRBTProgressCallback)sendingProgressCallback
                   receivingProgress:(YRBTProgressCallback)receivingProgressCallback
                             failure:(YRBTOperationFailureCallback)failureCallback;

+ (instancetype)responseOperationForRemoteRequest:(YRBTRemoteMessageRequest *)request
										 response:(YRBTMessage *)responseMessage
                                              MTU:(uint16_t)MTU
                                      successSend:(YRBTSuccessSendCallback)successSend
                                  sendingProgress:(YRBTProgressCallback)progress
                                          failure:(YRBTOperationFailureCallback)failure;

+ (instancetype)operationWithFastCommand:(YRBTMessage *)message
                               receivers:(NSArray <YRBTRemoteDevice *> *)receivers
                             successSend:(YRBTSuccessSendCallback)successSendCallback
                         sendingProgress:(YRBTProgressCallback)sendingProgressCallback
                                 failure:(YRBTOperationFailureCallback)failureCallback;

- (void)cancel;

@end
