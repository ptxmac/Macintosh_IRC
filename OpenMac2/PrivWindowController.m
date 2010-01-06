#import "PrivWindowController.h"
#import "IRCController.h"
#import "URLMutableAttributedString.h"
#import "URLTextView.h"
#import "Utils.h"
#import "TSAttributedStringFormattingAdditions.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation PrivWindowController

- (void)openSendPM
{
    [self showWindow:self];
    [self scrollToEnd];
}

- (void)scrollToEnd
{
    /*NSRange theRange;
    NSRange selectedRange = [privTextView selectedRange];

    // do not scroll if anything is selected
    if(selectedRange.length != 0)
        return;
    
    theRange.location = ([[privTextView string] length] - 1);
    // set location of this range to the end of the text - this is where we will scroll to
    theRange.length = 0; // length is 0, all we are doing is position for the scrolling
    [privTextView scrollRangeToVisible:theRange]; // scroll to end
    */
    BOOL scrollAtButtom = (NSMaxY([privTextView visibleRect])) == (NSMaxY([privTextView bounds]));
    if (scrollAtButtom) [privTextView scrollRangeToVisible:NSMakeRange([[privTextView textStorage] length],0)];

}

- (void)sendString:(NSString *)string
{
    NSString *trunc = [utils truncateNick:[ircController theNickName]];
    NSString *s = [NSString stringWithFormat:@"%@: %@\r\n", trunc, string];
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:s attributes:[NSDictionary dictionaryWithObject:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyColor"]] forKey:NSForegroundColorAttributeName]];
    NSMutableAttributedString *mutStr = [att mutableCopy];
    [mutStr detectURLs:[NSColor blueColor]];
    [mutStr convertSmileys];
    [[privTextView textStorage] appendAttributedString:mutStr];
    [ircc sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", [self nickname], string]];
    [mutStr release];
    [att release];
    [self scrollToEnd];
}
- (IBAction)sendPM:(id)sender
{
    NSString *theString = [[privTextField textStorage] string];
    NSString *stringToAppend;
    NSAttributedString *att;
    NSMutableAttributedString *mutStr;
    
    if ((![ircc isConnected]) || ([theString isEqualToString:@""]))
    {
	[privTextField setString:@""]; // clear text field
	[[privTextField window] makeFirstResponder:privTextField];

	[history addObject:[NSString stringWithString:theString]];
	historyIndex = [history count];
	return;
    }

    // For the "up/down arrow key repeat the last/previous line" feature
    [history addObject:[NSString stringWithString:theString]];
    historyIndex = [history count];
    
    stringToAppend = [NSString stringWithFormat:@"%@: %@\r\n", [utils truncateNick:[ircController theNickName]], theString];
    att = [[NSAttributedString alloc] initWithString:stringToAppend attributes:[NSDictionary dictionaryWithObject:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyColor"]] forKey:NSForegroundColorAttributeName]];
    mutStr = [att mutableCopy];
    [mutStr detectURLs:[NSColor blueColor]];
    [mutStr convertSmileys];
    [[privTextView textStorage] appendAttributedString:mutStr];
    [ircc sendData:[NSString stringWithFormat:@"PRIVMSG %@ :%@", [self nickname], theString]];
    [privTextField setString:@""];
    [[privTextField window] makeFirstResponder:privTextField];
    [mutStr release];
    [att release];
    [self scrollToEnd];
}

- (void)pmReceived:(NSString *)m
{
    NSString *s = [NSString stringWithFormat:@"%@: %@\r\n", [utils truncateNick:[self nickname]] , m];
    NSAttributedString *att = [[NSAttributedString alloc] initWithString:s attributes:[NSDictionary dictionaryWithObject:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateMessageColor"]] forKey:NSForegroundColorAttributeName]];
    NSMutableAttributedString *mutStr = [att mutableCopy];
    [mutStr detectURLs:[NSColor blueColor]];
    [mutStr convertSmileys];
    [[privTextView textStorage] appendAttributedString:mutStr];
    [mutStr release];
    [att release];
    if([[self window] isMiniaturized] == YES)
    {
        /* Doesn't work :-(
           In Fire either, and no solution can be found on Cocoa mailing lists
           Jaguar to the rescue? */

	[[self window] setMiniwindowImage:[NSImage imageNamed:@"mail"]]; // we'll leave it in just in case jaguar adds this support ;)
	/*NSLog(@"window is minimised\r"); // it does know that the window is minised...
	NSLog(@"%@\r", [[self window] miniwindowImage]); */
    }
    else
    {
	[self showWindow:self];
    }
    [self scrollToEnd];
}
- (void)setNickname:(NSString *)n
{
    [n retain];
    [nickname release];
    nickname = n;
    [[self window] setTitle:[NSString stringWithFormat:loc(@"Private chat with %@"), nickname]];
}
- (NSString *)nickname
{
    return nickname;
}
- (id)init
{
    self = [super initWithWindowNibName:@"PrivateMessage"];
    return self;
}
- (void)setIRCController:(IRCController *)newIrcc
{
    [newIrcc retain];
    [ircc release];
    ircc = newIrcc;
}
- (void)setFont:(NSFont *)theFont color:(NSColor *)textColor bgColor:(NSColor *)bgColor
{
    [privTextView setFont:theFont];
    [privTextField setFont:theFont];
    [privTextView setBackgroundColor:bgColor];
    [privTextField setBackgroundColor:bgColor];
    [privTextField setTextColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyColor"]]];
    [privTextView setDrawsBackground:YES];
    [privTextField setDrawsBackground:YES];
}
- (void)awakeFromNib
{
    NSSize contentSize;
    contentSize = [privScrollView contentSize];
    privTextView = [[URLTextView alloc] initWithFrame:NSMakeRect(0,0,contentSize.width,contentSize.height)];
    [privTextView setAutoresizingMask:NSViewWidthSizable];
    [[privTextView textContainer] setWidthTracksTextView:YES];
    [privTextView setRichText:YES];
    [privTextView setSelectable:YES];
    [privTextView setEditable:NO];
    [privTextView setFieldEditor:YES]; // set it to a field editor, so tab will work
    [privScrollView setDocumentView:privTextView];
    [privTextView release];

    // For the "up/down arrow key repeat the last/previous line" feature
    history = [[NSMutableArray alloc] init];
    historyIndex = 0;

    [[privTextField window] makeFirstResponder:privTextField];
}


// Circumvent some keys in the input textView
- (BOOL)textView:(NSTextView *)myTextView doCommandBySelector:(SEL)command;
{
    //NSLog(@"[history count]: %d", [history count]);
    //NSLog(@"historyIndex   : %d", historyIndex);

    // Send the message
    if (command == @selector(insertNewline:))
    {
        [self performSelector:@selector(sendPM:) withObject:myTextView afterDelay:0];
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
    // send a /me on option-return
    else if (command == @selector(insertNewlineIgnoringFieldEditor:))
    {
	// old cool, but odd behevior:
 //[myTextView setString:[NSString stringWithFormat:@"/me %@", [[chatInputField textStorage] string]]];
 //[self performSelector:@selector(doSend:) withObject:myTextView afterDelay:0.5];

	/*// new behevior - like irlce:
	if ([ircController isConnected])
	{
	    [self sendAction:[[chatInputField textStorage] string]];
	}*/
	
        [self performSelector:@selector(sendPM:) withObject:myTextView afterDelay:0];

	[history addObject:[NSString stringWithString:[[myTextView textStorage] string]]];
	historyIndex = [history count];

	[myTextView setString:@""];

	return YES;
    }
    else
    {
	return NO;
    }
    
}


/*
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
}*/

@end
