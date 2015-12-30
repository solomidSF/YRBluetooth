//
//  YRBTRemoteDevice.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/16/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTRemoteDevice.h"

@interface YRBTRemoteDevice ()

@property (nonatomic, readwrite) NSUUID *uuid;
@property (nonatomic, readwrite) NSString *peerName;
@property (nonatomic, readwrite) YRBTConnectionState connectionState;

@end

@implementation YRBTRemoteDevice

#pragma mark - Dynamic Properties

- (void)setPeerName:(NSString *)peerName {
    if (![_peerName isEqualToString:peerName]) {
        _peerName = peerName;
        
        !self.nameChangeCallback ? : self.nameChangeCallback(self, peerName);
    }
}

#pragma mark - Private

- (NSString *)humanReadableConnectionState:(YRBTConnectionState)state {
    return @[@"Disconnected",
             @"Connecting..",
             @"Connected without communication",
             @"Connected",
             @"Disconnecting"][state];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return [self.uuid.UUIDString isEqualToString:[object uuid].UUIDString];
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [self.uuid.UUIDString hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ Name: %@. State: %@. UUID: <%@>", [super description], self.peerName, [self humanReadableConnectionState:self.connectionState], [self.uuid UUIDString]];
}

@end
