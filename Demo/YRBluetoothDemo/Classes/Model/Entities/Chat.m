//
//  Chat.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "Chat.h"

// Components
#import "YRBluetooth.h"

@interface Chat ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) User *me;
@property (nonatomic, readwrite) NSMutableArray <User *> *mutableMembers;
@property (nonatomic, readonly) NSMutableArray <__kindof EventObject *> *mutableEvents;

@end

@implementation Chat {
    NSMutableArray <__kindof EventObject *> *_mutableEvents;
}

#pragma mark - Dynamic Properties 

- (NSMutableArray <__kindof EventObject *> *)mutableEvents {
    if (!_mutableEvents) {
        _mutableEvents = [NSMutableArray new];
    }
    
    return _mutableEvents;
}

- (NSArray <__kindof EventObject *> *)events {
    return [self.mutableEvents copy];
}

- (NSArray <User *> *)members {
    return [self.mutableMembers copy];
}

@end
