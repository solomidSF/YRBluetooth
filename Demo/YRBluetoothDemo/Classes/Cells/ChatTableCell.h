//
//  ChatTableCell.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Sessions
#import "ClientChatSession.h"

// Model
#import "ClientChat.h"

@interface ChatTableCell : UITableViewCell

@property (nonatomic) ClientChatSession *session;
@property (nonatomic) ClientChat *chat;

@end
