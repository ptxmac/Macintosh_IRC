//
//  AIKeychain.h
//  Adium
//
//  Created by Adam Iser on Thu Feb 28 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AIKeychain : NSObject {

}

+ (NSString *)getPasswordFromKeychainForService:(NSString *)service account:(NSString *)account;
+ (void)putPasswordInKeychainForService:(NSString *)service account:(NSString *)account password:(NSString *)password;
+ (void)removePasswordFromKeychainForService:(NSString *)service account:(NSString *)account;


//private
+ (KCItemRef)getKCItemRefWithAccount:(NSString *)account service:(NSString *)service;

@end
