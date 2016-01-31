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

@implementation MessageTableCell {
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_messageLabel;
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

@end
