//
//  Constants.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/21/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

/** FOR TESTING. */
extern NSString *const kAppIDForTesting;

/** Every server has internal service uuid. */
extern NSString *const kInternalServiceUUID;
/** Characteristics UUID to receive messages from client device. */
extern NSString *const kReceiveMessageFromClientCharacteristicUUID;
/** Characteristics UUID to send messages from server to client. */
extern NSString *const kSendMessageToClientCharacteristicUUID;
/** Characteristics UUID to which we will talk for both sides. */
extern NSString *const kInternalCommandsCharacteristicUUID;
// === Internal commands === //
/** Internal command from client that tells its username. */
extern NSString *const kClientUsernameCommand;

/** Internal command to respond for read request. We should respond to request with some value. */
extern NSString *const kPreparingToReadValueCommand;

static inline CBUUID *internalServiceUUID() {
    static CBUUID *internalServiceUUID = nil;
    
    if (!internalServiceUUID) {
        internalServiceUUID = [CBUUID UUIDWithString:kInternalServiceUUID];
    }
    
    return internalServiceUUID;
}

static inline CBUUID *sendToServerCharacteristicUUID() {
    static CBUUID *sendToServerCharacteristicUUID = nil;
    
    if (!sendToServerCharacteristicUUID) {
        sendToServerCharacteristicUUID = [CBUUID UUIDWithString:kReceiveMessageFromClientCharacteristicUUID];
    }
    
    return sendToServerCharacteristicUUID;
}

static inline CBUUID *receiveFromServerCharacteristicUUID() {
    static CBUUID *receiveFromServerCharacteristicUUID = nil;
    
    if (!receiveFromServerCharacteristicUUID) {
        receiveFromServerCharacteristicUUID = [CBUUID UUIDWithString:kSendMessageToClientCharacteristicUUID];
    }
    
    return receiveFromServerCharacteristicUUID;
}

static inline CBUUID *internalCommandsCharacteristicUUID() {
    static CBUUID *internalCommandsCharacteristicUUID = nil;
    
    if (!internalCommandsCharacteristicUUID) {
        internalCommandsCharacteristicUUID = [CBUUID UUIDWithString:kInternalCommandsCharacteristicUUID];
    }
    
    return internalCommandsCharacteristicUUID;
}
