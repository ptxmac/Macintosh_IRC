/* BuddyListController */

#import <Cocoa/Cocoa.h>
#import <AppKit/NSMenu.h>

@class IRCController, DrawerButtonController, ChatWindowController;

@interface BuddyListController : NSObject
{
    IBOutlet NSButton *buddyButton;
    IBOutlet NSMenu *buddyListMenu;  
    IBOutlet NSTableView *buddyListTableView;
    IBOutlet NSMenuItem *buddyMenu;  
    IBOutlet NSButton *buddyRemoveButton;
    IBOutlet NSMenuItem *buddyRemoveMenu;
    IBOutlet ChatWindowController *cwc;
    IBOutlet DrawerButtonController *drawerButtonController;
    IBOutlet IRCController *ircController;
    
    NSMutableArray *buddies;
}    
- (void)disableButtons;
- (void)addBuddy:(NSString *)nick;
- (void)awakeFromNib;
- (NSTableView *)buddyListTableView;
- (IRCController *)ircController;
- (void)initList;

- (void)removeBuddy:(NSString *)theNick;
- (void)enableButtons;

- (bool)isBuddy:(NSString *)theNick;
- (bool)buddyJoin:(NSString *)theNick;
- (void)buddyLeave:(NSString *)theNick;

- (void)disableButtons;
- (void)enableButtons;

- (NSMenuItem *)buddyRemoveMenu;
- (NSMenuItem *)buddyMenu;

- (NSButton *)buddyButton;
- (NSButton *)buddyRemoveButton;
@end
