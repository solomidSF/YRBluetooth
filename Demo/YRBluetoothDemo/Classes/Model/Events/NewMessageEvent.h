//
//  NewMessageEvent.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Events
#import "EventObject.h"

// Model
#import "Message.h"

@class Chat;

@interface NewMessageEvent : EventObject

@property (nonatomic, readonly, weak) __kindof Chat *chat;
@property (nonatomic, readonly) Message *message;

- (instancetype)initWithChat:(__kindof Chat *)chat message:(Message *)message timestamp:(NSTimeInterval)timestamp;

@end
