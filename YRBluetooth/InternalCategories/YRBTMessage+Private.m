//
//  BTMessage+Private.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 1/3/14.
//  Copyright (c) 2014 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTMessage+Private.h"
#import "_YRBTMessaging.h"

// Other
#import <objc/runtime.h>

@interface YRBTMessage ()
- (instancetype)initWithBTData:(NSData *)data
                          type:(YRBTObjectType)type;
@end

@implementation YRBTMessage (Private)

#pragma mark - Dynamic Properties

- (YRBTMessagePriority)priority {
    return (self.objectType == kYRBTObjectTypeServiceCommand) ? kYRBTMessagePriorityHighest : kYRBTMessagePriorityNormal;
}

#pragma mark - Public

+ (instancetype)messageWithData:(NSData *)data
                           type:(YRBTObjectType)type {
    switch (type) {
        case kYRBTObjectTypeCustom:
            return [self messageWithData:data];
        case kYRBTObjectTypeArray:
            return [self messageWithArray:[NSJSONSerialization JSONObjectWithData:data
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:nil]];
        case kYRBTObjectTypeDictionary:
            return [self messageWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingMutableContainers
                                                                                 error:nil]];
        case kYRBTObjectTypeString:
            return [self messageWithString:[[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding]];
        case kYRBTObjectTypeServiceCommand: {
            void *packetData = malloc(data.length);
            [data getBytes:packetData length:data.length];

            YRBTMessage *message = [self messageWithServiceCommand:packetData
                                                            length:(int32_t)data.length];
            
            free(packetData);
            
            return message;
        }
        default:
            NSAssert(NO, @"[YRBluetooth] Unknown object type in msg.");
            return nil;
    }
}

+ (instancetype)cancelMessageForOperationID:(message_id_t)messageID
                                   isSender:(BOOL)isSender {
    YRBTCancelCommandInternalChunkLayout cancelLayout = {isSender, messageID};
    NSData *cancelData = [NSData dataWithBytes:&cancelLayout length:sizeof(cancelLayout)];

    _YRBTInternalChunk *chunk = [_YRBTInternalChunk internalChunkWithCode:kYRBTInternalChunkCodeCancel
                                                              commandData:cancelData];
    
    return [[self alloc] initWithBTData:chunk.packedChunkData
                                   type:kYRBTObjectTypeServiceCommand];
}

@end
