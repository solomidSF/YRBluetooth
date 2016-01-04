//
//  ChatSession.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "ClientChatSession.h"

// Components
#import "YRBluetooth.h"

// Auxiliary
#import "Config.h"

@implementation ClientChatSession {
    YRBTClient *_client;
}

#pragma mark - Lifecycle

+ (instancetype)sessionWithNickname:(NSString *)nickname {
    return [[self alloc] initWithNickname:nickname];
}

- (instancetype)initWithNickname:(NSString *)nickname {
    if (self = [super init]) {
        _nickname = nickname;
        
        _client = [[YRBTClient alloc] initWithAppID:kChatAppID peerName:self.nickname];
    }
    
    return self;
}

@end
