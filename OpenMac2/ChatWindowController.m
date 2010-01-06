#import "ChatWindowController.h"
#import "IRCController.h"
#import "DrawerButtonController.h"
#import "DrawerController.h"
#import "InfoPanelController.h"
#import "NickRegController.h"
#import "AboutBoxController.h"
#import "PrivWindowController.h"
#import "URLMutableAttributedString.h"
#import "URLTextView.h"
#import "LivePrefsController.h"
#import "Globals.h"
#import "TSAttributedStringFormattingAdditions.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

//NATE
// added the following for the rewritten version check

@implementation ChatWindowController

- (void)enableContextualMenus:(BOOL)doEnable
{
    NSArray *itemArray = [userListMenu itemArray];
    int x;

    for (x = 0; x < [itemArray count]; x++)
    {
        [[itemArray objectAtIndex:x] setEnabled:doEnable];
    }
}

- (IRCController *)ircController
{
    return ircController;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([[menuItem title] isEqualToString:@"Register Nickname..."] && ![ircController isConnected])
        return NO;

    else if (([[menuItem title] isEqualToString:@"Connect"] || [[menuItem title] isEqualToString:@"Disconnect"]) && [[chatWindow toolbar] customizationPaletteIsRunning])
        return NO;

    else if ([[menuItem title] isEqualToString:[quitMenuItem title]] /*&& [sheetController quitSheetOpen]*/)
        return NO;

    else
        return YES;
}

- (void)appendString:(NSString *)sAppend kind:(NSString *)defaultsColorName
{
    //NSMutableAttributedString *attStr;
    NSAttributedString *temp;
    NSMutableAttributedString *temp2;
    NSRange selectionRange = [chatTextView selectedRange];
    NSColor *bgColor, *textColor;

    if (!sAppend)
        return;
    /*attStr = [[NSMutableAttributedString alloc] initWithRTF:[chatTextView RTFFromRange:NSMakeRange(0, [[chatTextView string] length])] documentAttributes:nil];*/

    bgColor = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]];
    textColor = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:defaultsColorName]];

    /*if ([[NSUserDefaults standardUserDefaults] floatForKey:@"FocusOpacity"] != 1.0)
    {
        if ([defaultsColorName caseInsensitiveCompare:@"ServerColor"] == NSOrderedSame)
        {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ServerMessageFocus"])
            {
                textColor = [textColor blendedColorWithFraction:(1 - [[NSUserDefaults standardUserDefaults] floatForKey:@"FocusOpacity"]) ofColor:bgColor];
            }
        }
        else if ([defaultsColorName caseInsensitiveCompare:@"NoticeColor"] == NSOrderedSame)
        {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NoticeFocus"])
            {
                textColor = [textColor blendedColorWithFraction:(1 - [[NSUserDefaults standardUserDefaults] floatForKey:@"FocusOpacity"]) ofColor:bgColor];
            }
        }
        else if ([defaultsColorName caseInsensitiveCompare:@"JoinPartColor"] == NSOrderedSame)
        {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"JoinPartFocus"])
            {
                textColor = [textColor blendedColorWithFraction:(1 - [[NSUserDefaults standardUserDefaults] floatForKey:@"FocusOpacity"]) ofColor:bgColor];
            }
        }
        else if ([defaultsColorName caseInsensitiveCompare:@"MyColor"] == NSOrderedSame)
        {
            // don't do anything
        }
        else
        {
            if (!(n == nil))
            {
                // do check of focused nicknames here
            }

            textColor = [textColor blendedColorWithFraction:(1 - [[NSUserDefaults standardUserDefaults] floatForKey:@"FocusOpacity"]) ofColor:bgColor];
        }
    }*/

    temp = [[NSAttributedString alloc] initWithString:sAppend attributes:[NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, [NSFont userFixedPitchFontOfSize:0.0], NSFontAttributeName, nil]];



    /*[attStr appendAttributedString:temp];
    [chatTextView replaceCharactersInRange:NSMakeRange(0, [[chatTextView string] length]) withRTF:[attStr RTFFromRange:NSMakeRange(0, [attStr length]) documentAttributes:nil]];
    */

    // I found an easier way to do all this, and it's below

    temp2 = [temp mutableCopy];

    [temp2 detectURLs:[NSColor blueColor]];

    [temp2 convertSmileys];

    [temp2 detectBelChar];

/*    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowTimeStamp"])
    { */
        NSAttributedString *time; // for the time stamp
        time = [[NSAttributedString alloc] initWithString:[[NSDate date] descriptionWithCalendarFormat:@"[%H:%M] " timeZone:nil locale:nil] attributes:[NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, [NSFont userFixedPitchFontOfSize:0.0], NSFontAttributeName, nil]];
    
    [[chatTextView textStorage] appendAttributedString:time]; // append the time stamp
    [time release]; // kill that memory leak!
/*    }  */

    [[chatTextView textStorage] appendAttributedString:temp2]; // append the chat



    [temp release];
    [temp2 release];
    //[attStr release]; // how nice

    [chatTextView setSelectedRange:selectionRange];
    [ircController scrollToEnd];
}

// and now that the funtion has been edited, you can edit some more
- (IBAction)sendEmail:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:EMAIL_ADDRESS]];
}

- (IBAction)gotoWebPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:MAIN_URL]];
}

- (IBAction)gotoSupport:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:SUPPORT_URL]];
}


/*
 - (IBAction)gotoMessageBoard:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:FORUM_URL]];
}
*/
- (IBAction)gotoGuidlines:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GUIDE_URL]];
}

- (IBAction)gotoStatsPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:STATS_URL]];
}

- (IBAction)connectClick:(id)sender
{
    [ircController connectToIRCServer];
}

- (IBAction)doSend:(id)sender
{
    NSArray *theLines; // we are going to be splitting up the "line" into multiple lines!
    int x; // we need a counter in the loop
    NSString *theString = [[chatInputField textStorage] string], *theCommand, *theRest = @"", *target;
    NSRange theRange;

    if (![theString isEqualToString:@""]) // if field is not empty
    {
        // For the "up/down arrow key repeat the last/previous line" feature
        [history addObject:[NSString stringWithString:[[chatInputField textStorage] string]]];
        historyIndex = [history count];
    }

    if (![ircController isConnected])
    {
        [chatInputField setString:@""]; // clear text field
        [[chatInputField window] makeFirstResponder:chatInputField];
        return;
    }

    theLines = [theString componentsSeparatedByString:@"\r"]; //find charage returns, and split them into the array (may just be \r or \n will experement)

    for( x = 0; x < ([theLines count]); x++)
    {

        theString = [theLines objectAtIndex:x];

        if ([[theString substringToIndex:1] caseInsensitiveCompare:@"\n"] == NSOrderedSame) // check that there is a \n
            theString = [theString substringFromIndex:1]; // kill the \n and make it not return all the errors

        if (![theString isEqualToString:@""]) // if field is not empty
        {
            if ([theString characterAtIndex:0] == '/') // if it's a command
            {
                theRange = [theString rangeOfString:@" "];
                if (theRange.location != NSNotFound) // is there a command with at least 1 param?
                {
                    theCommand = [[theString substringToIndex:(theRange.location)] substringFromIndex:1];
                    theRest = [theString substringFromIndex:(theRange.location + 1)];

                    if ([theCommand caseInsensitiveCompare:@"QUOTE"] == NSOrderedSame)
                    {
                        theRange = [theRest rangeOfString:@" "];

                        [self appendString:[NSString stringWithFormat:@"--> %@\r\n", theRest] kind:@"MyColor"];
                        [ircController sendData:theRest];

                    }
                    else if ([theCommand caseInsensitiveCompare:@"CTCP"] == NSOrderedSame)
                    {
                        theRange = [theRest rangeOfString:@" "];
                        target = [theRest substringToIndex:(theRange.location)];
                        theRest = [theRest substringFromIndex:(theRange.location + 1)];
                        [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001%@\001", target, theRest]];
                        [self appendString:[NSString stringWithFormat:@"CTCP %@ %@\r\n", target, theRest] kind:@"MyColor"];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"NOTICE"] == NSOrderedSame)
                    {
                        theRange = [theRest rangeOfString:@" "];
                        if (theRange.location != NSNotFound)
                        {
                            target = [theRest substringToIndex:(theRange.location)];
                            theRest = [theRest substringFromIndex:(theRange.location + 1)];

                            [ircController sendData:[NSString stringWithFormat:@"%@ %@ :%@", theCommand, target, theRest]];

                            [self appendString:[NSString stringWithFormat:@"Notice to %@: %@\r\n", target, theRest] kind:@"MyColor"];
                        }
                    }
                    else if ([theCommand caseInsensitiveCompare:@"NICK"] == NSOrderedSame)
                    {
                        [ircController sendData:[NSString stringWithFormat:@"NICK %@", theRest]];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"JOIN"] == NSOrderedSame)
                    {
                        // joins are not allowed in this chat program, unless someone wants to impliment them ;)
                }
                    else if ([theCommand caseInsensitiveCompare:@"PART"] == NSOrderedSame)
                    {
                        // parts are not allowed
                    }
                    else if ([theCommand caseInsensitiveCompare:@"QUIT"] == NSOrderedSame)
                    {
                        [ircController disconnectFromIRCServer];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"HELP"] == NSOrderedSame)
                    {
                        [self showHelp:self];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"WHOIS"] == NSOrderedSame)
                    {
                        [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", theRest]];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"ME"] == NSOrderedSame)
                    {
                        [self sendAction:theRest];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"AWAY"] == NSOrderedSame)
                    {
                        [ircController sendData:[NSString stringWithFormat:@"AWAY :%@", theRest]];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"TOPIC"] == NSOrderedSame)
                    {
                        // it seems to be ignoring this one and using the one on line 413
                        if([theRest isEqualToString:@""])
                            [self appendString:[NSString stringWithFormat:@"%@\r\n", [topicField stringValue]] kind:@"TextColor"];
                        else
                            [ircController sendData:[NSString stringWithFormat:@"TOPIC %@ :%@", IRC_CHANNEL, theRest]];
                    }
                    else if ([theCommand caseInsensitiveCompare:@"MSG"] == NSOrderedSame)
                    {
                        BOOL alreadyOpened = NO;
                        int y, index = 0;
                        NSMutableArray *pmNicks = [ircController pmNicks];
                        theRange = [theRest rangeOfString:@" "];

                        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PrivateMessageNewWindow"] == YES)
                        {
                            if (theRange.location != NSNotFound)
                            {
                                target = [theRest substringToIndex:(theRange.location)];
                                theRest = [theRest substringFromIndex:(theRange.location + 1)];

                                for (y = 0; y < [pmNicks count]; y++)
                                {
                                    if ([[[pmNicks objectAtIndex:y] nickname] caseInsensitiveCompare:target] == NSOrderedSame)
                                    {
                                        alreadyOpened = YES;
                                        index = y;
                                    }
                                }

                                if (alreadyOpened)
                                {
                                    [[pmNicks objectAtIndex:index] showWindow:self];
                                    [[[pmNicks objectAtIndex:index] window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
                                    [[pmNicks objectAtIndex:index] setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
                                    [[pmNicks objectAtIndex:index] sendString:theRest];
                                }
                                else
                                {
                                    PrivWindowController *pwc = [[PrivWindowController alloc] init];
                                    [pwc setNickname:target];
                                    [pwc setIRCController:ircController];
                                    [[pwc window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
                                    [pwc setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
                                    [pwc showWindow:self];
                                    [pwc sendString:theRest];
                                    [pmNicks addObject:pwc];
                                    [pwc release];
                                }
                                /*[ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", target, 					theRest]];*/

                                /*[self appendString:[NSString stringWithFormat:@"To %@: %@\r\n", target, theRest] kind:@"MyColor"];*/
                            }
                        }
                        else
                        {
                            if (theRange.location != NSNotFound)
                            {
                                target = [theRest substringToIndex:(theRange.location)];
                                theRest = [theRest substringFromIndex:(theRange.location + 1)];
                                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", target, theRest]];
                                [self appendString:[NSString stringWithFormat:@"To %@: %@\r\n", target, theRest] kind:@"PrivateMessageColor"];
                            }
                        }
                    }
                }
                else
                { // command by itself
                    if ([theString length] != 1) // it isn't just a "/"
                    {
                        theCommand = [theString substringFromIndex:1];
                        if ([theCommand caseInsensitiveCompare:@"QUIT"] == NSOrderedSame)
                        {
                            [ircController disconnectFromIRCServer];
                        }
                        else if ([theCommand caseInsensitiveCompare:@"DEBUG"] == NSOrderedSame)
                        {
                            [ircController debug:@"showing Debuggger window" kind:@"JoinPartColor"];

                            [debuggerWindow makeKeyAndOrderFront:self];
                        }
                        else if ([theCommand caseInsensitiveCompare:@"HELP"] == NSOrderedSame)
                        {
                            [self showHelp:self];
                        }
                        else if ([theCommand caseInsensitiveCompare:@"AWAY"] == NSOrderedSame)
                        {
                            [ircController sendData:@"AWAY"];
                        }
                        else if ([theCommand caseInsensitiveCompare:@"TOPIC"] == NSOrderedSame)
                        {
                            if([theRest isEqualToString:@""])
                                [self appendString:[NSString stringWithFormat:@"%@\r\n", [topicField stringValue]] kind:@"TextColor"];
                            else
                                [ircController sendData:[NSString stringWithFormat:@"TOPIC %@ :%@", IRC_CHANNEL, theRest]];
                        }
                        else if (([theCommand caseInsensitiveCompare:@"JOIN"] == NSOrderedSame) || ([theCommand caseInsensitiveCompare:@"PART"] == NSOrderedSame) || ([theCommand caseInsensitiveCompare:@"MODE"] == NSOrderedSame) || ([theCommand caseInsensitiveCompare:@"KICK"] == NSOrderedSame))
                        {
                            // do nothing
                        }
                        else
                        {
                            [ircController sendData:theCommand]; // send command by itself
                        }
                    }
                }
            }
            else // send as regular message
            {
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", IRC_CHANNEL, theString]]; // tell the irc controller to send the data

                [self appendString:[NSString stringWithFormat:@"%@: %@\r\n", [utils truncateNick:[ircController theNickName]], theString] kind:@"MyColor"];
            }
    }

        [chatInputField setString:@""]; // clear text field
        [[chatInputField window] makeFirstResponder:chatInputField];
    }
    
}

- (IBAction)selectInput:(id)sender
{
    [[chatInputField window] makeFirstResponder:chatInputField];
}

- (IBAction)clearInput:(id)sender
{
    [chatInputField setString:@""]; // clear text field
    [[chatInputField window] makeFirstResponder:chatInputField];
}

- (IBAction)sendKiss:(id)sender
{
    if (![ircController isConnected])
    {
        NSBeep();
        return;
    }
    else
    {
        //NSString *nickname = [ircController theNickName];
        //NSString *trunc = [utils truncateNick:[ircController theNickName]];
        NSString *theString = @":X";


        [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", IRC_CHANNEL, theString]]; // tell the irc controller to send the data

        [self appendString:[NSString stringWithFormat:@"%@: %@\r\n", [utils truncateNick:[ircController theNickName]], theString] kind:@"MyColor"];
    }
}

- (IBAction)addCtrG:(id)sender
{
    [chatInputField setString:[NSString stringWithFormat:@"%@\007", [[chatInputField textStorage] string]]];
}

- (IBAction)openNickReg:(id)sender
{
    if (!nrc)
    {
        nrc = [[NickRegController alloc] init];
        [nrc setIRCController:ircController];
    }

    [nrc showNickReg];
}

- (IBAction)showHelp:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ReadMe" ofType:@"rtfd"];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (IBAction)userListDoubleClicked:(id)sender
{
    int rowIndex = [userListTableView clickedRow];

    if (([ircController nickList] != nil) && (rowIndex != -1))
    {
        char last;
        int indexOfLast;

        indexOfLast = ([[[ircController nickList] objectAtIndex:rowIndex] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:rowIndex] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", [[[ircController nickList] objectAtIndex:rowIndex] substringToIndex:indexOfLast]]];
                break;
            default:
                [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", [[ircController nickList] objectAtIndex:rowIndex]]];
                break;
        }

        if (![drawerButtonController infoPanelController])
        {
            [drawerButtonController makeInfoPanelController];
        }
        [[drawerButtonController infoPanelController] showWindow:self];
    }
    else
    {
        return;
    }
}

- (void)awakeFromNib
{
    NSSize contentSize;
    NSSize windowSize;
    NSToolbarItem *tbItem;

    windowSize.height=72.00;
    windowSize.width=120.00;

    contentSize = [chatScrollView contentSize];
    // NSLog(@"%f, %f", contentSize.width,contentSize.height);
    chatTextView = [[URLTextView alloc] initWithFrame:NSMakeRect(0,0,contentSize.width,contentSize.height)];
    [chatTextView setAutoresizingMask:NSViewWidthSizable];
    [[chatTextView textContainer] setWidthTracksTextView:YES];
    [chatTextView setRichText:YES];
    [chatTextView setSelectable:YES];
    [chatTextView setEditable:NO];
    [chatTextView setFieldEditor:YES]; // set it to a field editor, so tab will work
    [chatScrollView setDocumentView:chatTextView];
    [chatTextView release];

    [chatWindow setTitle:THIS_CHAT_APP];
    [chatWindow setFrameAutosaveName:@"ChatWindow"];
    [chatWindow setFrameUsingName:@"ChatWindow"];
    [chatWindow setMinSize:windowSize];

    [[chatInputField window] makeFirstResponder:chatInputField];
    [userListMenu setAutoenablesItems:NO];
    [userListTableView setDoubleAction:@selector(userListDoubleClicked:)];
    [userListTableView setRowHeight:11.5];

    // For the "up/down arrow key repeat the last/previous line" feature
    history = [[NSMutableArray alloc] init];
    historyIndex = 0;

    toolbarItems = [[NSMutableDictionary alloc] init];

    // NATE
    // added the following to get the toolbar working
    //
    // "Setup The Toolbar" Part 1 - define your toolbar item names, actions, and images:

    // the email button
    /*  tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar email"];
    [tbItem setPaletteLabel:@"E-mail OpenMac"];
    [tbItem setLabel:@"E-mail OpenMac"];
    [tbItem setToolTip:@"E-mail OpenMac"];
    [tbItem setImage:[NSImage imageNamed:@"mail"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(sendEmail:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar email"];
    [tbItem release]; */

    // the WebPage Button
    /*  tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar WebPage"];
    [tbItem setPaletteLabel:@"Visit OpenMac Web Site"];
    [tbItem setLabel:@"OpenMac Web"];
    [tbItem setToolTip:@"Visit the OpenMac Web Site"];
    [tbItem setImage:[NSImage imageNamed:@"OpenMac"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(gotoWebPage:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar WebPage"];
    [tbItem release]; */

    // the Message Board Button
    /* tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar MessageBoard"];
    [tbItem setPaletteLabel:@"Visit Message Board"];
    [tbItem setLabel:@"Forums"];
    [tbItem setToolTip:@"yack in slow motion"];
    [tbItem setImage:[NSImage imageNamed:@"MessageBoard"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(gotoMessageBoard:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar MessageBoard"];
    [tbItem release];*/

    // the Stats Page Button
    /*  tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar Stats"];
    [tbItem setPaletteLabel:@"Visit Stats Page"];
    [tbItem setLabel:@"Stats"];
    [tbItem setToolTip:@"marvel at Doug's record line count"];
    [tbItem setImage:[NSImage imageNamed:@"stats"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(gotoStatsPage:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar Stats"];
    [tbItem release]; */

    // the Emoticons Button
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar Emoticons"];
    [tbItem setPaletteLabel:loc(@"Show/Hide Emoticons Window")];
    [tbItem setLabel:loc(@"Emoticons")];
    [tbItem setToolTip:loc(@"Show the Emoticons Window")];
    [tbItem setImage:[NSImage imageNamed:@"Emoticon"]];
    [tbItem setTarget:emoticonController];
    [tbItem setAction:@selector(showEmoticonList:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar Emoticons"];
    [tbItem release];

    // want any more buttons? use the above template!
    // you can probably stop with your button definitions here :)

    // the connect button
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar Connect"];
    [tbItem setPaletteLabel:loc(@"Connect/Disconnect")];
    [tbItem setLabel:loc(@"Connect")];
    [tbItem setToolTip:[NSString stringWithFormat:loc(@"Connect to"), THIS_CHAT_APP]];
    [tbItem setImage:[NSImage imageNamed:@"Network"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(connectClick:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar Connect"];
    [tbItem release];

    // the UserList Button (you probably only want to change it's icon - if that)
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"TooBar UserList"];
    [tbItem setPaletteLabel:loc(@"User Options")];
    [tbItem setLabel:loc(@"Options")];
    [tbItem setToolTip:loc(@"Show the User Options")];
    [tbItem setImage:[NSImage imageNamed:@"Users"]];
    [tbItem setTarget:drawerController];
    [tbItem setAction:@selector(toggleDrawer:)];

    [toolbarItems setObject:tbItem forKey:@"TooBar UserList"];
    [tbItem release];

    // the Preferences button (you probably only want to change it's icon - if that)
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"TooBar Prefs"];
    [tbItem setPaletteLabel:loc(@"Open Preferences")];
    [tbItem setLabel:loc(@"Preferences")];
    [tbItem setToolTip:loc(@"Tweak your settings")];
    [tbItem setImage:[NSImage imageNamed:@"prefs"]];
    [tbItem setTarget:prefController];
    [tbItem setAction:@selector(openPrefWindow:)];

    [toolbarItems setObject:tbItem forKey:@"TooBar Prefs"];
    [tbItem release];

    // the Update Button (you probably only want to change it's icon - if that)
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar Update"];
    [tbItem setPaletteLabel:loc(@"Check for Update")];
    [tbItem setLabel:loc(@"Update")];
    [tbItem setToolTip:loc(@"See if there is a new version")];
    [tbItem setImage:[NSImage imageNamed:@"Update"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(checkVersion:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar Update"];
    [tbItem release];

    // the ReadMe Button (you probably only want to change it's icon - if that)
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"ToolBar ReadMe"];
    [tbItem setPaletteLabel:loc(@"View ReadMe")];
    [tbItem setLabel:loc(@"ReadMe")];
    [tbItem setToolTip:[NSString stringWithFormat:loc(@"View Readme file"), THIS_CHAT_APP]];
    [tbItem setImage:[NSImage imageNamed:@"ReadMe"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(showHelp:)];

    [toolbarItems setObject:tbItem forKey:@"ToolBar ReadMe"];
    [tbItem release];

    // ok, all the buttons are done being defined, you can now pop on down to line 999 (that will change if you added or deleted buttons above)

    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarSeparatorItemIdentifier];
    [toolbarItems setObject:tbItem forKey:NSToolbarSeparatorItemIdentifier];
    [tbItem release];

    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarSpaceItemIdentifier];
    [toolbarItems setObject:tbItem forKey:NSToolbarSpaceItemIdentifier];
    [tbItem release];

    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
    [toolbarItems setObject:tbItem forKey:NSToolbarFlexibleSpaceItemIdentifier];
    [tbItem release];

    toolbar = [[NSToolbar alloc] initWithIdentifier:@"OpenMac ToolBar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    // [toolbar setSizeMode:NSToolbarSizeModeSmall]; // it's listed on apples documentaion page but doesn't work

    [chatWindow setToolbar:toolbar];

    [chatTextView setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];

    //initialise menu titles
    [aboutMenuItem setTitle:[NSString stringWithFormat:loc(@"About %@"), THIS_CHAT_APP]];
    [appMenu setTitle:THIS_CHAT_APP];
    [quitMenuItem setTitle:[NSString stringWithFormat:loc(@"Quit %@"), THIS_CHAT_APP]];
    [hideMenuItem setTitle:[NSString stringWithFormat:loc(@"Hide %@"), THIS_CHAT_APP]];
    [helpMenuItem setTitle:[NSString stringWithFormat:loc(@"%@ Help"), THIS_CHAT_APP]];

    [self updateList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fisk:) name:NSWindowDidBecomeKeyNotification object:nil];
    //NSWindowDidBecomeKeyNotification
}
- (void)fisk:(id)sender
{
    if([[sender object] isEqualTo:chatWindow])
        [chatWindow makeFirstResponder:chatInputField];
}

- (NSToolbarItem *)connectItem
{
    return [toolbarItems objectForKey:@"ToolBar Connect"];
}

- (NSToolbarItem *)emoticonItem
{
    return [toolbarItems objectForKey:@"ToolBar Emoticons"];
}

- (NSToolbarItem *)userItem
{
    return [toolbarItems objectForKey:@"TooBar UserList"];
}

- (bool)connectItemVisible
{
    return connectItemVisible;
}

- (bool)userItemVisible
{
    return userItemVisible;
}

- (NSMenuItem *)connectMenuItem
{
    return connectMenuItem;
}

- (NSMenuItem *)connectDockMenuItem
{
    return connectDockMenuItem;
}

- (NSTextView *)textView
{
    return chatTextView;
}

- (NSTextView *)textField;
{
    return chatInputField;
}

- (NSTextField *)topicField
{
    return topicField;
}

- (NSTextField *)nickField
{
    return nickField;
}

- (NSWindow *)chatWindow
{
    return chatWindow;
}

- (NSTextView *)chatInputField
{
    return chatInputField;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if ([ircController nickList] != nil)
        return [[ircController nickList] count];
    else
        return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"Nickname"] && ([ircController nickList] != nil))
    {
        //        if (rowIndex <= [[ircController nickList] count])
        //        {

        char last;
        int indexOfLast;

        indexOfLast = ([[[ircController nickList] objectAtIndex:rowIndex] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:rowIndex] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
            case '#':
                return [[[ircController nickList] objectAtIndex:rowIndex] substringToIndex:indexOfLast];
                break;
            default:
                return [[ircController nickList] objectAtIndex:rowIndex];
                break;
        }
        //        }
    }
    else
    {
        // NSString *number=@"%i", rowIndex];
        return [NSString stringWithFormat:@"%i", rowIndex+1];
    }
}

- (void)updateList
{
    [userListTableView reloadData];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSMutableArray *ignoreList;
    int x;
    char last;
    int indexOfLast;
    NSString *realNick;
    BOOL isInList = NO;

    ignoreList = [[ircController prefController] ignoreList];

    indexOfLast = ([[[ircController nickList] objectAtIndex:rowIndex] cStringLength] - 1);

    last = [[[ircController nickList] objectAtIndex:rowIndex] characterAtIndex:indexOfLast];

    //NSLog(@"%@", [[ircController nickList] objectAtIndex:rowIndex]);
    //NSLog(@"%@,  %c", [[ircController nickList] objectAtIndex:rowIndex], last);

    if ([[[ircController nickList] objectAtIndex:rowIndex] characterAtIndex:([[[ircController nickList] objectAtIndex:rowIndex] cStringLength] - 1)] == '@') // is an op
    {
        [aCell setTextColor:[NSColor redColor]];
    }
    else if ([[[ircController nickList] objectAtIndex:rowIndex] characterAtIndex:([[[ircController nickList] objectAtIndex:rowIndex] cStringLength] - 1)] == '#') // is an op with voice
    {
        [aCell setTextColor:[NSColor redColor]];
    }
    else if ([[[ircController nickList] objectAtIndex:rowIndex] characterAtIndex:([[[ircController nickList] objectAtIndex:rowIndex] cStringLength] - 1)] == '+') // is voiced
    {
        [aCell setTextColor:[NSColor greenColor]];
    }
    else // normal user
    {
        switch (last)
        {
            case '@':
            case '+':
            case '#':
                realNick = [[[ircController nickList] objectAtIndex:rowIndex] substringToIndex:indexOfLast];
                NSLog(@"%@", [[ircController nickList] objectAtIndex:rowIndex]);
                break;
            default:
                realNick = [[ircController nickList] objectAtIndex:rowIndex];
                break;
        }


        for (x = 0; x < [ignoreList count]; x++)
        {
            if ([realNick caseInsensitiveCompare:[ignoreList objectAtIndex:x]] == NSOrderedSame)
            {
                isInList = YES;
            }
        }

        if (isInList)
            [aCell setTextColor:[NSColor lightGrayColor]];
        else if([buddyListController isBuddy:realNick])
            [aCell setTextColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BuddyColor"]]];
        else
            [aCell setTextColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]]];
    }

    [aCell setFont:[NSFont systemFontOfSize:10.0]];
    // set the background color of the cell
    if (rowIndex % 2 == 0)
        // make it the backround color
        [aCell setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
    else
        // make it the stripe color
        [aCell setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"StripeColor"]]];



}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSMutableArray *ignoreList;
    int x;
    char last;
    int indexOfLast;
    int row = [userListTableView selectedRow];
    NSString *realNick;
    BOOL isInList = NO;

    if ([userListTableView selectedRow] != -1)
    {
        [drawerButtonController enableButtons];

        if ([drawerButtonController infoPanelController])
        {
            indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

            last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

            switch (last)
            {
                case '@':
                case '+':
                    [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast]]];
                    break;
                default:
                    [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", [[ircController nickList] objectAtIndex:row]]];
                    break;
            }
        }

        ignoreList = [[ircController prefController] ignoreList];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                realNick = [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast];
                break;
            default:
                realNick = [[ircController nickList] objectAtIndex:row];
                break;
        }

        if([buddyListController isBuddy:realNick])
        {
            [[buddyListController buddyButton] setTitle:loc(@"Remove from Buddies")];
            [[buddyListController buddyMenu] setTitle:loc(@"Remove from Buddies")];
        }
        else
        {
            [[buddyListController buddyButton] setTitle:loc(@"Add to Buddy List")];
            [[buddyListController buddyMenu] setTitle:loc(@"Add to Buddy List")];
        }

        for (x = 0; x < [ignoreList count]; x++)
        {
            if ([realNick caseInsensitiveCompare:[ignoreList objectAtIndex:x]] == NSOrderedSame)
            {
                isInList = YES;
            }

            if (isInList)
            {
                [[drawerButtonController ignoreButton] setTitle:loc(@"Unignore")];
                [[drawerButtonController ignoreMenu] setTitle:loc(@"Unignore")];
            }
            else
            {
                [[drawerButtonController ignoreButton] setTitle:loc(@"Ignore")];
                [[drawerButtonController ignoreMenu] setTitle:loc(@"Ignore")];
            }
        }
    }
    else
    {
        if ([drawerButtonController infoPanelController])
        {
            [[drawerButtonController infoPanelController] setNickName:loc(@"Nobody is selected")];
            [[drawerButtonController infoPanelController] setUserName:@""];
            [[drawerButtonController infoPanelController] setRealName:@""];
            [[drawerButtonController infoPanelController] setHostName:@""];
            [[drawerButtonController infoPanelController] setIdle:@""];
            [[drawerButtonController infoPanelController] setSignedOn:@""];
        }

        [drawerButtonController disableButtons];
    }
}

- (NSTableView *)userListTableView
{
    return userListTableView;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if ([ircController isConnected])
        [ircController disconnectFromIRCServer];
}

- (NickRegController *)nrc
{
    return nrc;
}

- (void)disconnectFromIRCServer
{
    [ircController disconnectFromIRCServer];

    //   [self setConnectToolbarItem:YES];
}

- (IBAction)showAbout:(id)sender
{
    if (!abc)
        abc = [[AboutBoxController alloc] init];

    [[abc window] center];
    [abc showWindow:self];
}

- (IBAction)topicClick:(id)sender
{
    if (![[topicField stringValue] isEqualToString:@""])
    {
        [self appendString:[NSString stringWithFormat:@"%@\r\n", [topicField stringValue]] kind:@"TextColor"];
    }
}

/*- (void)controlTextDidChange:(NSNotification *)n
{
    NSText *theText = [[n userInfo] objectForKey:@"NSFieldEditor"];

    NSLog(@"Text Changed.");

    NSLog([theText string]);

    [theText scrollRangeToVisible:NSMakeRange(([[theText string] length] - 1), 0)];
}*/

// Toolbar Delegate Methods:
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [toolbarItems objectForKey:itemIdentifier];
}


// "Setup The Toolbar" Part 2 - what do you want in your default toolbar? put it in in your prefered order here:
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *items = [[NSMutableArray alloc] init];

    [items addObject:@"ToolBar Connect"];
    [items addObject:NSToolbarFlexibleSpaceItemIdentifier]; // Felx Space
                                                            // [items addObject:@"ToolBar WebPage"];
                                                            // [items addObject:@"ToolBar MessageBoard"];
                                                            // [items addObject:@"ToolBar email"];
                                                            // [items addObject:NSToolbarSpaceItemIdentifier]; // space
                                                            // [items addObject:@"ToolBar ReadMe"];
                                                            //  [items addObject:@"ToolBar Update"];
                                                            //  [items addObject:NSToolbarSeparatorItemIdentifier]; // seperator
                                                            //  [items addObject:@"TooBar Prefs"];
                                                            // [items addObject:NSToolbarCustomizeToolbarItemIdentifier]; // customise
    [items addObject:NSToolbarSeparatorItemIdentifier]; // seperator
    [items addObject:@"TooBar UserList"];

    return items;
}

// "Setup The Toolbar" Part 3 - what do you want avalable in your default toolbar? put it in in your prefered order here:
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *items = [[NSMutableArray alloc] init];

    [items addObject:@"ToolBar Connect"];
    [items addObject:@"TooBar UserList"];
    [items addObject:@"ToolBar Update"];
    [items addObject:@"TooBar Prefs"];
    [items addObject:@"ToolBar WebPage"];
    [items addObject:@"ToolBar email"];
    //  [items addObject:@"ToolBar MessageBoard"];
    [items addObject:@"ToolBar Stats"];
    [items addObject:@"ToolBar Emoticons"];
    [items addObject:@"ToolBar ReadMe"];
    [items addObject:NSToolbarSpaceItemIdentifier]; // space
    [items addObject:NSToolbarFlexibleSpaceItemIdentifier]; // Felx Space
    [items addObject:NSToolbarSeparatorItemIdentifier]; // seperator
    [items addObject:NSToolbarCustomizeToolbarItemIdentifier]; // customize

    return items;
}

// your toolbar should be done! compile it and find out :)

- (int)count {
    return [toolbarItems count];
}

- (IBAction)customize:(id)sender {
    [toolbar runCustomizationPalette:sender];
}

- (IBAction)showhide:(id)sender {
    [toolbar setVisible:![toolbar isVisible]];
}

- (void)toolbaritemclicked:(NSToolbarItem*)item {
    // log to console that the item was clicked
    NSLog(@"Click %@!",[item label]);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // NSLog(@"i'm done launching");
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserDrawerOpen"])
    {
        [drawerController openDrawer];
        //	[[self userItem] setToolTip:@"Hide the Users list"];
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"] == YES)
    {
        [ircController connectToIRCServer];
    }

    [drawerButtonController disableButtons];

    //[self launchCheckVersion];
    [NSThread detachNewThreadSelector:@selector(launchCheckVersion) toTarget:self withObject:nil];

    [NSApp setDelegate:self];
    [prefController appFinishLaunch];
}


- (BOOL)windowShouldClose:(id)sender
{
    if ([ircController isConnected])
    {
        [sheetController runQuitSheet];
        return NO;
    }
    else
    {
        [NSApp terminate:nil];
        return YES;
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if ([ircController isConnected])
    {
        [sheetController runQuitSheet];
        return NO;
    }
    else
    {
        return YES;
    }
}


// Circumvent some keys in the input textView
- (BOOL)textView:(NSTextView *)myTextView doCommandBySelector:(SEL)command;
{
    //NSLog (@"command	: %s", SELNAME(command));

    // Send the message
    if (command == @selector(insertNewline:))
    {
        [self performSelector:@selector(doSend:) withObject:myTextView afterDelay:0];
        return YES;
    }

    // Display the previous line that was sent
    else if (command == @selector(moveToBeginningOfParagraph:))
    {
        if(historyIndex > 0)
        {
            historyIndex--;
            [myTextView setString:[NSString stringWithString:[history objectAtIndex:historyIndex]]];
        }
        return YES;
    }

    // Display the previous line that was sent (if the pref is set to do it on the up arrow)
    else if (command == @selector(moveUp:))
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"OptionBuffer"])
        {
            if(historyIndex > 0)
            {
                historyIndex--;
                [myTextView setString:[NSString stringWithString:[history objectAtIndex:historyIndex]]];
            }
            return YES;
        }
        else
        {
            return NO;
        }
    }

    // Display the next line
    else if (command == @selector(moveToEndOfParagraph:))
    {
        if((([history count] - historyIndex) > 0) && (historyIndex < [history count]-1))
        {
            historyIndex++;
            [myTextView setString:[NSString stringWithString:[history objectAtIndex:historyIndex]]];
        }
        else
        {

            if(historyIndex == [history count]-1)
            {
                historyIndex++;
                [myTextView setString:@""];
            }
        }
        return YES;
    }


    else if (command == @selector(moveDown:))
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"OptionBuffer"])
        {
            if((([history count] - historyIndex) > 0) && (historyIndex < [history count]-1))
            {
                historyIndex++;
                [myTextView setString:[NSString stringWithString:[history objectAtIndex:historyIndex]]];
            }
            else
            {

                if(historyIndex == [history count]-1)
                {
                    historyIndex++;
                    [myTextView setString:@""];
                }
            }
            return YES;
        }
        else
        {
            return NO;
        }
    }

    else if (command == @selector(insertTab:))
    {
        //insert tab autocompleet code here
        return YES;
    }

    else if (command == @selector(insertBacktab:))
    {
        //insert tab autocompleet (reversed) code here
        return YES;
    }

    else if (command == @selector(noop:))
    {
        //kill the beeps!

        // is there a way to find out if it was a ctr-g? if so, insert that code here
        // followed by the insert bel char code
        return YES;
    }

    // send a /me on option-return
    else if (command == @selector(insertNewlineIgnoringFieldEditor:))
    {
        // old cool, but odd behevior:
        //[myTextView setString:[NSString stringWithFormat:@"/me %@", [[chatInputField textStorage] string]]];
        //[self performSelector:@selector(doSend:) withObject:myTextView afterDelay:0.5];

        // new behevior - like irlce:
        if ([ircController isConnected])
        {
            [self sendAction:[[chatInputField textStorage] string]];
        }

        [history addObject:[NSString stringWithString:[[chatInputField textStorage] string]]];
        historyIndex = [history count];

        [myTextView setString:@""];

        return YES;
    }
    else
    {
        return NO;
    }

}

-(void)sendAction:(NSString *)theString
{
    NSString *indent =@" ";
    int x;

    for (x=0; x < [[NSUserDefaults standardUserDefaults] integerForKey:@"MsgIndent"]; x++)
    {
        indent = [NSString stringWithFormat:@" %@", indent];
    }

    [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001ACTION %@\001", IRC_CHANNEL, theString]];
    [self appendString:[NSString stringWithFormat:@"%@ %@ %@\r\n", indent, [ircController theNickName], theString] kind:@"MyColor"];
}

-(void)updateToolBar
{
    if(connectItemVisible)
    {
        if ([ircController isConnected])
        {
            //[[self connectItem] setPaletteLabel:@"Disconnect/Connect"];
            [[self connectItem] setImage:[NSImage imageNamed:@"Network"]];
            [[self connectItem] setToolTip:[NSString stringWithFormat:loc(@"Disconnect from"), THIS_CHAT_APP]];
            [[self connectItem] setLabel:loc(@"Disconnect")]; // set connectButton's title
            [[self connectItem] setAction:@selector(disconnectFromIRCServer)]; // set action of it
        }
        else
        {
            //	[[self connectItem] setPaletteLabel:@"Connect/Disconnect"];
            [[self connectItem] setImage:[NSImage imageNamed:@"Network"]];
            [[self connectItem] setToolTip:[NSString stringWithFormat:loc(@"Connect to"), THIS_CHAT_APP]];
            [[self connectItem] setLabel:loc(@"Connect")]; // change title back to connect
            [[self connectItem] setAction:@selector(connectClick:)]; // change action back to connect
        }
    }

    if(userItemVisible)
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UserDrawerOpen"])
            [[self userItem] setToolTip:loc(@"Hide the User Options")];
        else
            [[self userItem] setToolTip:loc(@"Show the User Options")];
    }
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
    NSToolbarItem *delitem = [[notification userInfo] objectForKey: @"item"];

    if ([[delitem itemIdentifier] isEqual: [[self connectItem] itemIdentifier]])
        connectItemVisible = NO;
    else if ([[delitem itemIdentifier] isEqual: [[self userItem] itemIdentifier]])
        userItemVisible = NO;
}

- (void)toolbarWillAddItem: (NSNotification *) notification
{
    NSToolbarItem *additem = [[notification userInfo] objectForKey: @"item"];

    if ([[additem itemIdentifier] isEqual: [[self connectItem] itemIdentifier]])
        connectItemVisible = YES;
    else if ([[additem itemIdentifier] isEqual: [[self userItem] itemIdentifier]])
        userItemVisible = YES;

    [self updateToolBar];
}

- (NSWindow *)debuggerWindow
{
    return debuggerWindow;
}
- (BOOL) textView:(NSTextView *) textView tabHit:(NSEvent *) event
{
    NSArray *tabArr = [[chatInputField string] componentsSeparatedByString:@" "];
    NSMutableArray *found = [NSMutableArray array];
    NSEnumerator *enumerator = [[ircController nickList] objectEnumerator];
    NSString *name = nil, *shortest = nil;
    unsigned len = [(NSString *)[tabArr lastObject] length], count = 0;
    if( ! len ) return YES;
    while( ( name = [enumerator nextObject] ) ) {
        if( [[tabArr lastObject] caseInsensitiveCompare:[name substringToIndex:len]] == NSOrderedSame ) {
            [found addObject:name];
            if( [name length] < [shortest length] || ! shortest ) shortest = [[name copy] autorelease];
            count++;
        }
    }
    if( count == 1 ) {
        [[chatInputField textStorage] replaceCharactersInRange:NSMakeRange([[chatInputField textStorage] length] - len, len) withString:shortest];
        if( ! [[chatInputField string] rangeOfString:@" "].length ) [chatInputField replaceCharactersInRange:NSMakeRange([[chatInputField textStorage] length], 0) withString:@": "];
        else [chatInputField replaceCharactersInRange:NSMakeRange([[chatInputField textStorage] length], 0) withString:@" "];
    } else if( count > 1 ) {
        BOOL match = YES;
        unsigned i = 0;
        NSString *cut = nil;
        count = NSNotFound;
        while( 1 ) {
            if( count == NSNotFound ) count = [shortest length];
            if( (signed) count <= 0 ) return YES;
            cut = [shortest substringToIndex:count];
            for( i = 0, match = YES; i < [found count]; i++ ) {
                if( ! [[found objectAtIndex:i] hasPrefix:cut] ) {
                    match = NO;
                    break;
                }
            }
            count--;
            if( match ) break;
        }
        [[chatInputField textStorage] replaceCharactersInRange:NSMakeRange([[chatInputField textStorage] length] - len, len) withString:cut];
    }
    return YES;
}
@end
