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

@implementation InformativeTableCell {
    __weak IBOutlet UILabel *_informativeLabel;
}

- (void)setEvent:(__kindof EventObject *)event {
    [super setEvent:event];
    
    ConnectionEvent *connectionEvent = event;
    
    _informativeLabel.text = [NSString stringWithFormat:@"%@ did %@", connectionEvent.user.name, connectionEvent.type == kEventTypeConnected ? @"connect" : @"disconnect"];
}

@end
