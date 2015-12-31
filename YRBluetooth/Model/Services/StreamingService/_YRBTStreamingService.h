//
// _YRBTStreamingService.h
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
@import CoreBluetooth;

#import "YRBTMessageOperation.h"
#import "_YRBTRemoteRequestCallbacks.h"

@class _YRBTDeviceStorage;

@protocol _YRBTReceivingStreamDelegate;
@protocol _YRBTSendingStreamDelegate;

@class YRBTSendingMessageOperation;
@class YRBTReceivingMessageOperation;

@class _YRBTWriteOperation;

typedef void (^YRBTWriteCompletionHandler) (BOOL success, NSError *cbError);

// TODO: REFACTOR COMPLETELY.

@class YRBTRemoteMessageRequest;
@class _YRBTOutgoingMessage;
@class _YRBTChunk;
@class _YRBTInternalChunk;

/**
 *  Streaming service to support receiving and sending messages.
 */
@interface _YRBTStreamingService : NSObject

@property (nonatomic, weak) id <_YRBTReceivingStreamDelegate> receivingDelegate;
@property (nonatomic, weak) id <_YRBTSendingStreamDelegate> sendingDelegate;

/**
 *  Current write opearation that should be completed.
 *  It may be nil, sendingDelegate will be notified when currentWriteOperation should be satisfied.
 */
@property (nonatomic, readonly) _YRBTWriteOperation *currentWriteOperation;

/**
 *  Chunk that should be sent to receivers contained in pending operation.
 */
@property (nonatomic, readonly) _YRBTChunk *pendingChunk;
@property (nonatomic, readonly) YRBTMessageOperation *pendingOperation;

#pragma mark - Init

+ (instancetype)streamingServiceWithStorage:(_YRBTDeviceStorage *)storage;

#pragma mark - Sending

/**
 *  Schedules operation.
 *  <#@param#> <#param name#> <#param description#>
 *  <#@return#> <#Return value description#>
 *  <#@see#> <#Similar method#>
 */
- (void)scheduleOperation:(YRBTMessageOperation *)operation;
- (void)cancelOperation:(YRBTMessageOperation *)operation;

#pragma mark - Receiving

/**
 *  Should be called when receiving data from peer.
 *  <#@param#> <#param name#> <#param description#>
 *  <#@return#> <#Return value description#>
 *  <#@see#> <#Similar method#>
 */
- (BOOL)handleReceivedData:(NSData *)data
                   forPeer:(CBPeer *)peer
            characteristic:(id)characteristic
                   cbError:(NSError *)cbError;

- (void)cancelRemoteRequest:(YRBTRemoteMessageRequest *)request;

#pragma mark - Cleanup

- (void)handlePeerDisconnected:(CBPeer *)peer;

- (void)invalidate;
- (void)invalidateWithError:(NSError *)error;

@end

@protocol _YRBTSendingStreamDelegate <NSObject>

- (void)streamingService:(_YRBTStreamingService *)service shouldSendChunk:(_YRBTChunk *)chunk
            forOperation:(YRBTMessageOperation *)operation completionHandler:(YRBTWriteCompletionHandler)completion;




- (uint32_t)streamingService:(_YRBTStreamingService *)service minMTUForReceivers:(NSArray *)receivers;



// TODO: Not needed
- (NSArray *)sendingStreamServiceAsksForConnectedPeers:(_YRBTStreamingService *)service;
- (id)sendingStreamService:(_YRBTStreamingService *)service sendingCharacteristicForPeer:(CBPeer *)peer
                                                                              isInternal:(BOOL)isInternal;
- (int16_t)sendingStreamService:(_YRBTStreamingService *)service
             minimalMTUForPeers:(NSArray *)peers;

@end

@protocol _YRBTReceivingStreamDelegate <NSObject>

- (void)streamingService:(_YRBTStreamingService *)service didReceiveServiceCommand:(_YRBTInternalChunk *)commandChunk
                fromPeer:(CBPeer *)peer;

- (_YRBTRemoteRequestCallbacks *)streamingService:(_YRBTStreamingService *)service
		 registeredCallbacksForOperationName:(NSString *)operationName;

@end