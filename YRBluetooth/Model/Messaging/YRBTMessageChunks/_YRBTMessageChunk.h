//
//  _YRBTMessageChunk.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTChunk.h"

/**
 *  Abstract class for message-related chunks.
 */
@interface _YRBTMessageChunk : _YRBTChunk

/**
 *  ID of the message being sent.
 */
@property (nonatomic, readonly) message_id_t messageID;

/**
 *  Tells if given chunk is response.
 */
@property (nonatomic, readonly) BOOL isResponse;

/**
 *  Raw message data associated with given chunk.
 */
@property (nonatomic, readonly) NSData *rawMessageData;

+ (instancetype)messageChunkWithMessageID:(message_id_t)messageID
							   isResponse:(BOOL)isResponse
								chunkType:(YRBTChunkType)chunkType
							  messageData:(NSData *)messageData;

@end
