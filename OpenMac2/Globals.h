//
//  Globals.h
//  ThinkSecret
//
//  Created by Nate Friedman on Thu Jun 20 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum NickIdentStyle { STR_PASS, STR_NICK_PASS, NICK_STR_PASS };

extern NSString *THIS_CHAT_APP;
extern const int PORT;
extern NSString *IRC_CHANNEL;
extern NSString *APP_URL;
extern NSString *MAIN_URL;
extern NSString *GUIDE_URL;
extern NSString *STATS_URL;
extern NSString *SUPPORT_URL;
extern NSString *FORUM_URL;
extern NSString *EMAIL_ADDRESS;
extern NSString *VERSION_URL;
extern const int APPBUILDNUMBER;
extern NSString *NICKSERV_NAME;
extern NSString *NICKSERV_REGED_TRIGGER;
extern NSString *NICKSERV_BAD_PASSWORD;
extern NSString *NICKSERV_IDENT;
extern NSString *KEYCHAIN_SERVICE;

extern enum NickIdentStyle IDENT_STYLE;

NSString * f(NSString *msgFormat, ...);

#define d(string) printf(">> %s:%d\n%s\n<<\n",__FILE__,__LINE__,[(string) cString]);


@interface Globals : NSObject {

}

@end
