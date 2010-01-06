/* PrivWindowController */
#import "Utils.h"
#import <Cocoa/Cocoa.h>

@class IRCController;

@interface PrivWindowController : NSWindowController
{
    IBOutlet NSTextView *privTextField;
    IBOutlet NSTextView *privTextView;
    IBOutlet NSScrollView *privScrollView;
    IBOutlet IRCController *ircController; // i need to find out why my nick name is
    IBOutlet Utils *utils;
    NSString *nickname;
    IRCController *ircc;

    // For the "up/down arrow key repeat the last/previous line" feature
    NSMutableArray *history;
    int historyIndex;
}
- (IBAction)sendPM:(id)sender;
- (void)setNickname:(NSString *)n;
- (void)pmReceived:(NSString *)m;
- (NSString *)nickname;
- (void)setIRCController:(IRCController *)newIrcc;
- (void)scrollToEnd;
- (void)setFont:(NSFont *)theFont color:(NSColor *)textColor bgColor:(NSColor *)bgColor;
- (void)openSendPM;
- (void)sendString:(NSString *)string;
@end
