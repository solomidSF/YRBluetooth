//
//  ServerChat.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/24/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "ServerChat.h"

@implementation ServerChat

#pragma mark - Dynamic Properties

- (NSString *)name {
    return self.me.name;
}

- (ChatState)state {
    return kChatStateConnected;
}

@end
