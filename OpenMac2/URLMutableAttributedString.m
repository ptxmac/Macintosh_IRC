
// Additions to NSMutableAttributedString to find URLs
// and mark them with the appropriate property
// Tab Size: 3
// Copyright (c) 2002 Aaron Sittig

#import "URLMutableAttributedString.h"

static NSURL* findURL(NSString* string);


@implementation NSMutableAttributedString (URLTextViewAdditions)

- (void)detectURLs:(NSColor*)linkColor
{
	NSScanner*					scanner;
	NSRange						scanRange;
	NSString*					scanString;
	NSCharacterSet*				whitespaceSet;
	NSURL*						foundURL;
	NSDictionary*				linkAttr;
	
	// Create our scanner and supporting delimiting character set
	scanner = [NSScanner scannerWithString:[self string]];
	whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	// Start Scan
	while( ![scanner isAtEnd] )
	{
		// Pull out a token delimited by whitespace or new line
		[scanner scanUpToCharactersFromSet:whitespaceSet intoString:&scanString];
		scanRange.length = [scanString length];
		scanRange.location = [scanner scanLocation] - scanRange.length;
		
		// If we find a url modify the string attributes
		if(( foundURL = findURL(scanString) ))
		{
			// Apply underline style and link color
			linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:
							foundURL, NSLinkAttributeName,
							[NSNumber numberWithInt:NSSingleUnderlineStyle], NSUnderlineStyleAttributeName,
							linkColor, NSForegroundColorAttributeName, NULL ];
			[self addAttributes:linkAttr range:scanRange];
		}
	}
}

@end

NSURL* findURL(NSString* string)
{
	NSRange		theRange;
	
	// Look for ://
	theRange = [string rangeOfString:@"://"];
	if( theRange.location != NSNotFound && theRange.length != 0 )
		return [NSURL URLWithString:string];
	
	// Look for www. at start
	theRange = [string rangeOfString:@"www."];
	if( theRange.location == 0 && theRange.length == 4 )
		return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", string]];
	
	// Look for ftp. at start
	theRange = [string rangeOfString:@"ftp."];
	if( theRange.location == 0 && theRange.length == 4 )
		return [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", string]];
	
	// Look for gopher. at start
	theRange = [string rangeOfString:@"gopher."];
	if( theRange.location == 0 && theRange.length == 7 )
		return [NSURL URLWithString:[NSString stringWithFormat:@"gopher://%@", string]];
		
	// Look for mailto: at start
	theRange = [string rangeOfString:@"mailto:"];
	if( theRange.location == 0 && theRange.length == 7 )
		return [NSURL URLWithString:string];
	
	// Look for nap: at start
	theRange = [string rangeOfString:@"nap:"];
	if( theRange.location == 0 && theRange.length == 4 )
		return [NSURL URLWithString:string];
	
	// Look for elite words
	/*theRange = [string rangeOfString:@"blackhole"];
	if( theRange.location == 0 && theRange.length == [string length] )
		return [NSURL URLWithString:@"http://www.blackholemedia.com/"];*/
	
	return nil;
}
