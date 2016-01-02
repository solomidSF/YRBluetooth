//
//  ChatSession.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

@interface ChatSession : NSObject

@property (nonatomic, readonly) NSString *nickname;

+ (instancetype)sessionWithNickname:(NSString *)nickname;

@end
