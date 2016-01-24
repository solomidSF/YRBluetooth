//
//  SubscribeResponse.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "SubscribeResponse.h"

// Categories
#import "User+Private.h"

@implementation SubscribeResponse

#pragma mark - Init

- (instancetype)initWithMessage:(YRBTMessage *)message {
    if (self = [super initWithMessage:message]) {
        _subscribedUser = [[User alloc] initWithPackedUserInfo:[message dictionaryValue][@"u"]];
        
        NSMutableArray *otherUsers = [NSMutableArray new];
        
        for (NSDictionary *packedInfo in [message dictionaryValue][@"om"]) {
            User *user = [[User alloc] initWithPackedUserInfo:packedInfo];
            
            if (!user.isChatOwner) {
                [otherUsers addObject:user];
            } else {
                _creator = user;
            }
        }
        
        _otherUsers = [otherUsers copy];
    }
    
    return self;
}

- (instancetype)initWithSubscribedUserInfo:(User *)userInfo otherUsers:(NSArray <User *> *)users {
    NSMutableArray *otherUsers = [NSMutableArray new];
    
    for (User *user in users) {
        [otherUsers addObject:[user packedUserInfo]];
    }
    
    YRBTMessage *message = [YRBTMessage messageWithDictionary:@{@"u" : [userInfo packedUserInfo],
                                                                @"om" : [otherUsers copy]}];
    
    return [self initWithMessage:message];
}

@end
