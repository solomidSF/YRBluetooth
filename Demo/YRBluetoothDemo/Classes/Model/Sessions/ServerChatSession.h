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

@property (nonatomic, readonly) NSArray <User *> *participants;
@property (nonatomic, readonly) Chat *chat;

#pragma mark - Session Management

+ (instancetype)sessionWithNickname:(NSString *)nickname;

- (void)endSession;

#pragma mark - Public

- (void)sendMessage:(NSString *)message;

#pragma mark - Observing

- (void)addObserver:(id <ServerChatSessionObserver>)observer;
- (void)removeObserver:(id <ServerChatSessionObserver>)observer;

@end

@protocol ServerChatSessionObserver <NSObject>
@optional

- (void)chatSession:(ServerChatSession *)session userDidConnect:(User *)user timestamp:(NSTimeInterval)timestamp;
- (void)chatSession:(ServerChatSession *)session userDidDisconnect:(User *)user timestamp:(NSTimeInterval)timestamp;
- (void)chatSession:(ServerChatSession *)session didReceiveNewMessage:(Message *)message;

@end