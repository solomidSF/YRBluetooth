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

// API
#import "SubscribeRequest.h"
#import "SubscribeResponse.h"
#import "UserConnection.h"
#import "NewMessage.h"
#import "UsernameChanged.h"

// Events
#import "NewMessageEvent.h"

// Categories
#import "User+Private.h"
#import "Chat+Private.h"

// Components
#import "YRBluetooth.h"

// Auxiliary
#import "Config.h"

// 3rdParty
#import "GCDMulticastDelegate.h"

@implementation ServerChatSession {
    YRBTServer *_server;
    ServerUser *_currentUserInfo;
    
    GCDMulticastDelegate <ServerChatSessionObserver> *_observers;
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

#pragma mark - Dynamic Properties

- (NSArray <ServerUser *> *)participants {
    return [self subscribedUsers];
}

- (YRBluetoothState)bluetoothState {
    return _server.bluetoothState;
}

- (BOOL)isAdvertising {
    return _server.isBroadcasting;
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
    NewMessageEvent *event = [[NewMessageEvent alloc] initWithChat:self.chat message:newMessage timestamp:timestamp];
    
    [self.chat.mutableEvents addObject:event];
    
    [_observers chatSession:self didReceiveMessage:event];
    
    NewMessage *messageToBeSent = [[NewMessage alloc] initWithSenderIdentifier:@"0"
                                                            isMessageByCreator:YES
                                                                     timestamp:timestamp
                                                                   messageText:message];
    
    [self scheduleMessage:messageToBeSent.rawMessage forOperation:kMessageOperation forUsers:[self subscribedUsers]];
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
    // TODO: Refactor a bit.
    __typeof(self) __weak weakSelf = self;
    
    _server.bluetoothStateChanged = ^(YRBluetoothState newState) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            if (newState == kYRBluetoothStatePoweredOn) {
                [strongSelf currentUserInfo].isSubscribed = YES;
            } else {
                [strongSelf currentUserInfo].isSubscribed = NO;
                [strongSelf.chat.members setValue:@NO forKey:@"isSubscribed"];
            }
            
            [strongSelf->_observers chatSession:strongSelf bluetoothStateDidChange:newState];
        }
    };
    
    _server.broadcastingStateChanged = ^(BOOL isBroadcasting) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf->_observers chatSession:strongSelf advertisingStateChanged:isBroadcasting];
        }
    };
    
    _server.deviceDisconnectCallback = ^(YRBTRemoteDevice *device) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            ServerUser *disconnectedUser = [strongSelf userForDevice:device];
            
            if (disconnectedUser.isSubscribed) {
                disconnectedUser.isSubscribed = NO;
                [disconnectedUser.messageQueue removeAllObjects];
                
                NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
                
                ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:strongSelf.chat
                                                                          user:disconnectedUser
                                                                     eventType:kEventTypeDisconnected
                                                                     timestamp:timestamp];
                
                [strongSelf.chat.mutableEvents addObject:event];
                
                [strongSelf->_observers chatSession:strongSelf userDidDisconnectWithEvent:event];
                
                UserConnection *connection = [[UserConnection alloc] initWithEventType:kUserConnectionTypeDisconnected
                                                                                  user:disconnectedUser
                                                                             timestamp:timestamp];
                
                [strongSelf scheduleMessage:connection.rawMessage forOperation:kUserEventOperation forUsers:[strongSelf subscribedUsers]];
            }
        }
    };
    
    // Register callbacks for SUBSCRIBE operation.
    [_server registerWillReceiveRemoteOperationCallback:NULL
                      didReceiveRemoteOperationCallback:^YRBTMessageOperation *(YRBTRemoteMessageOperation *operation,
                                                                                YRBTMessage *receivedMessage,
                                                                                BOOL wantsResponse) {
                          __typeof(weakSelf) __strong strongSelf = weakSelf;
                          
                          if (!strongSelf) {
                              return nil;
                          }
                          
                          SubscribeRequest *subscribeRequest = [[SubscribeRequest alloc] initWithName:[receivedMessage stringValue]];
                          ServerUser *subscribedUser = [strongSelf userForDevice:operation.sender];
                          
                          NSMutableArray *usersToNotify = [[strongSelf subscribedUsers] mutableCopy];
                          [usersToNotify removeObject:subscribedUser];
                          
                          if (!subscribedUser.isSubscribed) {
                              subscribedUser.name = subscribeRequest.subscriberName;
                              subscribedUser.isSubscribed = YES;
                              
                              // Notify users about connection event
                              NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
                              
                              ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:strongSelf.chat
                                                                                        user:subscribedUser
                                                                                   eventType:kEventTypeConnected
                                                                                   timestamp:timestamp];
                              
                              [strongSelf.chat.mutableEvents addObject:event];
                              
                              [strongSelf->_observers chatSession:strongSelf userDidConnectWithEvent:event];
                              
                              UserConnection *connection = [[UserConnection alloc] initWithEventType:kUserConnectionTypeConnected
                                                                                                user:subscribedUser
                                                                                           timestamp:timestamp];
                              
                              [strongSelf scheduleMessage:connection.rawMessage forOperation:kUserEventOperation forUsers:[usersToNotify copy]];
                          } else {
                              if (![subscribedUser.name isEqualToString:subscribeRequest.subscriberName]) {
                                  // User changed his name.
                                  subscribedUser.name = subscribeRequest.subscriberName;
                                  
                                  [strongSelf->_observers chatSession:strongSelf userDidUpdateName:subscribedUser];
                                  
                                  UsernameChanged *usernameChanged = [[UsernameChanged alloc] initWithUser:subscribedUser];
                                  
                                  [strongSelf scheduleMessage:usernameChanged.rawMessage
                                                 forOperation:kUserNameChangedOperation
                                                     forUsers:[usersToNotify copy]];
                              }
                          }
                          
                          NSArray *chatMembers = [usersToNotify arrayByAddingObject:[strongSelf currentUserInfo]];
                          
                          SubscribeResponse *response = [[SubscribeResponse alloc] initWithSubscribedUserInfo:subscribedUser
                                                                                                   otherUsers:chatMembers];
                          
                          return [YRBTMessageOperation responseOperationForRemoteOperation:operation
                                                                                  response:response.rawMessage
                                                                                       MTU:128
                                                                               successSend:NULL
                                                                           sendingProgress:NULL
                                                                                   failure:NULL];
                      } receivingProgressCallback:NULL
                                failedToReceiveCallback:NULL
                                           forOperation:kSubscribeOperation];
    
    [_server registerWillReceiveRemoteOperationCallback:NULL
                      didReceiveRemoteOperationCallback:^YRBTMessageOperation *(YRBTRemoteMessageOperation *operation,
                                                                                YRBTMessage *receivedMessage,
                                                                                BOOL wantsResponse) {
                          __typeof(weakSelf) __strong strongSelf = weakSelf;
                          
                          if (!strongSelf) {
                              return nil;
                          }
                          
                          ServerUser *sender = [strongSelf userForDevice:operation.sender];
                          NSString *messageText = [receivedMessage stringValue];
                          
                          Message *message = [[Message alloc] initWithChat:strongSelf.chat
                                                                    sender:sender
                                                                 timestamp:[NSDate date].timeIntervalSince1970
                                                               messageText:messageText];
                          
                          NewMessageEvent *event = [[NewMessageEvent alloc] initWithChat:strongSelf.chat
                                                                                 message:message
                                                                               timestamp:message.timestamp];
                          [strongSelf.chat.mutableEvents addObject:event];
                          
                          [strongSelf->_observers chatSession:strongSelf didReceiveMessage:event];
                          
                          NewMessage *newMessage = [[NewMessage alloc] initWithSenderIdentifier:sender.identifier
                                                                             isMessageByCreator:NO
                                                                                      timestamp:message.timestamp
                                                                                    messageText:messageText];
                          
                          NSMutableArray *usersToNotify = [[strongSelf subscribedUsers] mutableCopy];
                          [usersToNotify removeObject:sender];
                          
                          [strongSelf scheduleMessage:newMessage.rawMessage forOperation:kMessageOperation forUsers:usersToNotify];
                          
                          return [YRBTMessageOperation responseOperationForRemoteOperation:operation
                                                                                  response:newMessage.rawMessage
                                                                                       MTU:128
                                                                               successSend:NULL
                                                                           sendingProgress:NULL
                                                                                   failure:NULL];
                      } receivingProgressCallback:NULL
                                failedToReceiveCallback:NULL
                                           forOperation:kMessageOperation];
}

- (NSArray <ServerUser *> *)subscribedUsers {
    NSMutableArray *users = [NSMutableArray new];
    
    for (YRBTClientDevice *device in _server.connectedDevices) {
        ServerUser *user = [self userForDevice:device];
        
        if (user.isSubscribed) {
            [users addObject:user];
        }
    }
    
    return [users copy];
}

- (ServerUser *)userForDevice:(__kindof YRBTRemoteDevice *)device {
    for (ServerUser *user in self.chat.mutableMembers) {
        if ([user.device isEqual:device]) {
            return user;
        }
    }
    
    ServerUser *resultingUser = [[ServerUser alloc] initWithDevice:device];
    
    [self.chat.mutableMembers addObject:resultingUser];
    
    return resultingUser;
}

- (ServerUser *)currentUserInfo {
    if (!_currentUserInfo) {
        _currentUserInfo = [[ServerUser alloc] initWithIdentifier:@"0" name:_server.peerName isChatOwner:YES];
        _currentUserInfo.isSubscribed = (_server.bluetoothState == kYRBluetoothStatePoweredOn);
    }
    
    return _currentUserInfo;
}

// TODO: Should be a part of framework
- (void)scheduleMessage:(YRBTMessage *)message forOperation:(NSString *)operationName forUsers:(NSArray <ServerUser *> *)users {
    NSMutableArray *usersThatShouldReceiveImmediately = [NSMutableArray new];
    NSDictionary *messageMeta = @{kMessageQueueMessageKey : message,
                                  kMessageQueueOperationNameKey : operationName};
    
    for (ServerUser *user in users) {
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

- (void)removeMessageMeta:(NSDictionary *)messageMeta fromQueueForUsers:(NSArray <ServerUser *> *)users {
    for (ServerUser *user in users) {
        [user.messageQueue removeObject:messageMeta];
    }
}

- (void)processPendingMessagesForUsers:(NSArray <ServerUser *> *)users {
    for (ServerUser *user in users) {
        if (user.messageQueue.count > 0) {
            YRBTMessage *message = [user.messageQueue firstObject][kMessageQueueMessageKey];
            NSString *operationName = [user.messageQueue firstObject][kMessageQueueOperationNameKey];
            
            [self scheduleMessage:message forOperation:operationName forUsers:@[user]];
        }
    }
}

@end
