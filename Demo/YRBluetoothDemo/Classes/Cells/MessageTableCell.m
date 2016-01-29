//
//  MessageTableCell.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/22/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Cell
#import "MessageTableCell.h"

// Events
#import "NewMessageEvent.h"

@interface MessageTableCell ()
<
ClientChatSessionObserver,
ServerChatSessionObserver
>
@end

@implementation MessageTableCell {
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_messageLabel;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self.clientSession removeObserver:self];
    [self.serverSession removeObserver:self];
}

#pragma mark - Dynamic Properties

- (void)setClientSession:(ClientChatSession *)clientSession {
    if (!self.clientSession) {
        [super setClientSession:clientSession];
        
        [clientSession addObserver:self];
    }
}

- (void)setServerSession:(ServerChatSession *)serverSession {
    if (!self.serverSession) {
        [super setServerSession:serverSession];
        
        [serverSession addObserver:self];
    }
}

- (void)setEvent:(__kindof EventObject *)event {
    [super setEvent:event];
    
    [self updateUI];
}

#pragma mark - Private

- (void)updateUI {
    NewMessageEvent *messageEvent = self.event;

    _nameLabel.text = messageEvent.message.sender.name;
    _messageLabel.text = messageEvent.message.messageText;
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session userDidUpdateName:(ClientUser *)user inChat:(ClientChat *)chat {
    NewMessageEvent *messageEvent = self.event;
    
    if ([messageEvent.chat isEqual:chat] &&
        [messageEvent.message.sender isEqual:user]) {
        [self updateUI];
    }
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session userDidUpdateName:(ServerUser *)user {
    NewMessageEvent *messageEvent = self.event;
    
    if ([messageEvent.message.sender isEqual:user]) {
        [self updateUI];
    }
}

@end
