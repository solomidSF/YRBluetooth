//
//  _YRBTChunkProvider.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/7/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "_YRBTMessagingTypes.h"

@class YRBTMessage;
@class _YRBTInternalChunk;
@class YRBTMessageOperation;

/**
 *  Class that provides chunks for sending.
 */
@interface _YRBTChunkGenerator : NSObject

+ (NSArray *)chunksForOperation:(YRBTMessageOperation *)operation
                     totalBytes:(out uint32_t *)totalBytes;

+ (NSArray *)chunksForMessage:(YRBTMessage *)message
                    messageID:(uint32_t)messageID
                operationName:(NSString *)operationName
                   isResponse:(BOOL)isResponse
                wantsResponse:(BOOL)wantsResponse
                          MTU:(uint32_t)MTU
                   totalBytes:(out uint32_t *)totalBytes;

+ (NSArray *)optimizeChunks:(NSArray *)existingChunks
                  forNewMTU:(uint32_t)newMTU;

+ (_YRBTInternalChunk *)internalChunkForCode:(YRBTInternalChunkCode)code
                              additionalData:(NSData *)data;

@end
