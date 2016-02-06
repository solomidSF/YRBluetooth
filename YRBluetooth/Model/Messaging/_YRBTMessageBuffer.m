//
// _YRBTMessageBuffer.m
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
#import "YRBTMessage+Private.h"
#import "_YRBTMessageBuffer.h"

#define VALIDATE_TYPE_AND_EXECUTE_WITH_RETURN(type, expected_type, block) \
if (type == expected_type) { \
block(); \
return YES; \
} else { \
return NO; \
}

@implementation _YRBTMessageBuffer {
    NSMutableData *_operationNameGatheredData;
    NSMutableData *_rawMessageGatheredData;
}

#pragma mark - Dynamic Properties

- (NSData *)accumulatedData {
    return [_rawMessageGatheredData copy];
}

- (YRBTMessage *)message {
    if (_receivingState == kYRBTReceivingStateReceived) {
        return [YRBTMessage messageWithData:_rawMessageGatheredData
                                       type:_header.objectType];
    } else {
        return nil;
    }
}

#pragma mark - Public

- (BOOL)appendChunk:(__kindof _YRBTMessageChunk *)chunk {
    switch (_receivingState) {
        case kYRBTReceivingStateHeader:
            VALIDATE_TYPE_AND_EXECUTE_WITH_RETURN(chunk.chunkType, kYRBTChunkTypeHeader, ^{
                _header = chunk;
                
                _receivingState = _header.isResponse ? kYRBTReceivingStateRawData : kYRBTReceivingStateOperationName;
            });
        case kYRBTReceivingStateOperationName:
            VALIDATE_TYPE_AND_EXECUTE_WITH_RETURN(chunk.chunkType, kYRBTChunkTypeOperationName, ^{
                if (!_operationNameGatheredData) {
                    _operationNameGatheredData = [[NSMutableData alloc] initWithCapacity:_header.operationNameSize];
                }
                
                [_operationNameGatheredData appendData:chunk.rawMessageData];
                
                if (_operationNameGatheredData.length == _header.operationNameSize) {
                    _operationName = [[NSString alloc] initWithData:_operationNameGatheredData encoding:NSUTF8StringEncoding];
                    
                    _operationNameGatheredData = nil;
                    
                    _receivingState = kYRBTReceivingStateRawData;
                }
            });
        case kYRBTReceivingStateRawData:
            VALIDATE_TYPE_AND_EXECUTE_WITH_RETURN(chunk.chunkType, kYRBTChunkTypeRegular, ^{
                if (!_rawMessageGatheredData) {
                    _rawMessageGatheredData = [[NSMutableData alloc] initWithCapacity:_header.messageSize];
                }
                
                [_rawMessageGatheredData appendData:chunk.rawMessageData];
                
                if (_rawMessageGatheredData.length == _header.messageSize) {
                    _receivingState = kYRBTReceivingStateReceived;
                }
            });
        case kYRBTReceivingStateReceived:
            NSAssert(NO, @"[YRBluetooth]: Receiving buffer received a chunk while receiving state is 'RECEIVED'.");
            return NO;
        default:
            NSAssert(NO, @"[YRBluetooth]: Unknown receiving state.");
            return NO;
    }
}

@end
