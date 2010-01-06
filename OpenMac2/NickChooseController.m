#import "NickChooseController.h"
#import "Globals.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation NickChooseController

- (IBAction)okClick:(id)sender
{
    if (![[nickChoiceField stringValue] isEqualToString:@"ThinkSecret-Guest"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[nickChoiceField stringValue] forKey:@"Nickname"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NickChosen"];
        [[self window] close];
    }
    else
    {
        NSBeginAlertSheet(@"Nickname", nil, nil, nil, [self window], self, nil, nil, nil, @"Please choose a nickname other than ThinkSecret-Guest.");
    }
}

- (id)init
{
    self = [super initWithWindowNibName:@"NickChoose"];
    return self;
}

- (void)showWindowWithNick:(NSString *)nickToUse
{
    [self showWindow:self];
    [nickChoiceField setStringValue:nickToUse];
}

- (IBAction)urlClick:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GUIDE_URL]];
}

- (void)awakeFromNib
{
    [chooseText setStringValue:[NSString stringWithFormat:loc(@"Please choose a nickname to use in %@ (you can change it later in the preferences).\r\rIf you have already chosen a nickname with a previous version, please ignore this message. The nickname you have been using should already be in the text box below."), THIS_CHAT_APP]];
}

@end
