/* AboutBoxController */

#import <Cocoa/Cocoa.h>

@interface AboutBoxController : NSWindowController
{
    IBOutlet NSImageView *imageWell;
    IBOutlet NSTextField *versionBox;
    IBOutlet NSWindow *aboutWindow;
}
- (IBAction)urlClick:(id)sender;
- (IBAction)setVersion:(id)sender;
/* - (IBAction)clarusClick:(id)sender; */
@end
