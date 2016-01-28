//
//  SubscribeResponse.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "APIObject.h"

// Entities
#import "User.h"
#import "ServerUser.h"

@interface SubscribeResponse : APIObject

@property (nonatomic) __kindof User *subscribedUser;
@property (nonatomic) __kindof User *creator;
@property (nonatomic) NSArray <__kindof User *> *otherUsers;

- (instancetype)initWithSubscribedUserInfo:(ServerUser *)userInfo otherUsers:(NSArray <ServerUser *> *)users;

@end
