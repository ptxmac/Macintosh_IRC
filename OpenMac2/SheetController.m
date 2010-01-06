#import "SheetController.h"
#import "IRCController.h"
#import "ChatWindowController.h"
#import "Globals.h"
#import "AIKeychain.h"
#import <sys/sysctl.h>
#import <stdlib.h>

#import "Globals.h"

#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil] 

@class ChatWindowController;
@class IRCController;

@implementation SheetController

- (id)init
{
    if (self = [super init])
    {
        gestaltNames = [[NSMutableArray alloc] initWithCapacity:1];
        gestaltWindowOpen = NO;
    }
    return self;
}

- (void)addNickToGestaltQueue:(NSString *)nick
{
    [gestaltNames addObject:nick];
}

- (NSString *)nextNickInGestaltQueue
{
    if ([gestaltNames count] > 0)
    {
        NSString *nick = [[gestaltNames objectAtIndex:0] retain];
        [gestaltNames removeObjectAtIndex:0];
        return [nick autorelease];
    }
    return nil;
}

- (int)gestaltCount
{
    return [gestaltNames count];
}

- (IBAction)ncDisconnect:(id)sender
{
    [NSApp endSheet:nickChangePanel returnCode:0];
    [nickChangePanel close];
}

- (IBAction)gestaltYes:(id)sender
{
    [NSApp endSheet:gestaltPanel returnCode:1];
}

- (IBAction)gestaltNo:(id)sender
{
    [NSApp endSheet:gestaltPanel returnCode:0];
}
- (IBAction)ncOK:(id)sender
{
    [NSApp endSheet:nickChangePanel returnCode:1];
    [nickChangePanel close];
}

- (IBAction)nrDisconnect:(id)sender
{
    [NSApp endSheet:nickRegPanel returnCode:0];
    [nickRegPanel close];
}

- (IBAction)nrOK:(id)sender
{
    [NSApp endSheet:nickRegPanel returnCode:1];
    [nickRegPanel close];
}

- (IBAction)ipDisconnect:(id)sender
{
    [NSApp endSheet:ipPanel returnCode:0];
    [ipPanel close];
}

- (IBAction)ipOK:(id)sender
{
    [NSApp endSheet:ipPanel returnCode:1];
    [ipPanel close];
}

- (void)runNickChangeSheet:(NSString *)myNick
{
    [myNick retain];
    [ncNickField setStringValue:myNick];
    
    [NSApp beginSheet:nickChangePanel
       modalForWindow:[chatWindowController chatWindow]
	       modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
	  contextInfo:nickChangePanel];
    [myNick autorelease];
}

- (void)runNickRegSheet:(NSString *)myNick
{
    NSString *pass = [AIKeychain getPasswordFromKeychainForService:KEYCHAIN_SERVICE account:myNick];

    if(pass)
    {
	[self sendIdent:pass];
    }
    else
    {
	[myNick retain];
	[nrNickField setStringValue:myNick];
	[nrPassField setStringValue:@""];
	[NSApp beginSheet:nickRegPanel modalForWindow:[chatWindowController chatWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nickRegPanel];
	[myNick autorelease];
    }
}

- (void)runQuitSheet
{
		NSString *title = loc(@"Are you sure you want to quit");
		NSString *defaultButton = loc(@"Quit-button");
		NSString *alternateButton = loc(@"Cancel");
		NSString *otherButton = nil;
		NSString *message = [NSString stringWithFormat:loc(@"You are still connected"), THIS_CHAT_APP] ;

		quitSheetOpen = YES;
		// NSBeep();
		NSBeginAlertSheet(title, defaultButton, alternateButton, otherButton, [chatWindowController chatWindow], self, @selector(sheetDidEnd:returnCode:contextInfo:), nil, nil, message);
}

- (void)runIncorrectPassSheet:(NSString *)myNick
{
    [myNick retain];
    [ipNickField setStringValue:myNick];
    [ipPassField setStringValue:@""];
    [NSApp beginSheet:ipPanel modalForWindow:[chatWindowController chatWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:ipPanel];
    [myNick autorelease];
}
    

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)context
{
    NSString *newNick;

    if (context == nickChangePanel)
    {
	if (returnCode == 1) // ok button
	{
	    newNick = [[ncNickField stringValue] retain];
	    [ircController sendData:[NSString stringWithFormat:@"NICK %@", newNick]];

	    [newNick autorelease];
	}
	else // disconnect button
	{
	    [ircController disconnectFromIRCServer];
	}
    }
    else if (context == nickRegPanel) // context is nickRegPanel
    {
	if (returnCode == 1) // ok button
	{
	    if ([[nrPassField stringValue] isEqualToString:@""]) // user wants to change nickname
	    {
		newNick = [[nrNickField stringValue] retain];
		[ircController sendData:[NSString stringWithFormat:@"NICK %@", newNick]];

		[newNick autorelease];
	    }
	    else // user wants to identify
	    {
		NSString *pass = [nrPassField stringValue];
		[self sendIdent:pass];

		// drop the password in the keychain
		if ([nrKeyChainBox state])
		    [AIKeychain putPasswordInKeychainForService:KEYCHAIN_SERVICE account:[ircController theNickName] password:pass];
	    }
	}
	else // disconnect button
	{
	    [ircController disconnectFromIRCServer];
	}
    }
    else if (context == gestaltPanel)
    {
	NSString *nextNick;

	if (returnCode == 1) // yes, send it
	{
	    [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - System Version"), [gestaltNickField stringValue], [gestaltSysVersionField stringValue]]];
	    [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Computer"), [gestaltNickField stringValue], [gestaltComputerField stringValue]]];
	    [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Clock Speed"), [gestaltNickField stringValue], [gestaltProcessorSpeedField stringValue]]];
	    [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Memory Installed"), [gestaltNickField stringValue], [gestaltRAMInstalledField stringValue]]];
	    // send gestalt ctcp
	    [chatWindowController appendString:[NSString stringWithFormat:loc(@"reqinfo sent"), [gestaltNickField stringValue]] kind:@"ServerColor"];
	}
	else // no, privacy alert!
	{
	    [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo denied"), [gestaltNickField stringValue]]];
	    [chatWindowController appendString:[NSString stringWithFormat:loc(@"reqinfo was denied"), [gestaltNickField stringValue]] kind:@"ServerColor"];
	}

	if ([gestaltShowAgainBox state] == NSOnState)
	{
	    int x;

	    if (returnCode == 1) // Yes
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"GestaltAskAllow"];
	    else		// No
		[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"GestaltAskAllow"];

	    for (x = 0; x < ([self gestaltCount]); x++)
	    {
		[self sendGestaltTo:[gestaltNames objectAtIndex:x]];
	    }
	    [gestaltNames removeAllObjects];
	}

	[gestaltPanel close];

	if (nextNick = [self nextNickInGestaltQueue])
	{
	    [gestaltNickField setStringValue:nextNick];
	    // tell the other user that permmision is being gotton
	    [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo asking for permission"), [gestaltNickField stringValue], [ircController theNickName]]];
	    [self showGestaltSheet];
	}
	else
	{
	    gestaltWindowOpen = NO;
	}
    }

    else if (context == ipPanel) // context is ipPanel
    {
	if (returnCode == 1) // ok button
	{
	    if ([[ipPassField stringValue] isEqualToString:@""]) // user wants to change nick
	    {
		newNick = [[ipNickField stringValue] retain];
		[ircController sendData:[NSString stringWithFormat:@"NICK %@", newNick]];

		[newNick autorelease];
	    }
	    else // wants to identify
	    {
		NSString *pass = [ipPassField stringValue];
		[self sendIdent:pass];

		// drop the password in the keychain
		if ([ipKeyChainBox state])
		    [AIKeychain putPasswordInKeychainForService:KEYCHAIN_SERVICE account:[ircController theNickName] password:pass];
	    }
	}
    }
    else // it's from the quitsheet?
    {
	quitSheetOpen = NO;

	if (returnCode == NSAlertDefaultReturn)
	{
	    [ircController disconnectFromIRCServer];
	    [NSApp terminate:nil];
	}
    }
}

- (void)getCompName:(NSString **)compName speed:(int *)speed systemVersion:(NSString **)sysVer ramInstalled:(int *)ram
{
    char *model;
    int ncpu, amtram, cpufreq;
    int mib[2];
    size_t len;
    NSString *oldModelName, *newModelName;
    NSDictionary *dict;

    mib[0] = CTL_HW;
    mib[1] = HW_MODEL;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    model = malloc(len);
    sysctl(mib, 2, model, &len, NULL, 0);

    mib[0] = CTL_HW;
    mib[1] = HW_NCPU;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    sysctl(mib, 2, &ncpu, &len, NULL, 0);

    mib[0] = CTL_HW;
    mib[1] = HW_PHYSMEM;
    //sysctl(mib, 2, NULL, &len, NULL, 0);
    sysctl(mib, 2, &amtram, &len, NULL, 0);
    *ram = (amtram / (1024*1024));
    mib[0] = CTL_HW;
    mib[1] = HW_CPU_FREQ;
    //sysctl(mib, 2, NULL, &len, NULL, 0);
    sysctl(mib, 2, &cpufreq, &len, NULL, 0);
    *speed = (cpufreq / 1000000);

    oldModelName = [NSString stringWithCString:model];
    if ([oldModelName caseInsensitiveCompare:@"PowerMac4,4"] == NSOrderedSame)
    {
        newModelName = @"eMac";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac4,2"] == NSOrderedSame)
    {
        newModelName = @"iMac (Flat Panel)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac4,1"] == NSOrderedSame)
    {
        newModelName = @"iMac (Summer 2001) or iMac (Early 2001)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac2,2"] == NSOrderedSame)
    {
        newModelName = @"iMac (Summer 2000)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac2,1"] == NSOrderedSame)
    {
        newModelName = @"iMac (Slot Loading)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"iMac"] == NSOrderedSame)
    {
        newModelName = @"iMac (Rev a-d)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac1,1"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G3 (Blue and White)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook1,1"] == NSOrderedSame)
    {
        newModelName = @"PowerBook G3 Series (Bronze Keyboard/Lombard)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac1,2"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (PCI Graphics)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac3,1"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (AGP Graphics - Sawtooth)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac3,2"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (AGP Graphics - Sawtooth)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac3,3"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (Gigabit Ethernet)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac3,4"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (Digital Audio)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac3,5"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (QuickSilver)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac3,6"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 (Mirrored Drive Doors)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"RackMac1,1"] == NSOrderedSame)
    {
        newModelName = @"Xserv";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac5,1"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 Cube";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac5,2"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G4 Cube";
    }
    else if ([oldModelName caseInsensitiveCompare:@"Gossamer"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G3 Beige Revision A or B";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerMac-G3"] == NSOrderedSame)
    {
        newModelName = @"Power Macintosh G3 Beige Revision C";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook1998"] == NSOrderedSame)
    {
        newModelName = @"PowerBook G3 Series (Mainstreet/Wallstreet)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook4,4"] == NSOrderedSame)
    {
        newModelName = @"iBook (Unknown Type)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook4,3"] == NSOrderedSame)
    {
        newModelName = @"iBook (Unknown Type)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook4,2"] == NSOrderedSame)
    {
        newModelName = @"iBook (Dual USB) with 14\" Screen Option";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook4,1"] == NSOrderedSame)
    {
        newModelName = @"iBook (Dual USB)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook2,2"] == NSOrderedSame)
    {
        newModelName = @"iBook (FireWire)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook2,1"] == NSOrderedSame)
    {
        newModelName = @"iBook";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook3,4"] == NSOrderedSame)
    {
        newModelName = @"PowerBook G4 (DVI)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook3,3"] == NSOrderedSame)
    {
        newModelName = @"PowerBook G4 (Gigabit Ethernet)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook3,2"] == NSOrderedSame)
    {
        newModelName = @"PowerBook G4 (Titanium)";
    }
    else if ([oldModelName caseInsensitiveCompare:@"PowerBook3,1"] == NSOrderedSame)
    {
        newModelName = @"PowerBook G3 (FireWire)";
    }
    else
    {
        newModelName = [NSString stringWithFormat:loc(@"reqinfo unrecognized computer"), oldModelName];
    }

    *compName = newModelName;

    dict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];

    if (dict)
        *sysVer = [NSString stringWithFormat:@"%@ %@ (%@)", [dict objectForKey:@"ProductName"], [dict objectForKey:@"ProductVersion"], [dict objectForKey:@"ProductBuildVersion"]];
    else
        *sysVer = loc(@"reqinfo unable to determine");

    free(model);
}

- (void)runGestaltSheet
{
    NSString *model, *sysVersion, *nick;
    int procSpd,ramInst;
    NSString *ramString, *procString;
    BOOL allow;

    if ([self gestaltCount] < 1)
        return;

    nick = [self nextNickInGestaltQueue];
    //nick = [gestaltNames objectAtIndex:0];

    [self getCompName:&model
                speed:&procSpd
        systemVersion:&sysVersion
         ramInstalled:&ramInst];

    ramString = [NSString stringWithFormat:@"%d MB RAM", ramInst];
    procString = [NSString stringWithFormat:@"%d MHz", procSpd];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"GestaltAskAllow"] == 0) // if it's set to ask
    {
        gestaltWindowOpen = YES;
        [gestaltNickField setStringValue:nick];
        [gestaltComputerField setStringValue:model];
        [gestaltProcessorSpeedField setStringValue:procString];
        [gestaltRAMInstalledField setStringValue:ramString];
        [gestaltSysVersionField setStringValue:sysVersion];
        [gestaltShowAgainBox setState:NSOffState];

	// tell the other user that permmision is being gotton
	[ircController sendData:[NSString stringWithFormat:loc(@"reqinfo asking for permission"), [gestaltNickField stringValue], [ircController theNickName]]];

        [self showGestaltSheet];
    }
    else // already set
    {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"GestaltAskAllow"] == 1)
        {
            allow = YES;
        }
        else
        {
            allow = NO;
        }

        if (allow)
        {
            [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - System Version"), nick, sysVersion]];
            [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Computer"), nick, model]];
            [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Clock Speed"), nick, procString]];
            [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Memory Installed"), nick, ramString]];
            // send gestalt ctcp
            [chatWindowController appendString:[NSString stringWithFormat:loc(@"reqinfo sent"), nick] kind:@"ServerColor"];
        }
        else
        {
            [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo denied"), nick]];
            [chatWindowController appendString:[NSString stringWithFormat:loc(@"reqinfo was denied"), nick] kind:@"ServerColor"];
        }
    }
}

- (void)showGestaltSheet
{
    [NSApp beginSheet:gestaltPanel modalForWindow:[chatWindowController chatWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:gestaltPanel];
}

- (BOOL)gestaltWindowOpen
{
    return gestaltWindowOpen;
}

- (void)sendGestaltTo:(NSString *)nick
{
    NSString *model, *sysVersion;
    int procSpd,ramInst;
    NSString *ramString, *procString;
    BOOL allow;

    [self getCompName:&model
                speed:&procSpd
        systemVersion:&sysVersion
         ramInstalled:&ramInst];

    ramString = [NSString stringWithFormat:@"%d MB RAM", ramInst];
    procString = [NSString stringWithFormat:@"%d MHz", procSpd];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"GestaltAskAllow"] == 1)
    {
        allow = YES;
    }
    else
    {
        allow = NO;
    }

    if (allow)
    {
        //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
	// play a notice sound, a prefence to enable/disable this was added in 1.1b5
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
	{
	    NSSound *noticeSND = [NSSound soundNamed:@"notice"];
	    [noticeSND play];
        }                
	//end 1.1b4 edit, wasn't that easy?!
        [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - System Version"), nick, sysVersion]];
        [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Computer"), nick, model]];
        [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Clock Speed"), nick, procString]];
        [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo - Memory Installed"), nick, ramString]];
        // send gestalt ctcp
        [chatWindowController appendString:[NSString stringWithFormat:loc(@"reqinfo sent (gestalt)"), nick] kind:@"ServerColor"];
    }
    else
    {
        [ircController sendData:[NSString stringWithFormat:loc(@"reqinfo denied"), nick]];
        [chatWindowController appendString:[NSString stringWithFormat:loc(@"reqinfo was denied"), nick] kind:@"ServerColor"];
    }
}

-(bool) quitSheetOpen
{
		return quitSheetOpen;
}

-(void) sendIdent:(NSString *)pass
{
    switch(IDENT_STYLE){
	case STR_PASS : [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@ %@", NICKSERV_NAME, NICKSERV_IDENT,  pass]];
	    break;
	case STR_NICK_PASS : [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@ %@ %@", NICKSERV_NAME, NICKSERV_IDENT, [ircController theNickName],  pass]];
	    break;
	case NICK_STR_PASS : [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@ %@ %@", NICKSERV_NAME, [ircController theNickName], NICKSERV_IDENT,  pass]];
    }
}

@end
