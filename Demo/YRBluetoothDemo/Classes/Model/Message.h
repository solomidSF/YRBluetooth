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

@class Chat;

@interface Message : NSObject

@property (nonatomic, readonly, weak) Chat *chat; // TODO:
@property (nonatomic, readonly) User *sender;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) NSString *messageText;

- (instancetype)initWithChat:(Chat *)chat sender:(User *)sender timestamp:(NSTimeInterval)timestamp messageText:(NSString *)text;

@end
