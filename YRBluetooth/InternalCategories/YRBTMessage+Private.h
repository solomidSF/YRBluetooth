//
//  BTMessage+Private.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 1/3/14.
//  Copyright (c) 2014 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTMessage.h"
#import "_YRBTMessagingTypes.h"

@interface YRBTMessage (Private)

@property (nonatomic, readonly) YRBTMessagePriority priority;

+ (instancetype)messageWithData:(NSData *)data
						   type:(YRBTObjectType)type;

+ (instancetype)cancelMessageForOperationID:(message_id_t)messageID
                                   isSender:(BOOL)isSender;

@end
