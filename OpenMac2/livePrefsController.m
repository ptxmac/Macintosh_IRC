#import "LivePrefsController.h"
#import "ChatWindowController.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation LivePrefsController

- (IBAction)dragOpaqueSlider:(id)sender
{
    [[cwc chatWindow] setAlphaValue:[opaqueSlider floatValue]];
    [[[[[[cwc chatWindow] drawers] objectAtIndex: 0] contentView] window] setAlphaValue:[opaqueSlider floatValue]];
}


- (IBAction)dragTruncateSlider:(id)sender
{
    NSString *trunc = @"";

    if ([[nickField stringValue] cStringLength] == [truncateSlider intValue])
	trunc = [nickField stringValue];
    else if ([[nickField stringValue] cStringLength] > [truncateSlider intValue])
	trunc = [[nickField stringValue] substringToIndex:[truncateSlider intValue]];
    else // less
    {
	int x, spaces = [truncateSlider intValue] - [[nickField stringValue] cStringLength];

	for (x = 0; x < spaces; x++)
	{
	    trunc = [trunc stringByAppendingString:@" "];
	}
	trunc = [trunc stringByAppendingString:[nickField stringValue]];
    }

    [truncateField setStringValue:[NSString stringWithFormat:loc(@"what x characters looks like"), trunc, [truncateSlider intValue]]];
    
}

- (IBAction)dragIndentSlider:(id)sender
{
    NSString *indent =@" ";
    int x;
    
    for (x = 0; x < [indentSlider intValue]; x++)
    {
	indent = [NSString stringWithFormat:@" %@", indent];
    }

    [indentField setStringValue:[NSString stringWithFormat:loc(@"indent of characters"), indent, [nickField stringValue], [indentSlider intValue]]];
}

@end
