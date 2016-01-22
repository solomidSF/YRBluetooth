//
//  NewMessageEvent.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Events
#import "NewMessageEvent.h"

// Model
#import "Chat.h"

// Cells
#import "MessageTableCell.h"
#import "MyMessageTableCell.h"

@implementation NewMessageEvent

#pragma mark - Init

- (instancetype)initWithChat:(Chat *)chat message:(Message *)message timestamp:(NSTimeInterval)timestamp {
    if (self = [super initWithTimestamp:timestamp]) {
        _chat = chat;
        _message = message;
    }
    
    return self;
}

#pragma mark - Dynamic Properties

- (NSString *)reuseIdentifier {
    if ([self.message.sender isEqual:self.chat.me]) {
        return NSStringFromClass([MyMessageTableCell class]);
    } else {
        return NSStringFromClass([MessageTableCell class]);
    }
}

@end
