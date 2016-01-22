//
//  Message.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithChat:(Chat *)chat sender:(User *)sender timestamp:(NSTimeInterval)timestamp messageText:(NSString *)text {
    if (self = [super init]) {
        _chat = chat;
        _sender = sender;
        _timestamp = timestamp;
        _messageText = text;
    }
    
    return self;
}

@end
