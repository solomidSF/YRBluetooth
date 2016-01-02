//
//  ServerChatSession.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Model
#import "Chat.h"
#import "User.h"
#import "Message.h"

@protocol ServerChatSessionObserver;

@interface ServerChatSession : NSObject

@property (nonatomic, readonly) Chat *chat;

+ (instancetype)sessionWithNickname:(NSString *)nickname;

- (void)endSession;

- (void)addObserver:(id <ServerChatSessionObserver>)observer;
- (void)removeObserver:(id <ServerChatSessionObserver>)observer;

@end

@protocol ServerChatSessionObserver <NSObject>
@optional

- (void)chatSession:(ServerChatSession *)session didLoadChat:(Chat *)chat;
- (void)chatSession:(ServerChatSession *)session userDidConnect:(User *)user;
- (void)chatSession:(ServerChatSession *)session userDidDisconnect:(User *)user;
- (void)chatSession:(ServerChatSession *)session userDidChangeName:(User *)user;
- (void)chatSession:(ServerChatSession *)session didReceiveNewMessage:(Message *)message;

@end