//
// _YRBTContainerPriorityQueue.m
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

#import "_YRBTContainerPriorityQueue.h"

#import "_YRBTChunksContainer.h"
#import "YRBTMessage+Private.h"

@implementation _YRBTContainerPriorityQueue {
    NSMutableArray *_normalPriorityContainers;
    NSMutableArray *_highPriorityContainers;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        _normalPriorityContainers = [NSMutableArray new];
        _highPriorityContainers = [NSMutableArray new];
    }
    
    return self;
}

- (void)addContainer:(_YRBTChunksContainer *)container {
    if (container.operation.message.priority == kYRBTMessagePriorityNormal) {
        [_normalPriorityContainers addObject:container];
    } else {
        [_highPriorityContainers addObject:container];
    }
}

- (void)removeContainer:(_YRBTChunksContainer *)container {
    [_normalPriorityContainers removeObjectIdenticalTo:container];
    [_highPriorityContainers removeObjectIdenticalTo:container];
}

- (_YRBTChunksContainer *)nextHighestPriorityContainer {
    _YRBTChunksContainer *firstContainer = [_highPriorityContainers firstObject];
    
    if (firstContainer) {
        [_highPriorityContainers removeObjectIdenticalTo:firstContainer];
        [_highPriorityContainers addObject:firstContainer];
        
        return firstContainer;
    } else {
        firstContainer = [_normalPriorityContainers firstObject];
        
        if (firstContainer) {
            [_normalPriorityContainers removeObjectIdenticalTo:firstContainer];
            [_normalPriorityContainers addObject:firstContainer];
            
            return firstContainer;
        }
    }
    
    return nil;
}

@end
