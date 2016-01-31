//
//  ChatMemberCell.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Cells
#import "ChatMemberCell.h"

// Entities
#import "ClientUser.h"
#import "ServerUser.h"

@interface ChatMemberCell ()
<
ClientChatSessionObserver,
ServerChatSessionObserver
>
@end

@implementation ChatMemberCell {
    __weak IBOutlet UILabel *_memberNameLabel;
    __weak IBOutlet UIImageView *_memberOnlineStatusImageView;
}

#pragma mark - Lifecycle

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

- (void)setMember:(ClientUser *)member {
    _member = member;
    
    [self updateUI];
}

- (void)updateUI {
    _memberNameLabel.text = _member.name;

    BOOL isClientUser = self.clientSession != nil;
    BOOL isMemberConnected = isClientUser ? [(ClientUser *)_member isConnected] : [(ServerUser *)_member isSubscribed];
    
    _memberOnlineStatusImageView.image = [UIImage imageNamed:isMemberConnected ? @"online" : @"offline"];
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session chatStateDidUpdate:(ClientChat *)chat {
    if ([chat.members containsObject:self.member] ||
        [chat.me isEqual:self.member] ||
        [chat.creator isEqual:self.member]) {
        
        [self updateUI];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event inChat:(ClientChat *)chat {
    if ([self.member isEqual:event.user]) {
        [self updateUI];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidDisconnectWithEvent:(ConnectionEvent *)event inChat:(ClientChat *)chat {
    if ([self.member isEqual:event.user]) {
        [self updateUI];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidUpdateName:(ClientUser *)user inChat:(ClientChat *)chat {
    if ([self.member isEqual:user]) {
        [self updateUI];
    }
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event {
    if ([self.member isEqual:event.user]) {
        [self updateUI];
    }
}

- (void)chatSession:(ServerChatSession *)session userDidDisconnectWithEvent:(ConnectionEvent *)event {
    if ([self.member isEqual:event.user]) {
        [self updateUI];
    }
}

- (void)chatSession:(ServerChatSession *)session userDidUpdateName:(ServerUser *)user {
    if ([self.member isEqual:user]) {
        [self updateUI];
    }
}

@end
