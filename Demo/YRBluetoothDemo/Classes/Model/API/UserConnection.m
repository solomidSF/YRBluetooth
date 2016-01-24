//
//  UserEvent.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/16/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "UserConnection.h"

// Private
#import "User+Private.h"

@implementation UserConnection

- (instancetype)initWithMessage:(YRBTMessage *)message {
    if (self = [super initWithMessage:message]) {
        _eventType = (UserConnectionType)[[message dictionaryValue][@"eventType"] intValue];
        _timestamp = [[message dictionaryValue][@"timestamp"] doubleValue];
     
        _userIdentifier = [message dictionaryValue][@"user"][kUserInfoIdentifierKey];
        _userName = [message dictionaryValue][@"user"][kUserInfoNameKey];
        _connected = [[message dictionaryValue][@"user"][kUserInfoIsOnlineKey] boolValue];
    }
    
    return self;
}

- (instancetype)initWithEventType:(UserConnectionType)eventType user:(User *)user timestamp:(NSTimeInterval)timestamp {
    NSDictionary *meta = @{
                           @"eventType" : @(eventType),
                           @"timestamp" : @(timestamp),
                           @"user" : [user packedUserInfo]
                           };
    
    YRBTMessage *message = [YRBTMessage messageWithDictionary:meta];
    
    return [self initWithMessage:message];
}

@end
