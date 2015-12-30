//
//  _YRBTOperationNameChunk.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTMessageChunk.h"

@class _YRBTHeaderChunk;

@interface _YRBTOperationNameChunk : _YRBTMessageChunk

/**
 *  Operation name chunk data associated with header.
 */
@property (nonatomic, readonly) NSData *operationNameUTFChunk;

+ (instancetype)operationNameChunkWithMessageID:(message_id_t)messageID
										  chunk:(NSData *)chunk;

@end
