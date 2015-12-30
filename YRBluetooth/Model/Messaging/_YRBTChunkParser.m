//
//  _YRBTChunkParser.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 6/6/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "_YRBTChunkParser.h"

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
				[self.delegate chunkParser:self didParseRequestHeaderChunk:headerChunk fromSender:sender];
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
				[self.delegate chunkParser:self didParseRequestRegularMessageChunk:messageChunk fromSender:sender];
			} else {
				[self.delegate chunkParser:self didParseResponseRegularMessageChunk:messageChunk fromSender:sender];
			}
			
            break;
		}
        default:
            NSAssert(NO, @"Received incorrect chunk with incorrect chunk layout.");
            // TODO: Error: incorrect chunk layout.
            [self.delegate chunkParser:self didFailToParseChunkFromData:chunk
                            fromSender:sender withError:nil];
            break;
    }
}

@end
