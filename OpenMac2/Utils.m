//
//  Utils.m
//  ThinkSecret
//
//  Created by Nate Friedman on Mon Jun 17 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import <Carbon/Carbon.h>

@implementation Utils
//
//- (bool)isRunning:(NSString *)signiture
//{
//    auto OSErr    osErr   = noErr;
//    auto ProcessSerialNumber process;
//    auto ProcessInfoRec  procInfo;
//    auto Str255    procName;
//    auto DateTimeRec   launchDateTime;
//    FSSpec              appFSSpec;
//    NSString		* testSig;
//
//    bool		isTrue=NO;
//
//    process.highLongOfPSN = kNoProcess;
//    process.lowLongOfPSN  = kNoProcess;
//    procInfo.processInfoLength         = sizeof(ProcessInfoRec);
//    procInfo.processName          = procName;
//    procInfo.processAppSpec             = &appFSSpec;
//    while (procNotFound != (osErr = GetNextProcess(&process))) {
//	if (noErr == (osErr = GetProcessInformation(&process, &procInfo))) {
//	    if ('\0' == procName[1]) procName[1] = '0'; SecondsToDate(procInfo.processLaunchDate, &launchDateTime);
//	    {
//		testSig = [NSString stringWithFormat:@"%c%c%c%c",((char *) &procInfo.processSignature)[0], ((char *) &procInfo.processSignature)[1], ((char *) &procInfo.processSignature)[2], ((char *) &procInfo.processSignature)[3]];
//		if([testSig isEqualToString:signiture])
//		{
//		    isTrue=YES;
//		}
//	    }
//	}
//    }
//
//    return isTrue;
//}

- (NSString *)truncateNick:(NSString *)theNick
{// Nate's ThinkSecret 1.2 edit: longer truncating nicks
 //i changed it from 11 chars to [[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"] chhars
    int x;

    NSString *trunc = @"";

    if ([theNick cStringLength] == [[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"])
	trunc = theNick;
    else if ([theNick cStringLength] > [[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"])
	trunc = [theNick substringToIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"]];
    else // less
    {
	int spaces = [[NSUserDefaults standardUserDefaults] integerForKey:@"NickTruncate"] - [theNick cStringLength];

	for (x = 0; x < spaces; x++)
	{
	    trunc = [trunc stringByAppendingString:@" "];
	}
	trunc = [trunc stringByAppendingString:theNick];
    }

    return trunc;
}

- (NSString *)cleanNick:(NSString *)theNick
{
    NSLog(@"jsjsj %@", theNick);
    if([theNick hasSuffix:@"@"] || [theNick hasSuffix:@"+"])
        return [theNick substringToIndex:[theNick cStringLength]-1];
    else
        return theNick;
}

@end
