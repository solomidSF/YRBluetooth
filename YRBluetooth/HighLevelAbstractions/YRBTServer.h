//
//  BluetoothServer.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/16/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

#import "YRBTPeer.h"

@class YRBTClientDevice;
@class YRBTMessage;

typedef void (^YRBTDeviceDidConnectCallback) (YRBTClientDevice *device);
typedef void (^YRBTDeviceDidDisconnectCallback) (YRBTClientDevice *device);

/**
 *  Peer that accepts connection from another clients.
 *  It can receive requests and provide response for them.
 */
@interface YRBTServer : YRBTPeer

/** Devices that are currently connected to server. */
@property (nonatomic, readonly) NSArray *connectedDevices;

/** Callback that is called when device connects to server. */
@property (nonatomic, copy) YRBTDeviceDidConnectCallback deviceConnectCallback;
/** Callback that is called when device disconnects from server. */
@property (nonatomic, copy) YRBTDeviceDidDisconnectCallback deviceDisconnectCallback;

#pragma mark - Sending

/**
 *  Schedules message sending for specific client device.
 *  @param msg  Message to be sent. It shouldn't be empty.
 *  @param operationName    Operation name associated with given message.
 *  @return Return value description
 *  @see Similar method
 */
- (YRBTMessageOperation *)sendMessage:(YRBTMessage *)msg
                        operationName:(NSString *)operationName
                             toClient:(YRBTClientDevice *)client
                      withSuccessSend:(YRBTSuccessSendCallback)success
                     responseCallback:(YRBTResponseCallback)response
                      sendingProgress:(YRBTProgressCallback)sendingProgress
                    receivingProgress:(YRBTProgressCallback)receivingProgress
                              failure:(YRBTOperationFailureCallback)failure;

- (YRBTMessageOperation *)broadcastMessage:(YRBTMessage *)message
                             operationName:(NSString *)operationName
                                 toClients:(NSArray *)clients
                               withSuccess:(YRBTSuccessSendCallback)success
                           sendingProgress:(YRBTProgressCallback)sendingProgress
                                   failure:(YRBTOperationFailureCallback)failure;

- (void)sendFastMessage:(YRBTMessage *)message
              toDevices:(NSArray <YRBTClientDevice *> *)devices
            successSend:(YRBTSuccessSendCallback)successSend
               progress:(YRBTProgressCallback)progress
                failure:(YRBTOperationFailureCallback)failure;

- (void)cancelOperation:(YRBTMessageOperation *)operation;

#pragma mark - Broadcasting

/** Makes server discoverable to client peers. */
- (void)startBroadcasting;
/** Stops broadcasting self, so client peers won't see device. */
- (void)stopBroadcasting;

@end