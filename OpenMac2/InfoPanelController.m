//
//  InfoPanelController.m
//  ThinkSecret
//
//  Created by Doug Brown on Mon Dec 24 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "InfoPanelController.h"
#import "IRCController.h"


@implementation InfoPanelController
- (id)init
{
    self = [super initWithWindowNibName:@"Info"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [infoPanel setFrameAutosaveName:@"InfoPanel"];
    [infoPanel setFrameUsingName:@"InfoPanel"];
}

- (IBAction)updateInfo:(id)sender
{
    if ([[nickNameField stringValue] length] > 0)
        [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", [nickNameField stringValue]]];
}

- (void)setHostName:(NSString *)s
{
    [hostNameField setStringValue:s];
}

- (void)setIdle:(NSString *)s
{
    [idleField setStringValue:s];
}

- (void)setNickName:(NSString *)s
{
    [nickNameField setStringValue:s];
}

- (void)setRealName:(NSString *)s
{
    [realNameField setStringValue:s];
}

- (void)setSignedOn:(NSString *)s
{
    [signedOnField setStringValue:s];
}

- (void)setUserName:(NSString *)s
{
    [userNameField setStringValue:s];
}

- (void)setIRCController:(IRCController *)c
{
    [c retain];
    [ircController release];
    ircController = c;
}

@end
