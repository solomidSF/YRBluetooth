//
//  ChatSession.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "ClientChatSession.h"
#import "SubscribeRequest.h"
#import "SubscribeResponse.h"

// API
#import "NewMessage.h"
#import "UserConnection.h"

// Components
#import "YRBluetooth.h"

// Categories
#import "Chat+Private.h"
#import "User+Private.h"

// 3rdParty
#import "GCDMulticastDelegate.h"

// Auxiliary
#import "Config.h"

static NSString *const kSubscribeOperation = @"SBS";
static NSString *const kMessageOperation = @"MSG";
static NSString *const kUserEventOperation = @"UET";

@implementation ClientChatSession {
    YRBTClient *_client;
    
    NSMutableArray <ClientChat *> *_savedChats;
    
    GCDMulticastDelegate <ClientChatSessionObserver> *_observers;
}

#pragma mark - Lifecycle

+ (instancetype)sessionWithNickname:(NSString *)nickname {
    return [[self alloc] initWithNickname:nickname];
}

- (instancetype)initWithNickname:(NSString *)nickname {
    if (self = [super init]) {
        _nickname = nickname;
        
        _client = [[YRBTClient alloc] initWithAppID:kChatAppID peerName:self.nickname];
        
        _observers = (GCDMulticastDelegate <ClientChatSessionObserver> *)[GCDMulticastDelegate new];
        
        [self setupClient];
    }
    
    return self;
}

- (void)dealloc {
    [self endSession];
}

- (void)endSession {
    [_client invalidate];
}

#pragma mark - Scanning

- (void)startScanningForChatsWithSuccess:(ChatScanningCallback)scanningCallback failure:(ChatScanningFailureCallback)failure {
    [_client scanForDevicesWithCallback:^(NSArray <YRBTServerDevice *> *devices) {
        NSMutableArray <Chat *> *chats = [NSMutableArray new];
        
        for (YRBTServerDevice *device in devices) {
            [chats addObject:[self chatForRemoteDevice:device]];
        }
        
        !scanningCallback ? : scanningCallback([chats copy]);
    } failureCallback:failure];
}

- (void)stopScanningForChats {
    [_client stopScanningForDevices];
}

#pragma mark - Connecting

- (void)connectToChat:(ClientChat *)chat
          withSuccess:(ChatConnectionSuccessCallback)success
              failure:(ChatConnectionFailureCallback)failure {
    
    if (!chat.device.connectionStateCallback) {
        __typeof(self) __weak weakSelf = self;
        __typeof(ClientChat *) __weak weakChat = chat;
        
        chat.device.connectionStateCallback = ^(YRBTServerDevice *device, YRBTConnectionState newState) {
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            __typeof(ClientChat *) __strong strongChat = weakChat;
            
            if (strongSelf && strongChat) {
                [strongSelf->_observers chatSession:strongSelf chatStateDidUpdate:strongChat];
            }
        };
    }
    
    [_client connectToDevice:chat.device withSuccess:^(YRBTServerDevice *device) {
        SubscribeRequest *request = [[SubscribeRequest alloc] initWithName:_client.peerName];
        
        [_client sendMessage:request.rawMessage
                    toServer:device
               operationName:kSubscribeOperation
                 successSend:^(YRBTMessageOperation *operation) {
                     NSLog(@"Did send subscribe request! %@", operation);
                 } response:^(YRBTMessageOperation *operation, YRBTMessage *receivedMessage) {
                     NSLog(@"Received subscibe request response: %@. Operation: %@", [receivedMessage dictionaryValue], operation);
                     SubscribeResponse *response = [[SubscribeResponse alloc] initWithMessage:receivedMessage];
                     
                     chat.me = response.subscribedUser;
                     chat.creator = response.creator;
                     chat.mutableMembers = response.otherUsers ? [response.otherUsers mutableCopy] : [NSMutableArray new];
                     
                     // In case of reconnection clear all existing messages.
                     [chat.mutableMessages removeAllObjects];
                     
                     !success ? : success(chat, response.subscribedUser);
                     
                     [_observers chatSession:self didConnectToChat:chat];
                 } sendingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                     NSLog(@"SUB REQ Progress: %d/%d", currentBytes, totalBytes);
                 } receivingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                     NSLog(@"SUB RESP Progress: %d/%d", currentBytes, totalBytes);
                 } failure:^(YRBTMessageOperation *operation, NSError *error) {
                     [self disconnectFromChat:chat];
                     
                     !failure ? : failure(error);
                     
                     [_observers chatSession:self didFailToConnectToChat:chat withError:error];
                 }];
        
    } failure:^(YRBTRemoteDevice *device, NSError *error) {
        !failure ? : failure(error);
        
        [_observers chatSession:self didFailToConnectToChat:chat withError:error];
    }];
}

- (void)disconnectFromChat:(ClientChat *)chat {
    [_client disconnectFromDevice:chat.device];
}

#pragma mark - Sending

- (YRBTMessageOperation *)sendText:(NSString *)text
                            inChat:(ClientChat *)chat
                       withSuccess:(ChatSuccessSendCallback)success
                           failure:(YRBTOperationFailureCallback)failure {
    // TODO: Don't return message operation
    YRBTMessage *message = [YRBTMessage messageWithString:text];
    
    return [_client sendMessage:message
                       toServer:chat.device
                  operationName:kMessageOperation
                    successSend:^(YRBTMessageOperation *operation) {
                        NSLog(@"Did send!");
                    } response:^(YRBTMessageOperation *operation, YRBTMessage *receivedMessage) {
                        NewMessage *event = [[NewMessage alloc] initWithMessage:receivedMessage];
                        User *sender = chat.me;
                        
                        Message *newMessage = [[Message alloc] initWithChat:chat
                                                                     sender:sender
                                                                  timestamp:event.timestamp
                                                                messageText:event.messageText];
                        
                        [_observers chatSession:self didSendMessage:newMessage inChat:chat];
                        
                        !success ? : success(newMessage);
                    } sendingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                        NSLog(@"MSG Progress: %d/%d", currentBytes, totalBytes);
                    } receivingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                        NSLog(@"RCV Progress: %d/%d", currentBytes, totalBytes);
                    } failure:failure];
}

#pragma mark - Observing

- (void)addObserver:(id <ClientChatSessionObserver>)observer {
    [_observers addDelegate:observer delegateQueue:dispatch_get_main_queue()];
}

- (void)removeObserver:(id <ClientChatSessionObserver>)observer {
    [_observers removeDelegate:observer delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - Private

- (void)setupClient {
    __typeof(self) __weak weakSelf = self;
    _savedChats = [NSMutableArray new];
    
    // Register callbacks for user event operation
    [_client registerWillReceiveRequestCallback:^(YRBTRemoteMessageRequest *request) {
        NSLog(@"Will receive request: %@ for 'USR EVENT' operation", request);
    } didReceiveRequestCallback:^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                        YRBTMessage *requestMessage,
                                                        BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (!strongSelf) {
            return nil;
        }
        
        UserConnection *connection = [[UserConnection alloc] initWithMessage:requestMessage];
        
        ClientChat *chat = [strongSelf chatForRemoteDevice:request.sender];
        
        User *user = [strongSelf userWithIdentifier:connection.userIdentifier fromChat:chat];
        user.name = connection.userName;
        user.isConnected = connection.connected;
        
        if (!user) {
            user = [[User alloc] initWithIdentifier:connection.userIdentifier
                                               name:connection.userName
                                        isChatOwner:NO
                                          connected:connection.connected];
            
            [chat.mutableMembers addObject:user];
        }

        switch (connection.eventType) {
            case kUserConnectionTypeConnected:
                [strongSelf->_observers chatSession:strongSelf userDidConnect:user toChat:chat timestamp:connection.timestamp];
                break;
            case kUserConnectionTypeDisconnected:
                [strongSelf->_observers chatSession:strongSelf userDidDisconnect:user fromChat:chat timestamp:connection.timestamp];
                break;
            default:
                break;
        }
        
        return nil;
    } receivingProgressCallback:^(uint32_t currentBytes, uint32_t totalBytes) {
        NSLog(@"RCV progress: %d/%d", currentBytes, totalBytes);
    } failedToReceiveCallback:^(YRBTRemoteMessageRequest *request, NSError *error) {
        NSLog(@"Failed to rcv 'USR EVNT OPERATION' request from client: %@, error: %@", request, error);
    } forOperation:kUserEventOperation];
    
    // Register callbacks for message operation
    [_client registerWillReceiveRequestCallback:^(YRBTRemoteMessageRequest *request) {
        NSLog(@"Will receive request: %@ for 'MSG' operation", request);
    } didReceiveRequestCallback:^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                        YRBTMessage *requestMessage,
                                                        BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (!strongSelf) {
            return nil;
        }
        
        NewMessage *event = [[NewMessage alloc] initWithMessage:requestMessage];
        ClientChat *chat = [strongSelf chatForRemoteDevice:request.sender];
        
        User *sender = nil;
        if (event.isMessageByChatCreator) {
            sender = [strongSelf chatForRemoteDevice:request.sender].creator;
        } else {
            sender = [strongSelf userWithIdentifier:event.senderIdentifier fromChat:[strongSelf chatForRemoteDevice:request.sender]];
        }
        
        Message *newMessage = [[Message alloc] initWithChat:chat sender:sender timestamp:event.timestamp messageText:event.messageText];
        
        [chat.mutableMessages addObject:newMessage];
        
        [strongSelf->_observers chatSession:strongSelf didReceiveMessage:newMessage inChat:chat];
        
        return nil;
    } receivingProgressCallback:^(uint32_t currentBytes, uint32_t totalBytes) {
        NSLog(@"Response progress: %d/%d", currentBytes, totalBytes);
    } failedToReceiveCallback:^(YRBTRemoteMessageRequest *request, NSError *error) {
        NSLog(@"Failed to respond %@. ERR: %@", request, error);
    } forOperation:kMessageOperation];
}

- (ClientChat *)chatForRemoteDevice:(YRBTServerDevice *)device {
    for (ClientChat *chat in _savedChats) {
        if ([chat.device isEqual:device]) {
            return chat;
        }
    }

    ClientChat *chat = [ClientChat chatForDevice:device];
    
    [_savedChats addObject:chat];
    
    return chat;
}

- (User *)userWithIdentifier:(NSString *)identifier fromChat:(ClientChat *)chat {
    for (User *candidate in chat.members) {
        if ([candidate.identifier isEqualToString:identifier]) {
            return candidate;
        }
    }
    
    if ([chat.me.identifier isEqualToString:identifier]) {
        return chat.me;
    }
    
    if ([chat.creator.identifier isEqualToString:identifier]) {
        return chat.creator;
    }
    
    return nil;
}

@end
