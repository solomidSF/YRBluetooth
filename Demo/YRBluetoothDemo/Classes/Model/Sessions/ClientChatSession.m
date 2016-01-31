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
#import "UsernameChanged.h"

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
static NSString *const kUserNameChangedOperation = @"UNC";

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

#pragma mark - Dynamic Properties

- (NSArray <ClientChat *> *)activeChats {
    NSMutableArray *chats = [NSMutableArray new];
    
    for (YRBTServerDevice *device in _client.connectedDevices) {
        Chat *chat = [self chatForRemoteDevice:device];
        
        if (chat.state == kChatStateConnected) {
            [chats addObject:chat];
        }
    }
    
    return [chats copy];
}

#pragma mark - Scanning

- (void)startScanningForChatsWithSuccess:(ChatScanningCallback)scanningCallback failure:(ChatScanningFailureCallback)failure {
    [_client scanForDevicesWithCallback:^(NSArray <YRBTServerDevice *> *devices) {
        NSMutableArray <ClientChat *> *chats = [NSMutableArray new];
        
        for (YRBTServerDevice *device in devices) {
            [chats addObject:[self chatForRemoteDevice:device]];
        }
        
        [_observers chatSession:self reportsNearbyChats:[chats copy]];
        
        !scanningCallback ? : scanningCallback([chats copy]);
    } failureCallback:^(NSError *error) {
        [_observers chatSession:self failedToScanForNearbyChatsWithError:error];
        
        !failure ? : failure(error);
    }];
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
                if (newState == kYRBTConnectionStateNotConnected) {
                    ClientUser *me = strongChat.me;
                    ClientUser *creator = strongChat.creator;
                    
                    me.isConnected = NO;
                    creator.isConnected = NO;
                    
                    [strongChat.members setValue:@NO forKey:@"isConnected"];
                }

                [strongSelf->_observers chatSession:strongSelf chatStateDidUpdate:strongChat];
            }
        };
    }
    
    [_client connectToDevice:chat.device withSuccess:^(YRBTServerDevice *device) {
        SubscribeRequest *request = [[SubscribeRequest alloc] initWithName:_client.peerName];
        
        YRBTResponseCallback response = ^(YRBTMessageOperation *operation, YRBTMessage *receivedMessage) {
            NSLog(@"Received subscibe request response: %@. Operation: %@", [receivedMessage dictionaryValue], operation);
            SubscribeResponse *response = [[SubscribeResponse alloc] initWithMessage:receivedMessage];
            
            chat.me = response.subscribedUser;
            chat.creator = response.creator;
            chat.mutableMembers = response.otherUsers ? [response.otherUsers mutableCopy] : [NSMutableArray new];
            
            !success ? : success(chat, response.subscribedUser);
            
            [_observers chatSession:self didConnectToChat:chat];
        };
        
        YRBTOperationFailureCallback requestFailure = ^(YRBTMessageOperation *operation, NSError *error) {
            [self disconnectFromChat:chat];
            
            !failure ? : failure(error);
            
            [_observers chatSession:self didFailToConnectToChat:chat withError:error];
        };
        
        [_client sendMessage:request.rawMessage
                    toServer:device
               operationName:kSubscribeOperation
                 successSend:NULL
                    response:response
             sendingProgress:NULL
           receivingProgress:NULL
                     failure:requestFailure];
        
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
    
    YRBTResponseCallback response = ^(YRBTMessageOperation *operation, YRBTMessage *receivedMessage) {
        NewMessage *event = [[NewMessage alloc] initWithMessage:receivedMessage];
        ClientUser *sender = chat.me;
        
        Message *newMessage = [[Message alloc] initWithChat:chat
                                                     sender:sender
                                                  timestamp:event.timestamp
                                                messageText:event.messageText];
        
        NewMessageEvent *newMessageEvent = [[NewMessageEvent alloc] initWithChat:chat
                                                                         message:newMessage
                                                                       timestamp:newMessage.timestamp];
        
        [chat.mutableEvents addObject:newMessageEvent];
        
        [_observers chatSession:self didSendMessage:newMessageEvent inChat:chat];
        
        !success ? : success(newMessageEvent);
    };
    
    return [_client sendMessage:message
                       toServer:chat.device
                  operationName:kMessageOperation
                    successSend:NULL
                       response:response
                sendingProgress:NULL
              receivingProgress:NULL
                        failure:failure];
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
    
    YRBTReceivedRemoteRequestCallback userEventCallback = ^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                                                  YRBTMessage *requestMessage,
                                                                                  BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (!strongSelf) {
            return nil;
        }
        
        UserConnection *connection = [[UserConnection alloc] initWithMessage:requestMessage];
        
        ClientChat *chat = [strongSelf chatForRemoteDevice:request.sender];
        ClientUser *user = [strongSelf userWithIdentifier:connection.userIdentifier fromChat:chat];
        
        user.name = connection.userName;
        user.isConnected = connection.connected;
        
        if (!user) {
            user = [[ClientUser alloc] initWithIdentifier:connection.userIdentifier
                                                     name:connection.userName
                                              isChatOwner:NO];
            
            user.isConnected = connection.connected;
            
            [chat.mutableMembers addObject:user];
        }
        
        EventType type = connection.eventType == kUserConnectionTypeConnected ? kEventTypeConnected : kEventTypeDisconnected;
        
        ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:chat
                                                                  user:user
                                                             eventType:type
                                                             timestamp:connection.timestamp];
        
        switch (connection.eventType) {
            case kUserConnectionTypeConnected:
                [strongSelf->_observers chatSession:strongSelf userDidConnectWithEvent:event inChat:chat];
                break;
            case kUserConnectionTypeDisconnected:
                [strongSelf->_observers chatSession:strongSelf userDidDisconnectWithEvent:event inChat:chat];
                break;
            default:
                break;
        }
        
        return nil;
    };
    
    YRBTReceivedRemoteRequestCallback newMessageCallback = ^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                                                   YRBTMessage *requestMessage,
                                                                                   BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (!strongSelf) {
            return nil;
        }
        
        NewMessage *event = [[NewMessage alloc] initWithMessage:requestMessage];
        ClientChat *chat = [strongSelf chatForRemoteDevice:request.sender];
        
        ClientUser *sender = nil;
        if (event.isMessageByChatCreator) {
            sender = [strongSelf chatForRemoteDevice:request.sender].creator;
        } else {
            sender = [strongSelf userWithIdentifier:event.senderIdentifier fromChat:[strongSelf chatForRemoteDevice:request.sender]];
        }
        
        Message *newMessage = [[Message alloc] initWithChat:chat sender:sender timestamp:event.timestamp messageText:event.messageText];
        
        NewMessageEvent *newMessageEvent = [[NewMessageEvent alloc] initWithChat:chat
                                                                         message:newMessage
                                                                       timestamp:newMessage.timestamp];
        
        [chat.mutableEvents addObject:newMessageEvent];
        
        [strongSelf->_observers chatSession:strongSelf didReceiveMessage:newMessageEvent inChat:chat];
        
        return nil;
    };
    
    YRBTReceivedRemoteRequestCallback userNameChangedCallback = ^YRBTMessageOperation *(YRBTRemoteMessageRequest *request,
                                                                                        YRBTMessage *requestMessage,
                                                                                        BOOL wantsResponse) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            UsernameChanged *usernameChanged = [[UsernameChanged alloc] initWithMessage:requestMessage];
            
            ClientChat *chat = [strongSelf chatForRemoteDevice:request.sender];
            ClientUser *user = [strongSelf userWithIdentifier:usernameChanged.userID
                                                     fromChat:chat];
            user.name = usernameChanged.updatedName;
            
            [strongSelf->_observers chatSession:strongSelf userDidUpdateName:user inChat:chat];
        }
        
        return nil;
    };
    
    [_client registerWillReceiveRequestCallback:NULL
                      didReceiveRequestCallback:userEventCallback
                      receivingProgressCallback:NULL
                        failedToReceiveCallback:NULL
                                   forOperation:kUserEventOperation];
    
    [_client registerWillReceiveRequestCallback:NULL
                      didReceiveRequestCallback:newMessageCallback
                      receivingProgressCallback:NULL
                        failedToReceiveCallback:NULL
                                   forOperation:kMessageOperation];
    
    [_client registerWillReceiveRequestCallback:NULL
                      didReceiveRequestCallback:userNameChangedCallback
                      receivingProgressCallback:NULL
                        failedToReceiveCallback:NULL
                                   forOperation:kUserNameChangedOperation];
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

- (ClientUser *)userWithIdentifier:(NSString *)identifier fromChat:(ClientChat *)chat {
    for (ClientUser *candidate in chat.members) {
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
