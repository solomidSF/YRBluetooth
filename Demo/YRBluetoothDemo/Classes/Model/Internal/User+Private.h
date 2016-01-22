//
//  User+Private.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "User.h"

// Components
#import "YRBluetooth.h"

extern NSString *const kUserInfoIdentifierKey;
extern NSString *const kUserInfoNameKey;
extern NSString *const kUserInfoIsOnlineKey;
extern NSString *const kUserInfoIsCreatorKey;

extern NSString *const kMessageQueueMessageKey;
extern NSString *const kMessageQueueOperationNameKey;

@interface User (ServerPerspective)

@property (nonatomic) YRBTClientDevice *device;
@property (nonatomic) BOOL isSubscribed;
@property (nonatomic) NSString *name;

@property (nonatomic, readonly) NSMutableArray <NSDictionary *> *messageQueue;

- (instancetype)initWithClientDevice:(YRBTClientDevice *)device;
- (NSDictionary *)packedUserInfo;

@end

@interface User (ClientPerspective)

@property (nonatomic) NSString *identifier;
@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL isChatOwner;

- (instancetype)initWithPackedUserInfo:(NSDictionary *)packedInfo;
- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name isChatOwner:(BOOL)isChatOwner connected:(BOOL)connected;

@end