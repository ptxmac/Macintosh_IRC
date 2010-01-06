#import "NickRegController.h"
#import "IRCController.h"
#import "Globals.h"
#import "AIKeychain.h"


@implementation NickRegController

- (id)init
{
    self = [super initWithWindowNibName:@"NickRegistration"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [firstStepView retain];
    [firstStepView removeFromSuperview];

    [secondStepView retain];
    [secondStepView removeFromSuperview];

    [thirdStepView retain];
    [thirdStepView removeFromSuperview];

    [windowViews release];
    windowViews = nil;

    currentPanel = 1;
    [self setWindowView:firstStepView];
    [prevButton setEnabled:NO];
    [nextButton setEnabled:YES];

    [nickRegWindow center];
}

- (IBAction)finish:(id)sender
{
    [nickRegWindow close];
}

- (IBAction)next:(id)sender
{
    if (currentPanel == 3)
        return;

    currentPanel++;

    switch (currentPanel)
    {
        case 1:
            [self setWindowView:firstStepView];
            [prevButton setEnabled:NO];
            [nextButton setEnabled:YES];
            [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
            break;
        case 2:
            [self setWindowView:secondStepView];
            [prevButton setEnabled:YES];
            [nextButton setEnabled:YES];
            [nicknameField setStringValue:[ircController theNickName]];
            if ([statusField superview])
            {
                [statusField retain];
                [statusField removeFromSuperview];
            }
            if ([statusIndicator superview])
            {
                [statusIndicator retain];
                [statusIndicator removeFromSuperview];
            }
            [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
            break;
        case 3:
            if (![statusField superview])
            {
                [secondStepView addSubview:statusField];
                [statusField release];
            }
            if (![statusIndicator superview])
            {
                [secondStepView addSubview:statusIndicator];
                [statusIndicator release];
            }

            if ([ircController isConnected])
            {
		if ([keyChainBox state])
		{
		    [statusField setStringValue:@"Storeing your Password in the Keychain…"];
		    [AIKeychain putPasswordInKeychainForService:KEYCHAIN_SERVICE account:[ircController theNickName] password:[passwordField stringValue]];
		}
		
                [statusIndicator startAnimation:self];

		// "NickServ Setup - Register"
                [ircController sendData:[NSString stringWithFormat:@"PRIVMSG %@ :REGISTER %@", NICKSERV_NAME, [passwordField stringValue]]];
                [statusField setStringValue:@"Sending register command..."];
                waitingForNickServResponse = YES;
            }
            else
            {
                [statusField setStringValue:[NSString stringWithFormat:@"You aren't connected to %@.", THIS_CHAT_APP]];
            }

            currentPanel = 2;
            
            /*
            [self setWindowView:thirdStepView];
            [prevButton setEnabled:YES];
            [nextButton setEnabled:NO];
             */
            break;
    }

}

- (IBAction)previous:(id)sender
{
    if (currentPanel == 1)
        return;

    currentPanel--;

    switch (currentPanel)
    {
        case 1:
            [self setWindowView:firstStepView];
            [prevButton setEnabled:NO];
            [nextButton setEnabled:YES];
            [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
            break;
        case 2:
            [self setWindowView:secondStepView];
            [prevButton setEnabled:YES];
            [nextButton setEnabled:YES];
            [nicknameField setStringValue:[ircController theNickName]];
            if ([statusField superview])
            {
                [statusField retain];
                [statusField removeFromSuperview];
            }
            if ([statusIndicator superview])
            {
                [statusIndicator retain];
                [statusIndicator removeFromSuperview];
            }
            [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
            break;
        case 3:
            [self setWindowView:thirdStepView];
            [prevButton setEnabled:YES];
            [nextButton setEnabled:NO];
            [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
            break;
    }
}

- (void)showNickReg
{
    currentPanel = 1;
    [self setWindowView:firstStepView];
    [prevButton setEnabled:NO];
    [nextButton setEnabled:YES];
    [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
    [passwordField setStringValue:@""];
    [nicknameField setStringValue:@""];
    [statusField setStringValue:@""];

    // show as sheet, needs work to work as a sheet
    /*[NSApp beginSheet:self
       modalForWindow:chatWindow
	       modalDelegate:nil
       didEndSelector:nil
			contextInfo:nil];
    [NSApp runModalForWindow:self];
    [NSApp endSheet:self];
    [self orderOut:self];*/

    // show as window
    [self showWindow:self];
}

- (void)setWindowView:(NSBox *)theView
{
    if ([dummyView contentView] != theView)
        [dummyView setContentView:theView];
}

- (void)setIRCController:(IRCController *)newIRCController
{
    [newIRCController retain];
    [ircController release];
    ircController = newIRCController;
}

- (BOOL)waitingForNickServResponse
{
    return waitingForNickServResponse;
}

- (void)registrationSuccess
{
    currentPanel++;
    waitingForNickServResponse = NO;
    [self setWindowView:thirdStepView];
    [stepField setStringValue:[NSString stringWithFormat:@"Step %d of 3", currentPanel]];
    [prevButton setEnabled:YES];
    [nextButton setEnabled:NO];
}

- (void)alreadyRegistered
{
    waitingForNickServResponse = NO;
    [statusField setStringValue:[NSString stringWithFormat:@"The nickname \"%@\" is already registered.", [nicknameField stringValue]]];
    [statusIndicator stopAnimation:self];
    if ([statusIndicator superview])
    {
        [statusIndicator retain];
        [statusIndicator removeFromSuperview];
    }
}

- (void)awakeFromNib
{
    [theTextBlock setStringValue:[NSString stringWithFormat:@"This wizard will guide you through registering a nickname for use in %@.\r\rFirst of all, you need to change your nickname to the nickname you want to register. To do this, type /nick MyNewNick (replacing MyNewNick with the nickname you'd like to register). If you get a message saying that the nickname is already registered or in use, you need to choose another nickname. Please note that the server %@ is on is used for many other chats as well, so your desired nickname may not be in use by someone in %@, but it could still be in use by someone else.\r\rOnce you have changed to the nickname you'd like to register, click the right arrow at the bottom right hand corner of this window.", THIS_CHAT_APP, THIS_CHAT_APP, THIS_CHAT_APP]];
}

@end
