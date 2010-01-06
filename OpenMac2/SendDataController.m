//
//  SendDataController.m
//  OpenMac 2.0
//
//  Created by Nate Friedman on Thu Sep 26 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "SendDataController.h"
#import "IRCController.h"
#import "ChatWindowController.h"
#import "PrivWindowController.h"


@implementation SendDataController

- (void)sendLines:(NSArray *)theLines channel:(NSString *)theChannel
{
    int x; // we need a counter in the loop
    NSRange theRange;
    NSString *theString;//, *theCommand, *theRest = @"";//, *target;

	for(x = 0; x < ([theLines count]); x++)
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
			[self sendCommandWithParams:[[theString substringToIndex:(theRange.location)] substringFromIndex:1] params:[theString substringFromIndex:(theRange.location + 1)] channel:theChannel];
		    else
			if ([theString length] != 1) // it isn't just a "/"
			    [self sendVanillaCommand:[theString substringFromIndex:1] channel:theChannel];
		}
		else // send as regular message
		{
		    [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", theChannel, theString]]; // tell the irc controller to send the data

		    [chatWindowController appendString:[NSString stringWithFormat:@"%@: %@\r\n", [utils truncateNick:[ircController theNickName]], theString] kind:@"MyColor"];
		}
	    }
	}
}

- (void) sendVanillaCommand:(NSString *)theCommand channel:(NSString *)theChannel
{
    // command by itself
    NSString  *theRest = @"";
    if ([theCommand caseInsensitiveCompare:@"QUIT"] == NSOrderedSame)
    {
	[ircController disconnectFromIRCServer];
    }
    else if ([theCommand caseInsensitiveCompare:@"DEBUG"] == NSOrderedSame)
    {
	[ircController debug:@"showing Debuggger window" kind:@"JoinPartColor"];

	[[chatWindowController debuggerWindow] makeKeyAndOrderFront:self];
    }
    else if ([theCommand caseInsensitiveCompare:@"HELP"] == NSOrderedSame)
    {
	[chatWindowController showHelp:self];
    }
    else if ([theCommand caseInsensitiveCompare:@"AWAY"] == NSOrderedSame)
    {
	[ircController sendData:@"AWAY"];
    }
    else if ([theCommand caseInsensitiveCompare:@"TOPIC"] == NSOrderedSame)
    {
	if([theRest isEqualToString:@""])
	    [chatWindowController appendString:[NSString stringWithFormat:@"%@\r\n", [[chatWindowController topicField] stringValue]] kind:@"TextColor"];
	else
	    [ircController sendData:[NSString stringWithFormat:@"TOPIC %@ :%@", theChannel, theRest]];
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

- (void) sendCommandWithParams:(NSString *)theCommand params:(NSString *)theRest channel:(NSString *)theChannel;
{
    NSRange theRange;
    NSString *target;

    {
	if ([theCommand caseInsensitiveCompare:@"QUOTE"] == NSOrderedSame)
	{
	    theRange = [theRest rangeOfString:@" "];

	    [chatWindowController appendString:[NSString stringWithFormat:@"--> %@\r\n", theRest] kind:@"MyColor"];
	    [ircController sendData:theRest];

	}
	else if ([theCommand caseInsensitiveCompare:@"CTCP"] == NSOrderedSame)
	{
	    theRange = [theRest rangeOfString:@" "];
	    target = [theRest substringToIndex:(theRange.location)];
	    theRest = [theRest substringFromIndex:(theRange.location + 1)];
	    [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001%@\001", target, theRest]];
	    [chatWindowController appendString:[NSString stringWithFormat:@"CTCP %@ %@\r\n", target, theRest] kind:@"MyColor"];
	}
	else if ([theCommand caseInsensitiveCompare:@"NOTICE"] == NSOrderedSame)
	{
	    theRange = [theRest rangeOfString:@" "];
	    if (theRange.location != NSNotFound)
	    {
		target = [theRest substringToIndex:(theRange.location)];
		theRest = [theRest substringFromIndex:(theRange.location + 1)];

		[ircController sendData:[NSString stringWithFormat:@"%@ %@ :%@", theCommand, target, theRest]];

		[chatWindowController appendString:[NSString stringWithFormat:@"Notice to %@: %@\r\n", target, theRest] kind:@"MyColor"];
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
	    [chatWindowController showHelp:self];
	}
	else if ([theCommand caseInsensitiveCompare:@"WHOIS"] == NSOrderedSame)
	{
	    [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", theRest]];
	}
	else if ([theCommand caseInsensitiveCompare:@"ME"] == NSOrderedSame)
	{
	    [chatWindowController sendAction:theRest];
	}
	else if ([theCommand caseInsensitiveCompare:@"AWAY"] == NSOrderedSame)
	{
	    [ircController sendData:[NSString stringWithFormat:@"AWAY :%@", theRest]];
	}
	else if ([theCommand caseInsensitiveCompare:@"TOPIC"] == NSOrderedSame)
	{
	    // it seems to be ignoring this one and using the one on line 413
	    if([theRest isEqualToString:@""])
		[chatWindowController appendString:[NSString stringWithFormat:@"%@\r\n", [[chatWindowController topicField] stringValue]] kind:@"TextColor"];
	    else
		[ircController sendData:[NSString stringWithFormat:@"TOPIC %@ :%@", theChannel, theRest]];
	}
	else if ([theCommand caseInsensitiveCompare:@"MSG"] == NSOrderedSame)
	    [self sendMessage:theRest who:target];
		}
}

- (void)sendMessage:(NSString *)theMessage who:(NSString *)target
{
    BOOL alreadyOpened = NO;
    int y, index = 0;
    NSMutableArray *pmNicks = [ircController pmNicks];
    NSRange theRange = [theMessage rangeOfString:@" "];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PrivateMessageNewWindow"] == YES)
    {
	if (theRange.location != NSNotFound)
	{
	    target = [theMessage substringToIndex:(theRange.location)];
	    theMessage = [theMessage substringFromIndex:(theRange.location + 1)];

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
		[[pmNicks objectAtIndex:index] sendString:theMessage];
	    }
	    else
	    {
		PrivWindowController *pwc = [[PrivWindowController alloc] init];
		[pwc setNickname:target];
		[pwc setIRCController:ircController];
		[[pwc window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
		[pwc setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
		[pwc showWindow:self];
		[pwc sendString:theMessage];
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
	    target = [theMessage substringToIndex:(theRange.location)];
	    theMessage = [theMessage substringFromIndex:(theRange.location + 1)];
	    [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", target, theMessage]];
	    [chatWindowController appendString:[NSString stringWithFormat:@"To %@: %@\r\n", target, theMessage] kind:@"PrivateMessageColor"];
	}
    }
}

@end
