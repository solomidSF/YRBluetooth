//
//  ChatSession.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Entities
#import "ClientChat.h"
#import "ClientUser.h"

// Events
#import "ConnectionEvent.h"
#import "NewMessageEvent.h"

// Components
#import "YRBluetooth.h"

typedef void (^ChatScanningCallback) (NSArray <ClientChat *> *chats);
typedef void (^ChatScanningFailureCallback) (NSError *error);

typedef void (^ChatSuccessSendCallback) (NewMessageEvent *message);

typedef void (^ChatConnectionSuccessCallback) (ClientChat *chat, ClientUser *userInfo);
typedef void (^ChatConnectionFailureCallback) (NSError *error);

@protocol ClientChatSessionObserver;

@interface ClientChatSession : NSObject

@property (nonatomic, readonly) NSArray <ClientChat *> *activeChats;
@property (nonatomic, readonly) NSString *nickname;

#pragma mark - Session Management

+ (instancetype)sessionWithNickname:(NSString *)nickname;

- (void)endSession;

#pragma mark - Scanning

- (void)startScanningForChatsWithSuccess:(ChatScanningCallback)scanningCallback
                                 failure:(ChatScanningFailureCallback)failure;
- (void)stopScanningForChats;

#pragma mark - Chats

- (void)connectToChat:(ClientChat *)chat
          withSuccess:(ChatConnectionSuccessCallback)success
              failure:(ChatConnectionFailureCallback)failure;

- (void)disconnectFromChat:(ClientChat *)chat;

#pragma mark - Sending

- (YRBTMessageOperation *)sendText:(NSString *)text
                            inChat:(ClientChat *)chat
                       withSuccess:(ChatSuccessSendCallback)success
                           failure:(YRBTOperationFailureCallback)failure;
#pragma mark - Observing

- (void)addObserver:(id <ClientChatSessionObserver>)observer;
- (void)removeObserver:(id <ClientChatSessionObserver>)observer;

@end

@protocol ClientChatSessionObserver <NSObject>
@optional
- (void)chatSession:(ClientChatSession *)session reportsNearbyChats:(NSArray <ClientChat *> *)chats;
- (void)chatSession:(ClientChatSession *)session failedToScanForNearbyChatsWithError:(NSError *)error;

- (void)chatSession:(ClientChatSession *)session chatStateDidUpdate:(ClientChat *)chat;
- (void)chatSession:(ClientChatSession *)session didConnectToChat:(ClientChat *)chat;
- (void)chatSession:(ClientChatSession *)session didFailToConnectToChat:(ClientChat *)chat withError:(NSError *)error;

- (void)chatSession:(ClientChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event inChat:(ClientChat *)chat;
- (void)chatSession:(ClientChatSession *)session userDidDisconnectWithEvent:(ConnectionEvent *)event inChat:(ClientChat *)chat;
- (void)chatSession:(ClientChatSession *)session userDidUpdateName:(ClientUser *)user inChat:(ClientChat *)chat;

- (void)chatSession:(ClientChatSession *)session didSendMessage:(NewMessageEvent *)event inChat:(ClientChat *)chat;
- (void)chatSession:(ClientChatSession *)session didReceiveMessage:(NewMessageEvent *)event inChat:(ClientChat *)chat;
- (void)chatSession:(ClientChatSession *)session failedToSendMessage:(NSString *)text
             inChat:(ClientChat *)chat withError:(NSError *)error;

@end
