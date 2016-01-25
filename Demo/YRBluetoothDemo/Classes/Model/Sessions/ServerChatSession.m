//
//  ServerChatSession.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Model
#import "ServerChatSession.h"
#import "UsersPool.h"

// API
#import "SubscribeRequest.h"
#import "SubscribeResponse.h"
#import "UserConnection.h"
#import "NewMessage.h"

// Categories
#import "User+Private.h"
#import "Chat+Private.h"

// Components
#import "YRBluetooth.h"

// Auxiliary
#import "Config.h"

// 3rdParty
#import "GCDMulticastDelegate.h"

static NSString *const kSubscribeOperation = @"SBS";
static NSString *const kMessageOperation = @"MSG";
static NSString *const kUserEventOperation = @"UET";

@implementation ServerChatSession {
    YRBTServer *_server;
    User *_currentUserInfo;
    
    GCDMulticastDelegate <ServerChatSessionObserver> *_observers;
    
    UsersPool *_usersPool;
}

#pragma mark - Lifecycle

+ (instancetype)sessionWithNickname:(NSString *)nickname {
    return [[self alloc] initWithNickname:nickname];
}

- (instancetype)initWithNickname:(NSString *)nickname {
    if (self = [super init]) {
        _server = [[YRBTServer alloc] initWithAppID:kChatAppID peerName:nickname];
        _observers = (GCDMulticastDelegate <ServerChatSessionObserver> *)[GCDMulticastDelegate new];
        _chat = [ServerChat chatWithCreatorInfo:[self currentUserInfo]];
        
        [self setupServer];
    }
    
    return self;
}

- (void)dealloc {
    [self endSession];
}

- (void)endSession {
    [_server invalidate];
}

#pragma mark - Public

- (void)startAdvertising {
    [_server startBroadcasting];
}

- (void)stopAdvertising {
    [_server stopBroadcasting];
}

- (void)sendMessage:(NSString *)message {
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    Message *newMessage = [[Message alloc] initWithChat:self.chat sender:[self currentUserInfo] timestamp:timestamp messageText:message];
    
    [_observers chatSession:self didReceiveNewMessage:newMessage];
    
    NewMessage *event = [[NewMessage alloc] initWithSenderIdentifier:@"0"
                                                  isMessageByCreator:YES
                                                           timestamp:timestamp
                                                         messageText:message];
    
    [self scheduleMessage:event.rawMessage forOperation:kMessageOperation forUsers:[self subscribedUsers]];
}

#pragma mark - Observing

- (void)addObserver:(id <ServerChatSessionObserver>)observer {
    [_observers addDelegate:observer delegateQueue:dispatch_get_main_queue()];
}

- (void)removeObserver:(id <ServerChatSessionObserver>)observer {
    [_observers removeDelegate:observer];
}

#pragma mark - Private

- (void)setupServer {
    _usersPool = [UsersPool new];
    
    __typeof(self) __weak weakSelf = self;
    
    _server.deviceDisconnectCallback = ^(YRBTRemoteDevice *device) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            User *disconnectedUser = [strongSelf->_usersPool userForDevice:device];

            disconnectedUser.isSubscribed = NO;
            [disconnectedUser.messageQueue removeAllObjects];
            
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            [strongSelf->_observers chatSession:strongSelf userDidDisconnect:disconnectedUser timestamp:timestamp];
            
            UserConnection *connection = [[UserConnection alloc] initWithEventType:kUserConnectionTypeDisconnected
                                                                              user:disconnectedUser
                                                                         timestamp:timestamp];
            
            [strongSelf scheduleMessage:connection.rawMessage forOperation:kUserEventOperation forUsers:[strongSelf subscribedUsers]];
        }
    };
    
    // Register callbacks for SUBSCRIBE operation.
    [_server registerWillReceiveRequestCallback:^(YRBTRemoteMessageRequest *request) {
        NSLog(@"Will receive request: %@ for 'SUBSCRIBE' operation", request);
    } didReceiveRequestCallback:^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                        YRBTMessage *requestMessage,
                                                        BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (!strongSelf) {
            return nil;
        }
        
        SubscribeRequest *subscribeRequest = [[SubscribeRequest alloc] initWithName:[requestMessage stringValue]];
        User *subscribedUser = [strongSelf->_usersPool userForDevice:request.sender];
        
        NSMutableArray *usersToNotify = [[strongSelf subscribedUsers] mutableCopy];
        [usersToNotify removeObject:subscribedUser];
        
        if (!subscribedUser.isSubscribed) {
            subscribedUser.name = subscribeRequest.subscriberName;
            subscribedUser.isSubscribed = YES;
            
            // Notify users about connection event
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            [strongSelf->_observers chatSession:strongSelf userDidConnect:subscribedUser timestamp:timestamp];
            
            UserConnection *connection = [[UserConnection alloc] initWithEventType:kUserConnectionTypeConnected
                                                                              user:subscribedUser
                                                                         timestamp:timestamp];
            
            [strongSelf scheduleMessage:connection.rawMessage forOperation:kUserEventOperation forUsers:[usersToNotify copy]];
        }
        
        User *currentUserInfo = [strongSelf currentUserInfo];
        [usersToNotify addObject:currentUserInfo];
        
        NSArray *chatMembers = [usersToNotify copy];
        
        SubscribeResponse *response = [[SubscribeResponse alloc] initWithSubscribedUserInfo:subscribedUser
                                                                                 otherUsers:chatMembers];

        return [YRBTMessageOperation responseOperationForRemoteRequest:request
                                                              response:response.rawMessage
                                                                   MTU:128
                                                           successSend:^(YRBTMessageOperation *operation) {
                                                               NSLog(@"Successfuly responded to request! %@", operation);
                                                           } sendingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                                                               NSLog(@"Response progress: %d/%d", currentBytes, totalBytes);
                                                           } failure:^(YRBTMessageOperation *operation, NSError *error) {
                                                               NSLog(@"Failed to respond %@. ERR: %@", operation, error);
                                                           }];
    } receivingProgressCallback:^(uint32_t currentBytes, uint32_t totalBytes) {
        NSLog(@"RCV progress: %d/%d", currentBytes, totalBytes);
    } failedToReceiveCallback:^(YRBTRemoteMessageRequest *request, NSError *error) {
        NSLog(@"Failed to rcv 'SBS' request from client: %@, error: %@", request, error);
    } forOperation:kSubscribeOperation];
    
    [_server registerWillReceiveRequestCallback:^(YRBTRemoteMessageRequest *request) {
        NSLog(@"Will receive request: %@ for 'NEW MESSAGE' operation", request);
    } didReceiveRequestCallback:^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                        YRBTMessage *requestMessage,
                                                        BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (!strongSelf) {
            return nil;
        }
        
        User *sender = [strongSelf->_usersPool userForDevice:request.sender];
        NSString *messageText = [requestMessage stringValue];
        
        Message *message = [[Message alloc] initWithChat:strongSelf.chat
                                                  sender:sender
                                               timestamp:[NSDate date].timeIntervalSince1970
                                             messageText:messageText];
        
        [strongSelf.chat.mutableMessages addObject:message];
        
        [strongSelf->_observers chatSession:strongSelf didReceiveNewMessage:message];
        
        NewMessage *event = [[NewMessage alloc] initWithSenderIdentifier:sender.identifier
                                                      isMessageByCreator:NO
                                                               timestamp:message.timestamp
                                                             messageText:messageText];
        
        NSMutableArray *usersToNotify = [[strongSelf subscribedUsers] mutableCopy];
        [usersToNotify removeObject:sender];
        
        [strongSelf scheduleMessage:event.rawMessage forOperation:kMessageOperation forUsers:usersToNotify];
        
        return [YRBTMessageOperation responseOperationForRemoteRequest:request
                                                              response:event.rawMessage
                                                                   MTU:128
                                                           successSend:^(YRBTMessageOperation *operation) {
                                                               NSLog(@"Successfuly responded to request! %@", operation);
                                                           } sendingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                                                               NSLog(@"Response progress: %d/%d", currentBytes, totalBytes);
                                                           } failure:^(YRBTMessageOperation *operation, NSError *error) {
                                                               NSLog(@"Failed to respond %@. ERR: %@", operation, error);
                                                           }];
    } receivingProgressCallback:^(uint32_t currentBytes, uint32_t totalBytes) {
        NSLog(@"RCV progress: %d/%d", currentBytes, totalBytes);
    } failedToReceiveCallback:^(YRBTRemoteMessageRequest *request, NSError *error) {
        NSLog(@"Failed to rcv 'MSG' request from client: %@, error: %@", request, error);
    } forOperation:kMessageOperation];
}

- (NSArray <User *> *)subscribedUsers {
    NSMutableArray *users = [NSMutableArray new];
    
    for (YRBTClientDevice *device in _server.connectedDevices) {
        User *user = [_usersPool userForDevice:device];
        
        if (user.isSubscribed) {
            [users addObject:[_usersPool userForDevice:device]];
        }
    }
    
    return [users copy];
}

- (User *)currentUserInfo {
    if (!_currentUserInfo) {
        _currentUserInfo = [[User alloc] initWithIdentifier:@"0" name:_server.peerName isChatOwner:YES connected:YES];
    }
    
    return _currentUserInfo;
}

// TODO: Should be a part of framework
- (void)scheduleMessage:(YRBTMessage *)message forOperation:(NSString *)operationName forUsers:(NSArray <User *> *)users {
    NSMutableArray *usersThatShouldReceiveImmediately = [NSMutableArray new];
    NSDictionary *messageMeta = @{kMessageQueueMessageKey : message,
                                  kMessageQueueOperationNameKey : operationName};
    
    for (User *user in users) {
        if (user.messageQueue.count == 0) {
            [usersThatShouldReceiveImmediately addObject:user];
        }
        
        [user.messageQueue addObject:messageMeta];
    }
    
    if (usersThatShouldReceiveImmediately.count > 0) {
        [_server broadcastMessage:message
                    operationName:operationName
                        toClients:[usersThatShouldReceiveImmediately valueForKey:@"device"]
                      withSuccess:^(YRBTMessageOperation *op) {
                          NSLog(@"Finished op: %@", op);
                          [self removeMessageMeta:messageMeta fromQueueForUsers:usersThatShouldReceiveImmediately];
                          [self processPendingMessagesForUsers:usersThatShouldReceiveImmediately];
                      } sendingProgress:^(uint32_t currentBytes, uint32_t totalBytes) {
                          NSLog(@"OP Progress: %d/%d", currentBytes, totalBytes);
                      } failure:^(YRBTMessageOperation *op, NSError *error) {
                          NSLog(@"Failed to finish operation: %@ because of error: %@", op, error);
                          [self removeMessageMeta:messageMeta fromQueueForUsers:usersThatShouldReceiveImmediately];
                          [self processPendingMessagesForUsers:usersThatShouldReceiveImmediately];
                      }];
    }
}

- (void)removeMessageMeta:(NSDictionary *)messageMeta fromQueueForUsers:(NSArray <User *> *)users {
    for (User *user in users) {
        [user.messageQueue removeObject:messageMeta];
    }
}

- (void)processPendingMessagesForUsers:(NSArray <User *> *)users {
    for (User *user in users) {
        if (user.messageQueue.count > 0) {
            YRBTMessage *message = [user.messageQueue firstObject][kMessageQueueMessageKey];
            NSString *operationName = [user.messageQueue firstObject][kMessageQueueOperationNameKey];
            
            [self scheduleMessage:message forOperation:operationName forUsers:@[user]];
        }
    }
}

@end
