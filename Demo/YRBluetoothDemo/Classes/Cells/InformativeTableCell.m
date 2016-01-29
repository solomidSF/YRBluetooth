//
//  InformativeTableCell.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/4/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Cells
#import "InformativeTableCell.h"

// Events
#import "ConnectionEvent.h"

@interface InformativeTableCell ()
<
ClientChatSessionObserver,
ServerChatSessionObserver
>
@end

@implementation InformativeTableCell {
    __weak IBOutlet UILabel *_informativeLabel;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self.clientSession removeObserver:self];
    [self.serverSession removeObserver:self];
}

#pragma mark - Dynamic Properties

- (void)setClientSession:(ClientChatSession *)clientSession {
    if (![self.clientSession isEqual:clientSession]) {
        [super setClientSession:clientSession];

        [clientSession addObserver:self];
    }
}

- (void)setServerSession:(ServerChatSession *)serverSession {
    if (![self.serverSession isEqual:serverSession]) {
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
    ConnectionEvent *connectionEvent = self.event;

    _informativeLabel.text = [NSString stringWithFormat:@"%@ did %@", connectionEvent.user.name, connectionEvent.type == kEventTypeConnected ? @"connect" : @"disconnect"];
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session userDidUpdateName:(ClientUser *)user inChat:(ClientChat *)chat {
    ConnectionEvent *connectionEvent = self.event;

    if ([connectionEvent.chat isEqual:chat] &&
        [connectionEvent.user isEqual:user]) {
        [self updateUI];
    }
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session userDidUpdateName:(ServerUser *)user {
    ConnectionEvent *connectionEvent = self.event;
    
    if ([connectionEvent.user isEqual:user]) {
        [self updateUI];
    }
}

@end
