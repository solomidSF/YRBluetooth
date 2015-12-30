//
//  _YRBTMessageChunk.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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
