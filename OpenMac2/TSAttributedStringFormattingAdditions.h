//
//  TSAttributedStringFormattingAdditions.h
//  ThinkSecret
//
//  Created by Simon Jacquier on Thu Jun 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct{
    NSString 	*textString;
    NSString	*imageName;
}smileyType;

#define NUM_SMILEYS (sizeof(smiley)/(sizeof(smileyType*)*2))

@interface NSMutableAttributedString (FormattingAdditions)

- (void)convertSmileys;
- (void)detectBelChar;



@end
