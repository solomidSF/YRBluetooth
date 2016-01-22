//
//  ConnectionEvent.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Events
#import "EventObject.h"

// Model
#import "User.h"

@class Chat;

typedef enum {
    kEventTypeConnected,
    kEventTypeDisconnected
} EventType;

@interface ConnectionEvent : EventObject

@property (nonatomic, readonly, weak) Chat *chat;
@property (nonatomic, readonly) User *user;
@property (nonatomic, readonly) EventType type;

- (instancetype)initWithChat:(Chat *)chat user:(User *)user eventType:(EventType)type timestamp:(NSTimeInterval)timestamp;

@end
