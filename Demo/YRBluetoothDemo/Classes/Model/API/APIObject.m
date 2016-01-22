//
//  APIObject.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "APIObject.h"

@implementation APIObject

- (instancetype)initWithMessage:(YRBTMessage *)message {
    if (self = [super init]) {
        _rawMessage = message;
    }
    
    return self;
}

@end
