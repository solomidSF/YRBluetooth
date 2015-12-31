//
// YRBTMessage.h
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
