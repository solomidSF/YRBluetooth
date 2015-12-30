//
//  YRBTRemoteRequest.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/13/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "YRBTRemoteDevice.h"
#import "YRBTMessage.h"
#import "YRBluetoothTypes.h"

typedef enum {
	kYRBTRemoteMessageRequestStatusReceiving,
	kYRBTRemoteMessageRequestStatusReceived,
	kYRBTRemoteMessageRequestStatusFailed,
	kYRBTRemoteMessageRequestStatusCancelled,
	kYRBTRemoteMessageRequestStatusCancelledByRemote
} YRBTRemoteMessageRequestStatus;

@interface YRBTRemoteMessageRequest : NSObject

@property (nonatomic, readonly) YRBTRemoteMessageRequestStatus status;

@property (nonatomic, readonly) __kindof YRBTRemoteDevice *sender;

@property (nonatomic, readonly) YRBTMessage *requestMessage;
@property (nonatomic, readonly) NSString *operationName;
@property (nonatomic, readonly) BOOL wantsResponse;

@property (nonatomic, readonly) uint32_t bytesReceived;
@property (nonatomic, readonly) uint32_t totalBytesToReceive;

@property (nonatomic, copy) YRBTWillReceiveRemoteRequestCallback willReceiveRequestCallback;
@property (nonatomic, copy) YRBTProgressCallback progressCallback;
@property (nonatomic, copy) YRBTReceivedRemoteRequestCallback receivedCallback;
@property (nonatomic, copy) YRBTRemoteRequestFailureCallback failureCallback;

- (void)cancel;

@end
