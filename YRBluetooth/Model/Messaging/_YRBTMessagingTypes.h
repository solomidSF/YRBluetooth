//
// _YRBTMessagingTypes.h
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

#ifndef __YRBTMessagingTypes__
#define __YRBTMessagingTypes__

typedef uint32_t message_id_t;
typedef uint32_t message_size_t;
typedef uint8_t message_object_type_t;

static message_object_type_t kMessageObjectTypeCustom = 0;
static message_object_type_t kMessageObjectTypeArray = 1;
static message_object_type_t kMessageObjectTypeDictionary = 2;
static message_object_type_t kMessageObjectTypeString = 3;

typedef uint8_t message_additional_info_t;

#define ADDITIONAL_INFO_IS_RESPONSE_OFFSET 1
#define ADDITIONAL_INFO_OBJECT_TYPE_OFFSET 2

#define ADDITIONAL_INFO_WANTS_RESPONSE_BITS 1 << 0
#define ADDITIONAL_INFO_IS_RESPONSE_BITS 1 << ADDITIONAL_INFO_IS_RESPONSE_OFFSET
#define ADDITIONAL_INFO_OBJECT_TYPE_BITS 0x3 << ADDITIONAL_INFO_OBJECT_TYPE_OFFSET

typedef uint16_t YRBTChunkType;

static YRBTChunkType const kYRBTChunkTypeInternal = 0x00;
static YRBTChunkType const kYRBTChunkTypeHeader = 0x01;
static YRBTChunkType const kYRBTChunkTypeOperationName = 0x02;
static YRBTChunkType const kYRBTChunkTypeRegular = 0x03;

typedef uint16_t YRBTInternalChunkCode;

static YRBTInternalChunkCode const kYRBTInternalChunkCodeUserDefined = 0x00;
static YRBTInternalChunkCode const kYRBTInternalChunkCodeCancel = 0x01;

typedef enum {
    kYRBTMessagePriorityNormal,
    kYRBTMessagePriorityHighest
} YRBTMessagePriority;

#pragma pack(push, 2)

typedef struct {
	YRBTChunkType chunkType;
	uint16_t chunkSize;
	void *variadicData;
} YRBTChunkLayout;

typedef struct {
	YRBTInternalChunkCode code;
	void *variadicData;
} YRBTInternalChunkLayout;

typedef struct {
    message_id_t messageID;
	uint16_t isResponse; // TODO: Too much bits available and not used in operation name chunk.
	void *variadicData;
} YRBTMessageChunkLayout; // 10 bytes overhead !!! consider lowering message id?

typedef struct {
	message_size_t messageSize;
	uint8_t operationNameSize;
	message_additional_info_t additionalInfo;
} YRBTHeaderChunkLayout;

typedef struct {
    uint16_t isSender;
    message_id_t messageID;
} YRBTCancelCommandInternalChunkLayout;

#pragma pack(pop)

static size_t const kYRBTMinChunkSize = sizeof(YRBTHeaderChunkLayout) + sizeof(YRBTChunkLayout) - sizeof(void *);
static size_t const kYRBTMessageChunkLayoutSize = sizeof(YRBTChunkLayout) + sizeof(YRBTMessageChunkLayout) - 2 * sizeof(void *);

#endif
