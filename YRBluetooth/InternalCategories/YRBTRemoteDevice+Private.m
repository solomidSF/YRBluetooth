//
// YRBTRemoteDevice+Private.m
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

// Categories
#import "YRBTRemoteDevice+Private.h"

// Devices
#import "YRBTClientDevice.h"
#import "YRBTServerDevice.h"

@import CoreBluetooth;

@implementation YRBTRemoteDevice (Private)

@dynamic peerName;
@dynamic connectionState;

+ (__kindof YRBTRemoteDevice *)deviceForPeer:(__kindof CBPeer *)peer {
    if ([peer isKindOfClass:[CBCentral class]]) {
        return [YRBTClientDevice deviceForPeer:peer];
    } else if ([peer isKindOfClass:[CBPeripheral class]]) {
        return [YRBTServerDevice deviceForPeer:peer];
    }
    
    return nil;
}

@end
