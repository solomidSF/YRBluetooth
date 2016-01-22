//
//  SubscribeResponse.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "APIObject.h"
#import "User.h"

@interface SubscribeResponse : APIObject

@property (nonatomic) User *subscribedUser;
@property (nonatomic) User *creator;
@property (nonatomic) NSArray <User *> *otherUsers;

- (instancetype)initWithSubscribedUserInfo:(User *)userInfo otherUsers:(NSArray <User *> *)users;

@end
