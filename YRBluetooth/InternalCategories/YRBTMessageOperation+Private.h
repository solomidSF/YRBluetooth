//
// YRBTMessageOperation+Private.h
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

#import "YRBTMessageOperation.h"
#import "_YRBTMessageBuffer.h"
#import "_YRBTStreamingService.h"

@class YRBTRemoteMessageRequest;

@interface YRBTMessageOperation (Private)

@property (nonatomic, readonly) message_id_t messageID;

+ (instancetype)cancelOperationForOperation:(YRBTMessageOperation *)operation;
+ (instancetype)cancelOperationForRemoteRequest:(YRBTRemoteMessageRequest *)request;

@end

@interface YRBTMessageOperation (Mutable)

@property (nonatomic, weak) _YRBTStreamingService *streamingService;
@property (nonatomic) YRBTMessageOperationStatus status;
@property (nonatomic, readonly) NSMutableArray <YRBTRemoteDevice *> *mutableReceivers;

@property (nonatomic) uint32_t bytesSent;
@property (nonatomic) uint32_t totalBytesToSend;

@property (nonatomic) uint32_t bytesReceived;

@end

@interface YRBTMessageOperation (Receiving)

@property (nonatomic, readonly) _YRBTMessageBuffer *buffer;

@end

@interface YRBTMessageOperation (Multithreading)

@property (nonatomic) BOOL isDeallocating;
@property (nonatomic) BOOL isDeallocatingSilently;

@end

@interface YRBTMessageOperation (Timeout)

@property (nonatomic) NSTimer *timeoutTimer;

@end
