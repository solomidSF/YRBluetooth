//
// _YRBTInternalChunk.m
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

#import "_YRBTInternalChunk.h"

@implementation _YRBTInternalChunk

#pragma mark - Init

+ (instancetype)internalChunkWithCode:(YRBTInternalChunkCode)code
						  commandData:(NSData *)commandData {
	return [[self alloc] initWithChunkCode:code commandData:commandData];
}

- (instancetype)initWithChunkCode:(YRBTInternalChunkCode)code
					  commandData:(NSData *)commandData {
	
	uint16_t resultingSize = sizeof(YRBTInternalChunkLayout) - sizeof(void *) + commandData.length;
	
	if (self = [super initWithChunkType:kYRBTChunkTypeInternal
							  chunkSize:resultingSize]) {
		
		[self internalChunkLayout]->code = code;
		[commandData getBytes:&[self internalChunkLayout]->variadicData length:commandData.length];
	}
	
	return self;
}

- (instancetype)initWithRawData:(NSData *)data {
	if (self = [super initWithRawData:data]) {
		NSCParameterAssert(self.chunkLayout->chunkType == kYRBTChunkTypeInternal);
	}
	
	return self;
}

#pragma mark - Dynamic Properties

- (YRBTInternalChunkLayout *)internalChunkLayout {
	return (YRBTInternalChunkLayout *)(&self.chunkLayout->variadicData);
}

- (YRBTInternalChunkCode)commandCode {
	return [self internalChunkLayout]->code;
}

- (NSData *)commandData {
	return [NSData dataWithBytes:&[self internalChunkLayout]->variadicData
						  length:self.chunkLayout->chunkSize - sizeof(YRBTInternalChunkCode)];
}

@end
