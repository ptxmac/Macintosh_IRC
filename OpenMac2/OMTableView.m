#import "OMTableView.h"

#define STRIPE_RED   (237.0 / 255.0)
#define STRIPE_GREEN (243.0 / 255.0)
#define STRIPE_BLUE  (254.0 / 255.0)
static NSColor *sStripeColor = nil;

@implementation OMTableView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent // We need to override menuForEvent so that the row clicked gets selected
{
    NSPoint point = [theEvent locationInWindow]; // where in the window did it get clicked?
    NSPoint newPoint = [self convertPoint:point fromView:nil]; // convert from window coordinates to self coordinates
    int row = [self rowAtPoint:newPoint]; // what row got clicked?

    if (row != -1) // if it's -1, then apparently, no row got clicked. We'll just return the menu.
    {
        [self selectRow:row byExtendingSelection:NO]; // select the row
    }

    return [self menu]; // now, either way, return the menu
}

- (void) highlightSelectionInClipRect:(NSRect)rect {
		[self drawStripesInRect:rect];
		[super highlightSelectionInClipRect:rect];
}

// Based on Apples Code, blah blah blah
- (void) drawStripesInRect:(NSRect)clipRect {
		NSRect stripeRect;
		float fullRowHeight = [self rowHeight] + [self intercellSpacing].height;
		float clipBottom = NSMaxY(clipRect);
		int firstStripe = clipRect.origin.y / fullRowHeight;
		
		// set up first rect
		stripeRect.origin.x = clipRect.origin.x;
		stripeRect.origin.y = firstStripe * fullRowHeight;
		stripeRect.size.width = clipRect.size.width;
		stripeRect.size.height = fullRowHeight;
		
		while (stripeRect.origin.y < clipBottom) {
				int theStripe = stripeRect.origin.y / fullRowHeight;
				if (theStripe % 2 == 0)
                                    sStripeColor=	[NSColor whiteColor];		//[[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"BgColor"]] retain];
				else
					sStripeColor =		[[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"StripeColor"]] retain];
				

				[sStripeColor set];
				NSRectFill(stripeRect);
				
				stripeRect.origin.y += fullRowHeight;
		}
}



    
@end
