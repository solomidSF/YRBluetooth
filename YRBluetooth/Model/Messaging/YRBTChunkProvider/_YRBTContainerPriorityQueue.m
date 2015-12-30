//
//  _YRBTContainerPriorityQueue.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 8/11/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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
