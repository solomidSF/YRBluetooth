//
//  _YRBTInternalChunk.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTChunk.h"

/**
 *  Chunk that represents internal command to receiver.
 *	This is like one-chunk-command.
 */
@interface _YRBTInternalChunk : _YRBTChunk

/**
 *  Internal command code.
 */
@property (nonatomic, readonly) YRBTInternalChunkCode commandCode;

/**
 *  Additional command data associated with given chunk.
 */
@property (nonatomic, readonly) NSData *commandData;

+ (instancetype)internalChunkWithCode:(YRBTInternalChunkCode)code
						  commandData:(NSData *)commandData;

@end
