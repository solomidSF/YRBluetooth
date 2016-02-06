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

// Errors
static NSString *const kYRBTErrorDomain = @"YRBTErrorDomain";

typedef NS_ENUM(int32_t, YRBTErrorCode) {
    /**
     *  Unknown error. No information available.
     */
    kYRBTErrorCodeUnknown,
    /**
     *  Bluetooth is off.
     */
    kYRBTErrorCodeBluetoothOff,
    /**
     *  The connection with the system service was momentarily lost, update imminent.
     */
    kYRBTErrorCodeBluetoothServiceReset,
    /**
     *  The platform doesn't support the Bluetooth Low Energy Central/Client role.
     */
    kYRBTErrorCodeBluetoothUnsupported,
    /**
     *  The application is not authorized to use the Bluetooth Low Energy Central/Client role.
     */
    kYRBTErrorCodeBluetoothUnathorized,
    /**
     *  Device isn't connected.
     */
    kYRBTErrorCodeNotConnected,
    /**
     *  Device is connected, but communication channel is not yet established.
     */
    kYRBTErrorCodeCommunicationChannelNotEstablished,
    /**
     *  Failed to establish communication channel between devices.
     */
    kYRBTErrorCodeFailedToEstablishCommunicationChannel,
    /**
     *  Failed to connect to device.
     */
    kYRBTErrorCodeFailedToConnect,
    /**
     *  Failed to connect to device because of timeout.
     */
    kYRBTErrorCodeConnectionTimeout,
    /**
     *  Disconnected from device.
     */
    kYRBTErrorCodeDisconnected,
    /**
     *  Failed to receive remote request.
     */
    kYRBTErrorCodeReceivingFailed,
    /**
     *  Received incorrect chunk layout.
     */
    kYRBTErrorCodeReceivedIncorrectChunk,
    /**
     *  Failed to complete message operation.
     */
    kYRBTErrorCodeSendingFailed,
    /**
     *  There is no receivers left to receive message.
     */
    kYRBTErrorCodeNoReceivers,
    /**
     *  Timeout for remote request.
     */
    kYRBTErrorCodeReceiveTimeout,
    /**
     *  Timeout for message operation.
     */
    kYRBTErrorCodeSendTimeout,
    /**
     *  Message operation was cancelled.
     */
    kYRBTErrorCodeSendCancelled,
    /**
     *  Message operation was cancelled by remote.
     */
    kYRBTErrorCodeSendCancelledByRemote,
};

// Bluetooth state
typedef enum {
    /**
     *  State unknown, update imminent.
     */
    kYRBluetoothStateUnknown,
    /**
     *  The connection with the system service was momentarily lost, update imminent.
     */
    kYRBluetoothStateResetting,
    /**
     *  The platform doesn't support the Bluetooth Low Energy Central/Client role.
     */
    kYRBluetoothStateUnsupported,
    /**
     *  The application is not authorized to use the Bluetooth Low Energy Central/Client role.
     */
    kYRBluetoothStateUnauthorized,
    /**
     *  Bluetooth is currently powered off.
     */
    kYRBluetoothStatePoweredOff,
    /**
     *  Bluetooth is currently powered on and available to use.
     */
    kYRBluetoothStatePoweredOn
} YRBluetoothState;

typedef void (^YRBluetoothStateChanged) (YRBluetoothState newState);

// Common
typedef void (^YRBTProgressCallback) (uint32_t currentBytes,
									  uint32_t totalBytes);

typedef void (^YRBTFailureCallback) (NSError *error);

// Sending
typedef void (^YRBTSuccessSendCallback) (YRBTMessageOperation *operation);

typedef void (^YRBTResponseCallback) (YRBTMessageOperation *operation, YRBTMessage *receivedMessage);

typedef void (^YRBTOperationFailureCallback) (YRBTMessageOperation *operation,
											  NSError *error);

// Receiving
typedef void (^YRBTWillReceiveRemoteRequestCallback) (YRBTRemoteMessageRequest *request);

typedef YRBTMessageOperation *(^YRBTReceivedRemoteRequestCallback) (YRBTRemoteMessageRequest *request,
																	YRBTMessage *requestMessage,
																	BOOL wantsResponse);

typedef void (^YRBTRemoteRequestFailureCallback) (YRBTRemoteMessageRequest *request, NSError *error);

// Scanning
typedef void (^YRBTFoundDevicesCallback) (NSArray *foundDevices);
typedef void (^YRBTContiniousScanCallback) (NSArray <YRBTServerDevice *> *devices);
typedef void (^YRBTSuccessfulConnectionCallback) (YRBTServerDevice *device);
typedef void (^YRBTFailureWithDeviceCallback) (YRBTRemoteDevice *device,
                                               NSError *error);

#endif
