//
//  APIObject.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

#import "YRBluetooth.h"

@interface APIObject : NSObject

@property (nonatomic, readonly) YRBTMessage *rawMessage;

- (instancetype)initWithMessage:(YRBTMessage *)message;

@end
