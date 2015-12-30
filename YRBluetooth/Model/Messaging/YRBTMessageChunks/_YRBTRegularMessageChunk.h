//
//  _YRBTRegularMessageChunk.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/17/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTMessageChunk.h"

@interface _YRBTRegularMessageChunk : _YRBTMessageChunk

/**
 *  Chunk data associated with given message chunk.
 */
@property (nonatomic, readonly) NSData *chunkData;

+ (instancetype)regularMessageChunkWithMessageID:(message_id_t)messageID
									  isResponse:(BOOL)isResponse
									   chunkData:(NSData *)data;

@end
