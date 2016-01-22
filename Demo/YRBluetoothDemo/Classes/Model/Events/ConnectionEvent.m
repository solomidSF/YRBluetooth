//
//  ConnectionEvent.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "ConnectionEvent.h"

// Cells
#import "InformativeTableCell.h"

@implementation ConnectionEvent

#pragma mark - Init

- (instancetype)initWithChat:(Chat *)chat user:(User *)user eventType:(EventType)type timestamp:(NSTimeInterval)timestamp {
    if (self = [super initWithTimestamp:timestamp]) {
        _chat = chat;
        _user = user;
        _type = type;
    }
                            
    return self;
}

#pragma mark - Dynamic Properties

- (NSString *)reuseIdentifier {
    return NSStringFromClass([InformativeTableCell class]);
}

@end
