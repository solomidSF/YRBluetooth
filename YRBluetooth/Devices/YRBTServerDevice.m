//
//  ServerDevice.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/16/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

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
    !self.connectionStateCallback ? : self.connectionStateCallback(self, self.connectionState);    
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