//
//  _YRBTRegisteredCallbacks.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/26/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

@import Foundation;

#import "_YRBTRemoteRequestCallbacks.h"

/**
 *  Class that contains registered callbacks.
 */
@interface _YRBTRegisteredCallbacks : NSObject

/**
 *  Registers callbacks for given operation type.
 */
- (void)registerCallbacks:(_YRBTRemoteRequestCallbacks *)callbacks
             forOperation:(NSString *)operation;

/**
 *  Registers received remote request callback for unknown operation.
 */
- (void)registerCallbacksForUnknownOperation:(_YRBTRemoteRequestCallbacks *)callback;

/**
 *  Returns callbacks for given operation type.
 */
- (_YRBTRemoteRequestCallbacks *)callbacksForOperationType:(NSString *)operationType;

/**
 *  Removes all callbacks contained in instance.
 */
- (void)invalidate;

@end
