//
// YRBTPeer.h
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

@import Foundation;

#import "YRBluetoothTypes.h"

/**
 *  Abstract class for client/server.
 */
@interface YRBTPeer : NSObject

/**
 *  Application id that is used to determine peers.
 *  Clients will try to find servers with given app id.
 *  It's not neccessary to determine id in terms of 1 application.
 */
@property (nonatomic, readonly) NSString *appID;

/**
 *  Name of peer.
 *  Clients will tell server their name on connection.
 *  Servers will broadcast it for other clients while scanning.
 */
@property (nonatomic, readonly) NSString *peerName;

/**
 *  Maximum transmission unit per packet.
 *  Messages are sent by packets, so this value determines packet size.
 *  MTU can vary from 20 to 512 bpp. (Tested on iOS 8)
 *  Default to 128 bpp.
 *  This affects how fast messages will be sent.
 *  If you're sending too much messages consider lowering MTU, so each packet will be processed faster.
 */
@property (nonatomic) uint16_t MTU; // TODO: Maybe encapsulate it?

/**
 *  Current bluetooth peer state.
 */
@property (nonatomic, readonly) YRBluetoothState bluetoothState;

/**
 *  Callback that will be called when bluetooth state changes.
 */
@property (nonatomic, copy) YRBluetoothStateChanged bluetoothStateChanged;

#pragma mark - Init

+ (instancetype)peerWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName;

- (instancetype)initWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName NS_DESIGNATED_INITIALIZER;

#pragma mark - Callbacks

/**
 *  Method associates given callbacks for specific operation name.
 */
- (void)registerWillReceiveRemoteOperationCallback:(YRBTWillReceiveRemoteOperationCallback)willReceive
                 didReceiveRemoteOperationCallback:(YRBTReceivedRemoteOperationCallback)received
                         receivingProgressCallback:(YRBTProgressCallback)progress
                           failedToReceiveCallback:(YRBTRemoteOperationFailureCallback)failure
                                      forOperation:(NSString *)operation;

/**
 *  Associates received remote operation callback for any unknown operation.
 */
- (void)registerReceivedRemoteOperationForUnknownOperationName:(YRBTReceivedRemoteOperationCallback)operationCallback;

#pragma mark - Cleanup

/**
 *  Should be called when you don't need a peer.
 *  This would invalidate all internal operations, so peer can be safely deallocated.
 *  Also it's called automatically when instance deallocates.
 */
- (void)invalidate;

@end
