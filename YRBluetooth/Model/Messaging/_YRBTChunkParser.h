//
//  _YRBTChunkParser.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRequestHeaderChunk:(_YRBTHeaderChunk *)chunk
		 fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseOperationNameChunk:(_YRBTOperationNameChunk *)chunk
         fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseRequestRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
		 fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseResponseHeaderChunk:(_YRBTHeaderChunk *)chunk
		 fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didParseResponseRegularMessageChunk:(_YRBTRegularMessageChunk *)chunk
		 fromSender:(CBPeer *)sender;

- (void)chunkParser:(_YRBTChunkParser *)parser didFailToParseChunkFromData:(NSData *)chunkData
         fromSender:(CBPeer *)sender withError:(NSError *)error;

@end