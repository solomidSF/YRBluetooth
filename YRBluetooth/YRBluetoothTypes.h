//
//  YRBTTypes.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/23/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#ifndef __YRBluetoothTypes__
#define __YRBluetoothTypes__

@import Foundation;

@class YRBTMessage;
@class YRBTRemoteDevice;
@class YRBTServerDevice;
@class YRBTReceivingMessageOperation;
@class YRBTSendingMessageOperation;
@class YRBTMessageOperation;
@class YRBTRemoteMessageRequest;

static NSString *const kYRBTErrorDomain = @"YRBTErrorDomain";

typedef enum {
    // Bluetooth is not enabled.
    kYRBTErrorCodeBluetoothOff,
    // Device isn't connected.
    kYRBTErrorCodeNotConnected,
    // Failed to establish communication channel.
    kYRBTErrorCodeFailedToEstablishCommunicationChannel,
    // Couldn't connect to server.
    kYRBTErrorCodeFailedToConnect,
    // Failed to connect to server due to timeout.
    kYRBTErrorCodeConnectionTimeout,
    // Disconnected from server.
    kYRBTErrorCodeDisconnected,
    // Failed to receive message.
    kYRBTErrorCodeReceivingFailed,
    // Failed to send message.
    kYRBTErrorCodeSendingFailed,
    // Receiving timeout.
    kYRBTErrorCodeReceiveTimeout,
    // Send timeout.
    kYRBTErrorCodeSendTimeout,
    // Timeout for connect request.
    YRBTErrorCodeConnectionTimeout
} YRBTErrorCode;

// === Common === //
typedef void (^YRBTProgressCallback) (uint32_t currentBytes,
									  uint32_t totalBytes);

// === Sending-related === //
typedef void (^YRBTSuccessSendCallback) (YRBTMessageOperation *operation);

typedef void (^YRBTResponseCallback) (YRBTMessageOperation *operation, YRBTMessage *receivedMessage);

typedef void (^YRBTOperationFailureCallback) (YRBTMessageOperation *operation,
											  NSError *error);

// === Receiving-related === //
typedef void (^YRBTWillReceiveRemoteRequestCallback) (YRBTRemoteMessageRequest *request);

typedef YRBTMessageOperation *(^YRBTReceivedRemoteRequestCallback) (YRBTRemoteMessageRequest *request,
																	YRBTMessage *requestMessage,
																	BOOL wantsResponse);

typedef void (^YRBTRemoteRequestFailureCallback) (YRBTRemoteMessageRequest *request, NSError *error);

// TODO: DEPRECATED.



typedef void (^YRBTWillReceiveMessageCallback) (YRBTReceivingMessageOperation *operation);

typedef void (^YRBTFailureCallback) (NSError *error);

typedef void (^YRBTFailureWithReceiveOperationCallback) (YRBTReceivingMessageOperation *operation,
                                                         NSError *error);

typedef void (^YRBTReceivedMessageCallback) (YRBTReceivingMessageOperation *operation,
                                             YRBTMessage *incomingMessage,
                                             YRBTMessage **responseMessage,
                                             BOOL wantsResponse,
                                             YRBTSuccessSendCallback *successSend,
                                             YRBTFailureCallback *sendFailure,
                                             YRBTProgressCallback *sendProgress);


// TODO: DEPRECATED
typedef void (^YRBTSuccessSendWithDeviceCallback) (YRBTRemoteDevice *receiver);

typedef void (^YRBTSuccessSendWithDevicesCallback) (NSArray *receivers);

typedef void (^YRBTFailureWithDevicesCallback) (NSArray *devices,
                                                NSError *error);

typedef void (^YRBTFailureWithDeviceCallback) (YRBTRemoteDevice *device,
                                               NSError *error);

// === Scanning/Connection related === //

typedef void (^YRBTFoundDevicesCallback) (NSArray *foundDevices);
typedef void (^YRBTContiniousScanCallback) (YRBTServerDevice *device);
typedef void (^YRBTSuccessfulConnectionCallback) (YRBTServerDevice *device);

// ====== //

#endif
