//
//  _YRBTChunksContainer.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 8/2/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "_YRBTChunk.h"
#import "YRBTMessageOperation.h"

@interface _YRBTChunksContainer : NSObject

@property (nonatomic) NSArray *remainingChunks;
@property (nonatomic, readonly) YRBTMessageOperation *operation;
@property (nonatomic) uint16_t MTU;

+ (instancetype)containerWithChunks:(NSArray *)chunks
                      fromOperation:(YRBTMessageOperation *)operation;

- (_YRBTChunk *)nextChunk;

@end
