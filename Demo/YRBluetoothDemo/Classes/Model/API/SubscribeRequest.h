//
//  SubscribeRequest.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/15/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

#import "APIObject.h"

@interface SubscribeRequest : APIObject

@property (nonatomic, readonly) NSString *subscriberName;

- (instancetype)initWithName:(NSString *)name;

@end
