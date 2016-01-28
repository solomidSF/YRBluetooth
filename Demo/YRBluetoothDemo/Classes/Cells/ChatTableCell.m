//
//  ChatTableCell.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Cells
#import "ChatTableCell.h"

// Session
@interface ChatTableCell ()
<
ClientChatSessionObserver
>
@end

@implementation ChatTableCell {
    __weak IBOutlet UILabel *_chatNameLabel;
    __weak IBOutlet UIButton *_connectionButton;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [_session removeObserver:self];
}

#pragma mark - Dynamic Properties

- (void)setSession:(ClientChatSession *)session {
    if (_session != session) {
        _session = session;
        
        [_session addObserver:self];        
    }
}

- (void)setChat:(ClientChat *)chat {
    if (![_chat isEqual:chat]) {
        _chat = chat;
        
        [self updateUI];
    }
}

#pragma mark - Callbacks

- (IBAction)connectionButtonCallback:(id)sender {
    switch (self.chat.state) {
        case kChatStateDisconnected:
            [_session connectToChat:self.chat withSuccess:NULL failure:NULL];
            break;
        case kChatStateConnecting:
            // Do nothing
            break;
        case kChatStateConnected:
            [_session disconnectFromChat:self.chat];
            break;
    }
}

#pragma mark - Private

- (void)updateUI {
    _chatNameLabel.text = self.chat.name;
    
    switch (self.chat.state) {
        case kChatStateDisconnected:
            [_connectionButton setTitle:@"Connect" forState:UIControlStateNormal];
            break;
        case kChatStateConnecting:
            [_connectionButton setTitle:@"Connecting.." forState:UIControlStateNormal];
            break;
        case kChatStateConnected:
            [_connectionButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            break;
    }
    
    _connectionButton.enabled = self.chat.state != kChatStateConnecting;
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session reportsNearbyChats:(NSArray<ClientChat *> *)chats {
    if ([chats containsObject:self.chat]) {
        [self updateUI];
    }
}

- (void)chatSession:(ClientChatSession *)session chatStateDidUpdate:(Chat *)chat {
    if ([chat isEqual:_chat]) {
        [self updateUI];
    }
}

@end
