//
//  BaseTableCell.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Events
#import "EventObject.h"

// Sessions
#import "ClientChatSession.h"
#import "ServerChatSession.h"

@interface BaseEventTableCell : UITableViewCell

@property (nonatomic) ClientChatSession *clientSession;
@property (nonatomic) ServerChatSession *serverSession;
@property (nonatomic) __kindof EventObject *event;

@end
