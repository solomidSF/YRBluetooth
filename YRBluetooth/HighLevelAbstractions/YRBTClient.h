//
// YRBTClient.h
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
#import "YRBluetoothTypes.h"
#import "YRBTServerDevice.h"
#import "YRBTMessageOperation.h"

/**
 *  Peer that acts as a client. 
 *  It can scan, connect to another device that is acting as server.
 */
@interface YRBTClient : YRBTPeer

/** Array of YRBTServerDevice instances that contains devices to which current one is connected. */
@property (nonatomic, readonly) NSArray <YRBTServerDevice*> *connectedDevices;
@property (nonatomic, readonly) BOOL isScanning;

#pragma mark - Scanning

/**
 *  Finds devices asynchronously. If currently search is running - it will be restarted.
 *  Method invokes callback upon reaching timeout or just by getting max allowed device count.
 *  Specify NSIntegerMax to find all devices around for some amount of time.
 *  Caller is responsible to retain founded devices, otherwise they will be deallocated.
 *  Success callback contains array of founded devices, each instance represented by a YRBTServerDevice.
 *  You can't send messages to them, unless you explicitly connect to them using connectToDevice: method.
 */
- (void)retrieveAvailableServerDevicesWithTimeout:(NSTimeInterval)timeoutValue
                                   maxDeviceCount:(NSUInteger)maxDeviceCount
                              withSuccessCallback:(YRBTFoundDevicesCallback)successCallback
                                  failureCallback:(YRBTFailureCallback)errorCallback;
/**
 *  Scan's for devices and return them to provided callback.
 *  Method invoke your callback repeatedly upon finding device.
 *  When you finished call stopScanningForDevices method.
 *  Invoking this method while already scanning will restart scan at all.
 */
- (void)scanForDevicesWithCallback:(YRBTContiniousScanCallback)callback
                   failureCallback:(YRBTFailureCallback)failure;

/**
 *  Stops scanning for devices safely, without calling failure callback of current scanning operations.
 */
- (void)stopScanningForDevices;

#pragma mark - Connecting/Disconnecting

/**
 *  Connects to server asynchronously.
 */
- (void)connectToDevice:(YRBTServerDevice *)device
            withSuccess:(YRBTSuccessfulConnectionCallback)success
                failure:(YRBTFailureWithDeviceCallback)failure;

- (void)disconnectFromDevice:(YRBTServerDevice *)device;

#pragma mark - Sending

- (void)sendFastMessage:(YRBTMessage *)message
               toServer:(YRBTServerDevice *)server
            successSend:(YRBTSuccessSendCallback)successSend
               progress:(YRBTProgressCallback)progress
                failure:(YRBTOperationFailureCallback)failure;

- (YRBTMessageOperation *)sendMessage:(YRBTMessage *)message
                             toServer:(YRBTServerDevice *)server
                        operationName:(NSString *)operationName
                          successSend:(YRBTSuccessSendCallback)successSendCallback
                             response:(YRBTResponseCallback)responseCallback
                      sendingProgress:(YRBTProgressCallback)sendingProgress
                    receivingProgress:(YRBTProgressCallback)receivingProgress
                              failure:(YRBTOperationFailureCallback)failure;

- (void)cancelOperation:(YRBTMessageOperation *)operation;

@end
