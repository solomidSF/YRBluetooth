//
// _YRBTHeaderChunk.h
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

#import "_YRBTMessageChunk.h"

@interface _YRBTHeaderChunk : _YRBTMessageChunk

/**
 *  Size of operation name associated with given message in bytes.
 */
@property (nonatomic, readonly) uint8_t operationNameSize;

/**
 *  Message size up to 4 GB.
 */
@property (nonatomic, readonly) message_size_t messageSize;

/**
 *  Tells that given message wants response from receiver.
 */
@property (nonatomic, readonly) BOOL wantsResponse;

/**
 *  Object type that is contained in message.
 */
@property (nonatomic, readonly) message_object_type_t objectType;

+ (instancetype)headerChunkForMessageID:(message_id_t)messageID
					  operationNameSize:(uint8_t)operationNameSize
							messageSize:(message_size_t)messageSize
							 isResponse:(BOOL)isResponse
						  wantsResponse:(BOOL)wantsResponse
							 objectType:(message_object_type_t)objectType;

@end
