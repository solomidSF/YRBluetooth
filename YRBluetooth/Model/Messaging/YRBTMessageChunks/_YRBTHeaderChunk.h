//
//  _YRBTHeaderChunk.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTMessageChunk.h"

@interface _YRBTHeaderChunk : _YRBTMessageChunk

/**
 *  Size of operation name associated with given message in bytes.
 */
@property (nonatomic, readonly) uint8_t operationNameSize;

/**
 *  Message size up to 4 GB.
 */
@property (nonatomic, readonly) message_size_t messageSize;

/**
 *  Tells that given message wants response from receiver.
 */
@property (nonatomic, readonly) BOOL wantsResponse;

/**
 *  Object type that is contained in message.
 */
@property (nonatomic, readonly) message_object_type_t objectType;

+ (instancetype)headerChunkForMessageID:(message_id_t)messageID
					  operationNameSize:(uint8_t)operationNameSize
							messageSize:(message_size_t)messageSize
							 isResponse:(BOOL)isResponse
						  wantsResponse:(BOOL)wantsResponse
							 objectType:(message_object_type_t)objectType;

@end
