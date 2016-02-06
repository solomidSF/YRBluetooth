//
// _YRBTStreamingService.m
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
// Services.
#import "_YRBTStreamingService.h"

// Messaging
#import "_YRBTMessaging.h"
#import "YRBTRemoteMessageOperation.h"

// Categories.
#import "YRBTMessageOperation+Private.h"
#import "YRBTRemoteMessageOperation+Private.h"

// TODO: Refactor
#import "YRBTRemoteDevice.h"
#import "_YRBTErrorService.h"
#import "_YRBTDeviceStorage.h"

// General Types.
#import "_YRBTMessaging.h"
#import "YRBluetoothTypes.h"

// TODO:
#import "BTPrefix.h"

@interface _YRBTStreamingService (Protocols)
<
_YRBTChunkProviderDelegate,
_YRBTChunkParserDelegate
>
@end

// TODO: Validation.
@implementation _YRBTStreamingService {
    _YRBTDeviceStorage *_storage;
    
    NSMutableArray <YRBTMessageOperation *> *_operations;
    NSMutableArray <YRBTRemoteMessageOperation *> *_remoteOperations;
    
    _YRBTChunkProvider *_provider;
    _YRBTChunkParser *_parser;
    
    dispatch_queue_t _streamingQueue;
}

#pragma mark - Init

+ (instancetype)streamingServiceWithStorage:(_YRBTDeviceStorage *)storage {
    return [[self alloc] initWithStorage:storage];
}

- (instancetype)initWithStorage:(_YRBTDeviceStorage *)storage {
    if (self = [super init]) {
        NSLog(@"[_YRBTStreamingService]: Initializing...");
        _storage = storage;
        
        _operations = [NSMutableArray new];
        _remoteOperations = [NSMutableArray new];
        
        _provider = [_YRBTChunkProvider providerWithDelegate:self
                                                callingQueue:dispatch_get_main_queue()];
        _parser = [_YRBTChunkParser parserWithDelegate:self];
        
        _streamingQueue = dispatch_queue_create("com.YRBluetooth.streaming-queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - Sending

- (void)scheduleOperation:(YRBTMessageOperation *)operation {
    NSAssert(operation.status == kYRBTMessageOperationStatusWaiting,
             @"[YRBTStreamingService]: You can't schedule same operation twice!");
    
    if (operation.status != kYRBTMessageOperationStatusWaiting) {
        // Operation was already scheduled.
        return;
    }
    
    operation.streamingService = self;
    operation.status = kYRBTMessageOperationStatusSending;
    
    [_operations addObject:operation];
    
    [_provider addOperation:operation];
}

- (void)cancelOperation:(YRBTMessageOperation *)operation {
    if ([_operations containsObject:operation] &&
        (operation.status == kYRBTMessageOperationStatusWaiting ||
         operation.status == kYRBTMessageOperationStatusSending ||
         operation.status == kYRBTMessageOperationStatusReceiving)) {
            
            [self invalidateOperation:operation];
            
            [_provider invalidateChunkGenerationForOperation:operation];
            
            operation.status = kYRBTMessageOperationStatusCancelled;
            !operation.failureCallback ? : operation.failureCallback(operation,
                                                                     [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendCancelled]);
            
            if (_pendingOperation == operation) {
                // If current message to be written was this one - resume chunk generation and perform cleanup.
                [_provider resume];
                
                _pendingChunk = nil;
                _pendingOperation = nil;
            }
            
            YRBTMessageOperation *cancelOperation = [YRBTMessageOperation cancelOperationForOperation:operation];
            
            [self scheduleOperation:cancelOperation];
        }
}

#pragma mark - Receiving

- (BOOL)handleReceivedData:(NSData *)data
                   forPeer:(CBPeer *)peer
            characteristic:(id)characteristic
                   cbError:(NSError *)cbError {
    if (!cbError) {
        [_parser parseChunk:data
                 fromSender:peer];
        
        return YES;
    } else {
        // Shouldn't happen.
        // Investigate value of characteristic.
        BTDebugMsg(@"[StreamingService]: Failed to receive chunk from server %@ with error: %@",
                   [_storage deviceForPeer:peer],
                   cbError);
        return NO;
    }
}

- (void)cancelRemoteOperation:(YRBTRemoteMessageOperation *)operation {
    if ([_remoteOperations containsObject:operation] &&
        operation.status == kYRBTRemoteMessageOperationStatusReceiving) {
        
        // TODO: It would work like that till we move all logic to our queue. (Callouts will be in the same runloop cycle)
        [self invalidateRemoteOperation:operation];
        
        operation.status = kYRBTRemoteMessageOperationStatusCancelled;
        !operation.failureCallback ? : operation.failureCallback(operation,
                                                                 [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendCancelled]);
        
        YRBTMessageOperation *cancelOperation = [YRBTMessageOperation cancelOperationForRemoteOperation:operation];
        
        [self scheduleOperation:cancelOperation];
    }
}

#pragma mark - Cleanup

- (void)handlePeerDisconnected:(CBPeer *)peer {
    BTDebugMsg(@"[StreamingService]: <%@> disconnected! Will invalidate current operations for it.", [_storage deviceForPeer:peer]);
    YRBTRemoteDevice *device = [_storage deviceForPeer:peer];
    
    for (YRBTMessageOperation *operation in [_operations copy]) {
        if ([operation.mutableReceivers containsObject:device]) {
            
            [operation.mutableReceivers removeObject:device];
            
            if (operation.mutableReceivers.count == 0) {
                NSLog(@"[_YRBTStreamingService]: No receivers left for %@", operation);
                [self invalidateOperation:operation];
                
                [_provider invalidateChunkGenerationForOperation:operation];
                
                operation.status = kYRBTMessageOperationStatusFailed;
                !operation.failureCallback ? : operation.failureCallback(operation,
                                                                         [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeNoReceivers]);
                
                if (_pendingOperation == operation) {
                    // If current message to be written was this one and we don't have receivers for it anymore - resume chunk generation and perform cleanup.
                    [_provider resume];
                    
                    _pendingChunk = nil;
                    _pendingOperation = nil;
                }
            } else if (/* mtu dynamic */1) {
                // TODO: Set mtu to minimum value of receiving peers.
            }
        }
    }
    
    for (YRBTRemoteMessageOperation *operation in [_remoteOperations copy]) {
        if ([operation.sender isEqual:device]) {
            [self invalidateRemoteOperation:operation];
            
            operation.status = kYRBTRemoteMessageOperationStatusFailed;
            !operation.failureCallback ? : operation.failureCallback(operation,
                                                                     [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeDisconnected]);
        }
    }
}

- (void)invalidate {
    BTDebugMsg(@"[StreamingService]: Will invalidate.");
    [_provider invalidate];
    
    for (YRBTMessageOperation *operation in [_operations copy]) {
        [self invalidateOperation:operation];
        
        [_provider invalidateChunkGenerationForOperation:operation];
        
        operation.status = kYRBTMessageOperationStatusFailed;
        !operation.failureCallback ? : operation.failureCallback(operation, [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendingFailed]);
    }
    
    for (YRBTRemoteMessageOperation *operation in [_remoteOperations copy]) {
        [self invalidateRemoteOperation:operation];
        
        operation.status = kYRBTRemoteMessageOperationStatusFailed;
        
        operation.failureCallback ? : operation.failureCallback(operation,
                                                                [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeReceivingFailed]);
    }
}

- (void)invalidateWithError:(NSError *)error {
    BTDebugMsg(@"[StreamingService]: Will invalidate with error: %@", error);
    [_provider invalidate];
    
    for (YRBTMessageOperation *operation in [_operations copy]) {
        [self invalidateOperation:operation];
        
        [_provider invalidateChunkGenerationForOperation:operation];
        
        operation.status = kYRBTMessageOperationStatusFailed;
        !operation.failureCallback ? : operation.failureCallback(operation,
                                                                 [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendingFailed]);
    }
    
    for (YRBTRemoteMessageOperation *operation in [_remoteOperations copy]) {
        [self invalidateRemoteOperation:operation];
        
        operation.status = kYRBTRemoteMessageOperationStatusFailed;
        
        operation.failureCallback ? : operation.failureCallback(operation,
                                                                [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeReceivingFailed]);
    }
}

#pragma mark - NSTimer

- (void)handleTimeoutForOperation:(NSTimer *)timeoutTimer {
    YRBTMessageOperation *operation = timeoutTimer.userInfo;
    
    [self invalidateOperation:operation];
    
    [_provider invalidateChunkGenerationForOperation:operation];
    
    operation.status = kYRBTMessageOperationStatusFailed;
    
    !operation.failureCallback ? : operation.failureCallback(operation, [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendTimeout]);
    
    if (_pendingOperation == operation) {
        // If current message to be written was this one - resume chunk generation and perform cleanup.
        [_provider resume];
        
        _pendingChunk = nil;
        _pendingOperation = nil;
    }
}

- (void)handleTimeoutForRemoteOperation:(NSTimer *)timeoutTimer {
    YRBTRemoteMessageOperation *operation = timeoutTimer.userInfo;
    
    [self invalidateRemoteOperation:operation];
    
    operation.status = kYRBTRemoteMessageOperationStatusFailed;
    !operation.failureCallback ? : operation.failureCallback(operation,
                                                             [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeReceiveTimeout]);
    
    [self scheduleOperation:[YRBTMessageOperation cancelOperationForRemoteOperation:operation]];
}

#pragma mark - Private

- (YRBTMessageOperation *)operationForResponseChunk:(__kindof _YRBTMessageChunk *)chunk {
    for (YRBTMessageOperation *operation in _operations) {
        if (operation.messageID == chunk.messageID) {
            return operation;
        }
    }
    
    return nil;
}

- (YRBTRemoteMessageOperation *)remoteOperationForChunk:(__kindof _YRBTMessageChunk *)chunk sender:(__kindof CBPeer *)peer {
    for (YRBTRemoteMessageOperation *operation in _remoteOperations) {
        if (operation.messageID == chunk.messageID &&
            [operation.sender isEqual:[_storage deviceForPeer:peer]]) {
            return operation;
        }
    }
    
    return nil;
}

/**
 *  Invalidates operation SILENTLY, without calling any callbacks.
 */
- (void)invalidateOperation:(YRBTMessageOperation *)operation {
    [operation.timeoutTimer invalidate];
    operation.timeoutTimer = nil;
    
    [_operations removeObject:operation];
}

/**
 *  Invalidates operation SILENTLY, without calling any callbacks.
 */
- (void)invalidateRemoteOperation:(YRBTRemoteMessageOperation *)operation {
    [operation.timeoutTimer invalidate];
    operation.timeoutTimer = nil;
    
    [_remoteOperations removeObject:operation];
}

- (void)restartTimerForOperation:(YRBTMessageOperation *)operation {
    [operation.timeoutTimer invalidate];
    
    operation.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:operation.timeoutInterval
                                                              target:self
                                                            selector:@selector(handleTimeoutForOperation:)
                                                            userInfo:operation
                                                             repeats:NO];
}

- (void)restartTimerForRemoteOperation:(YRBTRemoteMessageOperation *)operation {
    [operation.timeoutTimer invalidate];
    
    operation.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kYRBTDefaultTimeoutInterval
                                                              target:self
                                                            selector:@selector(handleTimeoutForRemoteOperation:)
                                                            userInfo:operation
                                                             repeats:NO];
}

#pragma mark - <_YRBTChunkProviderDelegate>

- (void)chunkProvider:(_YRBTChunkProvider *)provider didGenerateChunk:(_YRBTChunk *)chunk
         forOperation:(YRBTMessageOperation *)operation isLastOne:(BOOL)isLastOne {
    [_provider pause];
    
    [self restartTimerForOperation:operation];
    
    _pendingOperation = operation;
    _pendingChunk = chunk;
    
    [self.sendingDelegate streamingService:self
                           shouldSendChunk:chunk
                              forOperation:operation
                         completionHandler:^(BOOL success, NSError *cbError) {
                             NSLog(@"[_YRBTStreamingService]: Sending delegate did finish writing. Did write: <%d> ERR: %@",
                                   success,
                                   cbError);
                             
                             if (_pendingChunk == chunk &&
                                 _pendingOperation == operation &&
                                 (operation.status != kYRBTMessageOperationStatusCancelled &&
                                  operation.status != kYRBTMessageOperationStatusCancelledByRemote &&
                                  operation.status != kYRBTMessageOperationStatusFailed)) {
                                     
                                     if (success) {
                                         operation.bytesSent += (uint32_t)[chunk packedChunkData].length;
                                         
                                         YRBTProgressCallback progress = operation.sendingProgressCallback;
                                         !progress ? : progress(operation.bytesSent, operation.totalBytesToSend);
                                         
                                         if (!isLastOne) {
                                             // Simply remove timers.
                                             [operation.timeoutTimer invalidate];
                                             operation.timeoutTimer = nil;
                                         } else {
                                             if (operation.responseCallback != NULL) {
                                                 // If we are waiting for response -> restart our timeout timer.
                                                 [self restartTimerForOperation:operation];
                                                 
                                                 operation.status = kYRBTMessageOperationStatusReceiving;
                                             } else {
                                                 operation.status = kYRBTMessageOperationStatusFinished;
                                                 
                                                 [self invalidateOperation:operation];
                                             }
                                             
                                             !operation.sendCallback ? : operation.sendCallback(operation);
                                         }
                                     } else {
                                         [self invalidateOperation:operation];
                                         [_provider invalidateChunkGenerationForOperation:operation];
                                         
                                         operation.status = kYRBTMessageOperationStatusFailed;
                                         
                                         !operation.failureCallback ? : operation.failureCallback(operation, [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendingFailed]);
                                     }
                                     
                                     _pendingChunk = nil;
                                     _pendingOperation = nil;
                                     
                                     [_provider resume];
                                 }
                         }];
}

// TODO: Not needed.
- (void)chunkProvider:(_YRBTChunkProvider *)provider willFinishGeneratingChunksForOperation:(YRBTMessageOperation *)operation {
    // Remove if won't be used
}

- (void)chunkProvider:(_YRBTChunkProvider *)provider didFinishGeneratingChunksForOperation:(YRBTMessageOperation *)operation {
    // Remove if won't be used
}

- (void)chunkProvider:(_YRBTChunkProvider *)provider didCancelChunkGenerationForOperation:(YRBTMessageOperation *)operation {
    // Not needed too. We do instant callout on cancel operation.
}

#pragma mark - <_YRBTChunkParserDelegate>

- (void)chunkParser:(_YRBTChunkParser *)parser didParseInternalChunk:(_YRBTInternalChunk *)chunk
         fromSender:(CBPeer *)sender {
    
    if (chunk.commandCode == kYRBTInternalChunkCodeCancel) {
        YRBTCancelCommandInternalChunkLayout cancelLayout = {0};
        
        [chunk.commandData getBytes:&cancelLayout length:sizeof(YRBTCancelCommandInternalChunkLayout)];
        
        // Is sender in this chunk means that remote is sender of remote operation.
        BOOL isSearchingForResponse = cancelLayout.isSender;
        
        NSLog(@"[_YRBTStreamingService]: Remote cancel. Message id: %d. Is response: %d, remote: %@",
              cancelLayout.messageID,
              isSearchingForResponse,
              sender);
        
        for (YRBTMessageOperation *operation in [_operations copy]) {
            // Find operation that remote requests to cancel.
            if (operation.messageID == cancelLayout.messageID &&
                isSearchingForResponse == operation.isResponse) {
                
                NSLog(@"[_YRBTStreamingService]: Found operation remote requested to cancel: %@", operation);
                
                // Check if operation is still in progress.
                if (operation.status == kYRBTMessageOperationStatusWaiting ||
                    operation.status == kYRBTMessageOperationStatusSending ||
                    operation.status == kYRBTMessageOperationStatusReceiving) {
                    
                    __kindof YRBTRemoteDevice *device = [_storage deviceForPeer:sender];
                    
                    // Remove remote from the list of receivers for given operation.
                    if ([operation.mutableReceivers containsObject:device]) {
                        [operation.mutableReceivers removeObject:device];
                        
                        if (operation.mutableReceivers.count == 0) {
                            NSLog(@"[_YRBTStreamingService]: No receivers left for %@", operation);
                            
                            [self invalidateOperation:operation];
                            
                            [_provider invalidateChunkGenerationForOperation:operation];
                            
                            operation.status = kYRBTMessageOperationStatusCancelledByRemote;
                            !operation.failureCallback ? : operation.failureCallback(operation,
                                                                                     [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendCancelledByRemote]);
                            
                            if (_pendingOperation == operation) {
                                // If current message to be written was this one and we don't have receivers for it anymore - resume chunk generation and perform cleanup.
                                [_provider resume];
                                
                                _pendingChunk = nil;
                                _pendingOperation = nil;
                            }
                        } else {
                            // TODO: Update MTU for operation.
                        }
                    }
                }
                
                break;
            }
        }
        
        if (isSearchingForResponse) {
            for (YRBTRemoteMessageOperation *operation in [_remoteOperations copy]) {
                if (operation.messageID == cancelLayout.messageID &&
                    operation.status == kYRBTRemoteMessageOperationStatusReceiving) {
                    NSLog(@"[_YRBTStreamingService]: Found request to remove: %@", operation);
                    
                    // TODO: It would work like that till we move all logic to our queue. (Callout in same runloop cycle)
                    [self invalidateRemoteOperation:operation];
                    
                    operation.status = kYRBTRemoteMessageOperationStatusCancelledByRemote;
                    
                    !operation.failureCallback ? : operation.failureCallback(operation,
                                                                             [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeSendCancelledByRemote]);
                }
            }
        }
        
        NSLog(@"[_YRBTStreamingService]: Cancel operation handled");
    } else {
        // Do immediate callout
        [self.receivingDelegate streamingService:self didReceiveServiceCommand:chunk
                                        fromPeer:sender];
    }
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRemoteOperationHeaderChunk:(_YRBTHeaderChunk *)chunk
         fromSender:(CBPeer *)sender {
    // We shouldn't have any operation for this.
    YRBTRemoteMessageOperation *remoteOperation = [self remoteOperationForChunk:chunk sender:sender];
    NSAssert(remoteOperation == nil, @"[_YRBTStreamingService]: Received header chunk from remote, but already has remote operation for it.");
    NSLog(@"[_YRBTStreamingService]: Did parse REMOTE OPERATION header chunk: %@", chunk);
    
    if (!remoteOperation) {
        // Create receiving operation.
        remoteOperation = [[YRBTRemoteMessageOperation alloc] initWithHeaderChunk:chunk sender:[_storage deviceForPeer:sender]];
        remoteOperation.streamingService = self;
        remoteOperation.status = kYRBTRemoteMessageOperationStatusReceiving;
        
        [_remoteOperations addObject:remoteOperation];
    }
    
    [self restartTimerForRemoteOperation:remoteOperation];
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseOperationNameChunk:(_YRBTOperationNameChunk *)chunk
         fromSender:(CBPeer *)sender {
    YRBTRemoteMessageOperation *remoteOperation = [self remoteOperationForChunk:chunk sender:sender];
    
    if (!remoteOperation) {
        // It may fail already.
        return;
    }
    
    NSLog(@"[_YRBTStreamingService]: Did parse operation name chunk: %@ for remote operation: %@", chunk, remoteOperation);
    
    BOOL didAppend = [remoteOperation.buffer appendChunk:chunk];
    
    if (didAppend) {
        [self restartTimerForRemoteOperation:remoteOperation];
        
        if (remoteOperation.buffer.receivingState == kYRBTReceivingStateRawData) {
            _YRBTRemoteOperationCallbacks *callbacks = [self.receivingDelegate streamingService:self
                                                            registeredCallbacksForOperationName:remoteOperation.operationName];
            
            remoteOperation.willReceiveRemoteOperationCallback = callbacks.willReceiveOperationCallback;
            remoteOperation.receivedCallback = callbacks.receivedOperationCallback;
            remoteOperation.progressCallback = callbacks.progressCallback;
            remoteOperation.failureCallback = callbacks.failureCallback;
            
            !remoteOperation.willReceiveRemoteOperationCallback ? : remoteOperation.willReceiveRemoteOperationCallback(remoteOperation);
            !remoteOperation.progressCallback ? : remoteOperation.progressCallback(0, remoteOperation.buffer.header.messageSize);
        }
    } else {
        // Buffer rejected to parse message chunk.
        // Invalidate receiving.
        [self invalidateRemoteOperation:remoteOperation];
        
        remoteOperation.status = kYRBTRemoteMessageOperationStatusFailed;
        
        [self scheduleOperation:[YRBTMessageOperation cancelOperationForRemoteOperation:remoteOperation]];
    }
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRemoteOperationRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
         fromSender:(CBPeer *)sender {
    YRBTRemoteMessageOperation *remoteOperation = [self remoteOperationForChunk:chunk sender:sender];
    if (!remoteOperation) {
        // It may fail already.
        return;
    }
    
    NSLog(@"[_YRBTStreamingService]: Did parse regular chunk: %@ for remote operation: %@", chunk, remoteOperation);
    
    BOOL didAppend = [remoteOperation.buffer appendChunk:chunk];
    
    if (didAppend) {
        [self restartTimerForRemoteOperation:remoteOperation];
        
        remoteOperation.bytesReceived = (uint32_t)remoteOperation.buffer.accumulatedData.length;
        !remoteOperation.progressCallback ? : remoteOperation.progressCallback(remoteOperation.bytesReceived,
                                                                               remoteOperation.totalBytesToReceive);
        
        if (remoteOperation.buffer.receivingState == kYRBTReceivingStateReceived) {
            [self invalidateRemoteOperation:remoteOperation];
            
            remoteOperation.status = kYRBTRemoteMessageOperationStatusReceived;
            
            YRBTMessageOperation *responseOperation = nil;
            
            if (remoteOperation.receivedCallback) {
                responseOperation = remoteOperation.receivedCallback(remoteOperation,
                                                                     remoteOperation.receivedMessage,
                                                                     remoteOperation.wantsResponse);
            }
            
            if (remoteOperation.wantsResponse) {
                if (responseOperation) {
                    NSAssert(responseOperation.isResponse, @"[_YRBTStreamingService]: Use '+[YRBTMessageOperation responseOperationForRemoteRequest:response:MTU:successSend:sendingProgress:failure:]' to provide response for remote request.");
                    [self scheduleOperation:responseOperation];
                } else {
                    NSLog(@"[_YRBTStreamingService]: <WARNING> No response provided for remote request: %@. Will respond with cancel.",
                          remoteOperation);
                    
                    // TODO: Create <no response> operation.
                    [self scheduleOperation:[YRBTMessageOperation cancelOperationForRemoteOperation:remoteOperation]];
                }
            }
        }
    } else {
        // Buffer rejected to parse message chunk.
        // Invalidate receiving.
        [self invalidateRemoteOperation:remoteOperation];
        
        remoteOperation.status = kYRBTRemoteMessageOperationStatusFailed;
        
        !remoteOperation.failureCallback ? : remoteOperation.failureCallback(remoteOperation, [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeReceivedIncorrectChunk]);
        
        [self scheduleOperation:[YRBTMessageOperation cancelOperationForRemoteOperation:remoteOperation]];
    }
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseResponseHeaderChunk:(_YRBTHeaderChunk *)chunk
         fromSender:(CBPeer *)sender {
    YRBTMessageOperation *operation = [self operationForResponseChunk:chunk];
    NSLog(@"[_YRBTStreamingService]: Did parse RESPONSE header chunk: %@ for operation: %@", chunk, operation);
    
    if (operation) {
        [operation.buffer appendChunk:chunk];
        
        [self restartTimerForOperation:operation];
        
        // We will have this callback only if we're receiving response for request.
        // Otherwise we will obtain them after parsing whole operation name (which is not sent for response messages).
        !operation.receivingProgressCallback ? : operation.receivingProgressCallback(0, operation.totalBytesToReceive);
    }
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseResponseRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
         fromSender:(CBPeer *)sender {
    YRBTMessageOperation *operation = [self operationForResponseChunk:chunk];
    
    BOOL didAppend = [operation.buffer appendChunk:chunk];
    
    if (didAppend) {
        [self restartTimerForOperation:operation];
        
        operation.bytesReceived = (uint32_t)operation.buffer.accumulatedData.length;
        
        !operation.receivingProgressCallback ? : operation.receivingProgressCallback(operation.bytesReceived,
                                                                                     operation.totalBytesToReceive);
        
        if (operation.buffer.receivingState == kYRBTReceivingStateReceived) {
            [self invalidateOperation:operation];
            
            operation.status = kYRBTMessageOperationStatusFinished;
            
            !operation.responseCallback ? : operation.responseCallback(operation, operation.buffer.message);
        }
    } else {
        [self invalidateOperation:operation];
        
        operation.status = kYRBTMessageOperationStatusFailed;
        
        !operation.failureCallback ? : operation.failureCallback(operation, [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeReceivedIncorrectChunk]);
    }
}

- (void)chunkParser:(_YRBTChunkParser *)parser didFailToParseChunkFromData:(NSData *)chunkData
         fromSender:(CBPeer *)sender withError:(NSError *)error {
    NSLog(@"[WARNING]: Received unsupported chunk: %@ from sender: %@. Error: %@", chunkData, sender, error);
}

@end