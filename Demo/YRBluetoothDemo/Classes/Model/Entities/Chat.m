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
@property (nonatomic, readonly) NSMutableArray <Message *> *mutableMessages;
@property (nonatomic, readwrite) NSMutableArray <User *> *mutableMembers;

@end

@implementation Chat {
    NSMutableArray <Message *> *_mutableMessages;
}

#pragma mark - Dynamic Properties 

- (NSMutableArray <Message *> *)mutableMessages {
    if (!_mutableMessages) {
        _mutableMessages = [NSMutableArray new];
    }
    
    return _mutableMessages;
}

- (NSArray <Message *> *)messages {
    return [self.mutableMessages copy];
}

- (NSArray <User *> *)members {
    return [self.mutableMembers copy];
}

@end
