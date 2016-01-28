//
//  User+Private.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "User.h"
#import "ClientUser.h"
#import "ServerUser.h"

// Components
#import "YRBluetooth.h"

extern NSString *const kUserInfoIdentifierKey;
extern NSString *const kUserInfoNameKey;
extern NSString *const kUserInfoIsOnlineKey;
extern NSString *const kUserInfoIsCreatorKey;

extern NSString *const kMessageQueueMessageKey;
extern NSString *const kMessageQueueOperationNameKey;

@interface User (Private)

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *name;
@property (nonatomic) BOOL isChatOwner;

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name isChatOwner:(BOOL)isChatOwner;

@end

@interface ClientUser (Private)

@property (nonatomic) BOOL isConnected;

- (instancetype)initWithPackedUserInfo:(NSDictionary *)packedInfo;
@end

@interface ServerUser (Private)

@property (nonatomic) YRBTClientDevice *device;
@property (nonatomic) BOOL isSubscribed;
@property (nonatomic, readonly) NSMutableArray <NSDictionary *> *messageQueue;

- (instancetype)initWithDevice:(YRBTClientDevice *)device;
- (NSDictionary *)packedUserInfo;

@end