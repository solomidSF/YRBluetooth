//
// _YRBTChunkParser.h
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
@import CoreBluetooth;

@protocol _YRBTChunkParserDelegate;
@class _YRBTInternalChunk;
@class _YRBTMessageChunk;
@class _YRBTHeaderChunk;
@class _YRBTOperationNameChunk;
@class _YRBTRegularMessageChunk;

@interface _YRBTChunkParser : NSObject

@property (nonatomic, weak) id <_YRBTChunkParserDelegate> delegate;

+ (instancetype)parserWithDelegate:(id <_YRBTChunkParserDelegate>)delegate;

- (void)parseChunk:(NSData *)chunk fromSender:(CBPeer *)sender;

@end

@protocol _YRBTChunkParserDelegate <NSObject>

- (void)chunkParser:(_YRBTChunkParser *)parser didParseInternalChunk:(_YRBTInternalChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRemoteOperationHeaderChunk:(_YRBTHeaderChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseOperationNameChunk:(_YRBTOperationNameChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRemoteOperationRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseResponseHeaderChunk:(_YRBTHeaderChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseResponseRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didFailToParseChunkFromData:(NSData *)chunkData
         fromSender:(CBPeer *)sender withError:(NSError *)error;

@end