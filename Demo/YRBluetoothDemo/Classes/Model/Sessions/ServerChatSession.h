//
//  ServerChatSession.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Entities
#import "ServerChat.h"
#import "ServerUser.h"
#import "Message.h"

// Events
#import "ConnectionEvent.h"
#import "NewMessageEvent.h"

@protocol ServerChatSessionObserver;

@interface ServerChatSession : NSObject

@property (nonatomic, readonly) NSArray <ServerUser *> *participants;
@property (nonatomic, readonly) ServerChat *chat;

#pragma mark - Session Management

+ (instancetype)sessionWithNickname:(NSString *)nickname;

- (void)endSession;

#pragma mark - Public

- (void)startAdvertising;
- (void)stopAdvertising;
- (void)sendMessage:(NSString *)message;

#pragma mark - Observing

- (void)addObserver:(id <ServerChatSessionObserver>)observer;
- (void)removeObserver:(id <ServerChatSessionObserver>)observer;

@end

@protocol ServerChatSessionObserver <NSObject>
@optional

- (void)chatSession:(ServerChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event;
- (void)chatSession:(ServerChatSession *)session userDidDisconnectWithEvent:(ConnectionEvent *)event;
- (void)chatSession:(ServerChatSession *)session userDidUpdateName:(ServerUser *)user;
- (void)chatSession:(ServerChatSession *)session didReceiveMessage:(NewMessageEvent *)event;

@end