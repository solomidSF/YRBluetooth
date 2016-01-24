//
//  BTPrefix.h
//  BluetoothTestProject
//
//  Created by Yuriy Romanchenko on 12/29/13.
//  Copyright (c) 2013 Yuriy Romanchenko. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

#define BTDebug

#ifdef BTDebug

#define BTDebugMsg(s, ...) { \
NSString *debugString = [NSString stringWithFormat:(s), ##__VA_ARGS__]; \
NSDateFormatter *formatter = [NSDateFormatter new]; \
[formatter setDateStyle:NSDateFormatterShortStyle]; \
[formatter setTimeStyle:NSDateFormatterMediumStyle]; \
fprintf(stderr, "[%s] %s\n", [[formatter stringFromDate:[NSDate date]] UTF8String], [debugString UTF8String]); \
}
//NSString *dbgMessage = [NSString stringWithFormat : (s), ##__VA_ARGS__];\
//NSString *dbgTitle = [NSString stringWithFormat:@"%s:(%d)", __PRETTY_FUNCTION__, __LINE__];\
//fprintf(stderr,"%s\t%s\n", [dbgTitle UTF8String], [dbgMessage UTF8String]);\


#else

#define BTDebugMsg(s, ...)

#endif

#define BTDebugClient               0
#define BTDebugServer               0
// Related to client
#define BTDebugSendingFromClient    0
#define BTDebugReceivingFromServer  0
// Server-related
#define BTDebugSendingFromServer    0
#define BTDebugReceivingFromClient  0

#define BTMessageChunksSending      0

#warning Add more and integrate.