//
//  ChatServerViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "ServerChatViewController.h"

// Sessions
#import "ServerChatSession.h"

// Events
#import "EventObject.h"

// Cells
#import "BaseEventTableCell.h"
#import "InformativeTableCell.h"
#import "MessageTableCell.h"
#import "MyMessageTableCell.h"

@interface ServerChatViewController ()
<
ServerChatSessionObserver,
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ServerChatViewController {
    ServerChatSession *_serverSession;
    __weak IBOutlet UITableView *_messagesTableView;
    
    NSMutableArray <EventObject *> *_datasource;
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

#pragma mark - <UITableViewDelegate/Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventObject *event = _datasource[indexPath.row];
    
    __kindof BaseEventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:event.reuseIdentifier];
    cell.event = event;
    
    return cell;
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session userDidConnect:(User *)user timestamp:(NSTimeInterval)timestamp {
    
}

- (void)chatSession:(ServerChatSession *)session userDidDisconnect:(User *)user timestamp:(NSTimeInterval)timestamp {
    
}

- (void)chatSession:(ServerChatSession *)session didReceiveNewMessage:(Message *)message {
    
}

@end
