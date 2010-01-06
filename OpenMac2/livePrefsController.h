/* LivePrefsController */

#import <Cocoa/Cocoa.h>
#import "Utils.h"

@class ChatWindowController;

@interface LivePrefsController : NSObject
{
    IBOutlet Utils *utils;
    
// opacity
    IBOutlet NSWindow *chatWindow;
    IBOutlet NSSlider *opaqueSlider;
    IBOutlet ChatWindowController *cwc;

// truncate
    IBOutlet NSSlider *truncateSlider;
    IBOutlet NSSlider *indentSlider;
    
    IBOutlet NSTextField *truncateField;
    IBOutlet NSTextField *indentField;
    
    IBOutlet NSTextField *nickField;
    
}
- (IBAction)dragOpaqueSlider:(id)sender;
- (IBAction)dragTruncateSlider:(id)sender;
- (IBAction)dragIndentSlider:(id)sender;
@end
