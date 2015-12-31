//
// _YRBTRemoteRequestCallbacks.h
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

#import "YRBluetoothTypes.h"

/**
 *  Class stores several callbacks inside.
 *  This class is used for registering callbacks for specific operations.
 */
@interface _YRBTRemoteRequestCallbacks : NSObject

@property (nonatomic, copy) YRBTWillReceiveRemoteRequestCallback willReceiveRequestCallback;
@property (nonatomic, copy) YRBTReceivedRemoteRequestCallback receivedRequestCallback;
@property (nonatomic, copy) YRBTProgressCallback progressCallback;
@property (nonatomic, copy) YRBTRemoteRequestFailureCallback failureCallback;
@property (nonatomic) BOOL isFinal;

+ (instancetype)callbacksWithWillReceiveRequestCallback:(YRBTWillReceiveRemoteRequestCallback)willReceiveRequest
								receivedRequestCallback:(YRBTReceivedRemoteRequestCallback)receivedRequest
							  receivingProgressCallback:(YRBTProgressCallback)progress
												failure:(YRBTRemoteRequestFailureCallback)failure
                                                  final:(BOOL)final;

@end