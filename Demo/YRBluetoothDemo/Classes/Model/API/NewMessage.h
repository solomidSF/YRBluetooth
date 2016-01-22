//
//  NewMessageEvent.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/18/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "APIObject.h"

@interface NewMessage : APIObject

@property (nonatomic, readonly) NSString *senderIdentifier;
/**
 *  For each client chat creator identifier will be different.
 *  We won't use identifier concept for chat creator.
 */
@property (nonatomic, readonly) BOOL isMessageByChatCreator;
@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) NSString *messageText;

- (instancetype)initWithSenderIdentifier:(NSString *)senderIdentfier
                      isMessageByCreator:(BOOL)isMessageByCreator
                               timestamp:(NSTimeInterval)timestamp
                             messageText:(NSString *)messageText;

@end
