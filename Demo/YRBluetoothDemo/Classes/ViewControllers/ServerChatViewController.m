//
//  ChatServerViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "ServerChatViewController.h"

// Model
#import "ServerChatSession.h"

@implementation ServerChatViewController {
    ServerChatSession *_serverSession;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _serverSession = [ServerChatSession sessionWithNickname:self.nickname];
}

- (void)dealloc {
    [_serverSession endSession];
}

@end
