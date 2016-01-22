//
//  EventObject.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp {
    if (self = [super init]) {
        _timestamp = timestamp;
    }
    
    return self;
}

@end
