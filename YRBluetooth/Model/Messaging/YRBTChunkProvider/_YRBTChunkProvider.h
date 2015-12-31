//
// _YRBTChunkProvider.h
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
