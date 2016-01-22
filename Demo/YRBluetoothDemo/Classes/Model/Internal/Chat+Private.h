//
//  Chat+Private.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "Chat.h"

// Components
#import "YRBluetooth.h"

@interface Chat (Private)

@property (nonatomic, readonly) NSMutableArray <Message *> *mutableMessages;
@property (nonatomic) NSMutableArray <User *> *mutableMembers;

@end

@interface Chat (ClientPerspective)

@property (nonatomic) YRBTServerDevice *device;
@property (nonatomic) User *me;
@property (nonatomic) User *creator;

+ (instancetype)chatForDevice:(YRBTServerDevice *)device;

@end