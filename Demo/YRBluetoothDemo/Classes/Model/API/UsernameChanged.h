//
//  UsernameChanged.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// API
#import "APIObject.h"

// Model
#import "ServerUser.h"

@interface UsernameChanged : APIObject

@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *updatedName;

- (instancetype)initWithUser:(ServerUser *)user;

@end
