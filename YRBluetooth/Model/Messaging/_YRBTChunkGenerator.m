//
// _YRBTChunkProvider.m
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

// Messaging
#import "_YRBTChunkGenerator.h"
#import "_YRBTMessaging.h"
#import "YRBTMessageOperation+Private.h"

@class YRBTResponse;

typedef void (^YRBTChunkProviderSubchunkCallback) (NSData *subchunk);

@implementation _YRBTChunkGenerator

+ (NSArray *)chunksForOperation:(YRBTMessageOperation *)operation
                     totalBytes:(out uint32_t *)totalBytes
{
    return [self chunksForMessage:operation.message
                        messageID:operation.messageID
                    operationName:operation.operationName
                       isResponse:operation.isResponse
                    wantsResponse:operation.responseCallback != NULL
                              MTU:operation.MTU
                       totalBytes:totalBytes];
}

+ (NSArray *)chunksForMessage:(YRBTMessage *)message
                    messageID:(uint32_t)messageID
                operationName:(NSString *)operationName
                   isResponse:(BOOL)isResponse
                wantsResponse:(BOOL)wantsResponse
                          MTU:(uint32_t)MTU
                   totalBytes:(out uint32_t *)totalBytes {
    NSCParameterAssert(MTU >= kYRBTMinChunkSize);
    NSCParameterAssert(operationName.length > 0);
    
    // Cut down operation name if it's too long.
    if (operationName.length > UINT8_MAX) {
        operationName = [operationName substringWithRange:(NSRange){0, UINT8_MAX}];
    }
    
    NSMutableArray *allChunks = [NSMutableArray new];
    
    // 1. Create header.
    _YRBTHeaderChunk *header = [_YRBTHeaderChunk headerChunkForMessageID:messageID
                                                       operationNameSize:operationName.length
                                                             messageSize:(int32_t)message.messageData.length
                                                              isResponse:isResponse
                                                           wantsResponse:wantsResponse
                                                              objectType:message.objectType];
    [allChunks addObject:header];
    
    // 2. Create operation name chunks or ignore this step if this is response message.
    if (!isResponse) {
        [self createSubchunksFromData:[operationName dataUsingEncoding:NSUTF8StringEncoding]
                         maxChunkSize:MTU - kYRBTMessageChunkLayoutSize
                             callback:^(NSData *subchunk) {
                                 _YRBTOperationNameChunk *operationNameChunk = nil;
                                 
                                 operationNameChunk = [_YRBTOperationNameChunk operationNameChunkWithMessageID:messageID
                                                                                                         chunk:subchunk];
                                 [allChunks addObject:operationNameChunk];
                             }];
    }
    
    // 3. Create regular message chunks.
    [self createSubchunksFromData:message.messageData
                     maxChunkSize:MTU - kYRBTMessageChunkLayoutSize
                         callback:^(NSData *subchunk) {
                             _YRBTRegularMessageChunk *chunk = nil;
                             
                             chunk = [_YRBTRegularMessageChunk regularMessageChunkWithMessageID:messageID
                                                                                     isResponse:isResponse
                                                                                      chunkData:subchunk];
                             
                             [allChunks addObject:chunk];
                         }];
    
    if (totalBytes) {
        *totalBytes = [[allChunks valueForKeyPath:@"@sum.packedChunkData.length"] intValue];
    }
    
    // 4. Return them
    return [NSArray arrayWithArray:allChunks];
}

+ (NSArray *)optimizeChunks:(NSArray *)existingChunks
                  forNewMTU:(uint32_t)newMTU {
    NSCParameterAssert(newMTU >= kYRBTMinChunkSize);
    
    NSMutableArray *resultingChunks = [NSMutableArray new];
    
    _YRBTHeaderChunk *headerChunk = nil;
    NSMutableData *operationNameData = [NSMutableData new];
    NSMutableData *messageData = [NSMutableData new];
    message_id_t messageID = 0;
    BOOL isResponse = NO;
    
    for (_YRBTChunk *chunk in existingChunks) {
        if (chunk.chunkType == kYRBTChunkTypeHeader) {
            headerChunk = (_YRBTHeaderChunk *)chunk;
            messageID = headerChunk.messageID;
            isResponse = headerChunk.isResponse;
        }
        
        if (chunk.chunkType == kYRBTChunkTypeOperationName) {
            _YRBTOperationNameChunk *operationNameChunk = (_YRBTOperationNameChunk *)chunk;
            
            messageID = operationNameChunk.messageID;
            
            [operationNameData appendData:operationNameChunk.operationNameUTFChunk];
        }
        
        if (chunk.chunkType == kYRBTChunkTypeRegular) {
            _YRBTRegularMessageChunk *messageChunk = (_YRBTRegularMessageChunk *)chunk;
            
            messageID = messageChunk.messageID;
            isResponse = messageChunk.isResponse;
            
            [messageData appendData:messageChunk.chunkData];
        }
        
        if (chunk.chunkType == kYRBTChunkTypeInternal) {
            // Don't change anything.
            // Internal chunk should be one!
            NSCParameterAssert(existingChunks.count == 1);
            [resultingChunks addObject:chunk];
        }
    }
    
    // Start building chunks with new MTU.
    if (headerChunk) {
        [resultingChunks addObject:headerChunk];
    }
    
    if (operationNameData.length > 0) {
        [self createSubchunksFromData:operationNameData
                         maxChunkSize:newMTU - kYRBTMessageChunkLayoutSize
                             callback:^(NSData *subchunk) {
                                 _YRBTOperationNameChunk *operationNameChunk = nil;
                                 
                                 operationNameChunk = [_YRBTOperationNameChunk operationNameChunkWithMessageID:messageID
                                                                                                         chunk:subchunk];
                                 [resultingChunks addObject:operationNameChunk];
                             }];
    }
    
    if (messageData.length > 0) {
        [self createSubchunksFromData:messageData
                         maxChunkSize:newMTU - kYRBTMessageChunkLayoutSize
                             callback:^(NSData *subchunk) {
                                 _YRBTRegularMessageChunk *chunk = nil;
                                 
                                 chunk = [_YRBTRegularMessageChunk regularMessageChunkWithMessageID:messageID
                                                                                         isResponse:isResponse
                                                                                          chunkData:subchunk];
                                 
                                 [resultingChunks addObject:chunk];
                             }];
    }
    
    return [NSArray arrayWithArray:resultingChunks];
}

+ (_YRBTInternalChunk *)internalChunkForCode:(YRBTInternalChunkCode)code
                              additionalData:(NSData *)data {
    return [_YRBTInternalChunk internalChunkWithCode:code
                                         commandData:data];
}

#pragma mark - Private

+ (void)createSubchunksFromData:(NSData *)data
                   maxChunkSize:(int32_t)maxSize
                       callback:(YRBTChunkProviderSubchunkCallback)callback {
    // TODO: Handle it above
    NSAssert(maxSize > 0, @"[_YRBTChunkGenerator]: MTU is too low, couldn't create subchunks!");
    
    if (!callback && maxSize <= 0) {
        return;
    }
    
    int32_t currentSubchunkPosition = 0;
    
    do {
        int32_t currentSize = maxSize;
        
        if (currentSubchunkPosition + currentSize > data.length) {
            currentSize = (int32_t)data.length - currentSubchunkPosition;
        }
        
        NSRange currentRange = (NSRange){currentSubchunkPosition, currentSize};
        
        NSData *resultingChunk = [data subdataWithRange:currentRange];
        
        !callback ? : callback(resultingChunk);
        
        currentSubchunkPosition += currentSize;
    } while (currentSubchunkPosition < data.length);
}

@end
