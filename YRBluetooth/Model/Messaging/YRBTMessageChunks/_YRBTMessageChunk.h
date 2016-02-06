//
// _YRBTMessageChunk.h
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
