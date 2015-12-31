//
// YRBTMessage+Private.m
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

#import "YRBTMessage+Private.h"
#import "_YRBTMessaging.h"

// Other
#import <objc/runtime.h>

@interface YRBTMessage ()
- (instancetype)initWithBTData:(NSData *)data
                          type:(YRBTObjectType)type;
@end

@implementation YRBTMessage (Private)

#pragma mark - Dynamic Properties

- (YRBTMessagePriority)priority {
    return (self.objectType == kYRBTObjectTypeServiceCommand) ? kYRBTMessagePriorityHighest : kYRBTMessagePriorityNormal;
}

#pragma mark - Public

+ (instancetype)messageWithData:(NSData *)data
                           type:(YRBTObjectType)type {
    switch (type) {
        case kYRBTObjectTypeCustom:
            return [self messageWithData:data];
        case kYRBTObjectTypeArray:
            return [self messageWithArray:[NSJSONSerialization JSONObjectWithData:data
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:nil]];
        case kYRBTObjectTypeDictionary:
            return [self messageWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingMutableContainers
                                                                                 error:nil]];
        case kYRBTObjectTypeString:
            return [self messageWithString:[[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding]];
        case kYRBTObjectTypeServiceCommand: {
            void *packetData = malloc(data.length);
            [data getBytes:packetData length:data.length];

            YRBTMessage *message = [self messageWithServiceCommand:packetData
                                                            length:(int32_t)data.length];
            
            free(packetData);
            
            return message;
        }
        default:
            NSAssert(NO, @"[YRBluetooth] Unknown object type in msg.");
            return nil;
    }
}

+ (instancetype)cancelMessageForOperationID:(message_id_t)messageID
                                   isSender:(BOOL)isSender {
    YRBTCancelCommandInternalChunkLayout cancelLayout = {isSender, messageID};
    NSData *cancelData = [NSData dataWithBytes:&cancelLayout length:sizeof(cancelLayout)];

    _YRBTInternalChunk *chunk = [_YRBTInternalChunk internalChunkWithCode:kYRBTInternalChunkCodeCancel
                                                              commandData:cancelData];
    
    return [[self alloc] initWithBTData:chunk.packedChunkData
                                   type:kYRBTObjectTypeServiceCommand];
}

@end
