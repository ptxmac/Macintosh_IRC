//
//  SendData.h
//  ThinkSecret
//
//  Created by Nate Friedman on Thu Sep 26 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/NSMenu.h>
#import "Utils.h"

@class IRCController, ChatWindowController;

@interface SendDataController : NSObject {

		IBOutlet IRCController *ircController;
		IBOutlet ChatWindowController *chatWindowController; // I need to be able to talk with the textView
		IBOutlet Utils *utils;

}

- (void) sendLines:(NSArray *)theLines channel:(NSString *)theChannel;
- (void) sendCommandWithParams:(NSString *)theCommand params:(NSString *)theRest channel:(NSString *)theChannel;
- (void) sendMessage:(NSString *)theMessage who:(NSString *)target;
- (void) sendVanillaCommand:(NSString *)theCommand channel:(NSString *)theChannel;

@end
