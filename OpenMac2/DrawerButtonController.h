#import <Cocoa/Cocoa.h>
#import "Utils.h"
//#import "BuddyListController.h"

@class InfoPanelController, IRCController, ChatWindowController, BuddyListController;

@interface DrawerButtonController : NSObject
{
    IBOutlet NSButton *gestaltButton;
    IBOutlet NSButton *ignoreButton;
    IBOutlet NSButton *iTunesButton;
    IBOutlet NSButton *timeButton;
    IBOutlet NSButton *getInfoButton;
    IBOutlet NSButton *buddyButton;
    IBOutlet NSButton *pingButton;
    IBOutlet NSButton *privateMessageButton;
    IBOutlet NSButton *versionButton;
    
    IBOutlet NSMenuItem *ignoreMenu;
    IBOutlet NSMenuItem *buddyMenu;
    IBOutlet NSMenuItem *gestaltMenu;
    IBOutlet NSMenuItem *iTunesMenu;
    IBOutlet NSMenuItem *getInfoMenu;
    IBOutlet NSMenuItem *pingMenu;
    IBOutlet NSMenuItem *privateMessageMenu;
    IBOutlet NSMenuItem *versionMenu;
    IBOutlet NSMenuItem *timeMenu;
    
    IBOutlet IRCController *ircController;
    IBOutlet BuddyListController *buddyListController; // i need to check the status of the BuddyList
    IBOutlet ChatWindowController *chatWindowController;
    
    InfoPanelController *infoPanelController;

    IBOutlet Utils *utils;
}
- (IBAction)gestalt:(id)sender;
- (IBAction)iTuens:(id)sender;
- (IBAction)time:(id)sender;
- (IBAction)getInfo:(id)sender;
- (IBAction)ignore:(id)sender;
- (IBAction)ping:(id)sender;
- (IBAction)privateMessage:(id)sender;
- (IBAction)version:(id)sender;
- (InfoPanelController *)infoPanelController;

- (NSButton *)ignoreButton;
- (NSButton *)gestaltButton;
- (NSButton *)buddyButton;
- (NSButton *)iTunesButton;
- (NSButton *)timeButton;
- (NSButton *)pingButton;
- (NSButton *)privateMessageButton;
- (NSButton *)versionButton;
- (NSButton *)getInfoButton;

- (NSMenuItem *)ignoreMenu;
- (NSMenuItem *)buddyMenu;
- (NSMenuItem *)gestaltMenu;
- (NSMenuItem *)iTunesMenu;
- (NSMenuItem *)getInfoMenu;
- (NSMenuItem *)pingMenu;
- (NSMenuItem *)privateMessageMenu;
- (NSMenuItem *)versionMenu;
- (NSMenuItem *)timeMenu;

- (void)makeInfoPanelController;

- (void)disableButtons;
- (void)enableButtons;

- (IBAction)addBuddy:(id)sender;
@end
