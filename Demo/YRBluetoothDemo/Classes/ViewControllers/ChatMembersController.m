//
//  ChatMembersController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "ChatMembersController.h"

// Cells
#import "ChatMemberCell.h"

@interface ChatMembersController ()
<
ClientChatSessionObserver,
ServerChatSessionObserver,
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ChatMembersController {
    NSArray <__kindof User *> *_users;
    
    __weak IBOutlet UITableView *_membersTableView;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _membersTableView.rowHeight = UITableViewAutomaticDimension;
    _membersTableView.estimatedRowHeight = 40.0f;
    
    [self refreshDatasourceAndReload];
}

- (void)dealloc {
    [self.clientSession removeObserver:self];
    [self.serverSession removeObserver:self];
}

#pragma mark - Dynamic Properties

- (void)setClientSession:(ClientChatSession *)clientSession {
    if (_clientSession != clientSession) {
        _clientSession = clientSession;
        
        [_clientSession addObserver:self];
    }
}

- (void)setServerSession:(ServerChatSession *)serverSession {
    if (_serverSession != serverSession) {
        _serverSession = serverSession;
        
        [_serverSession addObserver:self];
    }
}

#pragma mark - Private

- (void)refreshDatasourceAndReload {
    NSMutableArray <__kindof User *> *allUsers = [NSMutableArray new];

    BOOL isClient = self.clientSession != nil;
    
    if (isClient) {
        [allUsers addObject:[(ClientChat *)self.chat creator]];
    }
    
    [allUsers addObject:self.chat.me];
    [allUsers addObjectsFromArray:self.chat.members];
    
    _users = [allUsers copy];
    [_membersTableView reloadData];
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event inChat:(ClientChat *)chat {
    if ([self.chat isEqual:event.chat]) {
        if (![_users containsObject:event.user]) {
            [self refreshDatasourceAndReload];
        }
    }
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session bluetoothStateDidChange:(YRBluetoothState)newState {
    [self refreshDatasourceAndReload];
}

- (void)chatSession:(ServerChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event {
    if (![_users containsObject:event.user]) {
        [self refreshDatasourceAndReload];
    }
}

#pragma mark - <UITableViewDelegate&DataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatMemberCell class])];
    
    if (self.clientSession) {
        cell.clientSession = self.clientSession;
    } else if (self.serverSession) {
        cell.serverSession = self.serverSession;
    }

    cell.member = _users[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
