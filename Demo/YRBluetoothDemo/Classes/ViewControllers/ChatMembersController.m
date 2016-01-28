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
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ChatMembersController {
    NSArray <ClientUser *> *_users;
    
    __weak IBOutlet UITableView *_membersTableView;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _membersTableView.rowHeight = UITableViewAutomaticDimension;
    _membersTableView.estimatedRowHeight = 40.0f;
    
    [_session addObserver:self];

    [self refreshDatasourceAndReload];
}

- (void)dealloc {
    [_session removeObserver:self];
}

#pragma mark - Private

- (void)refreshDatasourceAndReload {
    NSMutableArray <ClientUser *> *allUsers = [NSMutableArray new];

    [allUsers addObject:self.chat.creator];
    [allUsers addObject:self.chat.me];
    [allUsers addObjectsFromArray:self.chat.members];
    
    _users = [allUsers copy];
    [_membersTableView reloadData];
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session userDidConnect:(ClientUser *)user
             toChat:(ClientChat *)chat timestamp:(NSTimeInterval)timestamp {
    if ([self.chat isEqual:chat]) {
        if (![_users containsObject:user]) {
            [self refreshDatasourceAndReload];
        }
    }
}

#pragma mark - <UITableViewDelegate&DataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatMemberCell class])];
    
    cell.session = self.session;
    cell.member = _users[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
