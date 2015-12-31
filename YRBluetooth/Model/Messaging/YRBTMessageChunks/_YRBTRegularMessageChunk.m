//
// _YRBTRegularMessageChunk.m
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

#import "_YRBTRegularMessageChunk.h"

@implementation _YRBTRegularMessageChunk

#pragma mark - Init

+ (instancetype)regularMessageChunkWithMessageID:(message_id_t)messageID
									  isResponse:(BOOL)isResponse
									   chunkData:(NSData *)data {
	return [self messageChunkWithMessageID:messageID
								isResponse:isResponse
								 chunkType:kYRBTChunkTypeRegular
							   messageData:data];
}

#pragma mark - Dynamic Properties

- (NSData *)chunkData {
	return self.rawMessageData;
}

#pragma mark - NSObject

- (NSString *)description {
    static NSArray *readableObjectType = nil;
    
    if (!readableObjectType) {
        readableObjectType = @[@"Custom",
                               @"Array",
                               @"Dictionary",
                               @"String"];
    }
    
    return [NSString stringWithFormat:@"%@ Chunk: %@", [super description], [[NSString alloc] initWithData:self.chunkData encoding:NSUTF8StringEncoding]];
}

@end
