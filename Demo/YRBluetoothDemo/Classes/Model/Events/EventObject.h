//
//  EventObject.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import Foundation;

/**
 *  Datasource for chat table view.
 */
@interface EventObject : NSObject

@property (nonatomic, readonly) NSString *reuseIdentifier;
@property (nonatomic, readonly) NSTimeInterval timestamp;

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp;

@end
