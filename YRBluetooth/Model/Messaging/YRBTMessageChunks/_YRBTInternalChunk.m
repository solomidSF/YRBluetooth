//
//  _YRBTInternalChunk.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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
