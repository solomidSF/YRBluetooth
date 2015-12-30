//
//  BTMessage.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/20/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

// Model
#import "YRBTMessage.h"
// Prefix
#import "BTPrefix.h"

#import "_YRBTMessaging.h"

@implementation YRBTMessage {
    NSData *_messageData;
}

#pragma mark - Init

+ (YRBTMessage *)messageWithData:(NSData *)data {
    return [[self alloc] initWithBTData:data
                                   type:kYRBTObjectTypeCustom];
}

+ (YRBTMessage *)messageWithArray:(NSArray *)array {
    if ([NSJSONSerialization isValidJSONObject:array]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        return [[self alloc] initWithBTData:data
                                       type:kYRBTObjectTypeArray];
    } else {
        BTDebugMsg(@"Given array is not valid JSON object.");
        return nil;
    }
}

+ (YRBTMessage *)messageWithDictionary:(NSDictionary *)dictionary {
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        return [[self alloc] initWithBTData:data
                                       type:kYRBTObjectTypeDictionary];
    } else {
        BTDebugMsg(@"Given dictionary is not valid JSON object.");
        return nil;
    }
}

+ (YRBTMessage *)messageWithString:(NSString *)string {
    return [[self alloc] initWithBTData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                   type:kYRBTObjectTypeString];
}

+ (instancetype)messageWithServiceCommand:(void *)data
                                   length:(int32_t)length {
    NSData *packetData = [NSData dataWithBytes:data
                                        length:length];
    
    _YRBTInternalChunk *userCommandChunk = [_YRBTInternalChunk internalChunkWithCode:kYRBTInternalChunkCodeUserDefined
                                                                         commandData:packetData];
    
    return [[self alloc] initWithBTData:userCommandChunk.packedChunkData
                                   type:kYRBTObjectTypeServiceCommand];
}

// Private initializer.
- (instancetype)initWithBTData:(NSData *)data
                          type:(YRBTObjectType)type {
    if (self = [super init]) {
        NSAssert(data.length <= UINT32_MAX, @"[YRBluetooth] Couldn't initialize message that exceeds max message size. [Max 4 GB]");
        _messageData = data;
        _objectType = type;
    }
    return self;
}

#pragma mark - Accessing Data

- (NSString *)stringValue {
    if (self.messageData) {
        return [[NSString alloc] initWithData:self.messageData
                                     encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

- (NSArray *)arrayValue {
    if (self.messageData) {
        return [NSJSONSerialization JSONObjectWithData:self.messageData
                                               options:NSJSONReadingMutableContainers
                                                 error:nil];
    } else {
        return nil;
    }
}

- (NSDictionary *)dictionaryValue {
    if (self.messageData) {
        return [NSJSONSerialization JSONObjectWithData:self.messageData
                                               options:NSJSONReadingMutableContainers
                                                 error:nil];
    } else {
        return nil;
    }
}

#pragma mark - Private

- (NSString *)humanReadableObjectTypeFromType:(YRBTObjectType)objectType {
    return @[@"Custom",
             @"Array",
             @"Dictionary",
             @"String",
             @"ServiceCommand"][objectType];
}

#pragma mark - Overridden

- (NSString *)description {
    return [NSString stringWithFormat:@"%@. Message type: %@. Message size: %d", [super description], [self humanReadableObjectTypeFromType:self.objectType], (int32_t)self.messageData.length];
}

@end
