#import <Cocoa/Cocoa.h>
#import "ChatWindowController.h"

@interface DrawerController : NSObject
{
    IBOutlet NSDrawer *theDrawer;
  //  IBOutlet NSButton *drawerButton;
    IBOutlet NSMenuItem *userListMenuItem;
    IBOutlet ChatWindowController *chatWindowController; // I need to change the tooltip
    float viewSize;
}
- (IBAction)toggleDrawer:(id)sender;
- (void)awakeFromNib;
- (void)drawerClosed:(NSNotification *)notification;
- (void)drawerOpened:(NSNotification *)notification;
- (void)openDrawer;
//- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset;
@end
