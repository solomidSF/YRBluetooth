//
//  BTMessage.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/20/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

typedef enum {
    kYRBTObjectTypeCustom,
    kYRBTObjectTypeArray,
    kYRBTObjectTypeDictionary,
    kYRBTObjectTypeString,
    kYRBTObjectTypeServiceCommand
} YRBTObjectType;

/**
 *  Class used to receive/send messages to client/server.
 *  To send custom objects you can convert them into data.
 */
@interface YRBTMessage : NSObject

/** Object packed to data. */
@property (nonatomic, readonly) NSData *messageData;
/** Object type. Will be delivered to the receiver for more introspection. */
@property (nonatomic, readonly) YRBTObjectType objectType;

#pragma mark - Init

#warning Create serialization protocol.

/** Initializes object with data. */
+ (instancetype)messageWithData:(NSData *)data;
/** Initializes YRBTMessage instance with array or returns nil if array is not valid JSON object. */
+ (instancetype)messageWithArray:(NSArray *)array;
/** Initializes YRBTMessage instance with dictionary or returns nil if dictionary is not valid JSON object. */
+ (instancetype)messageWithDictionary:(NSDictionary *)dictionary;
/** Initializes YRBTMessage instance with string. */
+ (instancetype)messageWithString:(NSString *)string;
/**
 *  Initializes YRBTMessage instance with custom internal structure that is meant to be delivered without overhead.
 */
+ (instancetype)messageWithServiceCommand:(void *)data
                                   length:(int32_t)length;

#pragma mark - Accessing Data

- (NSString *)stringValue;
- (NSArray *)arrayValue;
- (NSDictionary *)dictionaryValue;

@end
