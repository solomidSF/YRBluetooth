//
// YRBTRemoteMessageOperation+Private.h
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

// Operations
#import "YRBTRemoteMessageOperation.h"

// Services
#import "_YRBTStreamingService.h"

// Messaging
#import "_YRBTMessageBuffer.h"
#import "_YRBTMessagingTypes.h"

@interface YRBTRemoteMessageOperation (PrivateInterface)

@property (nonatomic, readonly) message_id_t messageID;

- (instancetype)initWithHeaderChunk:(_YRBTHeaderChunk *)headerChunk
                             sender:(__kindof YRBTRemoteDevice *)sender;

@end

@interface YRBTRemoteMessageOperation (Mutable)

@property (nonatomic, weak) _YRBTStreamingService *streamingService;
@property (nonatomic) YRBTRemoteMessageOperationStatus status;
@property (nonatomic) __kindof YRBTRemoteDevice *sender;
@property (nonatomic) uint32_t bytesReceived;

@end

@interface YRBTRemoteMessageOperation (Timeout)

@property (nonatomic) NSTimer *timeoutTimer;

@end

@interface YRBTRemoteMessageOperation (Receiving)

@property (nonatomic, readonly) _YRBTMessageBuffer *buffer;

@end
