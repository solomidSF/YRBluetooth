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

@implementation User (ServerPerspective)

@dynamic device;
@dynamic isSubscribed;
@dynamic name;
@dynamic messageQueue;

- (instancetype)initWithClientDevice:(YRBTClientDevice *)device {
    if (self = [super init]) {
        self.device = device;
        self.identifier = [device.uuid UUIDString];
    }
    
    return self;
}

- (NSDictionary *)packedUserInfo {
    return @{
             kUserInfoIdentifierKey : self.identifier,
             kUserInfoNameKey : self.name,
             kUserInfoIsOnlineKey : @(self.isConnected),
             kUserInfoIsCreatorKey : @(self.isChatOwner)
             };
}

@end

@implementation User (ClientPerspective)

@dynamic identifier;
@dynamic isConnected;
@dynamic isChatOwner;

- (instancetype)initWithPackedUserInfo:(NSDictionary *)packedInfo {
    NSString *identifier = packedInfo[kUserInfoIdentifierKey];
    NSString *name = packedInfo[kUserInfoNameKey];
    BOOL isConnected = [packedInfo[kUserInfoIsOnlineKey] boolValue];
    BOOL isCreator = [packedInfo[kUserInfoIsCreatorKey] boolValue];

    return [self initWithIdentifier:identifier name:name isChatOwner:isCreator connected:isConnected];
}

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name isChatOwner:(BOOL)isChatOwner connected:(BOOL)connected {
    if (self = [super init]) {
        self.identifier = identifier;
        self.name = name;
        self.isChatOwner = isChatOwner;
        self.isConnected = connected;
    }
    
    return self;
}

@end