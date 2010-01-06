/* SheetController */

#import <Cocoa/Cocoa.h>

#import "ChatWindowController.h"

@interface SheetController : NSObject
{
    /* IBOutlet NSButton *ncDisconnectButton;
    IBOutlet NSTextField *ncNickField;
    IBOutlet NSButton *ncOKButton;
    IBOutlet NSWindow *nickChangePanel;
    IBOutlet NSWindow *nickRegPanel;
    IBOutlet NSWindow *ipPanel;
    IBOutlet NSWindow *gestaltPanel;
    IBOutlet NSButton *nrDisconnectButton;
    IBOutlet NSTextField *nrNickField;
    IBOutlet NSButton *nrOKButton;
    IBOutlet NSSecureTextField *nrPassField;
    IBOutlet ChatWindowController *chatWindowController;
    IBOutlet IRCController *ircController;
    IBOutlet NSButton *ipOKButton;
    IBOutlet NSButton *ipDisconnectButton;
    IBOutlet NSTextField *ipNickField;
    IBOutlet NSSecureTextField *ipPassField;
    IBOutlet NSTextField *gestaltNickField;
    IBOutlet NSTextField *gestaltComputerField;
    IBOutlet NSTextField *gestaltProcessorSpeedField;
    IBOutlet NSTextField *gestaltRAMInstalledField;
    IBOutlet NSTextField *gestaltSysVersionField;
    IBOutlet NSButton *gestaltShowAgainBox;
    NSMutableArray *gestaltNames;
    BOOL gestaltWindowOpen;
    bool quitSheetOpen;*/


    // incorrect password stuff
    IBOutlet NSWindow *ipPanel;
    IBOutlet NSButton *ipOKButton;
    IBOutlet NSButton *ipDisconnectButton;
    IBOutlet NSTextField *ipNickField;
    IBOutlet NSSecureTextField *ipPassField;
    IBOutlet NSButton *ipKeyChainBox;

    // nickname registerd
    IBOutlet NSWindow *nickRegPanel;
    IBOutlet NSButton *nrDisconnectButton;
    IBOutlet NSTextField *nrNickField;
    IBOutlet NSButton *nrOKButton;
    IBOutlet NSSecureTextField *nrPassField;
    IBOutlet NSButton *nrKeyChainBox;

    // nick change
    IBOutlet NSWindow *nickChangePanel;
    IBOutlet NSTextField *ncNickField;
    IBOutlet NSButton *ncOKButton;
    IBOutlet NSButton *ncDisconnectButton;

    // gestalt stuff
    IBOutlet NSWindow *gestaltPanel;
    IBOutlet NSTextField *gestaltNickField;
    IBOutlet NSTextField *gestaltComputerField;
    IBOutlet NSTextField *gestaltProcessorSpeedField;
    IBOutlet NSTextField *gestaltRAMInstalledField;
    IBOutlet NSTextField *gestaltSysVersionField;
    IBOutlet NSButton *gestaltShowAgainBox;
    NSMutableArray *gestaltNames;
    BOOL gestaltWindowOpen;

    // initial nick choice window
    //IBOutlet NSTextField *nickChoiceField;

    // misc stuff
    IBOutlet ChatWindowController *chatWindowController;
    IBOutlet IRCController *ircController;

    bool quitSheetOpen;
				
}
- (IBAction)ncDisconnect:(id)sender;
- (IBAction)ncOK:(id)sender;
- (IBAction)nrDisconnect:(id)sender;
- (IBAction)nrOK:(id)sender;
- (IBAction)ipDisconnect:(id)sender;
- (IBAction)gestaltYes:(id)sender;
- (IBAction)gestaltNo:(id)sender;
- (IBAction)ipOK:(id)sender;
- (void)runQuitSheet;
- (void)runNickChangeSheet:(NSString *)myNick;
- (void)runNickRegSheet:(NSString *)myNick;
- (void)runIncorrectPassSheet:(NSString *)myNick;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)context;
- (void)addNickToGestaltQueue:(NSString *)nick;
- (NSString *)nextNickInGestaltQueue;
- (int)gestaltCount;
- (void)getCompName:(NSString **)compName speed:(int *)speed systemVersion:(NSString **)sysVer ramInstalled:(int *)ram;
- (void)showGestaltSheet;
- (void)runGestaltSheet;
- (BOOL)gestaltWindowOpen;
- (void)sendGestaltTo:(NSString *)nick;
- (bool)quitSheetOpen;

- (void)sendIdent:(NSString *)pass;
@end
