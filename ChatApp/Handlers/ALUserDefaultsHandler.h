//
//  ALUserDefaultsHandler.h
//  ChatApp
//
//  Created by shaik riyaz on 12/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#define EMAIL_VERIFIED @"EMAIL_VERIFIED"
#define DISPLAY_NAME @"DISPLAY_NAME"
#define DEVICE_KEY_STRING @"DEVICE_KEY_STRING"
#define USER_KEY_STRING @"USER_KEY_STRING"
#define EMAIL_ID @"EMAIL_ID"


#import <Foundation/Foundation.h>

@interface ALUserDefaultsHandler : NSObject

+(BOOL) isLoggedIn;

+(void) clearAll;

+(void) setEmailVerified: (BOOL) value;

+(void) setBoolForKey_isConversationDbSynced:(BOOL ) value;

+(BOOL) getBoolForKey_isConversationDbSynced;

+(void) setDeviceKeyString:(NSString*)deviceKeyString;

+(void) setUserKeyString:(NSString*)userKeyString;

+(void) setDisplayName:(NSString*)displayName;

+(void) setEmailId:(NSString*)emailId;

+(NSString *) getDeviceKeyString;

+(void) setUserId: (NSString *) userId;

+(NSString*)getUserId;

+(void) setLastSyncTime: (NSString *) lastSyncTime;

+(NSString *)getLastSyncTime;

@end
