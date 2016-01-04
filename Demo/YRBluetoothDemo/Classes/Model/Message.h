//
//  Message.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

// Model
#import "User.h"

@interface Message : NSObject

@property (nonatomic, readonly) uint64_t messageID;
@property (nonatomic, readonly) User *sender;
@property (nonatomic, readonly) NSString *messageText;

@end
