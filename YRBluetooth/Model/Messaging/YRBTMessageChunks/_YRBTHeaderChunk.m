//
// _YRBTHeaderChunk.m
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

#import "_YRBTHeaderChunk.h"

@implementation _YRBTHeaderChunk

#pragma mark - Init

+ (instancetype)headerChunkForMessageID:(message_id_t)messageID
					  operationNameSize:(uint8_t)operationNameSize
							messageSize:(message_size_t)messageSize
							 isResponse:(BOOL)isResponse
						  wantsResponse:(BOOL)wantsResponse
							 objectType:(message_object_type_t)objectType {
	
	YRBTHeaderChunkLayout headerLayout = {0};

	headerLayout.messageSize = messageSize;
	headerLayout.operationNameSize = operationNameSize;
	headerLayout.additionalInfo |= wantsResponse;
	headerLayout.additionalInfo |= isResponse << ADDITIONAL_INFO_IS_RESPONSE_OFFSET;
	headerLayout.additionalInfo |= objectType << ADDITIONAL_INFO_OBJECT_TYPE_OFFSET;
	
	NSData *headerData = [NSData dataWithBytes:&headerLayout
										length:sizeof(headerLayout)];
	
	return [self messageChunkWithMessageID:messageID
								isResponse:isResponse
								 chunkType:kYRBTChunkTypeHeader
							   messageData:headerData];
}

- (instancetype)initWithRawData:(NSData *)data {
	if (self = [super initWithRawData:data]) {
		NSCParameterAssert(self.chunkLayout->chunkType == kYRBTChunkTypeHeader);
	}
	return self;
}

#pragma mark - Dynamic Properties

- (YRBTHeaderChunkLayout *)headerLayout {
	return (YRBTHeaderChunkLayout *)[[self rawMessageData] bytes];
}

- (uint8_t)operationNameSize {
	return [self headerLayout]->operationNameSize;
}

- (message_size_t)messageSize {
	return [self headerLayout]->messageSize;
}

- (BOOL)isResponse {
	return ([self headerLayout]->additionalInfo & ADDITIONAL_INFO_IS_RESPONSE_BITS) > 0;
}

- (BOOL)wantsResponse {
	return ([self headerLayout]->additionalInfo & ADDITIONAL_INFO_WANTS_RESPONSE_BITS) > 0;
}

- (message_object_type_t)objectType {
	return ([self headerLayout]->additionalInfo & ADDITIONAL_INFO_OBJECT_TYPE_BITS) >> ADDITIONAL_INFO_OBJECT_TYPE_OFFSET;
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
    
    return [NSString stringWithFormat:@"%@ Operation name size: %d. Message size: %d. Wants response: %d. Object type: %@",
            [super description], self.operationNameSize, self.messageSize, self.wantsResponse, readableObjectType[self.objectType]];
}

@end
