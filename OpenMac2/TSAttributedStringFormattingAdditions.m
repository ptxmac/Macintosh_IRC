//
//  TSAttributedStringFormattingAdditions.m
//  ThinkSecret
//
//  Created by Simon Jacquier on Thu Jun 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//
//  *** Code borrowed from Adium © Adam Iser ***
//  *** http://www.adiumx.com/               ***
//

#import "TSAttributedStringFormattingAdditions.h"

smileyType smiley[] = {
	{@":)_",@"drool"},
        {@":)~",@"drool"},
        {@":-)~",@"drool"},
	{@"}:)",@"devil"},
	{@"]:)",@"devil"},
	{@":'>",@"devil"},
	{@"O:-)",@"angel"},
	{@"O:)",@"angel"},
	{@"O=)",@"angel"},
	{@"o:-)",@"angel"},
	{@"o:')",@"angel"},
	{@"o:)",@"angel"},
	{@"o=)",@"angel"},
	{@":-)",@"smile"},
	{@":')",@"smile"},
	{@":*)",@"smile"},
	{@":^)",@"smile"},
	{@":)",@"smile"},
	{@":']",@"smile"},
	{@"=)",@"smile"},
	{@":o)",@"smile"},
	{@":-(",@"sad"},
	{@":(",@"sad"},
	{@":o(",@"sad"},
	{@":^(",@"sad"},
	{@":*(",@"sad"},
	{@"=(",@"sad"},
	{@":-[",@"sad"},
	{@":[",@"sad"},
	{@"=[",@"sad"},
	{@":'C",@"sad"},
	{@":'(",@"cry"},
	{@"='(",@"cry"},
	{@":_(",@"cry"},
	{@";-)",@"wink"},
	{@";)",@"wink"},
	{@";')",@"wink"},
        {@";o)",@"wink"},
	{@":b",@"tounge"},
	{@":-b",@"tounge"},
	{@":-P",@"tounge"},
	{@":P",@"tounge"},
	{@";P",@"tounge"},
	{@":'P",@"tounge"},
	{@";'P",@"tounge"},
	{@"=P",@"tounge"},
	{@":-p",@"tounge"},
	{@":p",@"tounge"},
	{@"=p",@"tounge"},
	{@";-P",@"tounge"},
	{@":oh:",@"oh"},
	{@"=-o",@"oh"},
	{@"=-O",@"oh"},
	{@":-o",@"oh"},
        {@":-O",@"oh"},
	{@":o",@"oh"},
	{@":'O",@"oh"},
	{@"=o",@"oh"},
	{@":'X",@"love"},
	{@":-*",@"love"},
	{@":'*",@"love"},
	{@":*",@"love"},
	{@"=*",@"love"},
	{@":-x",@"love"},
	{@":x",@"love"},
	{@"=x",@"love"},
	{@":-X",@"love"},
	{@":X",@"love"},
	{@"=X",@"love"},
	{@":-D",@"biggrin"},
	{@":D",@"biggrin"},
	{@";D",@"biggrin"},
	{@":'D",@"biggrin"},
	{@"=D",@"biggrin"},
	{@":|",@"concerned"},
	{@":'|",@"concerned"},
	{@":-|",@"concerned"},
	{@":^|",@"concerned"},
	{@":'L",@"concerned"},
	{@":-/",@"confused"},
	{@":'/",@"confused"},
        {@":/",@"confused"},
    	{@"=/",@"confused"},
	{@"8-)",@"cool"},
	{@"8)",@"cool"},
	{@"8^)",@"cool"},
	{@"8')",@"cool"},
	{@":'}",@"garsh"},
	{@":}",@"garsh"},
        {@":-!",@"garsh"},
        {@":!",@"garsh"}
};


// Used for caching
//static NSMutableDictionary *smileyImageDict = [NSMutableDictionary dictionary];

@implementation NSMutableAttributedString (FormattingAdditions)

/*   convertSmileys
 *   converts the smileys in a string to lil images
 */
- (void)convertSmileys
{
    int 	loop;
    NSRange 	smileyRange;
    NSString 	*sourceString = [self string];
    NSRange	attributeRange;
    int		currentLocation = 0;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"UseEmoticons"])
    // Go through looking for each smiley image
    for(loop = 0;loop < NUM_SMILEYS;loop++)
    {
        // Put us at the beginning of the string
        currentLocation = 0;
        
        // Find a smiley
        smileyRange = [sourceString rangeOfString:smiley[loop].textString options:0 range:NSMakeRange(currentLocation,[sourceString length] - currentLocation)];

        while(smileyRange.length != 0) // If we found a smiley
        {
            NSString *smileyName = smiley[loop].imageName;

            // Make sure this smiley's not inside a link
            if([self attribute:NSLinkAttributeName atIndex:smileyRange.location effectiveRange:&attributeRange] == nil){
                // Insert the smiley
                //if([smileyImageDict objectForKey:smileyName] == nil)
                //{
                    NSAttributedString *smileyImageString;
                    NSFileWrapper *smileyFileWrapper = [[[NSFileWrapper alloc] initWithPath:[[NSBundle mainBundle] pathForResource:smileyName ofType:@"tif"]] autorelease];
                    NSTextAttachment *smileyAttatchment = [[[NSTextAttachment alloc] init] autorelease];
    
                    [smileyAttatchment setFileWrapper:smileyFileWrapper];
                    //[smileyImageDict setObject:[NSAttributedString attributedStringWithAttachment:smileyAttatchment] forKey:smileyName];
                    smileyImageString = [[NSAttributedString attributedStringWithAttachment:smileyAttatchment] retain];
                //}

                //[self replaceCharactersInRange:smileyRange withAttributedString:[smileyImageDict objectForKey:smileyName]];
                [self replaceCharactersInRange:smileyRange withAttributedString:smileyImageString];
		
                // Shrink the smiley range to 1 character
                // (the multicharacter chunk has been replaced with a single character/smiley)
                smileyRange.length = 1;
            }

            // Move our location
            currentLocation = smileyRange.location + smileyRange.length;

            // Find the next smiley
            smileyRange = [sourceString rangeOfString:smiley[loop].textString options:0 range:NSMakeRange(currentLocation,[sourceString length] - currentLocation)];
        }
    }    
}

- (void)detectBelChar
{
    NSRange 	beepRange;
    NSString 	*sourceString = [self string];
    NSRange	attributeRange;
    int		currentLocation = 0;

    // NSLog(sourceString);
    // we want to find a \\007


    // Put us at the beginning of the string
    currentLocation = 0;

    // Find a ^G
    beepRange = [sourceString rangeOfString:@"\007" options:0 range:NSMakeRange(currentLocation,[sourceString length] - currentLocation)];

    while(beepRange.length != 0) // If we found a beep
    {
	// Make sure this beep is not inside a link
	if([self attribute:NSLinkAttributeName atIndex:beepRange.location effectiveRange:&attributeRange] == nil)
	{

	    [self replaceCharactersInRange:beepRange withString:@"^G"];
	    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BellBeep"])
		NSBeep();
	    // Shrink the smiley range to 2 characters
            // (the 1 chunk has been replaced with a 2 char "^G")
	    beepRange.length = 2;
	}

            // Move our location
            currentLocation = beepRange.location + beepRange.length;

            // Find the next smiley
            beepRange = [sourceString rangeOfString:@"\007" options:0 range:NSMakeRange(currentLocation,[sourceString length] - currentLocation)];
    }

}

@end

