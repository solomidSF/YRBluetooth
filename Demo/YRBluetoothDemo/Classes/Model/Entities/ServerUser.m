//
//  ServerUser.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/27/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Entities
#import "ServerUser.h"

// Components
#import "YRBluetooth.h"

@interface ServerUser ()
@property (nonatomic, readwrite) YRBTClientDevice *device;
@property (nonatomic, readwrite) BOOL isSubscribed;
@property (nonatomic) NSMutableArray <NSDictionary *> *messageQueue;
@end

@implementation ServerUser

#pragma mark - Dynamic Properties

- (NSString *)identifier {
    if (self.isChatOwner) {
        return [super identifier];
    } else {
        return self.device.uuid.UUIDString;        
    }
}

@end
