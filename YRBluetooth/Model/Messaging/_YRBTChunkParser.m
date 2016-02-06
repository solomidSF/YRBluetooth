//
// _YRBTChunkParser.m
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

// Model
#import "_YRBTChunkParser.h"

// Services
#import "_YRBTErrorService.h"

// Messaging
#import "_YRBTMessaging.h"

@implementation _YRBTChunkParser

#pragma mark - Init

+ (instancetype)parserWithDelegate:(id <_YRBTChunkParserDelegate>)delegate {
    return [[self alloc] initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id <_YRBTChunkParserDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Public

- (void)parseChunk:(NSData *)chunk fromSender:(CBPeer *)sender {
    __kindof _YRBTChunk *packedChunk = [[_YRBTChunk alloc] initWithRawData:chunk];
    NSLog(@"[RECEIVING]: Received: %@. from %@. Parsed: %@", chunk, sender, packedChunk);
    
    switch (packedChunk.chunkType) {
        case kYRBTChunkTypeInternal:
            [self.delegate chunkParser:self didParseInternalChunk:packedChunk
                            fromSender:sender];
            break;
        case kYRBTChunkTypeHeader: {
            _YRBTHeaderChunk *headerChunk = packedChunk;
            
            if (!headerChunk.isResponse) {
                [self.delegate chunkParser:self didParseRemoteOperationHeaderChunk:headerChunk fromSender:sender];
            } else {
                [self.delegate chunkParser:self didParseResponseHeaderChunk:headerChunk fromSender:sender];
            }
            
            break;
        }
        case kYRBTChunkTypeOperationName:
            [self.delegate chunkParser:self didParseOperationNameChunk:packedChunk
                            fromSender:sender];
            break;
        case kYRBTChunkTypeRegular: {
            _YRBTRegularMessageChunk *messageChunk = packedChunk;
            
            if (!messageChunk.isResponse) {
                [self.delegate chunkParser:self didParseRemoteOperationRegularMessageChunk:messageChunk fromSender:sender];
            } else {
                [self.delegate chunkParser:self didParseResponseRegularMessageChunk:messageChunk fromSender:sender];
            }
            
            break;
        }
        default:
            NSAssert(NO, @"Received incorrect chunk with incorrect chunk layout.");
            NSError *error = [_YRBTErrorService buildErrorForCode:kYRBTErrorCodeReceivedIncorrectChunk];
            
            [self.delegate chunkParser:self didFailToParseChunkFromData:chunk
                            fromSender:sender withError:error];
            break;
    }
}

@end
