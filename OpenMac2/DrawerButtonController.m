#import "DrawerButtonController.h"
#import "InfoPanelController.h"
#import "ChatWindowController.h"
#import "IRCController.h"
#import "PrivWindowController.h"
#import "Utils.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil] 


@implementation DrawerButtonController

- (id)init
{
    if (self = [super init])
    {
        infoPanelController = nil;
    }
    return self;
}

- (void)dealloc
{
    [infoPanelController release];
    [super dealloc];
}

- (IBAction)gestalt:(id)sender
{
    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
        char last;
        int indexOfLast;
        int row = [[chatWindowController userListTableView] selectedRow];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001GESTALT\001", [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast]]];
                break;
            default:
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001GESTALT\001", [[ircController nickList] objectAtIndex:row]]];
                break;
        }
    }
}


- (IBAction)iTuens:(id)sender
{
    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
        char last;
        int indexOfLast;
        int row = [[chatWindowController userListTableView] selectedRow];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001iTunes\001", [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast]]];
                break;
            default:
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001iTunes\001", [[ircController nickList] objectAtIndex:row]]];
                break;
        }
    }
}


- (IBAction)time:(id)sender
{

    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
        char last;
        int indexOfLast;
        int row = [[chatWindowController userListTableView] selectedRow];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001TIME\001", [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast]]];
                break;
            default:
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001TIME\001", [[ircController nickList] objectAtIndex:row]]];
                break;
        }
    }
    
}

- (IBAction)getInfo:(id)sender
{
    int rowIndex = [[chatWindowController userListTableView] selectedRow];
    
    if (!infoPanelController)
    {
        infoPanelController = [[InfoPanelController alloc] init];
        [infoPanelController setIRCController:ircController];
    }

    [infoPanelController showWindow:self];
    
    if ([ircController isConnected])
    {
        if (rowIndex != -1)
        {
            //NSString *cleanNick = [utils cleanNick:[[ircController nickList] objectAtIndex:rowIndex]];
            //NSLog(@"Nick: %@", [[ircController nickList] objectAtIndex:rowIndex]);
            //NSLog(@"cleanNick: %@", cleanNick);

            NSString *cleanNick = [[ircController nickList] objectAtIndex:rowIndex];
            
            if([cleanNick hasSuffix:@"@"] || [cleanNick hasSuffix:@"+"])
                cleanNick = [cleanNick substringToIndex:[cleanNick cStringLength]-1];
            
            [ircController sendData:[NSString stringWithFormat:@"WHOIS %@", cleanNick]];
        }
        else
        {
            [infoPanelController setNickName:loc(@"Nobody is selected")];
            [infoPanelController setUserName:@""];
            [infoPanelController setRealName:@""];
            [infoPanelController setHostName:@""];
            [infoPanelController setIdle:@""];
            [infoPanelController setSignedOn:@""];
        }
    }
    else
    {
        [infoPanelController setNickName:loc(@"Nobody is selected")];
        [infoPanelController setUserName:@""];
        [infoPanelController setRealName:@""];
        [infoPanelController setHostName:@""];
        [infoPanelController setIdle:@""];
        [infoPanelController setSignedOn:@""];
    }
    
}

- (IBAction)ignore:(id)sender
{
    NSMutableArray *ignoreList;
    int x;
    char last;
    int indexOfLast;
    int row = [[chatWindowController userListTableView] selectedRow];
    NSString *realNick;

    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
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
        if ([ignoreButton tag] == 52)
        {
            for (x = 0; x < [ignoreList count]; x++)
            {
                if ([realNick caseInsensitiveCompare:[ignoreList objectAtIndex:x]] == NSOrderedSame)
                {
                    [[ircController prefController] removeIgnore:x];
                }
            }
            [[ircController prefController] addIgnore:realNick];
            [ignoreButton setTitle:loc(@"Unignore")];
	    [ignoreMenu setTitle:loc(@"Unignore")];
            [ignoreButton setTag:53];
        }
        else
        {
            for (x = 0; x < [ignoreList count]; x++)
            {
                if ([realNick caseInsensitiveCompare:[ignoreList objectAtIndex:x]] == NSOrderedSame)
                {
                    [[ircController prefController] removeIgnore:x];
                    [ignoreButton setTitle:loc(@"Ignore")];
		    [ignoreMenu setTitle:loc(@"Ignore")];
                    [ignoreButton setTag:52];
                }
            }
        }
    }
    [chatWindowController updateList];
}

- (IBAction)ping:(id)sender
{
    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
        char last;
        int indexOfLast;
        int row = [[chatWindowController userListTableView] selectedRow];
        long numberOfSeconds = [[NSDate date] timeIntervalSince1970];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];
        
        switch (last)
        {
            case '@':
            case '+':
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001PING %d\001", [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast], numberOfSeconds]];
                break;
            default:
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001PING %d\001", [[ircController nickList] objectAtIndex:row], numberOfSeconds]];
                break;
        }
    }
}

- (IBAction)privateMessage:(id)sender
{
    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
        NSString *nickToSend;
        char last;
        int indexOfLast;
        int row = [[chatWindowController userListTableView] selectedRow];
        BOOL alreadyOpened = NO;
        int y, index = 0;
        NSMutableArray *pmNicks = [ircController pmNicks];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                nickToSend = [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast];
                break;
            default:
                nickToSend = [[ircController nickList] objectAtIndex:row];
                break;
        }

        for (y = 0; y < [pmNicks count]; y++)
        {
            if ([[[pmNicks objectAtIndex:y] nickname] caseInsensitiveCompare:nickToSend] == NSOrderedSame)
            {
                alreadyOpened = YES;
                index = y;
            }
        }

        if (alreadyOpened)
        {
            [[pmNicks objectAtIndex:index] openSendPM];
        /*    [[[pmNicks objectAtIndex:index] window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
            [[pmNicks objectAtIndex:index] setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]]; */
        }
        else
        {
            PrivWindowController *pwc = [[PrivWindowController alloc] init];
            [pwc setNickname:nickToSend];
            [pwc setIRCController:ircController];
            [pwc openSendPM];
            [[pwc window] setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"PrivateMessageOpacity"]];
            [pwc setFont:[NSFont userFixedPitchFontOfSize:0.0] color:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]] bgColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];
            [pmNicks addObject:pwc];
            [pwc release];
        }

        
        /*[[chatWindowController chatWindow] makeFirstResponder:[chatWindowController chatInputField]];
        [[[chatWindowController chatInputField] currentEditor] setSelectedRange:NSMakeRange([[[chatWindowController chatInputField] stringValue] cStringLength], 0)];*/
    }
}

- (IBAction)version:(id)sender
{
    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
        char last;
        int indexOfLast;
        int row = [[chatWindowController userListTableView] selectedRow];

        indexOfLast = ([[[ircController nickList] objectAtIndex:row] cStringLength] - 1);

        last = [[[ircController nickList] objectAtIndex:row] characterAtIndex:indexOfLast];

        switch (last)
        {
            case '@':
            case '+':
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001VERSION\001", [[[ircController nickList] objectAtIndex:row] substringToIndex:indexOfLast]]];
                break;
            default:
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :\001VERSION\001", [[ircController nickList] objectAtIndex:row]]];
                break;
        }
    }
    
}

- (InfoPanelController *)infoPanelController
{
    return infoPanelController;
}

- (NSButton *)ignoreButton
{
    return ignoreButton;
}

- (NSButton *)gestaltButton
{
    return gestaltButton;
}

- (NSButton *)iTunesButton
{
    return iTunesButton;
}

- (NSButton *)timeButton
{
    return timeButton;
}

- (NSButton *)buddyButton
{
    return buddyButton;
}

- (NSButton *)getInfoButton
{
    return getInfoButton;
}

- (NSButton *)pingButton
{
    return pingButton;
}

- (NSButton *)privateMessageButton
{
    return privateMessageButton;
}

- (NSButton *)versionButton
{
    return versionButton;
}

- (NSMenuItem *)ignoreMenu
{
    return ignoreMenu;
}

- (NSMenuItem *)buddyMenu
{
    return buddyMenu;
}

- (NSMenuItem *)gestaltMenu
{
    return gestaltMenu;
}

- (NSMenuItem *)iTunesMenu
{
    return iTunesMenu;
}

- (NSMenuItem *)getInfoMenu
{
    return getInfoMenu;
}

- (NSMenuItem *)pingMenu
{
    return pingMenu;
}

- (NSMenuItem *)privateMessageMenu
{
    return privateMessageMenu;
}

- (NSMenuItem *)timeMenu
{
    return timeMenu;
}

- (NSMenuItem *)versionMenu
{
    return versionMenu;
}


- (void)makeInfoPanelController
{
    if (!infoPanelController)
    {
        infoPanelController = [[InfoPanelController alloc] init];
        [infoPanelController setIRCController:ircController];
    }
}

- (IBAction)addBuddy:(id)sender
{
    NSMutableArray *ignoreList;
    //   int x;
    char last;
    int indexOfLast;
    int row = [[chatWindowController userListTableView] selectedRow];
    NSString *realNick = @"";

    if ([[chatWindowController userListTableView] selectedRow] != -1)
    {
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

    }

    if([buddyListController isBuddy:realNick])
    {
	[buddyListController removeBuddy:realNick];
	[[buddyListController buddyButton] setTitle:loc(@"Add to Buddy List")];
	[[buddyListController buddyMenu] setTitle:loc(@"Add to Buddy List")];
    }
    else
    {
	[buddyListController addBuddy:realNick];
	[[buddyListController buddyButton] setTitle:loc(@"Remove from Buddies")];
	[[buddyListController buddyMenu] setTitle:loc(@"Remove from Buddies")];
    }

}

- (void)disableButtons
{
    // turn off all the buttons
    [[self ignoreButton] setEnabled:NO];
    [[self gestaltButton] setEnabled:NO];
    [[self iTunesButton] setEnabled:NO];
    [[self timeButton] setEnabled:NO];
    [[self buddyButton] setEnabled:NO];
    [[self pingButton] setEnabled:NO];
    [[self privateMessageButton] setEnabled:NO];
    [[self versionButton] setEnabled:NO];
    [[self getInfoButton] setEnabled:NO];

    [[self ignoreMenu] setEnabled:NO];
    [[self buddyMenu] setEnabled:NO];
    [[self gestaltMenu] setEnabled:NO];
    [[self iTunesMenu] setEnabled:NO];
    [[self getInfoMenu] setEnabled:NO];
    [[self pingMenu] setEnabled:NO];
    [[self privateMessageMenu] setEnabled:NO];
    [[self versionMenu] setEnabled:NO];
    [[self timeMenu] setEnabled:NO];
}

- (void)enableButtons
{
    //enable the buttons
    [[self ignoreButton] setEnabled:YES];
    [[self gestaltButton] setEnabled:YES];
    [[self buddyButton] setEnabled:YES];
    [[self iTunesButton] setEnabled:YES];
    [[self timeButton] setEnabled:YES];
    [[self pingButton] setEnabled:YES];
    [[self privateMessageButton] setEnabled:YES];
    [[self versionButton] setEnabled:YES];
    [[self getInfoButton] setEnabled:YES];

    [[self ignoreMenu] setEnabled:YES];
    [[self buddyMenu] setEnabled:YES];
    [[self gestaltMenu] setEnabled:YES];
    [[self iTunesMenu] setEnabled:YES];
    [[self getInfoMenu] setEnabled:YES];
    [[self pingMenu] setEnabled:YES];
    [[self privateMessageMenu] setEnabled:YES];
    [[self versionMenu] setEnabled:YES];
    [[self timeMenu] setEnabled:YES];
}
@end
