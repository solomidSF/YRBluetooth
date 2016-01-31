//
// YRBTServer.h
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Yuri R.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "YRBTPeer.h"

@class YRBTClientDevice;
@class YRBTMessage;

typedef void (^YRBTDeviceDidConnectCallback) (YRBTClientDevice *device);
typedef void (^YRBTDeviceDidDisconnectCallback) (YRBTClientDevice *device);
typedef void (^YRBTBroadcastingStateChanged) (BOOL isBroadcasting);

/**
 *  Peer that accepts connection from another clients.
 */
@interface YRBTServer : YRBTPeer

/**
 *  Devices that are currently connected to server.
 */
@property (nonatomic, readonly) NSArray <YRBTClientDevice *> *connectedDevices;

/**
 *  Callback that is called when device connects to server.
 */
@property (nonatomic, copy) YRBTDeviceDidConnectCallback deviceConnectCallback;

/**
 *  Callback that will be called when device disconnectst from server.
 */
@property (nonatomic, copy) YRBTDeviceDidDisconnectCallback deviceDisconnectCallback;
/**
 *  Tells if server is discoverable by others.
 */
@property (nonatomic, readonly) BOOL isBroadcasting;
/**
 *  Tells when server broadcasting state changed.
 */
@property (nonatomic, copy) YRBTBroadcastingStateChanged broadcastingStateChanged;

#pragma mark - Sending

/**
 *  Schedules message sending for specific client device.
 *  @param msg  Message to be sent. It shouldn't be empty.
 *  @param operationName Operation name associated with given message.
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