//
//  InfoPanelController.h
//  ThinkSecret
//
//  Created by Doug Brown on Mon Dec 24 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class IRCController;

@interface InfoPanelController : NSWindowController {
    IBOutlet NSTextField *hostNameField;
    IBOutlet NSTextField *idleField;
    IBOutlet NSTextField *nickNameField;
    IBOutlet NSTextField *realNameField;
    IBOutlet NSTextField *signedOnField;
    IBOutlet NSTextField *userNameField;
    IBOutlet NSWindow *infoPanel;
    IRCController *ircController;
}

- (IBAction)updateInfo:(id)sender;
- (void)setHostName:(NSString *)s;
- (void)setIdle:(NSString *)s;
- (void)setNickName:(NSString *)s;
- (void)setRealName:(NSString *)s;
- (void)setSignedOn:(NSString *)s;
- (void)setUserName:(NSString *)s;
- (void)setIRCController:(IRCController *)c;

@end
