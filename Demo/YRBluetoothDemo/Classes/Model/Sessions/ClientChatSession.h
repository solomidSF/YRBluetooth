//
//  ChatSession.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Model
#import "Chat.h"

// Components
#import "YRBluetooth.h"

typedef void (^ChatScanningCallback) (NSArray <Chat *> *chats);
typedef void (^ChatScanningFailureCallback) (NSError *error);

typedef void (^ChatConnectionSuccessCallback) (Chat *chat, User *userInfo);
typedef void (^ChatConnectionFailureCallback) (NSError *error);

@protocol ClientChatSessionObserver;

@interface ClientChatSession : NSObject

@property (nonatomic, readonly) NSArray <Chat *> *activeChats;
@property (nonatomic, readonly) NSString *nickname;

#pragma mark - Session Management

+ (instancetype)sessionWithNickname:(NSString *)nickname;
- (void)endSession;

#pragma mark - Scanning

- (void)startScanningForChatsWithSuccess:(ChatScanningCallback)scanningCallback
                                 failure:(ChatScanningFailureCallback)failure;
- (void)stopScanningForChats;

#pragma mark - Chats

- (void)connectToChat:(Chat *)chat
          withSuccess:(ChatConnectionSuccessCallback)success
              failure:(ChatConnectionFailureCallback)failure;

- (void)disconnectFromChat:(Chat *)chat;

#pragma mark - Sending

- (YRBTMessageOperation *)sendText:(NSString *)text
                            inChat:(Chat *)chat
                       withSuccess:(YRBTResponseCallback)success
                           failure:(YRBTOperationFailureCallback)failure;
#pragma mark - Observing

- (void)addObserver:(id <ClientChatSessionObserver>)observer;
- (void)removeObserver:(id <ClientChatSessionObserver>)observer;

@end

@protocol ClientChatSessionObserver <NSObject>

- (void)chatSession:(ClientChatSession *)session reportsNearbyChats:(NSArray <Chat *> *)chats;
- (void)chatSession:(ClientChatSession *)session failedToScanForNearbyChatsWithError:(NSError *)error;

- (void)chatSession:(ClientChatSession *)session didConnectToChat:(Chat *)chat;
- (void)chatSession:(ClientChatSession *)session didFailToConnectToChat:(Chat *)chat withError:(NSError *)error;

- (void)chatSession:(ClientChatSession *)session userDidConnect:(User *)user toChat:(Chat *)chat timestamp:(NSTimeInterval)timestamp;
- (void)chatSession:(ClientChatSession *)session userDidDisconnect:(User *)user fromChat:(Chat *)chat timestamp:(NSTimeInterval)timestamp;

- (void)chatSession:(ClientChatSession *)session didSendMessage:(Message *)message inChat:(Chat *)chat;
- (void)chatSession:(ClientChatSession *)session didReceiveMessage:(Message *)message inChat:(Chat *)chat;
- (void)chatSession:(ClientChatSession *)session failedToSendMessage:(Message *)message inChat:(Chat *)chat withError:(NSError *)error;

@end
