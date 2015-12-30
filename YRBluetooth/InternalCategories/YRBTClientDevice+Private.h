//
//  BTClientDevice+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/23/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "YRBTClientDevice.h"

@class CBCentral;

@interface YRBTClientDevice (Private)

@property (nonatomic) CBCentral *central;
@property (nonatomic) BOOL didPerformHandshake;
@property (nonatomic) BOOL isPerformingHandshake;

@end