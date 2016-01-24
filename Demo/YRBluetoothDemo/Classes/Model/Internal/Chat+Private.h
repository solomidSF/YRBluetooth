//
//  Chat+Private.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "Chat.h"
#import "ClientChat.h"
#import "ServerChat.h"

// Components
#import "YRBluetooth.h"

@interface Chat (Private)

@property (nonatomic) User *me;
@property (nonatomic, readonly) NSMutableArray <Message *> *mutableMessages;
@property (nonatomic) NSMutableArray <User *> *mutableMembers;

@end

@interface ClientChat (Private)

@property (nonatomic) User *creator;
@property (nonatomic) YRBTServerDevice *device;

+ (instancetype)chatForDevice:(YRBTServerDevice *)device;

@end

@interface ServerChat (Private)

+ (instancetype)chatWithCreatorInfo:(User *)user;

@end