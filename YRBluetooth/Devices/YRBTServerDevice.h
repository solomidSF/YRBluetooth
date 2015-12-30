//
//  ServerDevice.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/16/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTRemoteDevice.h"

@interface YRBTServerDevice : YRBTRemoteDevice
/**
 *  Tells if client can send messages to this server.
 */
- (BOOL)canReceiveMessages;

@end