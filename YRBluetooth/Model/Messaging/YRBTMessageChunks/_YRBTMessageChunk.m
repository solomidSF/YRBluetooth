//
// _YRBTMessageChunk.m
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

@implementation _YRBTMessageChunk

#pragma mark - Init

+ (instancetype)messageChunkWithMessageID:(message_id_t)messageID
                               isResponse:(BOOL)isResponse
                                chunkType:(YRBTChunkType)type
                              messageData:(NSData *)messageData {
    return [[self alloc] initWithMessageID:messageID
                                isResponse:isResponse
                                 chunkType:type
                               messageData:messageData];
}

- (instancetype)initWithMessageID:(message_id_t)messageID
                       isResponse:(BOOL)isResponse
                        chunkType:(YRBTChunkType)type
                      messageData:(NSData *)data {
    uint16_t chunkSize = sizeof(YRBTMessageChunkLayout) - sizeof(void *) + data.length;
    
    if (self = [super initWithChunkType:type
                              chunkSize:chunkSize]) {
        
        [self messageChunkLayout]->messageID = messageID;
        [self messageChunkLayout]->isResponse = isResponse;
        [data getBytes:&[self messageChunkLayout]->variadicData length:data.length];
    }
    
    return self;
}

#pragma mark - Dynamic Properties

- (YRBTMessageChunkLayout *)messageChunkLayout {
    YRBTMessageChunkLayout *resultingLayout = (YRBTMessageChunkLayout *)&self.chunkLayout->variadicData;
    
    return resultingLayout;
}

- (message_id_t)messageID {
    return [self messageChunkLayout]->messageID;
}

- (BOOL)isResponse {
    return ([self messageChunkLayout]->isResponse & 0x1) > 0;
}

- (NSData *)rawMessageData {
    return [NSData dataWithBytes:&[self messageChunkLayout]->variadicData
                          length:self.chunkLayout->chunkSize - sizeof(message_id_t) - sizeof(uint16_t)];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ Message ID: %d. Is response: %d", [super description], self.messageID, self.isResponse];
}

@end
