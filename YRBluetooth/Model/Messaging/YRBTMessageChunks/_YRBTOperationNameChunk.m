

//
//  _YRBTOperationNameChunk.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Messaging
#import "_YRBTOperationNameChunk.h"

@implementation _YRBTOperationNameChunk

#pragma mark - Init

+ (instancetype)operationNameChunkWithMessageID:(message_id_t)messageID
										  chunk:(NSData *)chunk {
	// Operation name is never sent in response message, because it will be the same as were on a request.
	return [self messageChunkWithMessageID:messageID
								isResponse:NO
								 chunkType:kYRBTChunkTypeOperationName
							   messageData:chunk];
}

#pragma mark - Dynamic Properties

- (NSData *)operationNameUTFChunk {
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
    
    return [NSString stringWithFormat:@"%@ Chunk: %@", [super description], [[NSString alloc] initWithData:self.operationNameUTFChunk encoding:NSUTF8StringEncoding]];
}

@end
