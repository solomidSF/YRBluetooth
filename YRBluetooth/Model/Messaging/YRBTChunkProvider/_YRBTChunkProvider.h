//
//  _YRBTChunkProvider.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 7/19/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

@protocol _YRBTChunkProviderDelegate;
@class _YRBTChunk;
@class YRBTMessageOperation;

/**
 *  Provides chunks for outgoing requests.
 */
@interface _YRBTChunkProvider : NSObject

@property (nonatomic, weak) id <_YRBTChunkProviderDelegate> delegate;

+ (instancetype)providerWithDelegate:(id <_YRBTChunkProviderDelegate>)delegate callingQueue:(dispatch_queue_t)queue;

- (void)addOperation:(YRBTMessageOperation *)operation;
- (void)cancelOperation:(YRBTMessageOperation *)operation;

/**
 *  Does not callout to delegate.
 */
- (void)invalidateChunkGenerationForOperation:(YRBTMessageOperation *)operation;

- (void)pause;
- (void)resume;

- (void)invalidate;

@end

@protocol _YRBTChunkProviderDelegate <NSObject>

- (void)chunkProvider:(_YRBTChunkProvider *)provider didGenerateChunk:(_YRBTChunk *)chunk
           forOperation:(YRBTMessageOperation *)operation isLastOne:(BOOL)isLastOne;

// TODO: Looks like it's not needed.
- (void)chunkProvider:(_YRBTChunkProvider *)provider willFinishGeneratingChunksForOperation:(YRBTMessageOperation *)operation;
- (void)chunkProvider:(_YRBTChunkProvider *)provider didFinishGeneratingChunksForOperation:(YRBTMessageOperation *)operation;
- (void)chunkProvider:(_YRBTChunkProvider *)provider didCancelChunkGenerationForOperation:(YRBTMessageOperation *)operation;

@end
