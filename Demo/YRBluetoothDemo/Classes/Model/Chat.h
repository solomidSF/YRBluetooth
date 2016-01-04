//
//  Chat.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Model
#import "User.h"
#import "Message.h"

@interface Chat : NSObject

@property (nonatomic, readonly) User *creator;
@property (nonatomic, readonly) NSArray <Message *> *messages;

@end