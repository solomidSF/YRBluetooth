//
//  MessageTableCell.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/22/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Cells
#import "BaseEventTableCell.h"

// Model
#import "Message.h"

@interface MessageTableCell : BaseEventTableCell

@property (nonatomic) Message *message;

@end
