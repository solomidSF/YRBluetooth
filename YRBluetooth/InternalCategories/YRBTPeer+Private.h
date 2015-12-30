//
//  YRBTPeer+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/26/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTPeer.h"

@class _YRBTRegisteredCallbacks;

@interface YRBTPeer (Private)

@property (nonatomic, readonly) _YRBTRegisteredCallbacks *callbacks;

@end
