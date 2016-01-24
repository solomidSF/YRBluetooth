//
//  SubscribeRequest.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "SubscribeRequest.h"

@implementation SubscribeRequest

- (instancetype)initWithName:(NSString *)name {
    YRBTMessage *message = [YRBTMessage messageWithString:name];
    
    if (self = [super initWithMessage:message]) {
        _subscriberName = name;
    }
    
    return self;
}

@end
