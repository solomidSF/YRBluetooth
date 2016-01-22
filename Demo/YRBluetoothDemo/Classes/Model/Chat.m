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
@property (nonatomic, readonly) NSMutableArray <Message *> *mutableMessages;
@property (nonatomic) NSMutableArray <User *> *mutableMembers;
@property (nonatomic) YRBTServerDevice *device;
@property (nonatomic) User *me;
@property (nonatomic) User *creator;
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

@end
