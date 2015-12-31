//
// YRBTRemoteRequest.h
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
