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
    if (self = [self init]) {
        NSDictionary *meta = [message dictionaryValue];
        
        _senderIdentifier = meta[@"identifier"];
        _isMessageByChatCreator = [meta[@"isCreatorMessage"] boolValue];
        _timestamp = [meta[@"timestamp"] doubleValue];
        _messageText = meta[@"text"];
    }
    
    return self;
}

- (instancetype)initWithSenderIdentifier:(NSString *)senderIdentfier
                      isMessageByCreator:(BOOL)isMessageByCreator
                               timestamp:(NSTimeInterval)timestamp
                             messageText:(NSString *)messageText {
    NSDictionary *meta = @{@"identifier" : senderIdentfier,
                           @"isCreatorMessage" : @(isMessageByCreator),
                           @"timestamp" : @(timestamp),
                           @"text" : messageText};
    
    YRBTMessage *message = [YRBTMessage messageWithDictionary:meta];

    return [self initWithMessage:message];
}

@end
