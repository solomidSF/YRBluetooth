//
//  _YRBTConnectionOperation.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/28/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Services
#import "_YRBTConnectionOperation.h"

// Devices
#import "YRBTServerDevice.h"

@implementation _YRBTConnectionOperation

+ (instancetype)operationWithServerDevice:(YRBTServerDevice *)device
                          successCallback:(YRBTSuccessfulConnectionCallback)successCallback
                          failureCallback:(YRBTFailureWithDeviceCallback)failureCallback {
    return [[self alloc] initWithDevice:device
                        successCallback:successCallback
                           failureBlock:failureCallback];
}

- (instancetype)initWithDevice:(YRBTServerDevice *)device
               successCallback:(YRBTSuccessfulConnectionCallback)successCallback
                  failureBlock:(YRBTFailureWithDeviceCallback)failureCallback {
    if (self = [super init]) {
        self.serverDevice = device;
        self.successCallback = successCallback;
        self.failureCallback = failureCallback;
    }
    
    return self;
}

@end
