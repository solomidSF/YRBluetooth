//
//  User.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "User.h"

// Components
#import "YRBluetooth.h"

@interface User ()
@property (nonatomic) YRBTClientDevice *device;
@property (nonatomic) BOOL isSubscribed;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableArray <NSDictionary *> *messageQueue;
@property (nonatomic) NSString *identifier;
@property (nonatomic) BOOL isConnected;
@property (nonatomic) BOOL isChatOwner;
@end

@implementation User

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqual:[(User *)object identifier]];
    } else {
        return NO;
    }
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

@end
