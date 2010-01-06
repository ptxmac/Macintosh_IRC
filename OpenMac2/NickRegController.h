/* NickRegController */

#import <Cocoa/Cocoa.h>

@class IRCController;

@interface NickRegController : NSWindowController
{
    IBOutlet NSBox *dummyView;
    IBOutlet NSBox *firstStepView;
    IBOutlet NSButton *nextButton;
    IBOutlet NSTextField *nicknameField;
    IBOutlet NSWindow *nickRegWindow;
    IBOutlet NSWindow *chatWindow;
    IBOutlet NSSecureTextField *passwordField;
    IBOutlet NSButton *prevButton;
    IBOutlet NSBox *secondStepView;
    IBOutlet NSTextField *statusField;
    IBOutlet NSProgressIndicator *statusIndicator;
    IBOutlet NSTextField *stepField;
    IBOutlet NSTextField *theTextBlock;
    IBOutlet NSBox *thirdStepView;
    IBOutlet NSPanel *windowViews;
    IRCController *ircController;
    int currentPanel;
    BOOL waitingForNickServResponse;
    IBOutlet NSButton *keyChainBox;
}
- (IBAction)finish:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;
- (void)showNickReg;
- (void)setWindowView:(NSBox *)theView;
- (void)setIRCController:(IRCController *)newIRCController;
- (BOOL)waitingForNickServResponse;
- (void)registrationSuccess;
- (void)alreadyRegistered;
@end
