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

@protocol ClientChatSessionActivityObserver;
@protocol ClientChatSessionObserver;

@interface ClientChatSession : NSObject

@property (nonatomic, readonly) NSArray <Chat *> *activeChats;
@property (nonatomic, readonly) NSString *nickname;

+ (instancetype)sessionWithNickname:(NSString *)nickname;

- (void)endSession;

- (void)addObserver:(id <ClientChatSessionObserver>)observer;
- (void)removeObserver:(id <ClientChatSessionObserver>)observer;

- (YRBTMessageOperation *)sendText:(NSString *)text
                            inChat:(Chat *)chat
                       withSuccess:(YRBTResponseCallback)success
                           failure:(YRBTOperationFailureCallback)failure;

@end

@protocol ClientChatSessionActivityObserver <NSObject>

@end

@protocol ClientChatSessionObserver <NSObject>

- (void)chatSession:(ClientChatSession *)session didSendMessage:(id)message inChat:(Chat *)chat;
- (void)chatSession:(ClientChatSession *)session failedToSendMessage:(id)message inChat:(Chat *)chat withError:(NSError *)error;

@end
