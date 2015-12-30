//
// YRBluetoothTypes.h
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

#ifndef __YRBluetoothTypes__
#define __YRBluetoothTypes__

@import Foundation;

@class YRBTMessage;
@class YRBTRemoteDevice;
@class YRBTServerDevice;
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

typedef void (^YRBTFailureCallback) (NSError *error);

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

// === Scanning/Connection related === //
typedef void (^YRBTFoundDevicesCallback) (NSArray *foundDevices);
typedef void (^YRBTContiniousScanCallback) (YRBTServerDevice *device);
typedef void (^YRBTSuccessfulConnectionCallback) (YRBTServerDevice *device);
typedef void (^YRBTFailureWithDeviceCallback) (YRBTRemoteDevice *device,
                                               NSError *error);

// ====== //

#endif
