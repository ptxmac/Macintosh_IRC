/* EmoticonController */

#import <Cocoa/Cocoa.h>

@class ChatWindowController;


@interface EmoticonController : NSObject
{
    IBOutlet ChatWindowController *cwc;
    IBOutlet NSMenuItem *emoticonMenu;
    IBOutlet NSWindow *emoticonWindow;
    IBOutlet NSTableView *emoticonTableView;

    NSMutableArray *icons;
}
- (IBAction)showEmoticonList:(id)sender;
- (IBAction)emoticonListDoubleClicked:(id)sender;

- (NSDictionary *)createRecord:(NSString *)theString icon:(NSString *)theIcon print:(NSString *)printString;
    //NSMutableArray *emoticons;

- (void)updateColors;

@end
