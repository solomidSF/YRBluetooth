//
//  _YRBTWriteOperation.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 3/7/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTWriteOperation.h"

@implementation _YRBTWriteOperation

#pragma mark - Init

+ (instancetype)operationWithChunk:(NSData *)chunk
                          forPeers:(NSArray *)peers
                 forCharacteristic:(id)characteristic
                 completionHandler:(YRBTWriteCompletionHandler)completion {
    return [[self alloc] initWithChunk:chunk
                              forPeers:peers
                     forCharacteristic:characteristic
                     completionHandler:completion];
}

- (instancetype)initWithChunk:(NSData *)chunk
                     forPeers:(NSArray *)peers
            forCharacteristic:(id)characteristic
            completionHandler:(YRBTWriteCompletionHandler)completion {
    if (self = [super init]) {
        _chunkData = chunk;
        _receivingPeers = [peers mutableCopy];
        _characteristic = characteristic;
        _completionHandler = completion;
    }
    return self;
}
@end
