//
//  Chat+Private.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "Chat+Private.h"

@implementation Chat (Private)

@dynamic me;
@dynamic mutableMembers;
@dynamic mutableEvents;

@end

@implementation ClientChat (Private)

@dynamic creator;
@dynamic device;

+ (instancetype)chatForDevice:(YRBTServerDevice *)device {
    ClientChat *chat = [self new];
    
    chat.device = device;
    
    return chat;
}

@end

@implementation ServerChat (Private)

+ (instancetype)chatWithCreatorInfo:(User *)user {
    ServerChat *chat = [self new];
    
    chat.me = user;
    chat.mutableMembers = [NSMutableArray new];
    
    return chat;
}

@end