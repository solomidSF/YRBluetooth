//
//  User+Private.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/3/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "User+Private.h"

NSString *const kUserInfoIdentifierKey = @"ID";
NSString *const kUserInfoNameKey = @"N";
NSString *const kUserInfoIsOnlineKey = @"IO";
NSString *const kUserInfoIsCreatorKey = @"IC";

NSString *const kMessageQueueMessageKey = @"Message";
NSString *const kMessageQueueOperationNameKey = @"Operation Name";

@implementation User (Private)
@dynamic identifier;
@dynamic name;
@dynamic isChatOwner;

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name isChatOwner:(BOOL)isChatOwner {
    if (self = [super init]) {
        self.identifier = identifier;
        self.name = name;
        self.isChatOwner = isChatOwner;
    }
    
    return self;
}

@end

@implementation ClientUser (Private)

@dynamic isConnected;

- (instancetype)initWithPackedUserInfo:(NSDictionary *)packedInfo {
    NSString *identifier = packedInfo[kUserInfoIdentifierKey];
    NSString *name = packedInfo[kUserInfoNameKey];
    BOOL isCreator = [packedInfo[kUserInfoIsCreatorKey] boolValue];

    if (self = [super initWithIdentifier:identifier name:name isChatOwner:isCreator]) {
        self.isConnected = [packedInfo[kUserInfoIsOnlineKey] boolValue];
    }
    
    return self;
}

@end

@implementation ServerUser (Private)

@dynamic device;
@dynamic isSubscribed;
@dynamic messageQueue;

- (instancetype)initWithDevice:(YRBTClientDevice *)device {
    if (self = [super init]) {
        self.device = device;
    }
    
    return self;
}

- (NSDictionary *)packedUserInfo {
    return @{
             kUserInfoIdentifierKey : self.identifier,
             kUserInfoNameKey : self.name,
             kUserInfoIsOnlineKey : @(self.isSubscribed),
             kUserInfoIsCreatorKey : @(self.isChatOwner)
             };
}

@end