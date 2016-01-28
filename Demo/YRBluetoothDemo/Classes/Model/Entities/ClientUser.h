//
//  ClientUser.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/27/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "User.h"

/**
 *  User from client's perspective.
 */
@interface ClientUser : User

@property (nonatomic, readonly) BOOL isConnected;

@end
