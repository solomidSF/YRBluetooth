//
//  YRBTPeer.m
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 2/16/15.
//  Copyright (c) 2015 Yuriy Romanchenko. All rights reserved.
//

// Model
#import "YRBTPeer.h"

// InternalModel
#import "_YRBTRegisteredCallbacks.h"
#import "_YRBTRemoteRequestCallbacks.h"

#import "_YRBTMessagingTypes.h"

// For iPhone 5/6 iOS 8.0 I found that max MTU can be 512, but let's cut down that value, so other messages can be sent faster.
static int32_t const kDefaultClientMTU = 128;
static int32_t const kMaxClientMTU = 512;

@interface YRBTPeer ()
@property (nonatomic, readonly) _YRBTRegisteredCallbacks *callbacks;
@end

@implementation YRBTPeer

#pragma mark - Lifecycle

+ (instancetype)peerWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName {
    return [[self alloc] initWithAppID:appID
                              peerName:peerName];
}

- (instancetype)initWithAppID:(NSString *)appID
                     peerName:(NSString *)peerName {
    if (self = [super init]) {
        NSAssert(appID.length > 0,
                 @"You must specify app id for peer on init, otherwise you won't be able to communicate with other devices.");
        
        _appID = appID;
        _peerName = peerName ? peerName : @"Unknown Device";
        
        _MTU = kDefaultClientMTU;
        
        _callbacks = [_YRBTRegisteredCallbacks new];
    }
    
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"[YRBluetooth] You must instantiate a peer via call 'peerWithAppID:peerName:' or 'initWithAppID:peerName:'");
    return [self initWithAppID:nil peerName:nil];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [self invalidate];
}

#pragma mark - Dynamic Properties

- (void)setMTU:(uint16_t)MTU {
    _MTU = MIN(MAX(kYRBTMinChunkSize, MTU), kMaxClientMTU);
}

#pragma mark - Public

- (void)registerWillReceiveRequestCallback:(YRBTWillReceiveRemoteRequestCallback)willReceiveRequest
                 didReceiveRequestCallback:(YRBTReceivedRemoteRequestCallback)receivedRequest
                 receivingProgressCallback:(YRBTProgressCallback)progress
                   failedToReceiveCallback:(YRBTRemoteRequestFailureCallback)failure
                              forOperation:(NSString *)operation {
    _YRBTRemoteRequestCallbacks *callbacks = [_YRBTRemoteRequestCallbacks callbacksWithWillReceiveRequestCallback:willReceiveRequest
                                                                                          receivedRequestCallback:receivedRequest
                                                                                        receivingProgressCallback:progress
                                                                                                          failure:failure
                                                                                                            final:NO];
    
    [self.callbacks registerCallbacks:callbacks
                     forOperation:operation];
}

- (void)registerReceivedRemoteRequestForUnknownOperation:(YRBTReceivedRemoteRequestCallback)requestCallback
{
    _YRBTRemoteRequestCallbacks *callbacks = [_YRBTRemoteRequestCallbacks callbacksWithWillReceiveRequestCallback:NULL
                                                                                          receivedRequestCallback:requestCallback
                                                                                        receivingProgressCallback:NULL
                                                                                                          failure:NULL
                                                                                                            final:NO];
    
    [self.callbacks registerCallbacksForUnknownOperation:callbacks];
}

#pragma mark - Cleanup

- (void)invalidate {
    [self.callbacks invalidate];
}

@end