//
//  Constants.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/21/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

#import "Constants.h"

#warning Remove when ship.
#if TARGET_OS_IPHONE
@import CoreBluetooth;
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

NSString *const kAppIDForTesting = @"84995EA6-37DD-4D2D-895A-712867184734";
NSString *const kInternalServiceUUID = @"7A226372-0DDF-4745-B490-55CC951A0922";

NSString *const kReceiveMessageFromClientCharacteristicUUID = @"F1638CC2-9898-4354-8887-DA9D63C0C846";
NSString *const kSendMessageToClientCharacteristicUUID      = @"B1BD5118-34B6-49A5-B634-4AD906E11633";
NSString *const kInternalCommandsCharacteristicUUID         = @"1E0E3384-8EBA-45F7-B13E-FE3F4BB96722";
NSString *const kClientUsernameCommand                      = @"_CUC:";

// Will read value.
NSString *const kPreparingToReadValueCommand                = @"-WRV";