//
// _YRBTInternal.h
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

//extern NSString *const kDeviceOperationName; // TODO:

/** Every server has internal service uuid. */
NSString *const kInternalServiceUUID = @"7A226372-0DDF-4745-B490-55CC951A0922";
/** Characteristics UUID to send data to client devices. */
NSString *const kSendCharacteristicUUID = @"B1BD5118-34B6-49A5-B634-4AD906E11633";
/** Characteristics UUID to receive data from clients. */
NSString *const kReceiveCharacteristicUUID = @"1E0E3384-8EBA-45F7-B13E-FE3F4BB96722";