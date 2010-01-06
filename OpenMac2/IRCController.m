#import <Cocoa/Cocoa.h>
#import "IRCController.h"
#import "InfoPanelController.h"
#import "NickRegController.h"
#import "PrivWindowController.h"
#import "Utils.h"
#import "Globals.h"
//#import "NDAppleScriptObject.h"
#import <string.h>
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <errno.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/wait.h>
#import <netdb.h>

#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil] 

@class SheetController;

@implementation IRCController

- (void)checkForMoreData:(NSNotification *)notification /* called by the socket when new data comes in, I'm too lazy to rename it */
{
    if (isConnected) // if i'm not connected, the socket shouldn't still be calling this, but just in case...
    {
        NSData *theData = [[notification userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
        // the data that just arrived
        NSString *theDataString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding/*[NSString defaultCStringEncoding]*/];
        // convert the data to a NSString
        // NSRange theRange; // set up a range for scrolling the textView all the way down
        // NSString *oldString = [[[chatWindowController textView] string] copy];
        // save copy of old contents -- for scrolling, see below
        // NSString *newString; // this will be the new contents of the textView

        /* [[chatWindowController textView] setString:[[[chatWindowController textView] string] stringByAppendingString:theDataString]]; // add the data to the end of the textView

	    [theDataString autorelease]; // release the data now, it's no longer used

        newString = [[chatWindowController textView] string]; // this is what the contents are now

        if (![oldString isEqualTo:newString])
	    // basically, we are checking to see if the data received was null (no data). If we don't do this,
     // it will get annoying because the textView will automatically scroll back down to the bottom all the time
        {
            theRange.location = ([[[chatWindowController textView] string] length] - 1);
            // set location of this range to the end of the text
            theRange.length = 0; // length is 0, all we are doing is position for the scrolling

            [[chatWindowController textView] scrollRangeToVisible:theRange]; // scroll to end
        }

        [oldString release]; // release the old string, no longer needed */

        if ([theDataString length] == 0)
        {
            [self disconnectFromIRCServer];
            [theDataString autorelease];
            return;
        }
        else
            [self separateLines:theDataString]; // go parse the data!

        [theDataString autorelease]; // release the data, no longer needed

        [theSocket readInBackgroundAndNotify]; // run loop again
    }
}

- (void)appendCwc:(NSString *)s kind:(NSString *)k
{
    [chatWindowController appendString:s kind:k];
}

/*- (void)connectThread:(NSArray *)ports
{
    NSAutoreleasePool *connectPool = [[NSAutoreleasePool alloc] init];
    NSConnection *conToMain = [NSConnection connectionWithReceivePort:[ports objectAtIndex:0] sendPort:[ports objectAtIndex:1]];
    id ircInMain = [conToMain rootProxy];
    NSString *errorString = @"";
    BOOL isError = NO;

    //    [ircInMain startSpin];

    [ircInMain appendCwc:[NSString stringWithFormat:@"Looking up %@...\r\n", [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]]] kind:@"ServerColor"];

    if ((he=gethostbyname([[prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]] cString])) == NULL) // looks up the hostname for later use by the socket
    { // if there is an error...
        errorString = [NSString stringWithFormat:@"%@: %@", [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]], [NSString stringWithCString:hstrerror(h_errno)]]; // set the error string
        herror("gethostbyname"); // print the error as well - just for extra debugging
        isError = YES; // set the isError boolean
    }
    if (!isError && !userStopped) // if there was no error, continue...
    {
        if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) // sets up the socket
        { // again, if there was an error...
            errorString = [NSString stringWithCString:strerror(errno)]; // set error string
            perror("socket"); // print error out for debugging
            isError = YES; // set isError to true
        }
        if (!userStopped)
        {
            sockConnected = YES;
            their_addr.sin_family = AF_INET;
            their_addr.sin_port = htons(6667);
            their_addr.sin_addr = *((struct in_addr *)he->h_addr);
            memset(&(their_addr.sin_zero), '\0', 8);
        }

        if (!isError && !userStopped) // if there was no error, continue...
        {
            if (connect(sockfd, (struct sockaddr *)&their_addr, sizeof(struct sockaddr)) == -1) // connect to server
            { // if there was an error...
                errorString = [NSString stringWithCString:strerror(errno)]; // set error string
                perror("connect"); // print error out for debugging
                isError = YES; // set isError to true
                sockConnected = NO;
            }
        }
    }

    if (isError) // if there was an error earlier....
    {
        isConnected = NO; // make sure it doesn't think it's connected
        sockConnected = NO;
        [ircInMain appendCwc:[NSString stringWithFormat:@"%@%@", errorString, @"\r\n"] kind:@"ServerColor"]; // print error message in chat view
    }
    else
    {
        [ircInMain finishConnecting];
    }

    //    [ircInMain stopSpin];

    [connectPool release];

    [NSThread exit];
} */

/*
 - (void)finishConnecting
 {
     NSString *connectString = [NSString stringWithFormat:@"NICK %@\r\nUSER ThinkSecret . . :%@\r\n", [[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"], [[NSUserDefaults standardUserDefaults] stringForKey:@"RealName"]];

     if (sockConnected && isConnected && !userStopped)
     {
	 theSocket = [[NSFileHandle alloc] initWithFileDescriptor:sockfd]; // set up NSFileHandle for socket

	 isConnected = YES; // set connected variable to true (this variable is used to prevent errors later)

	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForMoreData:) 				name:NSFileHandleReadCompletionNotification object:theSocket]; // tells socket to call checkForMoreData when new data arrives

	 [chatWindowController appendString:[NSString stringWithFormat:@"Connected to %@.\r\n", [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]]] kind:@"ServerColor"];

	 [[chatWindowController connectButton] setTitle:@"Disconnect"]; // set connectButton's title
	 [[chatWindowController connectButton] setAction:@selector(disconnectFromIRCServer)]; // set action of it

	 [theSocket writeData:[NSData dataWithBytes:[connectString cString] length:[connectString 			cStringLength]]]; // send connectString to socket before receiving anything

	 [theSocket readInBackgroundAndNotify];

     }
     else
     {
	 [self disconnectFromIRCServer];
     }

     [con release];
 }
 */

- (void)connectToIRCServer /* connect to the server */
{
    NSString *errorString = @"";
    NSString *connectString;
    BOOL isError = NO;

    isConnected = NO;
    sockConnected = NO;

    [self debug:@"beginging the connect cycle" kind:@"JoinPartColor"];
	
    /*Nate's ThinkSecret 1.1b5 User Settings Tweek*/
    //Before:
    //connectString = [NSString stringWithFormat:@"NICK %@\r\nUSER ThinkSecret . . :%@\r\n", [[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"], [[NSUserDefaults standardUserDefaults] stringForKey:@"RealName"]];

    //After:
    connectString = [NSString stringWithFormat:@"NICK %@\r\nUSER %@ . . :%@\r\n", [[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"],[[NSUserDefaults standardUserDefaults] stringForKey:@"ShortName"] , [[NSUserDefaults standardUserDefaults] stringForKey:@"RealName"]];
    /*end the version tweek */

    // connectString is set - nick and user messages

    [chatWindowController appendString:[NSString stringWithFormat:loc(@"Looking up %@...\r\n"), [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]]] kind:@"ServerColor"];

    [self debug:@"looking up the server" kind:@"JoinPartColor"];

    if ((he=gethostbyname([[prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]] cString])) == NULL) // looks up the hostname for later use by the socket
    { // if there is an error...
        errorString = [NSString stringWithFormat:@"%@: %@", [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]], [NSString stringWithCString:hstrerror(h_errno)]]; // set the error string
        herror("gethostbyname"); // print the error as well - just for extra debugging
        isError = YES; // set the isError boolean
    }

    if (!isError) // if there was no error, continue...
    {
        if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) // sets up the socket
        { // again, if there was an error...
            errorString = [NSString stringWithCString:strerror(errno)]; // set error string
            perror("socket"); // print error out for debugging
            isError = YES; // set isError to true
        }

        sockConnected = YES;
        their_addr.sin_family = AF_INET;
        their_addr.sin_port = htons(PORT);
        their_addr.sin_addr = *((struct in_addr *)he->h_addr);
        memset(&(their_addr.sin_zero), '\0', 8);

        [chatWindowController appendString:[NSString stringWithFormat:loc(@"Connecting to %@...\r\n"), [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]]] kind:@"ServerColor"];

	[self debug:@"connecting to the server" kind:@"JoinPartColor"];

        if (!isError) // if there was no error, continue...
        {
            if (connect(sockfd, (struct sockaddr *)&their_addr, sizeof(struct sockaddr)) == -1) // connect to server
            { // if there was an error...
                errorString = [NSString stringWithCString:strerror(errno)]; // set error string
                perror("connect"); // print error out for debugging
                isError = YES; // set isError to true
            }

            if (!isError) // if there was no error, continue...
            {
                theSocket = [[NSFileHandle alloc] initWithFileDescriptor:sockfd]; // set up NSFileHandle for socket

                isConnected = YES; // set connected variable to true (this variable is used to prevent errors later)

                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForMoreData:) 				name:NSFileHandleReadCompletionNotification object:theSocket]; // tells socket to call checkForMoreData when new data arrives

                [chatWindowController appendString:[NSString stringWithFormat:loc(@"Connected to %@. Please wait...\r\n"), [prefController whichServer:[[NSUserDefaults standardUserDefaults] integerForKey:@"NewServerPopUp"]]] kind:@"ServerColor"];
		[self debug:@"connected to the server" kind:@"JoinPartColor"];

		// Changes the connect button do disconnect.
		/*if ([chatWindowController connectItemVisible])
		{
		    //[[chatWindowController connectItem] setPaletteLabel:@"Disconnect/Connect"];
		    [[chatWindowController connectItem] setImage:[NSImage imageNamed:@"Network_off"]];
		    [[chatWindowController connectItem] setLabel:@"Disconnect"]; // set connectButton's title
		    [[chatWindowController connectItem] setAction:@selector(disconnectFromIRCServer)]; // set action of it
		    [[chatWindowController connectItem] setToolTip:[NSString stringWithFormat:@"Disconnect from %@", THIS_CHAT_APP]];
		}*/
		
                [theSocket writeData:[NSData dataWithBytes:[connectString cString] length:[connectString 			cStringLength]]]; // send connectString to socket before receiving anything

                [[chatWindowController connectMenuItem] setTitle:@"Disconnect"]; // set menubar's connect item title
                [[chatWindowController connectMenuItem] setAction:@selector(disconnectFromIRCServer)]; // set action of it

                [[chatWindowController connectDockMenuItem] setTitle:@"Disconnect"]; // set dock menu's connect item title
                [[chatWindowController connectDockMenuItem] setAction:@selector(disconnectFromIRCServer)]; // set action of it

                [theSocket readInBackgroundAndNotify];
																[chatWindowController updateToolBar];
																[[chatWindowController chatWindow] setDocumentEdited:YES];
            }
        }
    }

    if (isError) // if there was an error earlier....
    {
        isConnected = NO; // make sure it doesn't think it's connected
        [chatWindowController appendString:[NSString stringWithFormat:@"%@%@", errorString, @"\r\n"] kind:@"ServerColor"]; // print error message in chat view
    }
}

- (void)disconnectFromIRCServer /* disconnect from the server */
{
    if (isConnected)
    {
        //NSString *disconnectString = [NSString stringWithFormat:@"QUIT :%@\r\n", [[NSUserDefaults standardUserDefaults] stringForKey:@"QuitMessage"]]; // setup Quit message string
        //[theSocket writeData:[NSData dataWithBytes:[disconnectString cString] length:[disconnectString cStringLength]]];
        // send quit string
        [self sendData:[NSString stringWithFormat:@"QUIT :%@\r\n", [[NSUserDefaults standardUserDefaults] stringForKey:@"QuitMessage"]]];
        [theSocket closeFile]; // close connection on my end
    }
    if (sockConnected)
    {
        close(sockfd); // make sure that the underlying unix file descriptor is closed as well
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:theSocket]; // stop receiving from socket loop
    [chatWindowController appendString:loc(@"*** Disconnected.\r\n") kind:@"ServerColor"]; // print disconnected in chat view
    [[chatWindowController nickField] setStringValue:@""];
    [[chatWindowController topicField] setStringValue:@""];// set topic to empty.

	// ASHAMAN - Changes Disconnect Button to Connect
	/*if ([chatWindowController connectItemVisible])
	{
	    //	[[chatWindowController connectItem] setPaletteLabel:@"Connect/Disconnect"];
	    [[chatWindowController connectItem] setImage:[NSImage imageNamed:@"Network"]];
	    [[chatWindowController connectItem] setLabel:@"Connect"]; // change title back to connect
	    [[chatWindowController connectItem] setAction:@selector(connectClick:)]; // change action back to connect
	    [[chatWindowController connectItem] setToolTip:[NSString stringWithFormat:@"Connect to %@", THIS_CHAT_APP]];
	}*/
	

	[[chatWindowController connectMenuItem] setTitle:loc(@"Connect")]; // change title back to connect
	[[chatWindowController connectMenuItem] setAction:@selector(connectClick:)]; // change action back to connect
	[[chatWindowController connectDockMenuItem] setTitle:loc(@"Connect")]; // change title back to connect
	[[chatWindowController connectDockMenuItem] setAction:@selector(connectClick:)]; // change action back to connect

	//NATE - end the toggle

	if (isConnected)
	{
	    [theSocket release]; // release socket to prevent memory leak
	}
	sockConnected = NO;
	isConnected = NO; // make sure it doesn't think it's connected
	[nickList autorelease]; // release nickname list
	nickList = [[NSMutableArray arrayWithCapacity:1] mutableCopy]; // set to empty nickname list
	[chatWindowController updateList]; // update nickname list to empty
	[chatWindowController enableContextualMenus:NO];
	[buddyListController initList];
	[chatWindowController updateToolBar];
	[[chatWindowController chatWindow] setDocumentEdited:NO];
}

- (void)sendData:(NSString *)theStringData /* send outgoing data */
{
    if (isConnected) // if we aren't connected, this causes a crash, so we check
    {	
        NSString *temp = [theStringData stringByAppendingString:@"\r\n"]; // add crlf to end of command
        NSData *theData = [temp dataUsingEncoding:NSISOLatin1StringEncoding];

        [theSocket writeData:theData]; // send data out

	[self debug:theStringData kind:@"MyColor"];
    }
}

- (void)separateLines:(NSString *)theString /* separates data from socket into individual lines */
{
    NSArray *theLines; // array of lines
    int x; // used for loop

    if (tempHolder)
    {
        if ([[theString substringFromIndex:([theString length] - 2)] isEqualToString:@"\r\n"])
        {
            theLines = [theString componentsSeparatedByString:@"\r\n"]; // this separates lines into items in array



            combinedString = [tempHolder stringByAppendingString:[theLines objectAtIndex:0]];
            [self parseString:combinedString];

            combinedString = nil;

            [tempHolder release];
            tempHolder = nil;

            for (x = 1; x < ([theLines count]/* - 1*/); x++) // for each array item, a.k.a line...
            {
                if (![[theLines objectAtIndex:x] isEqualToString:@""])
                    [self parseString:[theLines objectAtIndex:x]]; // ... parse it!
            }
        }
        else
        {
            theLines = [theString componentsSeparatedByString:@"\r\n"]; // this separates lines into items in array

            combinedString = [tempHolder stringByAppendingString:[theLines objectAtIndex:0]];
            if ([theLines count] > 1)
            {
                [self parseString:combinedString];
                combinedString = nil;
                [tempHolder autorelease];

                tempHolder = [[theLines objectAtIndex:([theLines count] - 1)] copy];
                // take last item (incomplete) and put it into a buffer

                for (x = 1; x < ([theLines count] - 1); x++) // for each array item (except the last), a.k.a line...
                {
                    if (![[theLines objectAtIndex:x] isEqualToString:@""])
                        [self parseString:[theLines objectAtIndex:x]]; // ... parse it!
                }
            }
            else
            {
                [tempHolder autorelease];
                tempHolder = [combinedString copy];
                combinedString = nil;
            }
        }
    }
    else
    {
        if ([[theString substringFromIndex:([theString length] - 2)] isEqualToString:@"\r\n"])
        {
            theLines = [theString componentsSeparatedByString:@"\r\n"]; // this separates lines into items in array

            for (x = 0; x < ([theLines count]/* - 1*/); x++) // for each array item, a.k.a line...
            {
                if (![[theLines objectAtIndex:x] isEqualToString:@""])
                    [self parseString:[theLines objectAtIndex:x]]; // ... parse it!
            }
        }
        else
        {
            theLines = [theString componentsSeparatedByString:@"\r\n"]; // this separates lines into items in array

            tempHolder = [[theLines objectAtIndex:([theLines count] - 1)] copy];
            // take last item (incomplete) and put it into a buffer

            for (x = 0; x < ([theLines count] - 1/* 2 */); x++) // for each array item (except the last), a.k.a line...
            {
                if (![[theLines objectAtIndex:x] isEqualToString:@""])
                    [self parseString:[theLines objectAtIndex:x]]; // ... parse it!
            }
        }
    }
}

- (void)parseString:(NSString *)theString /* parses individual lines */
{
    NSArray *colonParam; // will hold two items: last parameter (if it exists) and the rest of the message
    NSArray *spaceParam; // will hold the prefix in the first item, command in second, all params except last in others
    NSString *prefix; // holds the prefix -- Doug!Doug@Doug
    NSString *lastParam; // holds last paramater
    NSString *command = @""; // holds command - PRIVMSG, 223, whatever
    NSString *nickname =@"bad nick"; // holds nickname from prefix -- Doug
    NSString *to;
    NSRange exclamationRange; // used to locate exclamation (for getting nickname)
    NSRange selectionRange = [[chatWindowController textView] selectedRange];

    [self debug:theString kind:@"NoticeColor"];

    //NSLog (theString); // show me what the client sees

    if ([theString length] > 0) // hey, if we had an empty line, it would suck if we didn't do this!
    {
        if ([theString characterAtIndex:0] == ':') // is this a certain type of message?
        {
            colonParam = [theString componentsSeparatedByString:@" :"]; // separate last param from rest of it

            if ([colonParam count] >= 2) // oh crap, the "rest of it" has a " :" in it.
            {
                NSRange colonRange;

                colonRange = [theString rangeOfString:@" :"];

                lastParam = [theString substringFromIndex:(colonRange.location + colonRange.length)]; // last param
                spaceParam = [[theString substringToIndex:(colonRange.location)] componentsSeparatedByString:@" "]; // the rest of it
                prefix = [[spaceParam objectAtIndex:0] substringFromIndex:1]; // get rid of ":" and set prefix in 1 step
                if ([spaceParam count] >= 2) // is there at least a prefix and a command?
                    command = [spaceParam objectAtIndex:1]; // command is second item

                if ([command caseInsensitiveCompare:@"PRIVMSG"] == NSOrderedSame) // is this a PRIVMSG message?
                {
                    exclamationRange = [prefix rangeOfString:@"!"];

                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        nickname = prefix;
                    }

                    if ([prefController nickIsIgnored:nickname])
                        return;

                    to = [spaceParam objectAtIndex:2];

                    if ([to caseInsensitiveCompare:theNickName] == NSOrderedSame)
			// is a private message
                    {
                        if (([lastParam characterAtIndex:0] == '\001') &&
                            ([lastParam characterAtIndex:([lastParam length] - 1)] == '\001')&&
                            ([lastParam length] != 1))
                        { // is it a CTCP
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPEnabled"])
                            { // is CTCP enabled
                                NSRange commandRange = [lastParam rangeOfString:@" "];
                                NSString *ctcpCommand, *newLastParam;

                                if (commandRange.location != NSNotFound)
                                {
                                    ctcpCommand = [[lastParam substringToIndex:commandRange.location] substringFromIndex:1];
                                    if ([lastParam length] > (commandRange.location + commandRange.length))
                                        newLastParam = [lastParam substringFromIndex:(commandRange.location + commandRange.length)];
                                    else
                                        newLastParam = @"";
                                }
                                else
                                {
                                    ctcpCommand = [[lastParam substringToIndex:[lastParam length] - 1] substringFromIndex:1];
                                    newLastParam = @"";
                                }

                                if ([ctcpCommand caseInsensitiveCompare:@"VERSION"] == NSOrderedSame) // ctcp action
                                {
                                    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
                                    // play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked your version"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001VERSION %@ %@ - %@ \001", nickname, THIS_CHAT_APP, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], APP_URL]];
                                }
                                else if ([ctcpCommand caseInsensitiveCompare:@"PING"] == NSOrderedSame)
                                {
                                    //begin Nate's ThinkSecret 1.1b4 edit: Ping SOUND!
                                    // play a ping sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PingSound"])
				    {
					NSSound *pingSND = [NSSound soundNamed:@"ping"];
					[pingSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked your lag delay"), nickname] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001PING %@\001", nickname, newLastParam]];
                                }

				//begin Nate's ThinkSecret 1.1b4 edit: USERINFO, CLIENTINFO, & TIME
                                else if ([ctcpCommand caseInsensitiveCompare:@"USERINFO"] == NSOrderedSame)
                                {
				    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
	// play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked to see that you realy are running"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:loc(@"yes i realy am using"), nickname, THIS_CHAT_APP]];
                                }
				else if ([ctcpCommand caseInsensitiveCompare:@"CLIENTINFO"] == NSOrderedSame)
                                {
				    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
				    // play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked what ctcp commands you responds too"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :CLIENTINFO PING USERINFO VERSION TIME iTunes GESTALT", nickname]];
                                }
				else if ([ctcpCommand caseInsensitiveCompare:@"TIME"] == NSOrderedSame)
                                {
				    // ctcp time was tweeked for speed in ThinkSecret Chat 1.2
				    // begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
	// play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked your time"), nickname] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001TIME %@\001", nickname, [[NSDate date] descriptionWithCalendarFormat:@"%I:%M:%S %p %A, %B %e, %Y" timeZone:nil locale:nil]]];
                                }
				//end ThinkSecret 1.1b4 edit: USERINFO, CLIENTINFO, & TIME

				// begin Nate's ThinkSecret 1.2 edit: iTunes reply
//				else if ([ctcpCommand caseInsensitiveCompare:@"ITUNES"] == NSOrderedSame)
//                {
//
//				    //[NSThread detachNewThreadSelector:@selector(ctcpiTunes:) toTarget:self withObject:nickname];
//
//                    [self ctcpiTunes:nickname];
//				}
				// end iTunes reply

                                else if ([ctcpCommand caseInsensitiveCompare:@"GESTALT"] == NSOrderedSame)
                                {
				    BOOL winOpen = [sheetController gestaltWindowOpen];
				    // begin Nate's ThinkSecret 1.2.1b1 edit: stray notice sound
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
				    // end stray notice sound

                                    [sheetController addNickToGestaltQueue:nickname];

                                    if (!winOpen)
                                    {
                                        [sheetController runGestaltSheet];
                                    }
                                    //[self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001GESTALT Command not implemented\001", nickname]];
                                    //[chatWindowController appendString:[NSString stringWithFormat:@"%@ requested information about your computer.\r\n", nickname] kind:@"ServerColor"];
                                }
                                else
                                {
                                    //[[chatWindowController textView] setString:[[[chatWindowController textView] string] 			stringByAppendingString:[NSString stringWithFormat:@"Private CTCP from %@: %@: %@\r\n", nickname, ctcpCommand, newLastParam]]];
                                }
                            }
                        }
                        else
                        {
                            BOOL alreadyOpened = NO;
                            int y, index = 0;

                            // check for preference here

                            //begin Nate's ThinkSecret 1.1b4 edit: Private Message SOUND!
                            // play a PM sound, a prefence to enable/disable this was added in 1.1b5
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PMSound"])
			    {
				NSSound *msgSND = [NSSound soundNamed:@"msg"];
				[msgSND play];
			    }
                            //end 1.1b4 edit, wasn't that easy?!

                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PrivateMessageNewWindow"] == YES)
                            {
                                for (y = 0; y < [pmNicks count]; y++)
                                {
                                    if ([[[pmNicks objectAtIndex:y] nickname] caseInsensitiveCompare:nickname] == NSOrderedSame)
                                    {
                                        alreadyOpened = YES;
                                        index = y;
                                    }
                                }

                                if (alreadyOpened)
                                {
                                    [[pmNicks objectAtIndex:index] pmReceived:lastParam];
				    /*    [[[pmNicks objectAtIndex:index] window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
                                    [[pmNicks objectAtIndex:index] setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
				    */     }
                                else
                                {
                                    PrivWindowController *pwc = [[PrivWindowController alloc] init];
                                    [pwc setNickname:nickname];
                                    [pwc setIRCController:self];
                                    [pwc pmReceived:lastParam];
                                    [[pwc window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
                                    [pwc setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
                                    [pmNicks addObject:pwc];
                                    [pwc release];
                                }
                            }
                            else // they want it in the main window
                            {
                                [chatWindowController appendString:[NSString stringWithFormat:@"*%@* %@\r\n", nickname, lastParam] kind:@"PrivateMessageColor"]; // post the PRIVMSG
                            }
                        }
                    }
                    else
                    {
                        if (([lastParam characterAtIndex:0] == '\001') &&
                            ([lastParam characterAtIndex:([lastParam length] - 1)] == '\001')&&
                            ([lastParam length] != 1))
                        { // is it a CTCP
                            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPEnabled"])
                            {
                                NSRange commandRange = [lastParam rangeOfString:@" "];
                                NSString *ctcpCommand, *newLastParam;

                                if (commandRange.location != NSNotFound)
                                {
                                    ctcpCommand = [[lastParam substringToIndex:commandRange.location] substringFromIndex:1];
                                    if ([lastParam length] > (commandRange.location + commandRange.length))
                                        newLastParam = [lastParam substringFromIndex:(commandRange.location + commandRange.length)];
                                    else
                                        newLastParam = @"";
                                }
                                else
                                {
                                    ctcpCommand = [[lastParam substringToIndex:[lastParam length] - 1] substringFromIndex:1];
                                    newLastParam = @"";
                                }

                                if ([ctcpCommand caseInsensitiveCompare:@"ACTION"] == NSOrderedSame) // ctcp action
                                {//begin Nate's ThinkSecret 1.1b5 edit: indented actions:
				    NSString *indent =@" ";
				    int x;

				    for (x=0; x < [[NSUserDefaults standardUserDefaults] integerForKey:@"MsgIndent"]; x++)
				    {
					indent = [NSString stringWithFormat:@" %@", indent];
				    }
				    if([buddyListController isBuddy:nickname])
					[chatWindowController appendString:[NSString stringWithFormat:@"%@ %@ %@\r\n", indent, nickname, newLastParam] kind:@"BuddyColor"];
				    else
					[chatWindowController appendString:[NSString stringWithFormat:@"%@ %@ %@\r\n", indent, nickname, newLastParam] kind:@"TextColor"];
                                }//end 1.1b5 edit
				else if ([ctcpCommand caseInsensitiveCompare:@"VERSION"] == NSOrderedSame) // ctcp action
                                {
                                    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
                                    // play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked your version"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :VERSION %@ %@ - %@ ", nickname, THIS_CHAT_APP, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], APP_URL]];
                                }
                                else if ([ctcpCommand caseInsensitiveCompare:@"PING"] == NSOrderedSame)
                                {
                                    //begin Nate's ThinkSecret 1.1b4 edit: Ping SOUND!
                                    // play a ping sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PingSound"])
				    {
					NSSound *pingSND = [NSSound soundNamed:@"ping"];
					[pingSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!

                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked your lag delay"), nickname] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001PING %@\001", nickname, newLastParam]];
                                }

				//begin Nate's ThinkSecret 1.1b4 edit: USERINFO, CLIENTINFO, & TIME
                                else if ([ctcpCommand caseInsensitiveCompare:@"USERINFO"] == NSOrderedSame)
                                {
				    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
	// play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked to see that you realy are running"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:loc(@"yes i realy am using"), nickname, THIS_CHAT_APP]];
                                }
				else if ([ctcpCommand caseInsensitiveCompare:@"CLIENTINFO"] == NSOrderedSame)
                                {
				    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
				    // play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked what ctcp commands you responds too"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :CLIENTINFO PING USERINFO VERSION TIME GESTALT", nickname]];
                                }

                                else if ([ctcpCommand caseInsensitiveCompare:@"TIME"] == NSOrderedSame)
                                {
				    //begin Nate's ThinkSecret 1.1b4 edit: notice SOUND!
	// play a notice sound, a prefence to enable/disable this was added in 1.1b5
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
                                    //end 1.1b4 edit, wasn't that easy?!
                                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked your time"), nickname] kind:@"ServerColor"];
                                    [self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001TIME %@\001", nickname, [[NSDate date] descriptionWithCalendarFormat:@"%I:%M:%S %p %A, %B %e, %Y" timeZone:nil locale:nil]]];
                                                                  }

				//end ThinkSecret 1.1b4 edit: USERINFO, CLIENTINFO, & TIME
				
//				else if ([ctcpCommand caseInsensitiveCompare:@"ITUNES"] == NSOrderedSame)
//                {
//
//				    //[NSThread detachNewThreadSelector:@selector(ctcpiTunes:) toTarget:self withObject:nickname];
//
//				    [self ctcpiTunes:nickname];
//				}
				
                                else if ([ctcpCommand caseInsensitiveCompare:@"GESTALT"] == NSOrderedSame)
                                {
                                    BOOL winOpen = [sheetController gestaltWindowOpen];

				    // begin Nate's ThinkSecret 1.2.1b1 edit: stray notice sound
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				    {
					NSSound *noticeSND = [NSSound soundNamed:@"notice"];
					[noticeSND play];
				    }
				    // end stray notice sound


                                    [sheetController addNickToGestaltQueue:nickname];

                                    if (!winOpen)
                                    {
                                        [sheetController runGestaltSheet];
                                    }
				    //[chatWindowController appendString:[NSString stringWithFormat:@"%@ requested information about your computer.\r\n", nickname] kind:@"ServerColor"];
	//[self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001GESTALT Command not implemented\001", nickname]];
                                }
                                else
                                {
                                    //[[chatWindowController textView] setString:[[[chatWindowController textView] string] 			stringByAppendingString:[NSString stringWithFormat:@"Channel CTCP from %@: %@: %@\r\n", nickname, ctcpCommand, newLastParam]]];
                                }
                            }
                        }
                        else
			{
			    //do truncate code
			    NSString * trunc = [utils truncateNick:nickname];
			    // print as channel message
			    if([buddyListController isBuddy:nickname])
				[chatWindowController appendString:[NSString stringWithFormat:@"%@: %@\r\n", trunc, lastParam] kind:@"BuddyColor"];
			    else
				[chatWindowController appendString:[NSString stringWithFormat:@"%@: %@\r\n", trunc, lastParam] kind:@"TextColor"]; // post the PRIVMSG
			}


                    }
                }
                else if ([command caseInsensitiveCompare:@"NOTICE"] == NSOrderedSame) // is this a NOTICE message?
                {
                    exclamationRange = [prefix rangeOfString:@"!"];

                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        nickname = prefix;
                    }

                    if ([prefController nickIsIgnored:nickname])
                        return;

                    to = [spaceParam objectAtIndex:2];

                    if (([lastParam characterAtIndex:0] == '\001') && ([lastParam characterAtIndex:[lastParam length] - 1] == '\001'))
                    {
                        NSRange commandRange = [lastParam rangeOfString:@" "];
                        NSString *ctcpReplyCommand, *newLastParam;

                        if (commandRange.location != NSNotFound)
                        {
                            ctcpReplyCommand = [[lastParam substringToIndex:commandRange.location] substringFromIndex:1];
                            if ([lastParam length] > (commandRange.location + commandRange.length))
                                newLastParam = [lastParam substringFromIndex:(commandRange.location + commandRange.length)];
                            else
                                newLastParam = @"";
                        }
                        else
                        {
                            ctcpReplyCommand = [[lastParam substringToIndex:[lastParam length] - 1] substringFromIndex:1];
                            newLastParam = @"";
                        }

                        if ([ctcpReplyCommand caseInsensitiveCompare:@"PING"] == NSOrderedSame)
                        {
                            long newSecs = [[NSDate date] timeIntervalSince1970];
                            long oldSecs = [newLastParam doubleValue];
                            long interval = newSecs - oldSecs;

                            long days = 0, hours = 0, minutes = 0, seconds = 0;
                            int count = 0;
                            BOOL previous = NO;
                            NSMutableString *timeString = [NSMutableString string];

                            days = interval / 86400;
                            hours = (interval % 86400) / 3600;
                            minutes = (interval % 3600) / 60;
                            seconds = (interval % 60);

                            if (days)
                            {
                                [timeString appendString:[NSString stringWithFormat:loc(@"%d day"), days]];
                                if (days != 1)
                                {
                                    [timeString appendString:loc(@"days")];
                                }
                                previous = YES;
                                count++;
                            }
                            if (hours)
                            {
                                if (count > 0)
                                    [timeString appendString:[NSString stringWithFormat:@", "]];

                                [timeString appendString:[NSString stringWithFormat:loc(@"%d hour"), hours]];
                                if (hours != 1)
                                {
                                    [timeString appendString:loc(@"hours")];
                                }
                                previous = YES;
                                count++;
                            }
                            if (minutes)
                            {
                                if (count > 0)
                                    [timeString appendString:[NSString stringWithFormat:@", "]];

                                [timeString appendString:[NSString stringWithFormat:loc(@"%d minute"), minutes]];
                                if (minutes != 1)
                                {
                                    [timeString appendString:loc(@"minutes")];
                                }
                                previous = YES;
                                count++;
                            }
                            if (previous)
                            {
                                if (count == 1)
                                    [timeString appendString:@" and "];
                                else if (count > 1)
                                    [timeString appendString:@", and "];
                            }

                            [timeString appendString:[NSString stringWithFormat:loc(@"%d second"), seconds]];
                            if (seconds != 1)
                            {
                                [timeString appendString:loc(@"seconds")];
                            }

			    // begin Nate's ThinkSecret 1.2 edit: stray notice sound
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
			    {
				NSSound *noticeSND = [NSSound soundNamed:@"notice"];
				[noticeSND play];
			    }
			    // end stray notice sound

                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"The delay between"), nickname, timeString] kind:@"NoticeColor"];
                        }
                        else
                        {
			    // begin Nate's ThinkSecret 1.2 edit: stray notice sound
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
			    {
				NSSound *noticeSND = [NSSound soundNamed:@"notice"];
				[noticeSND play];
			    }
			    // end stray notice sound
                            [chatWindowController appendString:[NSString stringWithFormat:@"-%@- |%@| %@.\r\n", nickname, ctcpReplyCommand, newLastParam] kind:@"NoticeColor"];
                        }

                    }
                    else
                    {

                        if ([to caseInsensitiveCompare:theNickName] == NSOrderedSame)
                            // is a private notice
                        {
                            if ([nickname caseInsensitiveCompare:NICKSERV_NAME] == NSOrderedSame) // woohoo, it's from NickServ!
                            {
                                // does it contain the owned by someone else message?
                                if ([lastParam rangeOfString:NICKSERV_REGED_TRIGGER].location != NSNotFound)
                                { // yes, this is an identify message!
                                    [sheetController runNickRegSheet:theNickName]; // let's run the nickReg sheet!
                                }
                                else if ([lastParam rangeOfString:@"If this is your nickname"].location != NSNotFound)
                                {
                                    // ignore
                                }
                                else if ([lastParam rangeOfString:NICKSERV_BAD_PASSWORD].location != NSNotFound)
                                {
                                    [sheetController runIncorrectPassSheet:theNickName];
                                }
                                else if ([lastParam rangeOfString:@"Your nickname is now registered under the hostmask"].location != NSNotFound)
                                {
                                    if ([chatWindowController nrc])
                                    {
                                        if ([[chatWindowController nrc] waitingForNickServResponse])
                                        {
                                            [[chatWindowController nrc] registrationSuccess];
                                        }
                                    }
                                }
                                else if ([lastParam rangeOfString:@"Remember this for later use"].location != NSNotFound)
                                {
                                }
                                else if ([lastParam rangeOfString:@"is already registered"].location != NSNotFound)
                                {
                                    if ([chatWindowController nrc])
                                    {
                                        if ([[chatWindowController nrc] waitingForNickServResponse])
                                        {
                                            [[chatWindowController nrc] alreadyRegistered];
                                        }
                                    }
                                }
                                else
                                {
                                    [chatWindowController appendString:[NSString stringWithFormat:@"-%@- %@\r\n", nickname, lastParam] kind:@"NoticeColor"];
                                }
                            }
                            else // this is from someone else.
				 // begin Nate's ThinkSecret 1.2 edit: stray notice sound
				if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
				{
				    NSSound *noticeSND = [NSSound soundNamed:@"notice"];
				    [noticeSND play];
				}
			    // end stray notice sound
			    [chatWindowController appendString:[NSString stringWithFormat:@"-%@- %@\r\n", nickname, lastParam] kind:@"NoticeColor"];

                            // do private notice stuff
                        }
                        else
                        {
			    // begin Nate's ThinkSecret 1.2 edit: stray notice sound
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
			    {
				NSSound *noticeSND = [NSSound soundNamed:@"notice"];
				[noticeSND play];
			    }
			    // end stray notice sound
                            [chatWindowController appendString:[NSString stringWithFormat:@"=%@= %@\r\n", nickname, lastParam] kind:@"NoticeColor"]; // post the NOTICE
																		     // print as channel message
                        }
                    }
                }
                else if ([command caseInsensitiveCompare:@"JOIN"] == NSOrderedSame) // is this a JOIN message?
                {
		    NSString *channelName = [colonParam objectAtIndex:1];
		    bool isBuddy;
                    int x = 0;

                    exclamationRange = [prefix rangeOfString:@"!"];

		    //NSLog (@"the string is \"%@\" i think the channel is \"%@\"", theString, channelName);


		    if (exclamationRange.location != NSNotFound) // was this from a nickname?
		    {
			nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
		    }
		    else // it was from a server, or we are using a server without the *!*@* prefixes
		    {
			nickname = prefix;
		    }
		    if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
		    {	// it was for the channel, right?
			if ([nickname characterAtIndex:0] == '@' || [nickname characterAtIndex:0] == '+')
			    isBuddy = [buddyListController buddyJoin:[nickname substringFromIndex:1]];
			else
			    isBuddy = [buddyListController buddyJoin:nickname];

			if (isBuddy)
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"])
			    {
				NSSound *pingSND = [NSSound soundNamed:@"buddy on"];
				// NSSound *pingSND = [NSSound soundNamed:@"buddy off"];
				[pingSND play];
			    }

				if ([nickname caseInsensitiveCompare:theNickName] == NSOrderedSame)
				    // whoa, was it ME who joined?
				{
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"JoinSound"])
				    {
					NSSound *joinSND = [NSSound soundNamed:@"join"];
					[joinSND play];
				    }
				    [chatWindowController appendString:[NSString stringWithFormat:loc(@"You joined"), THIS_CHAT_APP] kind:@"JoinPartColor"];

				    [chatWindowController enableContextualMenus:YES];
				    // I joined
				}
				else
				{
				    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"JoinSound"])
				    {
					NSSound *joinSND = [NSSound soundNamed:@"join"];
					[joinSND play];
				    }
				    if(isBuddy)
					[chatWindowController appendString:[NSString stringWithFormat:loc(@"buddy has joined"), nickname, THIS_CHAT_APP] kind:@"JoinPartColor"]; // post the JOIN
				    else
					[chatWindowController appendString:[NSString stringWithFormat:loc(@"has joined"), nickname, THIS_CHAT_APP] kind:@"JoinPartColor"]; // post the JOIN
																		  // someone else joined
				}

				for (x = 0; x < [nickList count]; x++)
				{
				    if (([[nickList objectAtIndex:x] caseInsensitiveCompare:nickname] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"@"]] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"+"]] == NSOrderedSame))
					[nickList removeObjectAtIndex:x];
				}

				[nickList addObject:nickname];

			[nickList sortUsingSelector:@selector(caseInsensitiveCompare:)];

			for (x = 0; x < [nickList count]; x++)
			{
			    if ([[nickList objectAtIndex:x] isEqualToString:@""])
				[nickList removeObjectAtIndex:x];
			}

			[chatWindowController updateList];
		    }
		    else
		    {
			[chatWindowController appendString:[NSString stringWithFormat:loc(@"has joined"), nickname, IRC_CHANNEL] kind:@"JoinPartColor"]; // post the JOIN
		    }
		}
                else if ([command caseInsensitiveCompare:@"PART"] == NSOrderedSame) // is this a PART message?
                {
		    NSString *channelName = [spaceParam objectAtIndex:2];
                    int x = 0;

                    exclamationRange = [prefix rangeOfString:@"!"];

		   // NSLog (theString);
                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        nickname = prefix;
                    }

		    [buddyListController buddyLeave:nickname];

                    if ([nickname caseInsensitiveCompare:theNickName] == NSOrderedSame)
			// whoa, was it ME who left?
                    {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"])
			{
			    NSSound *leaveSND = [NSSound soundNamed:@"leave"];
			    [leaveSND play];
			}
                        [chatWindowController appendString:[NSString stringWithFormat:loc(@"You left"), THIS_CHAT_APP] kind:@"JoinPartColor"];
                        // I left
			
			if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
			{	// it was for the channel, right?
			    [self disconnectFromIRCServer];
			}
                    }
                    else
                    {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"])
			{
			    NSSound *leaveSND = [NSSound soundNamed:@"leave"];
			    [leaveSND play];
			}
                        if ([lastParam isEqualToString:@""]) // no part message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"left"), nickname, THIS_CHAT_APP] kind:@"JoinPartColor"];
                        else // part message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"left (partmsg)"), nickname, THIS_CHAT_APP, lastParam] kind:@"JoinPartColor"];
			// post the part
   // someone else left
                    }
		    
		    if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
		    {	// it was for the channel, right?
			for (x = 0; x < [nickList count]; x++)
			{
			    if (([[nickList objectAtIndex:x] caseInsensitiveCompare:nickname] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"@"]] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"+"]] == NSOrderedSame))
				[nickList removeObjectAtIndex:x];
			}

			[chatWindowController updateList];
		    }

                }
                else if ([command caseInsensitiveCompare:@"QUIT"] == NSOrderedSame) // is this a QUIT message?
                {
                    int x = 0;

                    exclamationRange = [prefix rangeOfString:@"!"]; // ugh, let's decode the nickname from the prefix

                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        nickname = prefix;
                    }

                    if ([nickname caseInsensitiveCompare:theNickName] == NSOrderedSame)
			// whoa, was it ME who left?
                    {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"])
			{
			    NSSound *leaveSND = [NSSound soundNamed:@"leave"];
			    [leaveSND play];
			}
                        [chatWindowController appendString:[NSString stringWithFormat:loc(@"You left"), THIS_CHAT_APP] kind:@"JoinPartColor"];

                        // I left
                        [self disconnectFromIRCServer];
                    }
                    else
                    {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"LeaveSound"])
			{
			    NSSound *leaveSND = [NSSound soundNamed:@"leave"];
			    [leaveSND play];
			}
			if ([lastParam isEqualToString:@""]) // no quit message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"left"), nickname, THIS_CHAT_APP] kind:@"JoinPartColor"];
                        else // quit message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"left (partmsg)"), nickname, THIS_CHAT_APP, lastParam] kind:@"JoinPartColor"];
			// post the quit
   // someone else left
                        [buddyListController buddyLeave:nickname];
                    }

                    for (x = 0; x < [nickList count]; x++)
                    {
                        if (([[nickList objectAtIndex:x] caseInsensitiveCompare:nickname] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"@"]] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"+"]] == NSOrderedSame))
                            [nickList removeObjectAtIndex:x];
                    }

                    [chatWindowController updateList];
                }
                else if (([command isEqualToString:@"332"]) || ([command caseInsensitiveCompare:@"TOPIC"] == NSOrderedSame)) // is this a topic reply message?
                {
		    bool fromServer;

		    exclamationRange = [prefix rangeOfString:@"!"];

                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
			fromServer = NO;
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        fromServer = YES;
                    }

                    [[chatWindowController topicField] setStringValue:lastParam];
		    if (!fromServer)
		    {
			[[chatWindowController nickField] setStringValue:nickname];

			[chatWindowController appendString:[NSString stringWithFormat:loc(@"has set the topic to"), nickname, lastParam] kind:@"ServerColor"];
		    }

		    // set funny little topic bar to correct value
                }
                else if ([command isEqualToString:@"333"]) // the server is telling us who set the topic and when
                {
		    // [chatWindowController appendString:[NSString stringWithFormat:@"*** %@ set the topic to: %@\r\n", lastParam, [[chatWindowController nickField] stringValue] ] kind:@"ServerColor"];
		    [[chatWindowController nickField] setStringValue:theString];
                }
                else if ([command isEqualToString:@"433"])
                {
                    [sheetController runNickChangeSheet:[spaceParam objectAtIndex:3]];
                    // nick I wanted to change to is sent as param
                }
                else if ([command isEqualToString:@"305"]) // away back
                {
                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"no longer marked as being away"), THIS_CHAT_APP] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"306"]) // away
                {
                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"marked as being away"), THIS_CHAT_APP] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"311"]) // whois
                {
                    if ([drawerButtonController infoPanelController])
                    {

                        [[drawerButtonController infoPanelController] setNickName:[spaceParam objectAtIndex:3]];
                        [[drawerButtonController infoPanelController] setUserName:[spaceParam objectAtIndex:4]];
                        [[drawerButtonController infoPanelController] setHostName:[spaceParam objectAtIndex:5]];
                        [[drawerButtonController infoPanelController] setRealName:lastParam];
                    }
                }
                else if ([command isEqualToString:@"318"]) // end of /whois
                {
                    /*if ([drawerButtonController infoPanelController])
		{
                        if (![[[drawerButtonController infoPanelController] window] isVisible])
                            [[drawerButtonController infoPanelController] showWindow:self];
		}*/
                }
                else if ([command isEqualToString:@"421"]) // unknown command
                {
                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"Unknown command"), 					[spaceParam objectAtIndex:3]] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"432"]) // erroneous nickname
                {
                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"nickname is not allowed")] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"431"]) // no nickname given
                {
                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"nick syntax")] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"411"]) // no recipient given
                {
                    [chatWindowController appendString:[NSString stringWithFormat:loc(@"notice syntax")] kind:@"ServerColor"];
                }
                else if ([command caseInsensitiveCompare:@"KICK"] == NSOrderedSame) // kicked out
                {
                    int x = 0;

		    NSString *channelName = [spaceParam objectAtIndex:2];
                    exclamationRange = [prefix rangeOfString:@"!"];

                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        nickname = prefix;
                    }

                    if ([[spaceParam objectAtIndex:3] caseInsensitiveCompare:theNickName] == NSOrderedSame)
                        // whoa, was it ME who left?
                    {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"KickSound"])
			{
			    NSSound *kickSND = [NSSound soundNamed:@"kick"];
			    [kickSND play];
			}

                        //[chatWindowController appendString:[NSString stringWithFormat:@"*** You were kicked out of ThinkSecret.\r\n"] kind:@"JoinPartColor"];
			if ([lastParam isEqualToString:@""]) // no part message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"You were kicked"), THIS_CHAT_APP, nickname] kind:@"JoinPartColor"];
                        else // part message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"You were kicked (reason)"), THIS_CHAT_APP, nickname, lastParam] kind:@"JoinPartColor"];

			 //NSLog (theString);
			//NSLog (@"channel = %@, mode = %@", channelName, channelMode);

			if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
			{	// it was for the channel, right?

			    [self disconnectFromIRCServer];
			}
                    }
                    else
                    {
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"KickSound"])
			{
			    NSSound *kickSND = [NSSound soundNamed:@"kick"];
			    [kickSND play];
			}

                        if ([lastParam isEqualToString:@""]) // no part message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"was kicked"), [spaceParam objectAtIndex:3], THIS_CHAT_APP, nickname] kind:@"JoinPartColor"];
                        else // part message.
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"was kicked (reason)"), [spaceParam objectAtIndex:3], THIS_CHAT_APP, nickname, lastParam] kind:@"JoinPartColor"];
                        // post the part
                        // someone else left

                        [buddyListController buddyLeave:nickname];
                    }

                    for (x = 0; x < [nickList count]; x++)
                    {
                        if (([[nickList objectAtIndex:x] caseInsensitiveCompare:[spaceParam objectAtIndex:3]] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", [spaceParam objectAtIndex:3], @"@"]] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", [spaceParam objectAtIndex:3], @"+"]] == NSOrderedSame))
                            [nickList removeObjectAtIndex:x];
                    }

                    [chatWindowController updateList];

                }
                else if([command isEqualToString:@"312"] || [command isEqualToString:@"319"] || [command isEqualToString:@"320"] || [command isEqualToString:@"301"]) // misc whois stuff to ignore
                {
                }
                else if ([command isEqualToString:@"317"]) // idle & signon times
                {
                    if ([drawerButtonController infoPanelController])
                    {
                        long days = 0, hours = 0, minutes = 0, seconds = 0, total = 0;
                        BOOL previous = NO;
                        int count = 0;
                        NSMutableString *idleString = [NSMutableString string];
                        double secondsSince1970 = [[spaceParam objectAtIndex:5] doubleValue];
                        NSDate *signOnDate = [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
                        NSString *dateString = [signOnDate descriptionWithCalendarFormat:@"%A, %B %e, %Y at %I:%M:%S %p" timeZone:nil locale:nil];

                        total = [[spaceParam objectAtIndex:4] doubleValue];

                        days = total / 86400;
                        hours = (total % 86400) / 3600;
                        minutes = (total % 3600) / 60;
                        seconds = (total % 60);

                        if (days)
                        {
                            [idleString appendString:[NSString stringWithFormat:loc(@"%d day"), days]];
                            if (days != 1)
                            {
                                [idleString appendString:loc(@"days")];
                            }
                            previous = YES;
                            count++;
                        }
                        if (hours)
                        {
                            if (count > 0)
                                [idleString appendString:[NSString stringWithFormat:@", "]];

                            [idleString appendString:[NSString stringWithFormat:loc(@"%d hour"), hours]];
                            if (hours != 1)
                            {
                                [idleString appendString:loc(@"hours")];
                            }
                            previous = YES;
                            count++;
                        }
                        if (minutes)
                        {
                            if (count > 0)
                                [idleString appendString:[NSString stringWithFormat:@", "]];

                            [idleString appendString:[NSString stringWithFormat:loc(@"%d minute"), minutes]];
                            if (minutes != 1)
                            {
                                [idleString appendString:loc(@"minutes")];
                            }
                            previous = YES;
                            count++;
                        }
                        if (previous)
                        {
                            if (count == 1)
                                [idleString appendString:loc(@" and ")];
                            else if (count > 1)
                                [idleString appendString:loc(@", and ")];
                        }

                        [idleString appendString:[NSString stringWithFormat:loc(@"%d second"), seconds]];
                        if (seconds != 1)
                        {
                            [idleString appendString:loc(@"seconds")];
                        }

                        [[drawerButtonController infoPanelController] setIdle:idleString];
                        [[drawerButtonController infoPanelController] setSignedOn:dateString];
                    }
                }
                else if ([command caseInsensitiveCompare:@"NICK"] == NSOrderedSame) // is this a nick change message?
                {
                    int x = 0;

                    exclamationRange = [prefix rangeOfString:@"!"];

                    if (exclamationRange.location != NSNotFound) // was this from a nickname?
                    {
                        nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                    }
                    else // it was from a server, or we are using a server without the *!*@* prefixes
                    {
                        nickname = prefix;
                    }

                    if ([nickname caseInsensitiveCompare:theNickName] == NSOrderedSame)
			// ok, *I* changed my nickname.
                    {
                        bool isBuddy;

                        [chatWindowController appendString:[NSString stringWithFormat:loc(@"You are now"), lastParam] kind:@"ServerColor"];
                        // let's tell the user now.


			if ([lastParam characterAtIndex:0] == '@' || [lastParam characterAtIndex:0] == '+')
			    isBuddy = [buddyListController buddyJoin:[lastParam substringFromIndex:1]];
			else
			    isBuddy = [buddyListController buddyJoin:lastParam];


			if (isBuddy)
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"])
			    {
				NSSound *pingSND = [NSSound soundNamed:@"buddy on"];
				// NSSound *pingSND = [NSSound soundNamed:@"buddy off"];
				[pingSND play];
			    }
				//isBuddy = [buddyListController buddyJoin:lastParam];
				[buddyListController buddyLeave:theNickName];

                        [theNickName autorelease];

                        theNickName = [lastParam copy];

                        // update local copy.

                    }
                    else
                    {
			bool isBuddy;

                        if ([lastParam characterAtIndex:0] == '@' || [lastParam characterAtIndex:0] == '+')
			    isBuddy = [buddyListController buddyJoin:[lastParam substringFromIndex:1]];
			else
			    isBuddy = [buddyListController buddyJoin:lastParam];

                        if (isBuddy)
			    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"])
			    {
				NSSound *pingSND = [NSSound soundNamed:@"buddy on"];
				// NSSound *pingSND = [NSSound soundNamed:@"buddy off"];
				[pingSND play];
			    }

				//isBuddy = [buddyListController buddyJoin:lastParam];
				[chatWindowController appendString:[NSString stringWithFormat:loc(@"is now"), nickname, lastParam] kind:@"ServerColor"];
			[buddyListController buddyLeave:nickname];

                        // add nick change to end
                    }

                    for (x = 0; x < [nickList count]; x++)
                    {
                        if (([[nickList objectAtIndex:x] caseInsensitiveCompare:nickname] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"@"]] == NSOrderedSame) || ([[nickList objectAtIndex:x] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"+"]] == NSOrderedSame))
                            [nickList removeObjectAtIndex:x];
                    }

                    [nickList addObject:lastParam];

                    [nickList sortUsingSelector:@selector(caseInsensitiveCompare:)];

                    for (x = 0; x < [nickList count]; x++)
                    {
                        if ([[nickList objectAtIndex:x] isEqualToString:@""])
                            [nickList removeObjectAtIndex:x];
                    }

                    [chatWindowController updateList];

                    for (x = 0; x < [pmNicks count]; x++)
                    {
                        if (([[[pmNicks objectAtIndex:x] nickname] caseInsensitiveCompare:nickname] == NSOrderedSame) || ([[[pmNicks objectAtIndex:x] nickname] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"@"]] == NSOrderedSame) || ([[[pmNicks objectAtIndex:x] nickname] caseInsensitiveCompare:[NSString stringWithFormat:@"%@%@", nickname, @"+"]] == NSOrderedSame))
                            [[pmNicks objectAtIndex:x] setNickname:lastParam];
                    }
                }
                else if ([command isEqualToString:@"001"])
                {
                    NSArray *separateSpaces; // separate params in lastParam
                    NSString *lastOne; // last separated param in lastParam - tells you your nickname

                    separateSpaces = [lastParam componentsSeparatedByString:@" "];

                    lastOne = [separateSpaces objectAtIndex:([separateSpaces count] - 1)];

                    [theNickName autorelease];

                    theNickName = [[[lastOne componentsSeparatedByString:@"!"] objectAtIndex:0] copy];
                    
                    [self sendData:[NSString stringWithFormat:@"JOIN %@\r\n", IRC_CHANNEL]]; // join the channel!
		    [self sendData:[NSString stringWithFormat:@"MODE %@\r\n", IRC_CHANNEL]]; // lets find out the mode of the channel! :D
		    [chatWindowController appendString:[NSString stringWithFormat:loc(@"Your Host is"), prefix] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"002"] || [command isEqualToString:@"003"] || [command isEqualToString:@"251"] || [command isEqualToString:@"265"] || [command isEqualToString:@"266"] || [command isEqualToString:@"250"] || [command isEqualToString:@"255"]) // misc messages sent at signon?
                {
		    // begin Nate's ThinkSecret 1.2 edit: stray notice sound
		    /* if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
		{
			NSSound *noticeSND = [NSSound soundNamed:@"notice"];
			[noticeSND play];
		}
		    // end stray notice sound
                    [chatWindowController appendString:[NSString stringWithFormat:@"*** %@\r\n", lastParam] kind:@"ServerColor"]; */// just display it normally
                }
                else if ([command isEqualToString:@"375"]) // MOTD begin?
                {
		    /* if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowMOTD"] == YES)
		    [chatWindowController appendString:[NSString stringWithFormat:@"*** Message of the Day:\r\n"] kind:@"ServerColor"];*/
                    // tell the user that the message of the day is following
                }
                else if ([command isEqualToString:@"376"]) // motd end?
                {
                    // let's ignore this
                }
                else if ([command isEqualToString:@"461"]) // not enough params?
                {
                    // let's ignore this
                }
                else if ([command isEqualToString:@"252"] || [command isEqualToString:@"253"] || [command isEqualToString:@"254"])
		    // staff members/channels formed/unknown connections?
                {
		    /* if ([spaceParam count] >= 4) // is there at least one extra param?
		    [chatWindowController appendString:[NSString stringWithFormat:@"*** There are %@ %@.\r\n", [spaceParam 				objectAtIndex:3], lastParam] kind:@"ServerColor"]; */// command is third item
                }
                else if ([command isEqualToString:@"372"])
		    // MOTD thing
                {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowMOTD"] == YES)
                        [chatWindowController appendString:[NSString stringWithFormat:@"*** %@\r\n", lastParam] kind:@"ServerColor"];
                }
                else if ([command isEqualToString:@"353"]) // nickname list?
                {
		    NSString *channelName = [spaceParam objectAtIndex:4];
		    //NSLog(theString);
		    if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
		    {	// it was for the channel, right?
			bool isBuddy;
			int x = 0;

			//NSLog(@"%@", theString);

			if (receivingNames)
			{
			    [nickList addObjectsFromArray:[lastParam componentsSeparatedByString:@" "]];
			}
			else
			{
			    receivingNames = YES;

			    [nickList autorelease];

			    nickList = [[lastParam componentsSeparatedByString:@" "] mutableCopy];
			}

			[nickList sortUsingSelector:@selector(caseInsensitiveCompare:)];

			for (x = 0; x < [nickList count]; x++)
			{
			    if ([[nickList objectAtIndex:x] isEqualToString:@""])
				[nickList removeObjectAtIndex:x];
			    //NSLog(@"calling buddyJoin, nickname is \"%@\"", [nickList objectAtIndex:x]);

			    if ([[nickList objectAtIndex:x] characterAtIndex:0] == '@' || [[nickList objectAtIndex:x] characterAtIndex:0] == '+')
			    {
                                isBuddy = [buddyListController buddyJoin:[[nickList objectAtIndex:x] substringFromIndex:1]];
                                //NSLog(@"%@ is an op\r", [[nickList objectAtIndex:x] substringFromIndex:1]);
                            }
			    else
				isBuddy = [buddyListController buddyJoin:[nickList objectAtIndex:x]];

			    // NSLog(@"%@\r", [nickList objectAtIndex:x]);

			    //isBuddy = [buddyListController buddyJoin:[nickList objectAtIndex:x]];
       //NSLog(@"done calling buddyJoin, result: %i", buddyJoin);
			}
		    }
		}
                else if ([command isEqualToString:@"366"])
                {
                    int x = 0;

                    receivingNames = NO;
                    for (x = 0; x < [nickList count]; x++)
                    {
                        char first;
                        NSString *tempnick = [nickList objectAtIndex:x];

                        first = [tempnick characterAtIndex:0];

                        if (first == '@' || first == '+')
                        {
                            tempnick = [[[tempnick substringFromIndex:1] stringByAppendingString:[NSString stringWithFormat:@"%c", first]] retain];
                            [nickList replaceObjectAtIndex:x withObject:tempnick];
                            [tempnick release];
                        }
                    }

                    [nickList sortUsingSelector:@selector(caseInsensitiveCompare:)];

                    [chatWindowController updateList];
                }
                else if ([command caseInsensitiveCompare:@"MODE"] == NSOrderedSame)
                {
		    /*    if ([lastParam caseInsensitiveCompare:@"+e"] == NSOrderedSame)
		{
                        // ignore
		}
                    else
		{
                        [[chatWindowController textView] setString:[[[chatWindowController textView] string] 						stringByAppendingString:[NSString stringWithFormat:@"Mode change %@ by %@\r\n", lastParam, prefix]]];
		}*/
                }
                else
                {
                    [chatWindowController appendString:[NSString stringWithFormat:@"%@: %@: %@\r\n", prefix, command, lastParam] kind:@"ServerColor"];
                    // umm..I don't know what the message is that you sent me, server. I'll just show the user.
                }

                /*[self scrollToEnd];*/ // DUH! scroll to end!
            }
            else
            {
                spaceParam = [theString componentsSeparatedByString:@" "]; // the rest of it
                prefix = [[spaceParam objectAtIndex:0] substringFromIndex:1]; // get rid of ":" and set prefix in 1 step
                if ([spaceParam count] >= 2) // is there at least a prefix and a command?
                    command = [spaceParam objectAtIndex:1]; // command is second item

                exclamationRange = [prefix rangeOfString:@"!"];

                if (exclamationRange.location != NSNotFound) // was this from a nickname?
                {
                    nickname = [prefix substringToIndex:exclamationRange.location]; // yay, we got it!
                }
                else // it was from a server, or we are using a server without the *!*@* prefixes
                {
                    nickname = prefix;
                }

		if ([command isEqualToString:@"333"])
                {
		    // [chatWindowController appendString:[NSString stringWithFormat:@"*** %@ set the topic to: %@\r\n", [spaceParam objectAtIndex:4], [[chatWindowController nickField] stringValue] ] kind:@"ServerColor"];
		    NSString *channelName = [spaceParam objectAtIndex:3];
		    //NSLog (theString);
		    
		    if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
		    {	// it was for the channel, right?
			[[chatWindowController nickField] setStringValue:[spaceParam objectAtIndex:4]];
		    }
                }

		else if ([command isEqualToString:@"324"]) // it's the mode list
		{
		    NSString *channelName = [spaceParam objectAtIndex:3];
		    NSString *channelMode = [spaceParam objectAtIndex:4];

		    //NSLog (theString);

		    if ([channelName caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
		    {	// it was for the channel, right?
			int numModes = [channelMode length]; //count how meny modes there are
			unsigned int modeIndex = 0;
			bool plusT = NO;

			//NSLog (@"channel = %@, mode = %@, length = %i", channelName, channelMode, numModes);
                        //NSLog (@"yes, it is the mode list for this channel");
			
			for(modeIndex = 1; modeIndex < numModes; modeIndex++)
			{
			    //NSLog(@"index: %i, char: %c", modeIndex, [channelMode characterAtIndex:modeIndex]);
			    //NSLog (@"index: %i", modeIndex);
			    if ([channelMode characterAtIndex:modeIndex] =='t')
			    {
				[chatWindowController appendString:[NSString stringWithFormat:loc(@"topic is locked"), THIS_CHAT_APP] kind:@"ServerColor"];
				plusT = YES;
			    }
			    else if ([channelMode characterAtIndex:modeIndex] == 'm')
			    {
				[chatWindowController appendString:[NSString stringWithFormat:loc(@"moderation mode"), THIS_CHAT_APP, THIS_CHAT_APP] kind:@"ServerColor"];
			    } 

			}

			if (!plusT)
			{
			    [chatWindowController appendString:[NSString stringWithFormat:loc(@"topic is unlocked"), THIS_CHAT_APP] kind:@"ServerColor"];
			}
		    }
		}

                else if ([command caseInsensitiveCompare:@"MODE"] == NSOrderedSame)
                {
                    NSString *thirdItem = [spaceParam objectAtIndex:2];


                    if ([thirdItem caseInsensitiveCompare:IRC_CHANNEL] == NSOrderedSame)
                    { 	// it was for the channel, right?
                        NSString *fourthItem = [spaceParam objectAtIndex:3];

                        if ([fourthItem caseInsensitiveCompare:@"+o"] == NSOrderedSame)
                        {
                            NSString *fifthItem = [spaceParam objectAtIndex:4];
                            int x;
                            int index = 1500;
                            BOOL voice = NO;
                            BOOL alreadyOp = NO;

                            // NSLog(@"%@, %@", fifthItem, [self theNickName]);

                            if([fifthItem caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"granted operator status"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"became operator"), fifthItem, THIS_CHAT_APP] kind:@"ServerColor"];

                            for (x = 0; x < [nickList count]; x++)
                            {
                                if([[fifthItem stringByAppendingString:@"+"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame || [[fifthItem stringByAppendingString:@"#"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    alreadyOp = NO;
                                    voice = YES;
                                }
                                else if ([fifthItem caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    alreadyOp = NO;
                                }
                                else if ([[fifthItem stringByAppendingString:@"@"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    alreadyOp = YES;
                                }

                            }

                            if (!alreadyOp)
                            {
                                NSString *temp;
                                if(voice)
                                    temp = [fifthItem stringByAppendingString:@"#"];
                                else
                                    temp = [fifthItem stringByAppendingString:@"@"];
                                [nickList replaceObjectAtIndex:index withObject:temp];
                                [chatWindowController updateList];
                            }
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"-o"] == NSOrderedSame)
                        {
                            int x;
                            int index = 1500;
                            BOOL notMarkedAsOp = NO;
                            BOOL voice = NO;
                            NSString *fifthItem = [spaceParam objectAtIndex:4];

                            if([fifthItem caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"striped you of your Operator Status"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                            else
				[chatWindowController appendString:[NSString stringWithFormat:loc(@"was deopped"), fifthItem] kind:@"ServerColor"];

                            for (x = 0; x < [nickList count]; x++)
                            {
                                if([[fifthItem stringByAppendingString:@"#"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    voice = YES;
                                    notMarkedAsOp = NO;
                                }
                                else if ([[fifthItem stringByAppendingString:@"@"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    notMarkedAsOp = NO;
                                }
                                else if ([fifthItem caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    notMarkedAsOp = YES;
                                }
                            }

                            if (!notMarkedAsOp)
                            {
                                [nickList replaceObjectAtIndex:index withObject:fifthItem];
                                [chatWindowController updateList];
                            }

                            if(voice)
                            {
                                NSString *temp = [fifthItem stringByAppendingString:@"+"];
                                [nickList replaceObjectAtIndex:index withObject:temp];
                                [chatWindowController updateList];
                            }
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"+b"] == NSOrderedSame)
                        {
                            NSString *fifthItem = [spaceParam objectAtIndex:4];
                            NSString *personBanned;

                            exclamationRange = [fifthItem rangeOfString:@"!"];

                            if (exclamationRange.location != NSNotFound) // was this from a nickname?
                            {
                                personBanned = [fifthItem substringToIndex:exclamationRange.location]; // yay, we got it!
                            }
                            else // it was from a server, or we are using a server without the *!*@* prefixes
                            {
                                personBanned = fifthItem;
                            }

                            if([personBanned caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"You have been banned"), THIS_CHAT_APP, nickname, THIS_CHAT_APP , GUIDE_URL] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"has been banned"), nickname, personBanned, THIS_CHAT_APP] kind:@"ServerColor"];
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"-b"] == NSOrderedSame)
                        {
                            NSString *fifthItem = [spaceParam objectAtIndex:4];
                            NSString *personBanned;

                            exclamationRange = [fifthItem rangeOfString:@"!"];

                            if (exclamationRange.location != NSNotFound) // was this from a nickname?
                            {
                                personBanned = [fifthItem substringToIndex:exclamationRange.location]; // yay, we got it!
                            }
                            else // it was from a server, or we are using a server without the *!*@* prefixes
                            {
                                personBanned = fifthItem;
                            }

                            if([personBanned caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"Your ban has been lifted"), THIS_CHAT_APP, nickname] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"has been unbanned"), nickname, personBanned, THIS_CHAT_APP] kind:@"ServerColor"];
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"+q"] == NSOrderedSame)
                        {
                            NSString *fifthItem = [spaceParam objectAtIndex:4];
                            NSString *personGagged;

                            exclamationRange = [fifthItem rangeOfString:@"!"];

                            if (exclamationRange.location != NSNotFound) // was this from a nickname?
                            {
                                personGagged = [fifthItem substringToIndex:exclamationRange.location]; // yay, we got it!
                            }
                            else // it was from a server, or we are using a server without the *!*@* prefixes
                            {
                                personGagged = fifthItem;
                            }

                            if([personGagged caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"You have been gagged"), nickname, THIS_CHAT_APP , GUIDE_URL] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"was gagged"), personGagged, nickname] kind:@"ServerColor"];
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"-q"] == NSOrderedSame)
                        {
                            NSString *fifthItem = [spaceParam objectAtIndex:4];
                            NSString *personGagged;

                            exclamationRange = [fifthItem rangeOfString:@"!"];

                            if (exclamationRange.location != NSNotFound) // was this from a nickname?
                            {
                                personGagged = [fifthItem substringToIndex:exclamationRange.location]; // yay, we got it!
                            }
                            else // it was from a server, or we are using a server without the *!*@* prefixes
                            {
                                personGagged = fifthItem;
                            }

                            if([personGagged caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"You have been ungagged"), nickname] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"was ungagged"), personGagged, nickname] kind:@"ServerColor"];
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"+v"] == NSOrderedSame)
                        {
                            NSString *fifthItem = [spaceParam objectAtIndex:4];
                            int x;
                            int index = 1500;
                            BOOL alreadyVoice = NO;
                            BOOL op = NO;

                            if([fifthItem caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"You were given a voice"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"was given a voice"), fifthItem, nickname] kind:@"ServerColor"];

                            for (x = 0; x < [nickList count]; x++)
                            {
                                if([[fifthItem stringByAppendingString:@"@"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame || [[fifthItem stringByAppendingString:@"#"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    alreadyVoice = YES;
                                    op = YES;
                                }

                                else if ([fifthItem caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    alreadyVoice = NO;
                                }
                                else if ([[fifthItem stringByAppendingString:@"+"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
                                {
                                    index = x;
                                    alreadyVoice = YES;
                                }
                            }

                            if (!alreadyVoice)
                            {
                                NSString *temp = [fifthItem stringByAppendingString:@"+"];
                                [nickList replaceObjectAtIndex:index withObject:temp];
                                [chatWindowController updateList];
                            }

                            if (op)
                            {
                                NSString *temp = [fifthItem stringByAppendingString:@"#"];
                                [nickList replaceObjectAtIndex:index withObject:temp];
                                [chatWindowController updateList];
                            }


                        }
                        else if ([fourthItem caseInsensitiveCompare:@"-v"] == NSOrderedSame)
                        {
                            int x;
                            int index = 1500;
                            BOOL notMarkedAsVoice = NO;
                            BOOL op = NO;
                            NSString *fifthItem = [spaceParam objectAtIndex:4];

                            if([fifthItem caseInsensitiveCompare:[self theNickName]] == NSOrderedSame)
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"has removed your voice"), nickname] kind:@"ServerColor"];
                            else
                                [chatWindowController appendString:[NSString stringWithFormat:loc(@"had their voice taken"), fifthItem, nickname] kind:@"ServerColor"];

																												for (x = 0; x < [nickList count]; x++)
                            {

																														if([[fifthItem stringByAppendingString:@"@"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame || [[fifthItem stringByAppendingString:@"#"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
																														{
																																index = x;
																																notMarkedAsVoice = YES;
																																op = YES;
																														}

																														else if ([[fifthItem stringByAppendingString:@"+"] caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
																														{
																																index = x;
																																notMarkedAsVoice = NO;
																														}
																														else if ([fifthItem caseInsensitiveCompare:[nickList objectAtIndex:x]] == NSOrderedSame)
																														{
																																index = x;
																																notMarkedAsVoice = YES;
																														}
                            }

                            if (!notMarkedAsVoice)
                            {
                                [nickList replaceObjectAtIndex:index withObject:fifthItem];
                                [chatWindowController updateList];
                            }

                            if (op)
                            {
                                NSString *temp = [fifthItem stringByAppendingString:@"@"];
                                [nickList replaceObjectAtIndex:index withObject:temp];
                                [chatWindowController updateList];
                            }

                        }
                        else if ([fourthItem caseInsensitiveCompare:@"+m"] == NSOrderedSame)
                        {
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"is now in moderation mode"), THIS_CHAT_APP, THIS_CHAT_APP] kind:@"ServerColor"];
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"-m"] == NSOrderedSame)
                        {
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"is no longer in moderation mode"), THIS_CHAT_APP] kind:@"ServerColor"];
                        }
			else if ([fourthItem caseInsensitiveCompare:@"+t"] == NSOrderedSame)
                        {
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"has locked the topic"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                        }
                        else if ([fourthItem caseInsensitiveCompare:@"-t"] == NSOrderedSame)
                        {
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"has unlocked the topic"), nickname, THIS_CHAT_APP] kind:@"ServerColor"];
                        }
                        else
                        {
                            [chatWindowController appendString:[NSString stringWithFormat:loc(@"Mode change"), fourthItem, nickname] kind:@"ServerColor"];
                        }
                    }
                    else // mode change on me. probably the only time this will happen is when I identify and get +e
                    {
                        NSString *fourthItem = [spaceParam objectAtIndex:3];
			//NSLog(fourthItem);

                        if ([fourthItem caseInsensitiveCompare:@"+e"] == NSOrderedSame)
                        {
                            // ignore
                        }
		    }
                }
            }

            /*[self scrollToEnd];*/
        }
        else // hmm...this message doesn't start with a colon.
        {
            colonParam = [theString componentsSeparatedByString:@" :"]; // separate last param from the rest of it
            if ([colonParam count] >= 2) // oh crap, the "rest of it" has a " :" in it.
            {
                NSRange colonRange;

                colonRange = [theString rangeOfString:@" :"];

                lastParam = [theString substringFromIndex:(colonRange.location + colonRange.length)]; // last param is last item
                command = [theString substringToIndex:(colonRange.location)]; // let's separate rest
                spaceParam = [command componentsSeparatedByString:@" "];

                if (![[spaceParam objectAtIndex:0] isEqualToString:@""])
                {
                    command = [spaceParam objectAtIndex:0];

                    if ([command caseInsensitiveCompare:@"PING"] == NSOrderedSame) // was it a server ping?
                    {
                        [self sendData:[NSString stringWithFormat:@"PONG :%@", lastParam]]; // setup the pong reply
											    //[[chatWindowController textView] setString:[[[chatWindowController textView] string] 	stringByAppendingString:[NSString stringWithFormat:@"Replied to ping from %@\r\n", lastParam]]];
	       // tell the user that we got a ping, and replied to it
                    }
                    else if ([command caseInsensitiveCompare:@"NOTICE"] == NSOrderedSame) // was it a notice from the server?
                    {
			/*// begin Nate's ThinkSecret 1.2 edit: stray notice sound
			if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
			{
			    NSSound *noticeSND = [NSSound soundNamed:@"notice"];
			    [noticeSND play];
			}
			// end stray notice sound
                        [chatWindowController appendString:[NSString stringWithFormat:@"%@\r\n", lastParam] kind:@"NoticeColor"];*/
                    }
                    else // hrm. I don't recognize that command.
                    {
                        [chatWindowController appendString:[NSString stringWithFormat:@"%@\r\n", theString] kind:@"ServerColor"];
                    }
                }
            }
        }
    }
    else
    {
        NSLog(@"Empty String sent to IRCController parseString method!");
    }
    
    [[chatWindowController textView] setSelectedRange:selectionRange];
}

- (void)scrollToEnd
{
    /*NSRange theRange;
    NSRange selectedRange = [[chatWindowController textView] selectedRange];

    // do not scroll if anything is selected
    if(selectedRange.length != 0)
        return;

    theRange.location = ([[[chatWindowController textView] string] length] - 1);
    // set location of this range to the end of the text - this is where we will scroll to
    theRange.length = 0; // length is 0, all we are doing is position for the scrolling

    [[chatWindowController textView] scrollRangeToVisible:theRange]; // scroll to end*/
    
    BOOL scrollAtButtom = (NSMaxY([[chatWindowController textView] visibleRect])) == (NSMaxY([[chatWindowController textView] bounds]));
    if (scrollAtButtom) [[chatWindowController textView] scrollRangeToVisible:NSMakeRange([[[chatWindowController textView] textStorage] length],0)];
}

/* {
NSCharacterSet *newLineIgnore = [NSCharacterSet characterSetWithCharactersInString:@""]; // will ignore nothing
NSScanner *lineParser; // the actual Scanner, for parsing individual lines
NSScanner *stringParser = [NSScanner scannerWithString:theString]; // for separating lines
NSString *prefix = nil, *command = nil, *lastParam = nil, *theLine;

if ([parseString length] == 0)
return NO;

while (![stringParser isAtEnd])
{
    if ([stringParser scanUpToString:@"\r\n" intoString:&theLine])
    {
	lineParser = [NSScanner scannerWithString:theLine];
	[lineParser setCharactersToBeSkipped:newLineIgnore];
	if ([theLine length] != 0)
	{
	    (if [theLine characterAtIndex:0] == ':')
	{
		if !(([lineParser scanString:@":" intoString:NULL]) && ([lineParser scanUpToString:@" " 			intoString:&prefix]) && ([lineParser scanString:@" " intoString:NULL]))
		    return NO;
	}
	    if (![lineParser isAtEnd])
	    {
		if !(([lineParser scanUpToString:@" " intoString:&command]) && ([lineParser scanString:@" " 		intoString:NULL]))
		    return NO;
	    }


            // set textView text

            [stringParser scanString:@"\r\n" intoString:NULL];

        }
    }
}*/

- (NSMutableArray *)nickList
{
    return nickList;
}

- (void)awakeFromNib
{
    receivingNames = NO;
    theNickName = [[[NSUserDefaults standardUserDefaults] stringForKey:@"Nickname"] copy];
    [chatWindowController enableContextualMenus:NO];
    pmNicks = [[NSMutableArray array] retain];


}

- (NSString *)theNickName
{
    return theNickName;
}

- (BOOL)isConnected
{
    return isConnected;
}

- (PrefController *)prefController
{
    return prefController;
}

- (void)setPMOpacity:(float)opacity font:(NSFont *)theFont color:(NSColor *)textColor bgColor:(NSColor *)bgColor
{
    int y;

    for (y = 0; y < [pmNicks count]; y++)
    {
        [[[pmNicks objectAtIndex:y] window] setAlphaValue:opacity];
        [[pmNicks objectAtIndex:y] setFont:theFont color:textColor bgColor:bgColor];
    }
}

- (NSMutableArray *)pmNicks
{
    return pmNicks;
}

/*
- (void)ctcpiTunes:(NSString *)nickname
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    //NSString *musicString;
    int versionNum = 1; 	// store the version of iTunes

    NSString *theName = @"";	// store the song title
    NSString *theArtist = @""; 	// stoer the song artist
    NSString *theAlbum = @""; 	// album
    NSString *theTime = @""; 	// lenth
    unsigned int rating = 0;	 	// store the rating of the current song
    NSString *playerState = @""; // Player State
    int theRate = 0;		// bit rate
    float floatSize = 0.0;	// size in bytes
    NSString *theSize = @""; 	// store size in MB as string

    NSRange dotRange;

    NDAppleScriptObject	*iTunesScript;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CTCPSound"])
    {
	NSSound *noticeSND = [NSSound soundNamed:@"notice"];
	[noticeSND play];
    }

    [chatWindowController appendString:[NSString stringWithFormat:loc(@"checked what you are listening to"), nickname] kind:@"ServerColor"];

    if([utils isRunning:@"hook"])
    {
	// find out whave version of iTunes is running
	iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to set versionNum to the version as string\r\rif versionNum is greater than or equal to \"3.0\" then\r	return 3\relse if versionNum is greater than or equal to \"2.0.4\" then\r	return 2\relse\r	return 1\rend if" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];
	[iTunesScript execute];

	versionNum = [[iTunesScript resultAsString] intValue];

	if(versionNum >= 2)
	{

	    // get status of player
	    iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return player state as string\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];
	    [iTunesScript execute];

	    playerState = [iTunesScript resultAsString];

	    if ([[iTunesScript resultAsString] isEqualToString:@"\"playing\""])
	    {

		// get the name
		iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return (name of current track)\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];
		[iTunesScript execute];

		theName = [iTunesScript resultAsString];


		if ([theName isEqualToString:@""])
		    [self sendData:[NSString stringWithFormat:loc(@"iTunes is not currently playing any music"), nickname, [self theNickName]]];
		else
		{
		    [self sendData:[NSString stringWithFormat:loc(@"iTunes is listening to"), nickname, [self theNickName], theName]];

		    // get theArtist
		    iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return (artist of current track)\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];

		    [iTunesScript execute];
		    theArtist = [iTunesScript resultAsString];

		    //NSLog(@"i have theArtist (%@)\n", theArtist);

		    if (!([theArtist isEqualToString:@"\"\""] || [theArtist isEqualToString:@"missing value"]))
			[self sendData:[NSString stringWithFormat:loc(@"iTunes is by"), nickname, theName, theArtist]];


		    // get theAlbum
		    iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return (album of current track)\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];

		    [iTunesScript execute];
		    theAlbum = [iTunesScript resultAsString];

		    //NSLog(@"i have theAlbum (%@)\n", theAlbum);


		    if (!([theAlbum isEqualToString:@"\"\""] || [theAlbum isEqualToString:@"missing value"]))
			[self sendData:[NSString stringWithFormat:loc(@"iTunes from the album"), nickname, theName, theAlbum]];


		    // get theTime
		    iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return (time of current track)\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];

		    [iTunesScript execute];


		    theTime = [iTunesScript resultAsString];

		    if ([theTime isEqualToString:@"missing value"])
			// musicString = [NSString stringWithFormat:@"%@ is currrently listening to %@%@%@. %@ is is a live stream, check your radio tuner.", [self theNickName], theName, theArtist, theAlbum, theName ];
			[self sendData:[NSString stringWithFormat:loc(@"iTunes is a live stream"), nickname, theName]];
                    else
                    {
			[self sendData:[NSString stringWithFormat:loc(@"iTunes is long"), nickname, theName, theTime]];
			
			//NSLog(@"i have theTime (%@)\n", theTime);


			// get theRate
			iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return (bit rate of current track)\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];

			[iTunesScript execute];
			theRate = [[iTunesScript resultAsString] intValue];

			// NSLog(@"i have theRate (%i)\n", theRate);

			// get floatSize
			iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return (size of current track)\n" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];

			[iTunesScript execute];
			floatSize = [[iTunesScript resultAsString] floatValue];

			//calculate the nds tehSize
			floatSize = (((floatSize/1024.0/1024.0) *10.0)/10.0)+0.05555555;
			// floatSize = float(int(floatSize*100))/100;
			theSize = [NSString stringWithFormat:@"%f", floatSize];
			dotRange = [theSize rangeOfString:@"."];
			theSize = [theSize substringToIndex:(dotRange.location+2)];

			// NSLog(@"i have floatSize (%f)\n", floatSize);

			// put it all together
			// musicString = [NSString stringWithFormat:@"%@ is currrently listening to %@%@%@. %@ is %@ long, running at %ikbps; therefore it must be %@MB.", [self theNickName], theName, theArtist, theAlbum, theName, theTime, theRate, theSize ];
			[self sendData:[NSString stringWithFormat:loc(@"iTunes is running at"), nickname, theName, theRate, theSize]];
		    }

		    if(versionNum >= 3)
		    {
			// get the rating
			iTunesScript = [[NDAppleScriptObject alloc] initWithString:@"tell application \"iTunes\" to return the rating of the current track" modeFlags:(long)1 component:[NDAppleScriptObject findNextComponent]];
			[iTunesScript execute];

			rating = [[iTunesScript resultAsString] intValue];

			if(rating>0)
			{
			    rating /= 20;

			    [self sendData:[NSString stringWithFormat:loc(@"iTunes has rated"), nickname, [self theNickName], theName, rating]];
			}
		    }

		    //[self sendData:[NSString stringWithFormat:@"NOTICE %@ :\001iTunes %@\001", nickname, musicString]];
		}
	    }
	    else
	    {
		[self sendData:[NSString stringWithFormat:loc(@"iTunes is not currently playing any music"), nickname, [self theNickName]]];
	    }

	}
	else
	{
	    [self sendData:[NSString stringWithFormat:loc(@"unsupported version of iTunes"), nickname, [self theNickName]]];
	}
    }

    else

    {
	[self sendData:[NSString stringWithFormat:loc(@"iTunes is not listening to any music right now"), nickname, [self theNickName]]];
    }
    //   [pool release];
    //   [NSThread exit];

}
*/

- (void)debug:(NSString *)theString kind:(NSString *)defaultsColorName
{
    NSRange theRange;
    NSRange selectedRange = [debuggerText selectedRange];
    NSString *temp = [theString stringByAppendingString:@"\n"]; // add crlf to end of command
    NSAttributedString *debugData = [[NSAttributedString alloc] initWithString:temp attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:defaultsColorName]], NSForegroundColorAttributeName, [NSFont userFixedPitchFontOfSize:0.0], NSFontAttributeName, nil]];
    [[debuggerText textStorage] appendAttributedString:debugData];

    // do not scroll if anything is selected
    if(selectedRange.length != 0)
        return;

    theRange.location = ([[debuggerText string] length] - 1);
    // set location of this range to the end of the text - this is where we will scroll to
    theRange.length = 0; // length is 0, all we are doing is position for the scrolling

    [debuggerText scrollRangeToVisible:theRange]; // scroll to end
}

@end
