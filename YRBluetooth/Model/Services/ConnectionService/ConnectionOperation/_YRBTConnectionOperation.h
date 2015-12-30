//
//  _YRBTConnectionOperation.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "YRBluetoothTypes.h"

@interface _YRBTConnectionOperation : NSObject

@property (nonatomic) YRBTServerDevice *serverDevice;
@property (nonatomic, copy) YRBTSuccessfulConnectionCallback successCallback;
@property (nonatomic, copy) YRBTFailureWithDeviceCallback failureCallback;

+ (instancetype)operationWithServerDevice:(YRBTServerDevice *)device
                          successCallback:(YRBTSuccessfulConnectionCallback)successCallback
                          failureCallback:(YRBTFailureWithDeviceCallback)failureCallback;

@end