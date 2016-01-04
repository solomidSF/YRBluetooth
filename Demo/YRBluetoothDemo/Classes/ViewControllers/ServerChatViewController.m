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

@interface ServerChatViewController ()
<
ServerChatSessionObserver,
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ServerChatViewController {
    ServerChatSession *_serverSession;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _serverSession = [ServerChatSession sessionWithNickname:self.nickname];
    
    [_serverSession addObserver:self];
}

- (void)dealloc {
    [_serverSession endSession];
}

#pragma mark - <ServerChatSessionObserver>



#pragma mark - <UITableViewDelegate/Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
