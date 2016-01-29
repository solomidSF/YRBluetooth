//
//  UserEvent.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/16/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// API
#import "APIObject.h"

// Model
#import "User.h"

typedef enum {
    kUserConnectionTypeConnected,
    kUserConnectionTypeDisconnected
} UserConnectionType;

@interface UserConnection : APIObject

@property (nonatomic, readonly) UserConnectionType eventType;
@property (nonatomic, readonly) NSTimeInterval timestamp;

@property (nonatomic, readonly) NSString *userIdentifier;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readonly) NSString *userName;

- (instancetype)initWithEventType:(UserConnectionType)eventType user:(__kindof User *)user timestamp:(NSTimeInterval)timestamp;

@end
