//
//  Chat+Private.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "Chat+Private.h"

@implementation Chat (Private)

@dynamic mutableMembers;
@dynamic mutableMessages;

@end

@implementation Chat (ClientPerspective)

@dynamic device;
@dynamic me;
@dynamic creator;

+ (instancetype)chatForDevice:(YRBTServerDevice *)device {
    Chat *chat = [self new];
    
    chat.device = device;
    
    return chat;
}

@end