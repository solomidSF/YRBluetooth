//
//  ClientChat.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/24/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "Chat.h"

/**
 *  Chat from client's perspective.
 */
@interface ClientChat : Chat

@property (nonatomic, readonly) User *creator;

@end
