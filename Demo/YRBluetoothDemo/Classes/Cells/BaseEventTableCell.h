//
//  BaseTableCell.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

#import "EventObject.h"

@interface BaseEventTableCell : UITableViewCell

@property (nonatomic) __kindof EventObject *event;

@end
