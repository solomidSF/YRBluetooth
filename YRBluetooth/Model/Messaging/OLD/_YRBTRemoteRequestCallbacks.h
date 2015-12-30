//
//  _BTMessageCallbacks.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/19/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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