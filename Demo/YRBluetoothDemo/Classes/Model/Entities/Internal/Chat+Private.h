//
//  Chat+Private.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Entities
#import "Chat.h"
#import "ClientChat.h"
#import "ServerChat.h"
#import "ClientUser.h"
#import "ServerUser.h"

// Events
#import "EventObject.h"

// Components
#import "YRBluetooth.h"

@interface Chat (Private)

@property (nonatomic) __kindof User *me;
@property (nonatomic, readonly) NSMutableArray <__kindof EventObject *> *mutableEvents;
@property (nonatomic) NSMutableArray <__kindof User *> *mutableMembers;

@end

@interface ClientChat (Private)

@property (nonatomic) ClientUser *creator;
@property (nonatomic) YRBTServerDevice *device;

+ (instancetype)chatForDevice:(YRBTServerDevice *)device;

@end

@interface ServerChat (Private)

+ (instancetype)chatWithCreatorInfo:(ServerUser *)user;

@end