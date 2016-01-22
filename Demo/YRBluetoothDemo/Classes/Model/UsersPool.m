//
//  UsersPool.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "UsersPool.h"
#import "User+Private.h"

@implementation UsersPool {
    NSMutableArray <User *> *_users;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _users = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Public

- (User *)userForDevice:(__kindof YRBTRemoteDevice *)device {
    NSArray <__kindof YRBTRemoteDevice *> *devices = [_users valueForKey:@"device"];
    
    if ([devices containsObject:device]) {
        return _users[[devices indexOfObject:device]];
    }
    
    User *newUser = [[User alloc] initWithClientDevice:device];
    
    [_users addObject:newUser];
    
    return newUser;
}

@end
