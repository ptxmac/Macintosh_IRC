/* NickChooseController */

#import <Cocoa/Cocoa.h>

@interface NickChooseController : NSWindowController
{
    IBOutlet NSTextField *chooseText;
    IBOutlet NSTextField *nickChoiceField;
}
- (IBAction)okClick:(id)sender;
- (IBAction)urlClick:(id)sender;
- (void)showWindowWithNick:(NSString *)nickToUse;
@end
