//
// _YRBTRemoteRequestCallbacks.m
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

#import "_YRBTRemoteRequestCallbacks.h"

@implementation _YRBTRemoteRequestCallbacks

+ (instancetype)callbacksWithWillReceiveRequestCallback:(YRBTWillReceiveRemoteRequestCallback)willReceiveRequest
								receivedRequestCallback:(YRBTReceivedRemoteRequestCallback)receivedRequest
							  receivingProgressCallback:(YRBTProgressCallback)progress
												failure:(YRBTRemoteRequestFailureCallback)failure
                                                  final:(BOOL)final {
	return [[self alloc] initWithWillReceiveRequestCallback:willReceiveRequest
									receivedRequestCallback:receivedRequest
								  receivingProgressCallback:progress
													failure:failure
                                                      final:final];
}

- (instancetype)initWithWillReceiveRequestCallback:(YRBTWillReceiveRemoteRequestCallback)willReceiveRequest
						   receivedRequestCallback:(YRBTReceivedRemoteRequestCallback)receivedRequest
						 receivingProgressCallback:(YRBTProgressCallback)progress
										   failure:(YRBTRemoteRequestFailureCallback)failure
                                             final:(BOOL)final {
	if (self = [super init]) {
		_willReceiveRequestCallback = willReceiveRequest;
		_receivedRequestCallback = receivedRequest;
		_progressCallback = progress;
		_failureCallback = failure;
        
        _isFinal = final;
	}
	
	return self;
}

@end
