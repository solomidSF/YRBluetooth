//
//  _BTMessageCallbacks.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/19/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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
