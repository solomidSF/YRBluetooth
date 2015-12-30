//
//  _YRBTRegularMessageChunk.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/17/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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
