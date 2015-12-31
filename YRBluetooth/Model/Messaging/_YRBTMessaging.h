//
// _YRBTMessaging.h
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

#ifndef __YRBTMessaging__
#define __YRBTMessaging__

// General
#import "_YRBTMessagingTypes.h"

// Queue
// TODO: ??

// Messages
#import "YRBTMessage.h"

// Chunk Managers
#import "_YRBTChunkParser.h"
#import "_YRBTChunkGenerator.h"

// Provider
#import "_YRBTChunkProvider.h"
#import "_YRBTChunksContainer.h"

// Chunks
#import "_YRBTChunk.h"
#import "_YRBTInternalChunk.h"
#import "_YRBTMessageChunk.h"
#import "_YRBTHeaderChunk.h"
#import "_YRBTOperationNameChunk.h"
#import "_YRBTRegularMessageChunk.h"

#endif
