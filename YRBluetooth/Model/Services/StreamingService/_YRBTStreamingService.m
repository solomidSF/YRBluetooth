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
#import "YRBTRemoteMessageRequest.h"

// Categories.
#import "YRBTMessageOperation+Private.h"
#import "YRBTRemoteMessageRequest+Private.h"

// TODO: Refactor
#import "YRBTRemoteDevice.h"
#import "_YRBTErrorService.h"
#import "_YRBTDeviceStorage.h"

// Operations.
#import "_YRBTWriteOperation.h"

// General Types.
#import "_YRBTMessaging.h"
#import "YRBluetoothTypes.h"

// TODO:
#import "BTPrefix.h"
#import "Constants.h"

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
    NSMutableArray <YRBTRemoteMessageRequest *> *_remoteRequests;
	
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
        _remoteRequests = [NSMutableArray new];
		
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
            // TODO: Cancelled error.
            !operation.failureCallback ? : operation.failureCallback(operation, nil);
            
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

- (void)cancelRemoteRequest:(YRBTRemoteMessageRequest *)request {
    if ([_remoteRequests containsObject:request] &&
        request.status == kYRBTRemoteMessageRequestStatusReceiving) {
        
        // TODO: It would work like that till we move all logic to our queue.
        [self invalidateRemoteRequest:request];

        request.status = kYRBTRemoteMessageRequestStatusCancelled;
        // TODO: Cancelled error
        !request.failureCallback ? : request.failureCallback(request, nil);
        
        YRBTMessageOperation *cancelOperation = [YRBTMessageOperation cancelOperationForRemoteRequest:request];
        
        [self scheduleOperation:cancelOperation];
    }
}

#pragma mark - Cleanup

- (void)handlePeerDisconnected:(CBPeer *)peer {
    BTDebugMsg(@"[StreamingService]: <%@> disconnected! Will invalidate current requests for it.", [_storage deviceForPeer:peer]);
    YRBTRemoteDevice *device = [_storage deviceForPeer:peer];
    
	for (YRBTMessageOperation *operation in [_operations copy]) {
		if ([operation.mutableReceivers containsObject:device]) {
			
			[operation.mutableReceivers removeObject:device];
			
			if (operation.mutableReceivers.count == 0) {
                NSLog(@"[_YRBTStreamingService]: No receivers left for %@", operation);
                [self invalidateOperation:operation];
				
                [_provider invalidateChunkGenerationForOperation:operation];
                
				operation.status = kYRBTMessageOperationStatusFailed;
				// TODO: No receivers error.
				!operation.failureCallback ? : operation.failureCallback(operation, nil);
				
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
    
    for (YRBTRemoteMessageRequest *request in [_remoteRequests copy]) {
        if ([request.sender isEqual:device]) {
            [self invalidateRemoteRequest:request];
            
            request.status = kYRBTRemoteMessageRequestStatusFailed;
            // TODO: Cancelled error.
            request.failureCallback ? : request.failureCallback(request, nil);
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
        // TODO: Dealloc error ? Or use cancelled error?
        !operation.failureCallback ? : operation.failureCallback(operation, nil);
	}
	
    for (YRBTRemoteMessageRequest *request in [_remoteRequests copy]) {
        [self invalidateRemoteRequest:request];
        
        request.status = kYRBTRemoteMessageRequestStatusFailed;
        // TODO: Dealloc error ? Or use cancelled error?
        request.failureCallback ? : request.failureCallback(request, nil);
    }
}

- (void)invalidateWithError:(NSError *)error {
    BTDebugMsg(@"[StreamingService]: Will invalidate with error: %@", error);
    [_provider invalidate];

    for (YRBTMessageOperation *operation in [_operations copy]) {
        [self invalidateOperation:operation];

        [_provider invalidateChunkGenerationForOperation:operation];
        
        operation.status = kYRBTMessageOperationStatusFailed;
		!operation.failureCallback ? : operation.failureCallback(operation, error);
    }
	
    for (YRBTRemoteMessageRequest *request in [_remoteRequests copy]) {
        [self invalidateRemoteRequest:request];
        
        request.status = kYRBTRemoteMessageRequestStatusFailed;
        // TODO: Cancelled error.
        request.failureCallback ? : request.failureCallback(request, nil);
    }
}

#pragma mark - NSTimer

- (void)handleTimeoutForOperation:(NSTimer *)timeoutTimer {
    YRBTMessageOperation *operation = timeoutTimer.userInfo;
    
    [self invalidateOperation:operation];
    
    [_provider invalidateChunkGenerationForOperation:operation];
    
    operation.status = kYRBTMessageOperationStatusFailed;
    // TODO: Timeout error
    !operation.failureCallback ? : operation.failureCallback(operation, nil);
}

- (void)handleTimeoutForRemoteRequest:(NSTimer *)timeoutTimer {
	YRBTRemoteMessageRequest *request = timeoutTimer.userInfo;

	[self invalidateRemoteRequest:request];
	
	request.status = kYRBTRemoteMessageRequestStatusFailed;
	// TODO: Timeout error
	!request.failureCallback ? : request.failureCallback(request, nil);
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

- (YRBTRemoteMessageRequest *)remoteRequestForChunk:(__kindof _YRBTMessageChunk *)chunk {
    for (YRBTRemoteMessageRequest *request in _remoteRequests) {
        if (request.messageID == chunk.messageID) {
            return request;
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
- (void)invalidateRemoteRequest:(YRBTRemoteMessageRequest *)request {
	[request.timeoutTimer invalidate];
	request.timeoutTimer = nil;
	
	[_remoteRequests removeObject:request];
}

- (void)restartTimerForOperation:(YRBTMessageOperation *)operation {
    [operation.timeoutTimer invalidate];
    
    operation.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:operation.timeoutInterval
                                                              target:self
                                                            selector:@selector(handleTimeoutForOperation:)
                                                            userInfo:operation
                                                             repeats:NO];
}

- (void)restartTimerForRemoteRequest:(YRBTRemoteMessageRequest *)request {
	[request.timeoutTimer invalidate];
	
    request.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kYRBTDefaultTimeoutInterval
                                                            target:self
                                                          selector:@selector(handleTimeoutForRemoteRequest:)
                                                          userInfo:request
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
                                 _pendingOperation == operation) {
                                 
                                 // TODO: What if operation was cancelled?
                                 
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
                                     
                                     operation.status = kYRBTMessageOperationStatusFailed;
                                     
                                     // TODO: Failed to send message
                                     !operation.failureCallback ? : operation.failureCallback(operation, nil);
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
    // Not needed too.
    [self invalidateOperation:operation];
    
    operation.status = kYRBTMessageOperationStatusCancelled;
    // TODO: Cancelled error
    !operation.failureCallback ? : operation.failureCallback(operation, nil);
}

#pragma mark - <_YRBTChunkParserDelegate>

- (void)chunkParser:(_YRBTChunkParser *)parser didParseInternalChunk:(_YRBTInternalChunk *)chunk
         fromSender:(CBPeer *)sender {
    
    if (chunk.commandCode == kYRBTInternalChunkCodeCancel) {
        YRBTCancelCommandInternalChunkLayout cancelLayout = {0};
        
        [chunk.commandData getBytes:&cancelLayout length:sizeof(YRBTCancelCommandInternalChunkLayout)];
        
        // Is sender in this chunk means that remote is sender of request.
        BOOL isSearchingForResponse = cancelLayout.isSender;
        
        NSLog(@"[_YRBTStreamingService]: Remote cancel. Message id: %d. Is response: %d",
              cancelLayout.messageID,
              isSearchingForResponse);
        
        for (YRBTMessageOperation *operation in [_operations copy]) {
            if (operation.messageID == cancelLayout.messageID &&
                isSearchingForResponse == operation.isResponse) {
                
                NSLog(@"[_YRBTStreamingService]: Found operation to remove: %@", operation);
                
                if (operation.status == kYRBTMessageOperationStatusWaiting ||
                    operation.status == kYRBTMessageOperationStatusSending ||
                    operation.status == kYRBTMessageOperationStatusReceiving) {
                    
                    [self invalidateOperation:operation];
                    
                    [_provider invalidateChunkGenerationForOperation:operation];
                    
                    operation.status = kYRBTMessageOperationStatusCancelledByRemote;
                    // TODO: Cancelled by remote error.
                    !operation.failureCallback ? : operation.failureCallback(operation, nil);
                }
                
            }
        }
        
        if (isSearchingForResponse) {
            for (YRBTRemoteMessageRequest *request in [_remoteRequests copy]) {
                if (request.messageID == cancelLayout.messageID &&
                    request.status == kYRBTRemoteMessageRequestStatusReceiving) {
                    NSLog(@"[_YRBTStreamingService]: Found request to remove: %@", request);
                    
                    // TODO: It would work like that till we move all logic to our queue.
                    [self invalidateRemoteRequest:request];
                    
                    request.status = kYRBTRemoteMessageRequestStatusCancelledByRemote;
                    // TODO: Cancelled by remote error
                    !request.failureCallback ? : request.failureCallback(request, nil);
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

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRequestHeaderChunk:(_YRBTHeaderChunk *)chunk
         fromSender:(CBPeer *)sender {
    // We shouldn't have any operation for this.
	YRBTRemoteMessageRequest *remoteRequest = [self remoteRequestForChunk:chunk];
	NSAssert(remoteRequest == nil, @"[_YRBTStreamingService]: Received header chunk from remote, but already has remote request for it.");
    NSLog(@"[_YRBTStreamingService]: Did parse REQUEST header chunk: %@", chunk);

    if (!remoteRequest) {
        // Create receiving operation.
        remoteRequest = [[YRBTRemoteMessageRequest alloc] initWithHeaderChunk:chunk sender:[_storage deviceForPeer:sender]];
		remoteRequest.status = kYRBTRemoteMessageRequestStatusReceiving;
		
		[_remoteRequests addObject:remoteRequest];
    }
	
    [self restartTimerForRemoteRequest:remoteRequest];
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseOperationNameChunk:(_YRBTOperationNameChunk *)chunk
         fromSender:(CBPeer *)sender {
	YRBTRemoteMessageRequest *remoteRequest = [self remoteRequestForChunk:chunk];
    NSLog(@"[_YRBTStreamingService]: Did parse operation name chunk: %@ for request: %@", chunk, remoteRequest);
    
    BOOL didAppend = [remoteRequest.buffer appendChunk:chunk];
    
    if (didAppend) {
        [self restartTimerForRemoteRequest:remoteRequest];
        
        if (remoteRequest.buffer.receivingState == kYRBTReceivingStateRawData) {
            _YRBTRemoteRequestCallbacks *callbacks = [self.receivingDelegate streamingService:self
                                                          registeredCallbacksForOperationName:remoteRequest.operationName];

            remoteRequest.willReceiveRequestCallback = callbacks.willReceiveRequestCallback;
            remoteRequest.receivedCallback = callbacks.receivedRequestCallback;
            remoteRequest.progressCallback = callbacks.progressCallback;
            remoteRequest.failureCallback = callbacks.failureCallback;
            
			!remoteRequest.willReceiveRequestCallback ? : remoteRequest.willReceiveRequestCallback(remoteRequest);
			!remoteRequest.progressCallback ? : remoteRequest.progressCallback(0, remoteRequest.buffer.header.messageSize);
        }
    } else {
        // Buffer rejected to parse message chunk.
        // Invalidate receiving.
		[self invalidateRemoteRequest:remoteRequest];
        
        remoteRequest.status = kYRBTRemoteMessageRequestStatusFailed;
    }
}

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRequestRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
         fromSender:(CBPeer *)sender {
    YRBTRemoteMessageRequest *remoteRequest = [self remoteRequestForChunk:chunk];
    NSLog(@"[_YRBTStreamingService]: Did parse regular chunk: %@ for request: %@", chunk, remoteRequest);

    BOOL didAppend = [remoteRequest.buffer appendChunk:chunk];
    
    if (didAppend) {
        [self restartTimerForRemoteRequest:remoteRequest];

		remoteRequest.bytesReceived = (uint32_t)remoteRequest.buffer.accumulatedData.length;
		!remoteRequest.progressCallback ? : remoteRequest.progressCallback(remoteRequest.bytesReceived,
																		   remoteRequest.totalBytesToReceive);

        if (remoteRequest.buffer.receivingState == kYRBTReceivingStateReceived) {
            [self invalidateRemoteRequest:remoteRequest];

			remoteRequest.status = kYRBTRemoteMessageRequestStatusReceived;
			
			YRBTMessageOperation *responseOperation = nil;
			
			if (remoteRequest.receivedCallback) {
				responseOperation = remoteRequest.receivedCallback(remoteRequest,
																   remoteRequest.requestMessage,
																   remoteRequest.wantsResponse);
			}
			
			if (remoteRequest.wantsResponse) {
                if (responseOperation) {
                    NSAssert(responseOperation.isResponse, @"[_YRBTStreamingService]: Use '+[YRBTMessageOperation responseOperationForRemoteRequest:response:MTU:successSend:sendingProgress:failure:]' to provide response for remote request.");
                    [self scheduleOperation:responseOperation];
                } else {
                    NSLog(@"[_YRBTStreamingService]: <WARNING> No response provided for remote request: %@. Will respond with cancel.",
                          remoteRequest);

                    // TODO: Create <no response> operation.
                    YRBTMessageOperation *cancelOperation = [YRBTMessageOperation cancelOperationForRemoteRequest:remoteRequest];
                    
                    [self scheduleOperation:cancelOperation];
                }
			}
        }
    } else {
        // Buffer rejected to parse message chunk.
        // Invalidate receiving.
		[self invalidateRemoteRequest:remoteRequest];
        
        remoteRequest.status = kYRBTRemoteMessageRequestStatusFailed;
        // TODO: Invalid message chunk.
        !remoteRequest.failureCallback ? : remoteRequest.failureCallback(remoteRequest, nil);
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
		// TODO: Corrupted chunk error
		!operation.failureCallback ? : operation.failureCallback(operation, nil);
	}
}

- (void)chunkParser:(_YRBTChunkParser *)parser didFailToParseChunkFromData:(NSData *)chunkData
         fromSender:(CBPeer *)sender withError:(NSError *)error {
    NSLog(@"[WARNING]: Received unsupported chunk: %@ from sender: %@. Error: %@", chunkData, sender, error);
}

@end