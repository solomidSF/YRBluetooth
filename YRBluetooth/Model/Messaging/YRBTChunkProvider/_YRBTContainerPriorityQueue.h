//
//  _YRBTContainerPriorityQueue.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 8/11/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

@class _YRBTChunksContainer;

@interface _YRBTContainerPriorityQueue : NSObject

- (void)addContainer:(_YRBTChunksContainer *)container;
- (void)removeContainer:(_YRBTChunksContainer *)container;

- (_YRBTChunksContainer *)nextHighestPriorityContainer;

@end
