//
//  _YRBTChunk.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "_YRBTMessagingTypes.h"

/**
 *  Abstract class for all chunks that can be sent using YRBluetooth.
 */
@interface _YRBTChunk : NSObject

/**
 *  Type of chunk.
 */
@property (nonatomic, readonly) YRBTChunkType chunkType;

/**
 *  Size of given chunk.
 */
@property (nonatomic, readonly) uint16_t chunkSize;

/**
 *  Raw chunk layout structure.
 */
@property (nonatomic, readonly) YRBTChunkLayout *chunkLayout;

/**
 *  Returns packed chunk data ready for sending.
 */
@property (nonatomic, readonly) NSData *packedChunkData;

/**
 *  Designated initializer methods.
 */
- (__kindof _YRBTChunk *)initWithRawData:(NSData *)data;

- (__kindof _YRBTChunk *)initWithChunkType:(YRBTChunkType)type
								 chunkSize:(uint16_t)chunkSize;

@end