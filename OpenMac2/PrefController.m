#import "PrefController.h"
#import "ChatWindowController.h"
#import "IRCController.h"
#import "NickChooseController.h"
#import "EmoticonController.h"
#import "Globals.h"

#pragma align=powerpc
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation PrefController

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // standard user defaults
    NSArray *defaultKeys = [NSArray arrayWithObjects:
	
// "Setup the prefs" Part 1 - the pref item names and discriptsion - look, don't touch :)
	@"Nickname", 		// the name the user chats under
	@"RealName", 		// the name that shows up when someone gets info on the user
	@"ShortName",		// the short user name, not publicly changeable
	@"CTCPEnabled", 	// does the user want to have his/her privacy?
	@"QuitMessage", 	// what does the user want to say when they leave?
	@"NewServerPopUp", 	// i'm not sure what this is used for, i think it's the default IRC server
	@"ShowMOTD",	 	// does the user want to see the message of the day?
	@"IgnoreList",		// who doesn't the user like?
	@"TextColor",		// what color should incoming text be?
	@"BgColor",		// the backgound color?
	@"StripeColor",		// the backgound color?
	@"ChatWindowOpacity",	// the window opacity
	@"PrivateMessageOpacity", // private message window opacity
	@"NickChosen",		// has the user choses a nickname?
	@"MyColor",		// users text color
	@"ServerColor",		// the color of non-user generated text
	@"NoticeColor",		// the color of notices
	@"JoinPartColor",	// what color should joins and leaves be?
	@"PrivateMessageNewWindow", // should PM's be in new windows?
	@"PrivateMessageColor",	// what color should PM's be?
	@"BuddyColor",		// what color should buddies be?
	@"GestaltAskAllow",	// does the user want her privacy?
	@"BellBeep",		// should the computer beep when someone presses ctr-G (not currently implimented)
	@"CTCPSound",		// should the computer make noices when someone does a CTCP command on them?
	@"PMSound",		// a PM?
	@"PingSound",		// a ping?
	@"JoinSound",		// when people join?
	@"LeaveSound",		// how 'bout when they leave?
	@"KickSound",		// when there is a kick?
        @"BuddySound",		// when a buddy joines/leaves?
	@"NickTruncate",	// how meny chars should a nickname have before we cut them off?
	@"MsgIndent",		// who far in should a /me indent?
	@"AutoConnect",		// do we want to connect when the user opesn the app?
	@"UserDrawerOpen",	// was the user drawer open when the user quit?
	@"BuddyList",		// who does the user like?
	@"OptionBuffer",	// only scroll through the buffer when the option key is down?
	@"UseEmoticons",	// should it be flat text or should it show the emoticons?
	@"ShowTimeStamp",	// should the time stamp be visble? (there is no front end optoin to toggle this)
// did those make sence? good move on to Part 2
	
	nil]; // setup "default" default keys

    NSArray *defaultValues = [NSArray arrayWithObjects:

// "Setup the prefs" Part 2 - the defaults for the prefs item names, see above for the discriptsions
	NSUserName(), 							// Nickname
	NSFullUserName(),						// RealName
	NSUserName(), //THIS_CHAT_APP,					// ShortName (NSUserName() works well)
	[NSNumber numberWithBool:YES],					// CTCPEnabled
	@"http://macintosh.irczone.dk/ ", 				// QuitMessage
	[NSNumber numberWithInt:0],  					// NewServerPopUp (the 1st thing on the list in the prefs window is 0)
	[NSNumber numberWithBool:NO],					// ShowMOTD
	[NSMutableArray array],						// IgnoreList
	[NSArchiver archivedDataWithRootObject:[NSColor blackColor]],	// TextColor
	[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],	// BgColor
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:(237.0 / 255.0) green:(243.0 / 255.0) blue:(254.0 / 255.0) alpha:1.0]],					// StripeColor
	[NSNumber numberWithFloat:0.9999],				// ChatWindowOpacity
	[NSNumber numberWithFloat:0.9999],				// PrivateMessageOpacity
	[NSNumber numberWithBool:NO],					// NickChosen - leave on NO if you know whats good for you ;)
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceCyan:0.49 magenta:0.76 yellow:0.0 black:0.0 alpha:1.0]],							// MyColor
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceCyan:0.6 magenta:0.6 yellow:0.4 black:0.0 alpha:1.0]],							// ServerColor
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceCyan:0.33 magenta:0.33 yellow:0.33 black:0.0 alpha:1.0]],							// NoticeColor
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceCyan:0.6 magenta:0.6 yellow:0.4 black:0.0 alpha:1.0]],							// JoinPartColor
	[NSNumber numberWithBool:YES],					// PrivateMessageNewWindow
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceCyan:0.05 magenta:1.0 yellow:0.47 black:0.27 alpha:1.0]],							// PrivateMessageColor
	[NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceCyan:1.0 magenta:0.37 yellow:0.26 black:0.05 alpha:1.0]],							// BuddyColor
	[NSNumber numberWithInt:0],					// GestaltAskAllow
	[NSNumber numberWithBool:NO],					// BellBeep
	[NSNumber numberWithBool:YES],					// CTCPSound
	[NSNumber numberWithBool:YES],					// PMSound
	[NSNumber numberWithBool:YES],					// PingSound
	[NSNumber numberWithBool:YES],					// JoinSound
	[NSNumber numberWithBool:YES],					// LeaveSound
	[NSNumber numberWithBool:YES],					// KickSound
 [NSNumber numberWithBool:YES],					// BuddySound
	[NSNumber numberWithInt:8],					// NickTruncate
	[NSNumber numberWithInt:8],					// MsgIndent
	[NSNumber numberWithBool:NO],					// AutoConnect
	[NSNumber numberWithBool:NO],					// UserDrawerOpen
	[NSMutableArray array],						// BuddyList
	[NSNumber numberWithBool:YES],					// OptionBuffer
	[NSNumber numberWithBool:YES],					// UseEmoticons
	[NSNumber numberWithBool:NO],					// ShowTimeStamp
// and that is how your app acts the 1st time you launch it.
	
	nil]; // setup "default" default values
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:defaultValues forKeys:defaultKeys]; // make the app defaults dictionary using the two arrays

    [defaults registerDefaults:appDefaults]; // register as the appDefaults
}

- (IBAction)openPrefWindow:(id)sender
{
    //NSString *trunc;
    NSString *indent =@" ";
    int x;

    /* Save current defaults to temporary instance variables, set control values, show window */
    autoConnectTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];

// if i decide to put the toolbar back in....
    /*
    // begin toolbar
    NSToolbarItem *tbItem;
    toolbarItems = [[NSMutableDictionary alloc] init];

    //Connection
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Prefs Connection"];
    [tbItem setPaletteLabel:@"Connection"];
    [tbItem setLabel:@"Connection"];
    [tbItem setToolTip:@"Your Connection Preferences"];
    [tbItem setImage:[NSImage imageNamed:@"connect-prefs"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(showConnection:)];

    [toolbarItems setObject:tbItem forKey:@"Prefs Connection"];
    [tbItem release];

    //Appearance
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Prefs Appearance"];
    [tbItem setPaletteLabel:@"Appearance"];
    [tbItem setLabel:@"Appearance"];
    [tbItem setToolTip:@"Your Appearance Preferences"];
    [tbItem setImage:[NSImage imageNamed:@"Appearance-prefs"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(showAppearance:)];

    [toolbarItems setObject:tbItem forKey:@"Prefs Appearance"];
    [tbItem release];

    //Advanced
    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:@"Prefs Advanced"];
    [tbItem setPaletteLabel:@"Advanced"];
    [tbItem setLabel:@"Advanced"];
    [tbItem setToolTip:@"Your Advanced Preferences"];
    [tbItem setImage:[NSImage imageNamed:@"Advanced-prefs"]];
    [tbItem setTarget:self];
    [tbItem setAction:@selector(ShowAdvanced:)];

    [toolbarItems setObject:tbItem forKey:@"Prefs Advanced"];
    [tbItem release];
    
    // done defining buttons

    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarSeparatorItemIdentifier];
    [toolbarItems setObject:tbItem forKey:NSToolbarSeparatorItemIdentifier];
    [tbItem release];

    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarSpaceItemIdentifier];
    [toolbarItems setObject:tbItem forKey:NSToolbarSpaceItemIdentifier];
    [tbItem release];

    tbItem = [[NSToolbarItem alloc] initWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
    [toolbarItems setObject:tbItem forKey:NSToolbarFlexibleSpaceItemIdentifier];
    [tbItem release];

    toolbar = [[NSToolbar alloc] initWithIdentifier:@"PrefsTB"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];

    [prefWindow setToolbar:toolbar];    
    
    // end toolbar
     */
    
    truncateTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"];
    indentTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"MsgIndent"];

    
    /*begin Nate's ThinkSecret 1.1b5 sound prefs */
    bellBeepTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"BellBeep"];
    soundCTCPTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"];
    soundMPTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"PMSound"];
    soundPingTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"PingSound"];
    soundJoinTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"JoinSound"];
    soundLeaveTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"];
    soundKickTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"KickSound"];
    /*end 1.1b5 sound prefs*/
    soundBuddyTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"];
    
    ctcpEnabledTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPEnabled"];
    nameTemp = [[[NSUserDefaults standardUserDefaults] stringForKey:@"RealName"] retain];
    nicknameTemp = [[[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"] retain];
    quitMessageTemp = [[[NSUserDefaults standardUserDefaults] stringForKey:@"QuitMessage"] retain];
    NewServerPopUpTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"];
    showMOTDTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowMOTD"];
    pmNewWindowTemp = [[NSUserDefaults standardUserDefaults] boolForKey:@"PrivateMessageNewWindow"];
    chatFontTemp = [[NSFont userFixedPitchFontOfSize:0.0] retain];
    gestaltTemp = [[NSUserDefaults standardUserDefaults] integerForKey:@"GestaltAskAllow"];
    if (gestaltTemp > 2)
        gestaltTemp = 1;

    newFont = [chatFontTemp retain];
    textColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]] retain];
    bgColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]] retain];
    stripeColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"StripeColor"]] retain];
    myColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyColor"]] retain];
    joinPartColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"JoinPartColor"]] retain];
    serverColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerColor"]] retain];
    noticeColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"NoticeColor"]] retain];
    pmColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] retain];
    buddyColorTemp = [[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BuddyColor"]] retain];

    opaqueTemp = [[NSUserDefaults standardUserDefaults] floatForKey:@"ChatWindowOpacity"];
    pmOpaqueTemp = [[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"];

    /*begin Nate's ThinkSecret 1.1b5 sound prefs */
    [bellBeepBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"BellBeep"]];
    [soundCTCPBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"]];
    [soundPMBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"PMSound"]];
    [soundPingBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"PingSound"]];
    [soundJoinBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"JoinSound"]];
    [soundLeaveBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"]];
    [soundKickBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"KickSound"]];
    /*end 1.1b5 sound prefs*/
    [soundBuddyBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"]];

    [autoConnectBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"]];
    [autoConnectBox setTitle:[NSString stringWithFormat:loc(@"Automatically connect"), THIS_CHAT_APP]];
    
    [emotBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"UseEmoticons"]];
    [bufferBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"OptionBuffer"]];

 // fill truncateFeild
    // trunc = [utils truncateNick:nicknameTemp];
    
    [truncateField setFont:[chatFontTemp retain]];
    [truncateField setStringValue:[NSString stringWithFormat:loc(@"what x characters looks like"), [utils truncateNick:nicknameTemp], truncateTemp]];

// fill indent feild
    for (x = 0; x < indentTemp; x++)
    {
	indent = [NSString stringWithFormat:@" %@", indent];
    }

    [indentField setFont:[chatFontTemp retain]];
    [indentField setStringValue:[NSString stringWithFormat:loc(@"indent of characters"), indent, nicknameTemp, indentTemp]];

    [truncateSlider setIntValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"]];
    [indentSlider setIntValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"MsgIndent"]];
    
    [quitMessageField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"QuitMessage"]];
    [nameField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"RealName"]];
    [nickField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"]];
    [ctcpEnabledBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPEnabled"]];
    [serverPopUp selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]];
    [showMOTDBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"ShowMOTD"]];
    [currentFontField setStringValue:[NSString stringWithFormat:@"%@ %g", [chatFontTemp fontName], [chatFontTemp pointSize]]];
    [opaqueSlider setFloatValue:opaqueTemp];
    [pmOpaqueSlider setFloatValue:pmOpaqueTemp];
    [opaqueSlider setMaxValue:0.9999];
    [pmOpaqueSlider setMaxValue:0.9999];
    [bgColorWell setColor:bgColorTemp];
    [stripeColorWell setColor:stripeColorTemp];
    [textColorWell setColor:textColorTemp];
    [myColorWell setColor:myColorTemp];
    [joinPartColorWell setColor:joinPartColorTemp];
    [serverColorWell setColor:serverColorTemp];
    [noticeColorWell setColor:noticeColorTemp];
    [pmColorWell setColor:pmColorTemp];
    [buddyColorWell setColor:buddyColorTemp];
    [pmNewWindowBox setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"PrivateMessageNewWindow"]];
    [gestaltBox selectCellAtRow:gestaltTemp column:0];

    [NSApp beginSheet:prefWindow
       modalForWindow:chatWindow
	       modalDelegate:self
       didEndSelector:nil
			contextInfo:prefWindow];
    //[NSApp runModalForWindow:prefWindow];
   // [NSApp endSheet:prefWindow];

    // [prefWindow orderOut:self];
    
    //[prefWindow makeKeyAndOrderFront:self];

				[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
}

- (IBAction)prefWindowCancel:(id)sender
{

    [NSApp endSheet:prefWindow];
    [prefWindow close];
    
    // revert button states back and don't change defaults

    /*begin Nate's ThinkSecret 1.1b5 sound prefs */
    [bellBeepBox setState:bellBeepTemp];
    [soundCTCPBox setState:soundCTCPTemp];
    [soundPMBox setState:soundMPTemp];
    [soundPingBox setState:soundPingTemp];
    [soundJoinBox setState:soundJoinTemp];
    [soundLeaveBox setState:soundLeaveTemp];
    [soundKickBox setState:soundKickTemp];
    /*end 1.1b5 sound prefs*/
    [soundBuddyBox setState:soundBuddyTemp];

    [autoConnectBox setState:autoConnectTemp];

    [emotBox setState:emotTemp];
    [bufferBox setState:bufferTemp];

    [truncateSlider setIntValue:truncateTemp];
    [indentSlider setIntValue:indentTemp];
    
    [quitMessageField setStringValue:quitMessageTemp];
    [nameField setStringValue:nameTemp];
    [nickField setStringValue:nicknameTemp];
    [ctcpEnabledBox setState:ctcpEnabledTemp];
    [serverPopUp selectItemAtIndex:NewServerPopUpTemp];
    [showMOTDBox setState:showMOTDTemp];
    [currentFontField setStringValue:[NSString stringWithFormat:@"%@ %g", [[NSFont userFixedPitchFontOfSize:0.0] fontName], [[NSFont userFixedPitchFontOfSize:0.0] pointSize]]];
    [bgColorWell setColor:bgColorTemp];
    [stripeColorWell setColor:stripeColorTemp];
    [textColorWell setColor:textColorTemp];
    [myColorWell setColor:myColorTemp];
    [noticeColorWell setColor:noticeColorTemp];
    [serverColorWell setColor:serverColorTemp];
    [joinPartColorWell setColor:joinPartColorTemp];
    [opaqueSlider setFloatValue:opaqueTemp];
    [pmOpaqueSlider setFloatValue:pmOpaqueTemp];
    [pmColorWell setColor:pmColorTemp];
    [pmNewWindowBox setState:pmNewWindowTemp];
    [[cwc ircController] setPMOpacity:pmOpaqueTemp font:[NSFont userFixedPitchFontOfSize:0.0] color:textColorTemp bgColor:bgColorTemp];

    [gestaltBox selectCellAtRow:gestaltTemp column:0];

    [[cwc textView] setBackgroundColor:bgColorTemp];
    [[cwc textField] setBackgroundColor:bgColorTemp];
    /*[[cwc textView] setTextColor:textColorTemp];*/
    [[cwc textField] setTextColor:myColorTemp];

    //[[cwc userListTableView] setBackgroundColor:bgColorTemp];
   // [[buddyListController buddyListTableView] setBackgroundColor:bgColorTemp];
    
    [nameTemp release];
    [nicknameTemp release];
    [quitMessageTemp release];
    [chatFontTemp release];
    [newFont release];
    [bgColorTemp release];
    [stripeColorTemp release];
    [textColorTemp release];
    [myColorTemp release];
    [joinPartColorTemp release];
    [serverColorTemp release];
    [noticeColorTemp release];
    [pmColorTemp release];

//    [[cwc chatWindow] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"ChatWindowOpacity"]];
    [[cwc chatWindow] setAlphaValue:opaqueTemp];
    [[[[[[cwc chatWindow] drawers] objectAtIndex: 0] contentView] window] setAlphaValue:opaqueTemp];

    
   // [NSApp stopModal];
//    [prefWindow close];
}

- (IBAction)prefWindowOk:(id)sender
{
    /* Verify if prefs have been changed, and if so, write them to user defaults. Also, close the window. */
    
    if ([truncateSlider intValue] != [[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"])
        [[NSUserDefaults standardUserDefaults] setInteger:[truncateSlider intValue] forKey:@"NickTruncate"];

    if ([indentSlider intValue] != [[NSUserDefaults standardUserDefaults] integerForKey:@"MsgIndent"])
        [[NSUserDefaults standardUserDefaults] setInteger:[indentSlider intValue] forKey:@"MsgIndent"];

 
    
    /*begin Nate's ThinkSecret 1.1b5 sound prefs */
    if ([bellBeepBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"BellBeep"])
        [[NSUserDefaults standardUserDefaults] setBool:[bellBeepBox state] forKey:@"BellBeep"];
    if ([soundCTCPBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundCTCPBox state] forKey:@"CTCPSound"];
    if ([soundPMBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"PMSound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundPMBox state] forKey:@"PMSound"];
    if ([soundPingBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"PingSound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundPingBox state] forKey:@"PingSound"];
    if ([soundJoinBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"JoinSound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundJoinBox state] forKey:@"JoinSound"];
    if ([soundLeaveBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundLeaveBox state] forKey:@"LeaveSound"];
    if ([soundKickBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"KickSound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundKickBox state] forKey:@"KickSound"];
    /*end 1.1b5 sound prefs*/
    if ([soundBuddyBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"])
        [[NSUserDefaults standardUserDefaults] setBool:[soundBuddyBox state] forKey:@"BuddySound"];

    if ([autoConnectBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"])
        [[NSUserDefaults standardUserDefaults] setBool:[autoConnectBox state] forKey:@"AutoConnect"];


    if ([bufferBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"OptionBuffer"])
        [[NSUserDefaults standardUserDefaults] setBool:[bufferBox state] forKey:@"OptionBuffer"];
    
    if ([emotBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"UseEmoticons"])
        [[NSUserDefaults standardUserDefaults] setBool:[emotBox state] forKey:@"UseEmoticons"];

    if ([emotBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"UseEmoticons"])
        [[NSUserDefaults standardUserDefaults] setBool:[emotBox state] forKey:@"UseEmoticons"];
    if ([bufferBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"OptionBuffer"])
        [[NSUserDefaults standardUserDefaults] setBool:[bufferBox state] forKey:@"OptionBuffer"];

       
    if (![[quitMessageField stringValue] isEqualToString:[[NSUserDefaults standardUserDefaults]
        stringForKey:@"QuitMessage"]])
        [[NSUserDefaults standardUserDefaults] setObject:[quitMessageField stringValue] forKey:@"QuitMessage"];
    if (![[nameField stringValue] isEqualToString:[[NSUserDefaults standardUserDefaults]
        stringForKey:@"RealName"]])
        [[NSUserDefaults standardUserDefaults] setObject:[nameField stringValue] forKey:@"RealName"];
    if (![[nickField stringValue] isEqualToString:[[NSUserDefaults standardUserDefaults]
        stringForKey:@"Nickname"]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[nickField stringValue] forKey:@"Nickname"];
	[ircController sendData:[NSString stringWithFormat:@"NICK %@", [nickField stringValue]]];
    }
    if ([ctcpEnabledBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPEnabled"]) 
        [[NSUserDefaults standardUserDefaults] setBool:[ctcpEnabledBox state] forKey:@"CTCPEnabled"];
    if ([serverPopUp indexOfSelectedItem] != [[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"])
        [[NSUserDefaults standardUserDefaults] setInteger:[serverPopUp indexOfSelectedItem] forKey:@"NewServerPopUp"];
    if ([showMOTDBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowMOTD"])
        [[NSUserDefaults standardUserDefaults] setBool:[showMOTDBox state] forKey:@"ShowMOTD"];
    if ([pmNewWindowBox state] != [[NSUserDefaults standardUserDefaults] boolForKey:@"PrivateMessageNewWindow"]) 
        [[NSUserDefaults standardUserDefaults] setBool:[pmNewWindowBox state] forKey:@"PrivateMessageNewWindow"];
    if ([textColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[textColorWell color]] forKey:@"TextColor"];
    if ([bgColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[bgColorWell color]] forKey:@"BgColor"];
    if ([stripeColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"StripeColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[stripeColorWell color]] forKey:@"StripeColor"];
    if ([myColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[myColorWell color]] forKey:@"MyColor"];
    if ([joinPartColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"JoinPartColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[joinPartColorWell color]] forKey:@"JoinPartColor"];
    if ([noticeColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"NoticeColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[noticeColorWell color]] forKey:@"NoticeColor"];
    if ([serverColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"ServerColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[serverColorWell color]] forKey:@"ServerColor"];
    if ([pmColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[pmColorWell color]] forKey:@"PrivateMessageColor"];
    if ([buddyColorWell color] != [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BuddyColor"]])
        [[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[buddyColorWell color]] forKey:@"BuddyColor"];

    if ([opaqueSlider floatValue] != [[NSUserDefaults standardUserDefaults] floatForKey:@"ChatWindowOpacity"])
        [[NSUserDefaults standardUserDefaults] setFloat:[opaqueSlider floatValue] forKey:@"ChatWindowOpacity"];

    if ([pmOpaqueSlider floatValue] != [[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"])
        [[NSUserDefaults standardUserDefaults] setFloat:[pmOpaqueSlider floatValue] forKey:@"PrivateMessageOpacity"];

    if ([gestaltBox selectedRow] != [[NSUserDefaults standardUserDefaults] integerForKey:@"GestaltAskAllow"])
        [[NSUserDefaults standardUserDefaults] setInteger:[gestaltBox selectedRow] forKey:@"GestaltAskAllow"];
    
    [[cwc textView] setBackgroundColor:[bgColorWell color]];
    [[cwc textField] setBackgroundColor:[bgColorWell color]];
    /*[[cwc textView] setTextColor:[textColorWell color]];*/
    [[cwc textField] setTextColor:[myColorWell color]];

    [[cwc textView] setNeedsDisplay:YES];

    [[cwc chatWindow] setAlphaValue:[opaqueSlider floatValue]];
    [[[[[[cwc chatWindow] drawers] objectAtIndex: 0] contentView] window] setAlphaValue:[opaqueSlider floatValue]];

    //[[cwc userListTableView] setBackgroundColor:[bgColorWell color]];
    //[[buddyListController buddyListTableView] setBackgroundColor:[bgColorWell color]];
    
    if (newFont)
    {
        if (![newFont isEqual:[NSFont userFixedPitchFontOfSize:0.0]])
        {
            [NSFont setUserFixedPitchFont:newFont];
            [[cwc textView] setFont:newFont];
            [[cwc textField] setFont:newFont];

            [[cwc ircController] scrollToEnd];
        }
    }

    [[cwc ircController] setPMOpacity:[pmOpaqueSlider floatValue] font:newFont color:[textColorWell color] bgColor:[bgColorWell color]];

    [cwc updateList];
    [[buddyListController buddyListTableView] reloadData];
    [emotCont updateColors];

    [nameTemp release];
    [nicknameTemp release];
    [quitMessageTemp release];
    [chatFontTemp release];
    [newFont release];
    [textColorTemp release];
    [buddyColorTemp release];
    [bgColorTemp release];
    [stripeColorTemp release];
    [myColorTemp release];
    [joinPartColorTemp release];
    [serverColorTemp release];
    [noticeColorTemp release];
    
    [NSApp endSheet:prefWindow];
    [prefWindow close];
    // [NSApp stopModal];
   // [prefWindow close];
}


- (IBAction)changeFontClick:(id)sender
{
    [prefWindow makeFirstResponder:prefWindow];
    [[NSFontManager sharedFontManager] setSelectedFont:newFont isMultiple:NO];
    [[NSFontManager sharedFontManager] orderFrontFontPanel:self];
}

- (void)changeFont:(id)fontManager
{
    [newFont autorelease];
    newFont = [[fontManager convertFont:newFont] retain];
    [currentFontField setStringValue:[NSString stringWithFormat:@"%@ %g", [newFont fontName], [newFont pointSize]]];
}

- (void)awakeFromNib
{
    [[cwc textView] setFont:[NSFont userFixedPitchFontOfSize:0.0]];
    [[cwc textField] setFont:[NSFont userFixedPitchFontOfSize:0.0]];

    [[cwc textView] setDrawsBackground:YES];
    [[cwc textField] setDrawsBackground:YES];

    [[cwc textView] setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
    [[cwc textField] setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
    [[cwc textView] setTextColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]]];
    [[cwc textField] setTextColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyColor"]]];

    // [[cwc userListTableView] setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];

    // [[buddyListController buddyListTableView] setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
    
    [[cwc chatWindow] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"ChatWindowOpacity"]];
    [[[[[[cwc chatWindow] drawers] objectAtIndex: 0] contentView] window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"ChatWindowOpacity"]];


   

    [cwc updateList];
}
- (void)appFinishLaunch
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NickChosen"] == NO)
    {
        ncc = [[NickChooseController alloc] init];
        [ncc showWindowWithNick:[[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"]];
    }
}
- (NSString *)whichServer:(int)index
{
    return [serverPopUp itemTitleAtIndex:index];
    // return the string of the currently selected server, so that the IRCController can get it when needed
}

- (NSMutableArray *)ignoreList
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"IgnoreList"];
}

- (void)addIgnore:(NSString *)nick
{
    NSMutableArray *new = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IgnoreList"] mutableCopy];

    [new addObject:nick];

    [[NSUserDefaults standardUserDefaults] setObject:new forKey:@"IgnoreList"];

    [new release];
}

- (void)removeIgnore:(int)index
{
    NSMutableArray *new = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IgnoreList"] mutableCopy];

    [new removeObjectAtIndex:index];

    [[NSUserDefaults standardUserDefaults] setObject:new forKey:@"IgnoreList"];

    [new release];
}

- (BOOL)nickIsIgnored:(NSString *)nick
{
    int x;

    NSMutableArray *ignoreList = [self ignoreList];
    
    for (x = 0; x < [ignoreList count]; x++)
    {
        if ([nick caseInsensitiveCompare:[ignoreList objectAtIndex:x]] == NSOrderedSame)
        {
            return YES;
        }
    }

    return NO;
}
//if i decide to put the ToolBar back in....
/* Toolbar Delegate Methods:
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return [toolbarItems objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *items = [[NSMutableArray alloc] init];

    [items addObject:NSToolbarFlexibleSpaceItemIdentifier]; // Felx Space
    [items addObject:@"Prefs Connection"];
    [items addObject:@"Prefs Appearance"];
    [items addObject:@"Prefs Advanced"];
    [items addObject:NSToolbarFlexibleSpaceItemIdentifier]; // Felx Space

    return items;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    NSMutableArray *items = [[NSMutableArray alloc] init];

    [items addObject:@"Prefs Connection"];
    [items addObject:@"Prefs Appearance"];
    [items addObject:@"Prefs Advanced"];
    [items addObject:NSToolbarFlexibleSpaceItemIdentifier]; // Felx Space
    return items;
}

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
*/

@end
