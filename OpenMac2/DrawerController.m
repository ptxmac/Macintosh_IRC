#import "DrawerController.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation DrawerController

- (IBAction)toggleDrawer:(id)sender
{
    [theDrawer toggle:self];
}

- (void)openDrawer
{
    [theDrawer toggle:self];
  //  NSLog(@"the drawer is open");
}

- (void)awakeFromNib
{
    NSSize theSize;

    theSize.height=344.00;
    theSize.width=180.00;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawerClosed:) name:@"NSDrawerDidCloseNotification" object:nil]; // tell me when the drawer closes 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawerOpened:) name:@"NSDrawerDidOpenNotification" object:nil]; // tell me when the drawer opens

   // - (void)setContentSize:(NSSize)size
    [theDrawer setContentSize:theSize];
}

- (void)drawerClosed:(NSNotification *)notification
{
    if ([notification object] == theDrawer) // if the drawer is my drawer
    {
       // [drawerButton setState:NSOffState]; // tell the drawer button to turn the lights off!
       // [drawerButton setTitle:@"Users ->"];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UserDrawerOpen"];

	/*if ([chatWindowController userItemVisible])
	    [[chatWindowController userItem] setToolTip:@"Show the Users list"];*/

	[chatWindowController updateToolBar];
	
	[userListMenuItem setTitle:loc(@"Show User Options")];
    }
}
- (void)drawerOpened:(NSNotification *)notification
{
    if ([notification object] == theDrawer) // if the drawer is my drawer
    {
        // [drawerButton setState:NSOnState]; // tell the drawer button to turn the lights on!
        // [drawerButton setTitle:@"<- sresU"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UserDrawerOpen"];

	/*if ([chatWindowController userItemVisible])
	    [[chatWindowController userItem] setToolTip:@"Hide the Users list"];*/

	[chatWindowController updateToolBar];
	
	[userListMenuItem setTitle:loc(@"Hide User Options")];

    }
}

// deal with the split view in the users tab
- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
    viewSize = proposedMax;
    return proposedMax;
}

- (float)splitView:(NSSplitView *)splitView constrainSplitPosition:(float)proposedPosition ofSubviewAt:(int)offset
{
    [chatWindowController updateList];
    
    if(proposedPosition <= viewSize - 215.0)
	return viewSize - 215.0;
    else
	return proposedPosition;
}

/*- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    //NSLog(@"oldSize: %s", oldSize);
}*/

@end
