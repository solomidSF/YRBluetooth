//
//  UsernameChanged.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "UsernameChanged.h"

@implementation UsernameChanged

- (instancetype)initWithMessage:(YRBTMessage *)message {
    if (self = [super initWithMessage:message]) {
        _userID = [message dictionaryValue][@"id"];
        _updatedName = [message dictionaryValue][@"un"];
    }
    
    return self;
}

- (instancetype)initWithUser:(ServerUser *)user {
    YRBTMessage *message = [YRBTMessage messageWithDictionary:@{@"un" : user.name,
                                                                @"id" : user.identifier}];
    
    return [self initWithMessage:message];
}

@end
