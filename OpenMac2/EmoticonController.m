#import "EmoticonController.h"
#import "TSAttributedStringFormattingAdditions.h"
#import "ChatWindowController.h"
#define loc(x) [[NSBundle bundleForClass:[self class]] localizedStringForKey:x value:nil table:nil]

@implementation EmoticonController

- (IBAction)showEmoticonList:(id)sender
{
		if([emoticonMenu tag] == 42)
		{
				[emoticonMenu setTitle:loc(@"Hide Emoticons")];
                                [emoticonMenu setTag:43];
				[[cwc emoticonItem] setToolTip:loc(@"Hide Emoticons")];


				[emoticonWindow orderOut:self];

				[emoticonWindow makeKeyAndOrderFront:self];

				[emoticonTableView reloadData];

		}
		else
		{
				[emoticonMenu setTitle:loc(@"Show Emoticons")];
                                [emoticonMenu setTag:42];
				[[cwc emoticonItem] setToolTip:loc(@"Show Emoticons")];

				[emoticonWindow close];
		}
}

- (BOOL)windowShouldClose:(id)sender
{
		[emoticonMenu setTitle:loc(@"Show Emoticons")];
                [emoticonMenu setTag:42];
		[[cwc emoticonItem] setToolTip:loc(@"Show Emoticons")];

		return YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
		return [icons count];
}



- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
												row:(int)rowIndex
{
		if ([[aTableColumn identifier] isEqualToString:@"icon"])
		{
				return [NSImage imageNamed:[[icons objectAtIndex:rowIndex] objectForKey:@"imageName"]];
		}
		else
		{
				return [[icons objectAtIndex:rowIndex] objectForKey:@"showString"];
		}

}

- (void)awakeFromNib
{
		// make the doublclick action
		[emoticonTableView setDoubleAction:@selector(emoticonListDoubleClicked:)];

		// Prepare the cell for the image
		[[emoticonTableView tableColumnWithIdentifier:@"icon"] setDataCell:[NSImageCell new]];

		// initilaise the emoticon list
		icons = [[NSMutableArray alloc] init];
		[icons addObject:[self createRecord:loc(@"*smile*") icon:@"smile" print:@":)"]];
		[icons addObject:[self createRecord:loc(@"*sad*") icon:@"sad" print:@":("]];
		[icons addObject:[self createRecord:loc(@"*cry*") icon:@"cry" print:@":'("]];
		[icons addObject:[self createRecord:loc(@"*wink*") icon:@"wink" print:@";)"]];
		[icons addObject:[self createRecord:loc(@"*tongue*") icon:@"tounge" print:@":-p"]];
		[icons addObject:[self createRecord:loc(@"*oh*") icon:@"oh" print:@":-O"]];
		[icons addObject:[self createRecord:loc(@"*love*") icon:@"love" print:@":-*"]];
		[icons addObject:[self createRecord:loc(@"*biggrin*") icon:@"biggrin" print:@":D"]];
		[icons addObject:[self createRecord:loc(@"*confused*") icon:@"confused" print:@":-/"]];
		[icons addObject:[self createRecord:loc(@"*cool*") icon:@"cool" print:@"8)"]];
		[icons addObject:[self createRecord:loc(@"*concerned*") icon:@"concerned" print:@":|"]];
		[icons addObject:[self createRecord:loc(@"*devil*") icon:@"devil" print:@"}:)"]];
		[icons addObject:[self createRecord:loc(@"*angel*") icon:@"angel" print:@"O:)"]];
		[icons addObject:[self createRecord:loc(@"*garsh*") icon:@"garsh" print:@":}"]];

		[emoticonWindow setFrameAutosaveName:@"EmoticonWindow"];

}

- (NSDictionary *)createRecord:(NSString *)showString icon:(NSString *)theIcon print:(NSString *)printString
{
		NSMutableDictionary *record = [NSMutableDictionary dictionary];
		[record setObject:showString forKey:@"showString"];
		[record setObject:theIcon forKey:@"imageName"];
		[record setObject:printString forKey:@"printString"];
		return record;
}

- (IBAction)emoticonListDoubleClicked:(id)sender
{
		int rowIndex = [emoticonTableView clickedRow];
		NSString *theText = [[[cwc chatInputField] textStorage] string];

		//New emoticon code here
		NSString *theEmoticon = [[icons objectAtIndex:rowIndex] objectForKey:@"printString"];

		NSString *theString = [NSString stringWithFormat:@"%@%@", theText, theEmoticon];

		[[cwc chatInputField] setString:theString];
}

- (void) updateColors
{
		[emoticonTableView reloadData];
}

@end
