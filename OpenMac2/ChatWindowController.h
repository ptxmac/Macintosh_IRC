#import <Cocoa/Cocoa.h>
#import <AppKit/NSMenu.h>
#import "Utils.h"
//#import "BudieListController.h"
//#import "BuddyListController.h"

@class IRCController, DrawerButtonController, NickRegController, AboutBoxController, DrawerController, PrefController, BuddyListController, EmoticonController, SheetController;

@interface ChatWindowController : NSObject
{	
    IBOutlet NSWindow *debuggerWindow;
    
    IBOutlet Utils *utils;
    
    IBOutlet NSMenuItem *aboutMenuItem;
    IBOutlet NSMenuItem *appMenu;
    IBOutlet NSMenuItem *quitMenuItem;
    IBOutlet NSMenuItem *hideMenuItem;
    IBOutlet NSMenuItem *helpMenuItem;
    IBOutlet NSMenuItem *connectMenuItem;
    IBOutlet NSMenuItem *connectDockMenuItem;
    
    IBOutlet NSTextView *chatInputField;
    IBOutlet NSTextView *chatTextView;
    IBOutlet NSScrollView *chatScrollView;
    IBOutlet NSWindow *chatWindow;
    IBOutlet NSTableView *userListTableView;
    IBOutlet NSTextField *topicField;
    IBOutlet NSTextField *nickField;
		
    IBOutlet IRCController *ircController;
    IBOutlet EmoticonController *emoticonController;
    IBOutlet DrawerButtonController *drawerButtonController;
    IBOutlet DrawerController *drawerController;
    IBOutlet PrefController *prefController;
    IBOutlet BuddyListController *buddyListController; // i need to check the status of the BuddyList
		IBOutlet SheetController *sheetController; // for the quit sheet
		
    IBOutlet NSMenuItem *nickRegItem;
    IBOutlet NSMenu *userListMenu;
    NickRegController *nrc;
    AboutBoxController *abc;

    // For the "up/down arrow key repeat the last/previous line" feature
    NSMutableArray *history;
    int historyIndex;

    //For Toolbar
    NSMutableDictionary *toolbarItems;
    NSToolbar *toolbar;
    //IBOutlet NSView *ctcpMenuView;

    bool userItemVisible;
    bool connectItemVisible;
}

- (bool)connectItemVisible;
- (bool)userItemVisible;

- (IBAction)sendEmail:(id)sender;
- (IBAction)gotoWebPage:(id)sender;
- (IBAction)gotoMessageBoard:(id)sender;
- (IBAction)gotoSupport:(id)sender;
- (IBAction)gotoStatsPage:(id)sender;
- (IBAction)gotoGuidlines:(id)sender;
- (IBAction)connectClick:(id)sender;
- (IBAction)doSend:(id)sender;
- (IBAction)openNickReg:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)checkVersion:(id)sender;
- (void)awakeFromNib;
- (NSToolbarItem *)connectItem;
- (NSToolbarItem *)emoticonItem;
- (NSToolbarItem *)userItem;
- (NSMenuItem *)connectMenuItem;
- (NSMenuItem *)connectDockMenuItem;
- (NSTextView *)textView;
//- (NSButton *)connectButton;
- (NSTextView *)textField;
- (NSTextField *)topicField;
- (NSTextField *)nickField;
- (NSTextView *)chatInputField;
- (NSWindow *)chatWindow;
- (NSWindow *)debuggerWindow;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)updateList;
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (NSTableView *)userListTableView;
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;
- (NickRegController *)nrc;
- (void)disconnectFromIRCServer;
- (NSTextView *)chatInputField;
- (IBAction)showAbout:(id)sender;
- (IBAction)topicClick:(id)sender;
- (IRCController *)ircController;
- (void)enableContextualMenus:(BOOL)doEnable;
- (void)appendString:(NSString *)sAppend kind:(NSString *)defaultsColorName;
- (void)launchCheckVersion;
- (void)toolbarDidRemoveItem:(NSNotification *)notification;
- (void)toolbarWillAddItem: (NSNotification *) notification;
- (void)updateToolBar;

- (IBAction)sendKiss:(id)sender;
- (IBAction)clearInput:(id)sender;
- (IBAction)selectInput:(id)sender;
- (IBAction)addCtrG:(id)sender;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

- (void)sendAction:(NSString *)theString;
@end
