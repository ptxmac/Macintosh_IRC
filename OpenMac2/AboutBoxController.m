#import "AboutBoxController.h"
#import "Globals.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation AboutBoxController

- (id)init
{
    self = [super initWithWindowNibName:@"About"];
    return self;
}

- (void)windowDidLoad
{
    [self setVersion:self];
    [aboutWindow setTitle:[NSString stringWithFormat:loc(@"About %@"), THIS_CHAT_APP]];
}

- (IBAction)urlClick:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:MAIN_URL]];
}

- (IBAction)setVersion:(id)sender
{
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    [versionBox setStringValue:[NSString stringWithFormat:@"Version %@", versionString]];
}

/*  Oh my god, we killed Clarus!!!

- (IBAction)clarusClick:(id)sender
{
    NSImage *whichImage = [imageWell image];

    if (whichImage == [NSImage imageNamed:@"dogcow"])
        [imageWell setImage:[NSImage imageNamed:@"macintosh-logo-irc"]];
    else
        [imageWell setImage:[NSImage imageNamed:@"dogcow"]];

} */

@end
