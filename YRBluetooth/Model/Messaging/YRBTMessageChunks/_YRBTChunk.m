//
//  _YRBTChunk.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTChunk.h"

#import "_YRBTMessaging.h"

@implementation _YRBTChunk

#pragma mark - Lifecycle

- (instancetype)initWithRawData:(NSData *)data {
    if ([self isMemberOfClass:[_YRBTChunk class]]) {
        YRBTChunkLayout layout = {0};
        [data getBytes:&layout length:sizeof(layout)];
        
        switch (layout.chunkType) {
            case kYRBTChunkTypeInternal:
                return [[_YRBTInternalChunk alloc] initWithRawData:data];
            case kYRBTChunkTypeHeader:
                return [[_YRBTHeaderChunk alloc] initWithRawData:data];
            case kYRBTChunkTypeOperationName:
                return [[_YRBTOperationNameChunk alloc] initWithRawData:data];
            case kYRBTChunkTypeRegular:
                return [[_YRBTRegularMessageChunk alloc] initWithRawData:data];
            default:
                NSAssert(NO, @"Unsupported chunk type!");
                return nil;
        }
    }
    
	if (self = [super init]) {
		NSCParameterAssert(data.length > 0);
		
		_chunkLayout = malloc(data.length);
		[data getBytes:_chunkLayout length:data.length];
	}
	
	return self;
}

- (instancetype)initWithChunkType:(YRBTChunkType)type
						chunkSize:(uint16_t)chunkSize {
	if (self = [super init]) {
		_chunkLayout = calloc(1, chunkSize + sizeof(YRBTChunkLayout) - sizeof(void *));
		
		_chunkLayout->chunkType = type;
		_chunkLayout->chunkSize = chunkSize;
	}
	
	return self;
}

- (void)dealloc {
	free(_chunkLayout);
}

#pragma mark - Dynamic Properties

- (YRBTChunkType)chunkType {
	return _chunkLayout->chunkType;
}

- (uint16_t)chunkSize {
	return _chunkLayout->chunkSize;
}

- (NSData *)packedChunkData {
	return [NSData dataWithBytes:_chunkLayout length:_chunkLayout->chunkSize + sizeof(YRBTChunkLayout) - sizeof(void *)];
}

#pragma mark - NSObject

- (NSString *)description {
    static NSArray *readableTypes = nil;
    
    if (!readableTypes) {
        readableTypes = @[@"Internal",
                          @"Header",
                          @"Operation name",
                          @"Regular"];
    }
    
    return [NSString stringWithFormat:@"%@. Chunk type: %@. Size: %d.", [super description], readableTypes[self.chunkType], self.chunkSize];
}

@end