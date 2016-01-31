//
// YRBTServerDevice.m
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

@import CoreBluetooth;

#import "YRBTServerDevice.h"
#import "YRBTServerDevice+Private.h"

@interface YRBTServerDevice ()
@property (nonatomic) CBPeripheral *peripheral;
@end

@implementation YRBTServerDevice

#pragma mark - Lifecycle

+ (instancetype)deviceForPeer:(__kindof CBPeer *)peer {
    return [[self alloc] initWithPeripheral:peer];
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    if (self = [super init]) {
        _peripheral = peripheral;
        
        [_peripheral addObserver:self
                      forKeyPath:@"state"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"%s. %@", __FUNCTION__, self);
    [_peripheral removeObserver:self forKeyPath:@"state"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([object isEqual:self.peripheral]) {
        !self.connectionStateCallback ? : self.connectionStateCallback(self, self.connectionState);
    }
}

#pragma mark - Dynamic Properties

- (YRBTConnectionState)connectionState {
    switch (self.peripheral.state) {
        case CBPeripheralStateDisconnected:
            return kYRBTConnectionStateNotConnected;
        case CBPeripheralStateConnecting:
            return kYRBTConnectionStateConnecting;
        case CBPeripheralStateConnected:
            if (self.receiveCharacteristic.isNotifying) {
                return kYRBTConnectionStateConnected;
            } else {
                return kYRBTConnectionStateConnectedWithoutCommunication;
            }
        case CBPeripheralStateDisconnecting:
            return kYRBTConnectionStateDisconnecting;
        default:
            break;
    }
}

- (NSUUID *)uuid {
    return self.peripheral.identifier;
}

#pragma mark - Public

- (BOOL)canReceiveMessages {
    return self.connectionState == kYRBTConnectionStateConnected && self.receiveCharacteristic.isNotifying;
}

@end