//
//  ChatMemberCell.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Sessions
#import "ClientChatSession.h"

// Entities
#import "ClientUser.h"

@interface ChatMemberCell : UITableViewCell

@property (nonatomic) ClientChatSession *session;
@property (nonatomic) ClientUser *member;

@end
