//
// YRBTRemoteMessageOperation+Private.m
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
#import "YRBTRemoteMessageOperation+Private.h"

// Obj-C
#import <objc/runtime.h>

@implementation YRBTRemoteMessageOperation (PrivateInterface)

#pragma mark - Init

- (instancetype)initWithHeaderChunk:(_YRBTHeaderChunk *)headerChunk
                             sender:(__kindof YRBTRemoteDevice *)sender {
    if (self = [super init]) {
        self.sender = sender;
        
        [self.buffer appendChunk:headerChunk];
    }
    
    return self;
}

#pragma mark - Dynamic Properties

- (message_id_t)messageID {
    return self.buffer.header.messageID;
}

@end

@implementation YRBTRemoteMessageOperation (Mutable)

@dynamic status;
@dynamic streamingService;
@dynamic sender;
@dynamic bytesReceived;

@end

@implementation YRBTRemoteMessageOperation (Timeout)

#pragma mark - Dynamic Properties

- (void)setTimeoutTimer:(NSTimer *)timeoutTimer {
    objc_setAssociatedObject(self, &@selector(timeoutTimer), timeoutTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)timeoutTimer {
    return objc_getAssociatedObject(self, &@selector(timeoutTimer));
}

@end

@implementation YRBTRemoteMessageOperation (Receiving)

@dynamic buffer;

@end
