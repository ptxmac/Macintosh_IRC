//
//  LSTextView.m
//  OpenMac
//
//  Created by Peter Kristensen on Sat Mar 22 2003.
//  Copyright (c) 2003 Lucky Software. All rights reserved.
//

#import "LSTextView.h"

#import </usr/include/objc/objc-class.h>
void MethodSwizzle(Class aClass, SEL orig_sel, SEL alt_sel)
{
    Method orig_method = nil, alt_method = nil;

    // First, look for the methods
    orig_method = class_getInstanceMethod(aClass, orig_sel);
    alt_method = class_getInstanceMethod(aClass, alt_sel);

    // If both are found, swizzle them
    if ((orig_method != nil) && (alt_method != nil))
    {
        char *temp1;
        IMP temp2;

        temp1 = orig_method->method_types;
        orig_method->method_types = alt_method->method_types;
        alt_method->method_types = temp1;

        temp2 = orig_method->method_imp;
        orig_method->method_imp = alt_method->method_imp;
        alt_method->method_imp = temp2;
    }
}


@implementation NSTextView (LSTextView)

+ (void)load
{
    MethodSwizzle([self class],@selector(keyDown:),@selector(mykeyDown:));
}
- (void) mykeyDown:(NSEvent *) theEvent
{
    NSString *chars = [theEvent charactersIgnoringModifiers];
    if( [chars length] && [chars characterAtIndex:0] == 9 )
    {
        if( [[self delegate] respondsToSelector:@selector(textView:tabHit:)] )
        {
            if( [[self delegate] textView:self tabHit:theEvent] ) return;
        }
    }
    [self mykeyDown:theEvent];
}

@end
