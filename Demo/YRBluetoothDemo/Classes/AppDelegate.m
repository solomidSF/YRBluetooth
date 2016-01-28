//
//  AppDelegate.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 12/30/15.
//  Copyright © 2015 solomidSF. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    UIUserNotificationType allNotificationTypes = UIUserNotificationTypeSound |
                                                  UIUserNotificationTypeAlert |
                                                  UIUserNotificationTypeBadge;
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    return YES;
}

@end
