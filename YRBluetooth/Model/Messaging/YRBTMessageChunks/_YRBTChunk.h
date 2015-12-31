//
// _YRBTChunk.h
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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

- (__kindof _YRBTChunk *)initWithRawData:(NSData *)data;
- (__kindof _YRBTChunk *)initWithChunkType:(YRBTChunkType)type
								 chunkSize:(uint16_t)chunkSize;

@end