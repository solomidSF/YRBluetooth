//
//  ChatMembersController.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/28/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Sessions
#import "ClientChatSession.h"
#import "ServerChatSession.h"

@interface ChatMembersController : UIViewController

@property (nonatomic) ClientChatSession *clientSession;
@property (nonatomic) ServerChatSession *serverSession;
@property (nonatomic) __kindof Chat *chat;

@end
