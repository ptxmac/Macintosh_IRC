#import "BuddyListController.h"
#import "ChatWindowController.h"

@implementation BuddyListController

- (void)addBuddy:(NSString *)nick
{
    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];

   // NSString *theNick=@"someNick";

    [record setObject:[NSNumber numberWithBool:TRUE] forKey:@"Online"];
    [record setObject:nick forKey:@"Nickname"];

    [buddies addObject:record];

   // [buddies sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [buddyListTableView reloadData];
    [cwc updateList];
    [record autorelease];

    [[NSUserDefaults standardUserDefaults] setObject:buddies forKey:@"BuddyList"];
}

- (IBAction)buddyListRemove:(id)sender
{
    int selectedRowIndex = [buddyListTableView selectedRow];
    NSNumber *index;

    if(selectedRowIndex >= 0)
    {
        NSMutableArray *buddiesToRemove = [NSMutableArray array];

        // Get an enumerator for the selected rows
        NSEnumerator *e = [buddyListTableView selectedRowEnumerator];

        // Interate over the selected rows
        while (index = [e nextObject])
        {
            [buddiesToRemove addObject:[buddies objectAtIndex:[index intValue]]];
        }

        [buddies removeObjectsInArray:buddiesToRemove];

        [buddyListTableView reloadData];
        [cwc updateList];
        // Post notification to force the label of the add/remove button to be updated on the first tab
        [[NSNotificationCenter defaultCenter] postNotificationName:NSTableViewSelectionDidChangeNotification object:[cwc userListTableView]];

        [[NSUserDefaults standardUserDefaults] setObject:buddies forKey:@"BuddyList"];
    }
    else
    {
        NSBeep();
    }

/* Old code
    
    int index = [buddyListTableView selectedRow];
    
    if(index >= 0)
    {
        [buddies removeObjectAtIndex:index];

        [buddies sortUsingSelector:@selector(caseInsensitiveCompare:)];

        [buddyListTableView reloadData];
        [cwc updateList];

        [[NSUserDefaults standardUserDefaults] setObject:buddies forKey:@"BuddyList"];
    }
    else
        NSBeep();
*/
}

- (void)removeBuddy:(NSString *)theNick
{
    int arrayLoc;
    int buddyLoc = -0;

    for (arrayLoc = 0; arrayLoc < [buddies count]; arrayLoc++)
    {
	if ([[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] isEqualToString:theNick])
	    buddyLoc = arrayLoc;
    }

    [buddies removeObjectAtIndex:buddyLoc];

  //  [buddies sortUsingSelector:@selector(caseInsensitiveCompare:)];

    [buddyListTableView reloadData];
    [cwc updateList];

    [[NSUserDefaults standardUserDefaults] setObject:buddies forKey:@"BuddyList"];
}


- (void)awakeFromNib
{
    buddies = [[[NSUserDefaults standardUserDefaults] objectForKey:@"BuddyList"] mutableCopy];
    //[[self buddyListTableView] setBackgroundColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]]];

    [buddyListTableView setRowHeight:11.5];
    
    // set all online values to false - we aren't connected
    [self initList];
    [self disableButtons];
}

- (void)initList
{
    int arrayLoc;
    for (arrayLoc = 0; arrayLoc < [buddies count]; arrayLoc++)
    {
	NSMutableDictionary *record = [[NSMutableDictionary alloc] init];

	[record setObject:[NSNumber numberWithBool:FALSE] forKey:@"Online"];
	[record setObject:[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] forKey:@"Nickname"];

	[buddies replaceObjectAtIndex:arrayLoc withObject:record];

	[record autorelease];
    }

    // [buddies sortUsingSelector:@selector(caseInsensitiveCompare:)];

    // Prepare the cell for the image
    [[buddyListTableView tableColumnWithIdentifier:@"Online"] setDataCell:[NSImageCell new]];

    [buddyListTableView reloadData];
    [cwc updateList];    
}

- (NSTableView *)buddyListTableView
{
    return buddyListTableView;
}

- (IRCController *)ircController
{
    return ircController;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [buddies count];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"Nickname"])
    {
        [aCell setTextColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"TextColor"]]];

	[aCell setFont:[NSFont systemFontOfSize:10.0]];
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
	    row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"Online"])
    {
        if ([[[buddies objectAtIndex:rowIndex] objectForKey:@"Online"] boolValue])
        {
            return [NSImage imageNamed:@"onlineDot"];
        }
        else
        {
            return [NSImage imageNamed:@"offlineDot"];
        }
    }
    else
    {
        return [[buddies objectAtIndex:rowIndex] objectForKey:@"Nickname"];
    }
    
    // Old code:
    //return [[buddies objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (bool)isBuddy:(NSString *)theNick
{
    bool returnValue=NO;
    int arrayLoc;
    
    for (arrayLoc = 0; arrayLoc < [buddies count]; arrayLoc++)
    {
	if ([[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] isEqualToString:theNick])
	    returnValue = YES;

    }
    return returnValue;
}

- (bool)buddyJoin:(NSString *)theNick
{
    bool returnValue=NO;
    int arrayLoc;
    //NSBeep();
    for (arrayLoc = 0; arrayLoc < [buddies count]; arrayLoc++)
    {
	if ([[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] isEqualToString:theNick])
	{
	    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];

	    returnValue = YES;

	    [record setObject:[NSNumber numberWithBool:TRUE] forKey:@"Online"];
	    [record setObject:[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] forKey:@"Nickname"];

	    [buddies replaceObjectAtIndex:arrayLoc withObject:record];

	    [record autorelease];
	    [buddyListTableView reloadData];
	    [cwc updateList];
	}

    }
    return returnValue;
}

- (void)buddyLeave:(NSString *)theNick
{
    int arrayLoc;
    for (arrayLoc = 0; arrayLoc < [buddies count]; arrayLoc++)
    {
	if ([[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] isEqualToString:theNick])
	{
	    NSMutableDictionary *record = [[NSMutableDictionary alloc] init];

	    [record setObject:[NSNumber numberWithBool:FALSE] forKey:@"Online"];
	    [record setObject:[[buddies objectAtIndex:arrayLoc] objectForKey:@"Nickname"] forKey:@"Nickname"];

	    [buddies replaceObjectAtIndex:arrayLoc withObject:record];

	    [record autorelease];
	    [buddyListTableView reloadData];
	    [cwc updateList];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BuddySound"])
            {
                //NSSound *pingSND = [NSSound soundNamed:@"buddy on"];
                NSSound *pingSND = [NSSound soundNamed:@"buddy off"];
                [pingSND play];
            }
	}
    }
}

- (NSButton *)buddyButton
{
    return buddyButton;
}

- (NSButton *)buddyRemoveButton
{
    return buddyRemoveButton;
}


- (NSMenuItem *)buddyMenu
{
    return buddyMenu;
}


- (NSMenuItem *)buddyRemoveMenu
{
    return buddyRemoveMenu;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{

    if ([buddyListTableView selectedRow] != -1)
    	[self enableButtons];
    else
    	[self disableButtons];

    
}

- (void)disableButtons
{
    [[self buddyRemoveMenu] setEnabled:NO];
    [[self buddyRemoveButton] setEnabled:NO];
}

- (void)enableButtons
{
    [[self buddyRemoveMenu] setEnabled:YES];
    [[self buddyRemoveButton] setEnabled:YES];
}

@end
