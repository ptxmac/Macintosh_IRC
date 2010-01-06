//
//  LSTextView.m
//  OpenMac
//
//  Created by Peter Kristensen on 03/01/10.
//  Copyright 2010 Lucky Software. All rights reserved.
//

#import "LSTextView.h"


@implementation LSTextView
- (void) keyDown:(NSEvent *) theEvent {
    NSString *chars = [theEvent charactersIgnoringModifiers];
    if( [chars length] && [chars characterAtIndex:0] == 9 ) {
        if( [[self delegate] respondsToSelector:@selector(textView:tabHit:)] ) {
            if( [[self delegate] textView:self tabHit:theEvent] ) return;
        }
    }
    [super keyDown:theEvent];
}

@end
