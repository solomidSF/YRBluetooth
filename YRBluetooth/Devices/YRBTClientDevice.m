//
//  ClientDevice.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/16/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

@import CoreBluetooth;

#import "YRBTClientDevice.h"

@interface YRBTClientDevice ()
@property (nonatomic) CBCentral *central;
@property (nonatomic) BOOL didPerformHandshake;
@property (nonatomic) BOOL isPerformingHandshake;
@end

@implementation YRBTClientDevice

#pragma mark - Lifecycle

+ (instancetype)deviceForPeer:(__kindof CBPeer *)peer {
    return [[self alloc] initWithCentral:peer];
}

- (instancetype)initWithCentral:(CBCentral *)central {
    if (self = [super init]) {
        _central = central;
    }
    
    return self;
}

- (void)dealloc {
    NSLog(@"%s. %@", __FUNCTION__, self);
}

#pragma mark - Dynamic Properties

- (NSUUID *)uuid {
    return self.central.identifier;
}

@end
