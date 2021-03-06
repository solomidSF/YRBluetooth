//
//  ChatClientViewController.h
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

@import UIKit;

// Sessions
#import "ClientChatSession.h"

@interface ClientChatViewController : UIViewController

@property (nonatomic) ClientChatSession *session;
@property (nonatomic) ClientChat *pickedChat;

@end
