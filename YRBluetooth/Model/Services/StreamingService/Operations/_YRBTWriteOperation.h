//
//  _YRBTWriteOperation.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 3/7/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

typedef void (^YRBTWriteCompletionHandler) (BOOL success, NSError *cbError);

@interface _YRBTWriteOperation : NSObject

@property (nonatomic, readonly) NSData *chunkData;
@property (nonatomic, readonly) NSMutableArray *receivingPeers;
@property (nonatomic, readonly) id characteristic;
@property (nonatomic, copy, readonly) YRBTWriteCompletionHandler completionHandler;

+ (instancetype)operationWithChunk:(NSData *)chunk
                          forPeers:(NSArray *)peers
                 forCharacteristic:(id)characteristic
                 completionHandler:(YRBTWriteCompletionHandler)completion;

@end
