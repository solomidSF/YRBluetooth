//
//  YRBTPeer.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/16/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

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

#pragma mark - Init

+ (instancetype)peerWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName;

- (instancetype)initWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName NS_DESIGNATED_INITIALIZER;

#pragma mark - Callbacks

/**
 *  Method associates given callbacks for specific operation name.
 */
- (void)registerWillReceiveRequestCallback:(YRBTWillReceiveRemoteRequestCallback)willReceiveRequest
				 didReceiveRequestCallback:(YRBTReceivedRemoteRequestCallback)receivedRequest
                 receivingProgressCallback:(YRBTProgressCallback)progress
                   failedToReceiveCallback:(YRBTRemoteRequestFailureCallback)failure
                              forOperation:(NSString *)operation;

/**
 *  Associates request callback for any unknown operation.
 */
- (void)registerReceivedRemoteRequestForUnknownOperation:(YRBTReceivedRemoteRequestCallback)requestCallback;

#pragma mark - Cleanup

/**
 *  Should be called when you don't need a peer. 
 *  This would invalidate all internal operations, so peer can be safely deallocated.
 *  Also it's called automatically when instance deallocates.
 */
- (void)invalidate;

@end
