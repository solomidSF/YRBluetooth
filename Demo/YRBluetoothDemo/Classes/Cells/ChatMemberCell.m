//
//  ChatMemberCell.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "ChatMemberCell.h"

@interface ChatMemberCell ()
<
ClientChatSessionObserver
>
@end

@implementation ChatMemberCell {
    __weak IBOutlet UILabel *_memberNameLabel;
    __weak IBOutlet UIImageView *_memberOnlineStatusImageView;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self.session removeObserver:self];
}

#pragma mark - Dynamic Properties

- (void)setSession:(ClientChatSession *)session {
    if (_session != session) {
        _session = session;
        
        [_session addObserver:self];        
    }
}

- (void)setMember:(ClientUser *)member {
    if (_member != member) {
        _member = member;
        
        [self updateUI];
    }
}

- (void)updateUI {
    _memberNameLabel.text = _member.name;
    _memberOnlineStatusImageView.image = [UIImage imageNamed:_member.isConnected ? @"online" : @"offline"];
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session chatStateDidUpdate:(ClientChat *)chat {
    if ([chat.members containsObject:self.member] ||
        [chat.me isEqual:self.member] ||
        [chat.creator isEqual:self.member]) {
        
        [self updateUI];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidConnect:(ClientUser *)user
             toChat:(ClientChat *)chat timestamp:(NSTimeInterval)timestamp {
    if ([self.member isEqual:user]) {
        [self updateUI];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidDisconnect:(ClientUser *)user
           fromChat:(ClientChat *)chat timestamp:(NSTimeInterval)timestamp {
    if ([self.member isEqual:user]) {
        [self updateUI];
    }
}

@end
