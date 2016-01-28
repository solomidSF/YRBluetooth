//
//  Chat.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Model
#import "User.h"
#import "Message.h"

typedef enum {
    kChatStateDisconnected,
    kChatStateConnecting,
    kChatStateConnected
} ChatState;

@interface Chat : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) __kindof User *me;
@property (nonatomic, readonly) ChatState state;
@property (nonatomic, readonly) NSArray <__kindof User *> *members;
@property (nonatomic, readonly) NSArray <Message *> *messages;

@end