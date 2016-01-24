//
//  NewMessageEvent.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "NewMessage.h"

@implementation NewMessage

#pragma mark - Init

- (instancetype)initWithMessage:(YRBTMessage *)message {
    if (self = [super initWithMessage:message]) {
        NSDictionary *meta = [message dictionaryValue];
        
        _senderIdentifier = meta[@"id"];
        _isMessageByChatCreator = [meta[@"isc"] boolValue];
        _timestamp = [meta[@"tsp"] doubleValue];
        _messageText = meta[@"m"];
    }
    
    return self;
}

- (instancetype)initWithSenderIdentifier:(NSString *)senderIdentfier
                      isMessageByCreator:(BOOL)isMessageByCreator
                               timestamp:(NSTimeInterval)timestamp
                             messageText:(NSString *)messageText {
    NSDictionary *meta = @{@"id" : senderIdentfier,
                           @"isc" : @(isMessageByCreator),
                           @"tsp" : @(timestamp),
                           @"m" : messageText};
    
    YRBTMessage *message = [YRBTMessage messageWithDictionary:meta];

    return [self initWithMessage:message];
}

@end
