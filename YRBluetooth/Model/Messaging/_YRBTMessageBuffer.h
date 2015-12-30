//
//  _YRBTMessageBuffer.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/13/15.
//  Copyright © 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "YRBTMessage.h"
#import "_YRBTHeaderChunk.h"

typedef enum {
	kYRBTReceivingStateHeader,
	kYRBTReceivingStateOperationName,
	kYRBTReceivingStateRawData,
	kYRBTReceivingStateReceived
} YRBTReceivingState;

@interface _YRBTMessageBuffer : NSObject

@property (nonatomic, readonly) YRBTReceivingState receivingState;

@property (nonatomic, readonly) _YRBTHeaderChunk *header;
@property (nonatomic, readonly) NSString *operationName;
@property (nonatomic, readonly) YRBTMessage *message;
@property (nonatomic, readonly) NSData *accumulatedData;

- (BOOL)appendChunk:(__kindof _YRBTMessageChunk *)chunk;

@end
