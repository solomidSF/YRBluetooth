//
//  _YRBTChunksContainer.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 8/2/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTChunksContainer.h"

@implementation _YRBTChunksContainer {
    NSMutableArray *_remainingChunks;
}

#pragma mark - Init

+ (instancetype)containerWithChunks:(NSArray *)chunks
                        fromOperation:(YRBTMessageOperation *)operation {
    return [[self alloc] initWithChunks:chunks
                          fromOperation:operation];
}

- (instancetype)initWithChunks:(NSArray *)chunks
                 fromOperation:(YRBTMessageOperation *)operation {
    if (self = [super init]) {
        _remainingChunks = [chunks mutableCopy];
        _operation = operation;
        _MTU = operation.MTU;
    }
    
    return self;
}

#pragma mark - Dynamic Properties

- (void)setRemainingChunks:(NSArray *)remainingChunks {
    _remainingChunks = [remainingChunks mutableCopy];
}

#pragma mark - Public

- (_YRBTChunk *)nextChunk {
    _YRBTChunk *chunk = [_remainingChunks firstObject];
    
    if (chunk) {
        [_remainingChunks removeObject:chunk];
    }
    
    return chunk;
}

@end
