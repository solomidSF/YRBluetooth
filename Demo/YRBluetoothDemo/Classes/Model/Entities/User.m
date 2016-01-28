//
//  User.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Model
#import "User.h"

@interface User ()
@property (nonatomic, readwrite) NSString *identifier;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) BOOL isChatOwner;
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
