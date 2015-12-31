//
// _YRBTChunkProvider.m
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

// TODO: SORT
// Messaging
#import "_YRBTChunkProvider.h"
#import "_YRBTMessaging.h"

// Internal categories
#import "YRBTMessageOperation+Private.h"

#import "_YRBTContainerPriorityQueue.h"

static void const *kCallingQueueDummyKey = &kCallingQueueDummyKey;
static void *kCallingQueueDummyValue = (void *)0xCAFEBABE;

@implementation _YRBTChunkProvider {
    dispatch_queue_t _callingQueue;
    dispatch_queue_t _chunkProviderQueue;
    BOOL _isInvalidating;
    
    BOOL _paused;
    NSMutableArray *_chunkContainers;
    _YRBTContainerPriorityQueue *_containerPriorityQueue;
    
    _YRBTChunk *_pendingGeneratedChunk;
    YRBTMessageOperation *_pendingOperation;
    BOOL _isLastChunk;
    
    NSTimer *_stallTimer;
}

#pragma mark - Init

+ (instancetype)providerWithDelegate:(id <_YRBTChunkProviderDelegate>)delegate callingQueue:(dispatch_queue_t)queue {
    return [[self alloc] initWithDelegate:delegate callingQueue:queue];
}

- (instancetype)initWithDelegate:(id <_YRBTChunkProviderDelegate>)delegate callingQueue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        _delegate = delegate;
        _callingQueue = queue;
        dispatch_queue_set_specific(_callingQueue, kCallingQueueDummyKey, kCallingQueueDummyValue, NULL);
        
        _chunkProviderQueue = dispatch_queue_create("com.YRBluetooth.chunk-provider", DISPATCH_QUEUE_SERIAL);
        _chunkContainers = [NSMutableArray new];
        _containerPriorityQueue = [_YRBTContainerPriorityQueue new];
        NSLog(@"[_YRBTChunkProvider]: <INIT> Chunk provider ready.");
    }
    
    return self;
}

#pragma mark - Public

- (void)addOperation:(YRBTMessageOperation *)operation {
    NSLog(@"[_YRBTChunkProvider]: <ADD> Adding operation: %@", operation);
    dispatch_async(_chunkProviderQueue, ^{
        NSArray *chunks = nil;
        uint32_t totalBytes = 0;
        
        if (operation.message.objectType != kYRBTObjectTypeServiceCommand) {
            chunks = [_YRBTChunkGenerator chunksForOperation:operation totalBytes:&totalBytes];
            
            NSLog(@"[_YRBTChunkProvider]: <ADD> Common message %@, got %d chunks! KBytes: %d", operation.message, (int32_t)chunks.count, totalBytes / 1024);
        } else {
            NSLog(@"[_YRBTChunkProvider]: <ADD> Service command request. %@", operation);
            _YRBTInternalChunk *internalChunk = [[_YRBTInternalChunk alloc] initWithRawData:operation.message.messageData];
            chunks = @[internalChunk];
            
            totalBytes = (uint32_t)[internalChunk packedChunkData].length;
        }
        
        operation.totalBytesToSend = totalBytes;
        
        _YRBTChunksContainer *container = [_YRBTChunksContainer containerWithChunks:chunks
                                                                      fromOperation:operation];
        
        [_chunkContainers addObject:container];
        [_containerPriorityQueue addContainer:container];
        
        [self tryToGenerateChunkAsync];
    });
}

- (void)cancelOperation:(YRBTMessageOperation *)operation {
    NSAssert(dispatch_get_specific(kCallingQueueDummyKey) == kCallingQueueDummyValue,
             @"All calls to chunk provider must be done on queue that was provided on init!");
    NSLog(@"[_YRBTChunkProvider]: <CANCEL> Cancelling generation for %@", operation);
    
    operation.isDeallocating = YES;
    
    dispatch_async(_chunkProviderQueue, ^{
        NSLog(@"[_YRBTChunkProvider]: <CANCEL> Will try remove %@", operation);
        
        _YRBTChunksContainer *container = [self containerForOperation:operation];
        
        if (container) {
            NSLog(@"[_YRBTChunkProvider]: <CANCEL> Will remove %@", operation);
            [_containerPriorityQueue removeContainer:container];
            [_chunkContainers removeObject:container];
            
            if (_pendingOperation == operation) {
                NSLog(@"[_YRBTChunkProvider]: <CANCEL> Clearing current generated chunk, because it was generated for %@ which is invalidated!", operation);
                _pendingGeneratedChunk = nil;
                _pendingOperation = nil;
                _isLastChunk = NO;
                
                if (!operation.isDeallocatingSilently) {
                    [self.delegate chunkProvider:self didCancelChunkGenerationForOperation:operation];
                }
            }
        } else {
            NSLog(@"[_YRBTChunkProvider]: <CANCEL> Container was already removed for %@.", operation);
        }
        
        [self tryToGenerateChunkAsync];
    });
}

- (void)invalidateChunkGenerationForOperation:(YRBTMessageOperation *)operation {
    operation.isDeallocatingSilently = YES;
    
    [self cancelOperation:operation];
}

- (void)pause {
    NSAssert(dispatch_get_specific(kCallingQueueDummyKey) == kCallingQueueDummyValue,
             @"All calls to chunk provider must be done on queue that was provided on init!");
    
    NSLog(@"[_YRBTChunkProvider]: <PAUSE> Will pause chunk generation...");
    _paused = YES;
    
    _stallTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                   target:self
                                                 selector:@selector(warnStalling:)
                                                 userInfo:nil
                                                  repeats:NO];
}

- (void)resume {
    NSAssert(dispatch_get_specific(kCallingQueueDummyKey) == kCallingQueueDummyValue,
             @"All calls to chunk provider must be done on queue that was provided on init!");

    if (_paused) {
        NSLog(@"[_YRBTChunkProvider]: <RESUME> Will resume chunk generation!");
        _paused = NO;
        [_stallTimer invalidate];
        
        [self tryToGenerateChunkAsync];
    }
}

- (void)invalidate {
    NSAssert(dispatch_get_specific(kCallingQueueDummyKey) == kCallingQueueDummyValue,
             @"All calls to chunk provider must be done on queue that was provided on init!");
    
    NSLog(@"[_YRBTChunkProvider]: <INVALIDATE> Will invalidate chunk generator!");
    [_stallTimer invalidate];
    _isInvalidating = YES;
    
    dispatch_async(_chunkProviderQueue, ^{
        NSLog(@"[_YRBTChunkProvider]: <INVALIDATE> INVALIDATION IN PROGRESS..");
        _pendingOperation = nil;
        _pendingGeneratedChunk = nil;
        
        for (_YRBTChunksContainer *container in [_chunkContainers copy]) {
            [_chunkContainers removeObject:container];
            [_containerPriorityQueue removeContainer:container];
        }
        
        dispatch_async(_callingQueue, ^{
            _isInvalidating = NO;
        });
    });
}

#pragma mark - Timer

- (void)warnStalling:(NSTimer *)timer {
    NSLog(@"[_YRBTChunkProvider]: <WARNING> Chunk provider is stalling!");
}

#pragma mark - Private

- (void)tryToGenerateChunkAsync {
    NSLog(@"[_YRBTChunkProvider]: <GENERATE> Checking state...");
    if ([self canGenerateSomething]) {
        NSLog(@"[_YRBTChunkProvider]: <GENERATE> Will try to generate chunk!");
        dispatch_async(_chunkProviderQueue, ^{
            if ([self canGenerateSomething]) {
                [self generateChunkWithCallout];
            }
        });
    } else {
        NSLog(@"[_YRBTChunkProvider]: <GENERATE> Won't generate. Paused? %@. Containers: %d",
              _paused ? @"YES" : @"NO",
              (int32_t)_chunkContainers.count);
    }
}

- (void)generateChunkWithCallout {
    NSAssert(_chunkContainers.count > 0, @"Wanted to generate chunk from stream, but no stream are present!");
    NSLog(@"[_YRBTChunkProvider]: <GENERATE> Generating...");
    
    if (_pendingOperation == NULL && _pendingGeneratedChunk == NULL) {
        NSLog(@"[_YRBTChunkProvider]: <GENERATE> Will generate from scratch!");
        _YRBTChunksContainer *container = [_containerPriorityQueue nextHighestPriorityContainer];
        NSLog(@"[_YRBTChunkProvider]: <GENERATE> Got container for %@", container.operation);
        NSCParameterAssert(container);
        
        // Optimize chunks if needed.
        if (container.MTU != container.operation.MTU) {
            NSLog(@"[_YRBTChunkProvider]: <GENERATE> MTU Changed, will regenerate chunks for operation, chunks left: %d", (int32_t)container.remainingChunks.count);
            container.remainingChunks = [_YRBTChunkGenerator optimizeChunks:container.remainingChunks
                                                                  forNewMTU:container.operation.MTU];
            container.MTU = container.operation.MTU;
            NSLog(@"[_YRBTChunkProvider]: <GENERATE> Chunks regenerated. Chunks left: %d", (int32_t)container.remainingChunks.count);
        }
        
        _pendingGeneratedChunk = [container nextChunk];
        _pendingOperation = container.operation;
        _isLastChunk = container.remainingChunks.count == 0;
    } else {
        NSLog(@"[_YRBTChunkProvider]: <GENERATE> Already has pending generated chunk for operation: %@, will try to provide it..", _pendingOperation);
    }
    
    dispatch_sync(_callingQueue, ^{
        NSLog(@"[_YRBTChunkProvider]: <GENERATE> Will try to provide generated chunk...");
        if (!_paused && !_isInvalidating) {
            if (!_pendingOperation.isDeallocating) {
                NSLog(@"[_YRBTChunkProvider]: <GENERATE> Chunk provided for %@!", _pendingOperation);
                // Do callout with pending chunk and pending message.
                if (_isLastChunk) {
                    [self.delegate chunkProvider:self willFinishGeneratingChunksForOperation:_pendingOperation];
                }
                
                [self.delegate chunkProvider:self didGenerateChunk:_pendingGeneratedChunk
                                forOperation:_pendingOperation isLastOne:_isLastChunk];
                
                if (_isLastChunk) {
					NSLog(@"[_YRBTChunkProvider]: <GENERATE> Finished generating chunks for %@", _pendingOperation);
					
                    _YRBTChunksContainer *emptyContainer = [self containerForOperation:_pendingOperation];
                    
                    [_containerPriorityQueue removeContainer:emptyContainer];
                    [_chunkContainers removeObject:emptyContainer];
                    
                    [self.delegate chunkProvider:self didFinishGeneratingChunksForOperation:_pendingOperation];
                }
            } else {
                NSLog(@"[_YRBTChunkProvider]: <GENERATE> Chunk generation was cancelled for %@!", _pendingOperation);
                _YRBTChunksContainer *container = [self containerForOperation:_pendingOperation];
                
                [_containerPriorityQueue removeContainer:container];
                [_chunkContainers removeObject:container];

                if (!_pendingOperation.isDeallocatingSilently) {
                    [self.delegate chunkProvider:self didCancelChunkGenerationForOperation:_pendingOperation];
                }
            }
            
            // Reset recently generated chunks.
            _pendingGeneratedChunk = nil;
            _pendingOperation = nil;
            _isLastChunk = NO;
            
            // Try to generate another chunk if we're not paused.
            [self tryToGenerateChunkAsync];
        } else {
            NSLog(@"[_YRBTChunkProvider]: <GENERATE> Couldn't provide generated chunk, because provider is paused or in invalidating state!");
        }
    });
}

- (BOOL)canGenerateSomething {
    return !_paused && _chunkContainers.count > 0;
}

- (_YRBTChunksContainer *)containerForOperation:(YRBTMessageOperation *)operation {
    for (_YRBTChunksContainer *container in _chunkContainers) {
        if (container.operation == operation) {
            return container;
        }
    }
    
    return nil;
}

@end
