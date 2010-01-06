#import <Foundation/Foundation.h>
#import "NDAppleScriptObject.h"
#import "NSAppleEventDescriptor+NDAppleScriptObject.h"

void createAndExecuteScriptObject( NSString * aPath );

const OSType	kProjectBuilderCreatorCode = 'pbxa';

@interface SendTarget : NSObject <NDAppleScriptObjectSendEvent, NDAppleScriptObjectActive>
{
	NDAppleScriptObject		* appleScriptObject;
	unsigned int				OK_Enough;
}
+ (id)sendTargetWithAppleScriptObject:(NDAppleScriptObject *)anObject;
@end

/*
 * main
 */
int main (int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSString		* thePath;

	thePath = @"../Test Script.scpt";
	createAndExecuteScriptObject( thePath );
	
	[pool release];
	return 0;
}

/*
 * createAndExecuteScriptObject()
 */
void createAndExecuteScriptObject( NSString * aPath )
{
	NSString					* theScriptText;
	NDAppleScriptObject		* theScriptObject;

	/*
	 * compiling and executing a script within a string
	 */
	[NDAppleScriptObject compileExecuteString:@"say \"This is a compiled and executed string\"\n"];

	if( [[aPath pathExtension] isEqualToString:@"applescript"] )
	{
		/*
		 * This shows creating a script object from a string
		 */		
		theScriptText = [NSString stringWithContentsOfFile:aPath];
		theScriptObject = [NDAppleScriptObject appleScriptObjectWithString:theScriptText];
	}
	else
	{
		/*
		 * This shows creating a script object from a compiled apple script file.
		 */
		theScriptObject = [[NDAppleScriptObject alloc] initWithContentsOfFile:aPath];
//		theScriptObject = [[NDAppleScriptObject alloc] initWithContentsOfFile:aPath component:[NDAppleScriptObject findNextComponent]];
	}
	
	if( theScriptObject )
	{
		id					theResult;
		NSArray			* theEventIdentifierList;
		SendTarget		* theSendTarget;

		/*
		 * set execution mode flags
		 */
		[theScriptObject setExecutionModeFlags:kOSAModeCanInteract];

		/*
		 * set target object which implements the NDAppleScriptObjectSendEvent protocol,
		 * it simple prints a message and then passes all of the paramter back to NDAppleScriptObject
		 * which also implements the NDAppleScriptObjectSendEvent protocol.
		 */
		theSendTarget = [SendTarget sendTargetWithAppleScriptObject:theScriptObject];
		[theScriptObject setAppleEventSendTarget:theSendTarget];

		/*
		 * set target object which implements the NDAppleScriptObjectActive protocol,
		 * it simple prints a message and then calls NDAppleScriptObject
		 * which also implements the NDAppleScriptObjectActive protocol.
		 */
		[theScriptObject  setActiveTarget:theSendTarget];
	
		/*
		 * display the events the script object responded
		 */
		theEventIdentifierList = [theScriptObject arrayOfEventIdentifier];
		printf("This script responds to the events %s\n", [[theEventIdentifierList description] cString]);

		/*
		 * set Finder as the default target, for display dialog etc.
		 */
//		[theScriptObject setDefaultTargetAsCreator:kProjectBuilderCreatorCode];
		[theScriptObject setFinderAsDefaultTarget];

		/*
		 * display the scripts source
		 */
		printf("The script\n\n%s\n\ngives us\n\n", [[theScriptObject description] cString]);

		/*
		 * exectue and get result
		 */
		[theScriptObject execute];
		theResult = [theScriptObject resultObject];

		/*
		 * the result can be returned as a object, NSArray, NSDictionary, NSNumber, NSString, NSURL, NSAppleEventDescriptor
		 * even an NDAppleScriptObject which can then be executed
		 */
		if( [theResult isKindOfClass:[NDAppleScriptObject class]] )
		{
			[theResult execute];
		}
		else
		{
			printf("%s\n\n",[[theResult description] cString]);
		}

		/*
		 * lets display the result as a string
		 */
		printf("Result as a string\n%s\n\n", [[theScriptObject resultAsString]  cString]);

		/*
		 * executeOpen takes an array of paths or urls and passes them to the script through the open
		 * event as a list of aliases
		 */
		printf("Attempt to open '../Source' '../build'\n");
		[theScriptObject executeOpen:[NSArray arrayWithObjects:@"../Source", @"../build", nil]];

		/*
		 * test if the script executes the apple event 'quit' and if so execute it
		 */
		if( [theScriptObject respondsToEventClass:kCoreEventClass eventID:kAEQuitApplication] )
		{
			[theScriptObject executeEvent:[NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass eventID:kAEQuitApplication targetDescriptor:[theScriptObject targetNoProcess] returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID]];
		}
		else
		{
			printf("Script does not respond to kCoreEventClass:kAEQuitApplication\n");
		}

		/*
		 * write the compiled script back out to the file so that any varible bindings are updated
		 */
		if( [[aPath pathExtension] isEqualToString:@"scpt"] )
		{
			[theScriptObject writeToFile:aPath];
//			[theScriptObject writeToFile:@"../Test Script out.scpt"];
		}
	}
	else
	{
		printf("Could not create the AppleScript object\n");
	}
}

@implementation SendTarget

+ (id)sendTargetWithAppleScriptObject:(NDAppleScriptObject *)anObject
{
	SendTarget		* theInstance;

	if( theInstance = [[[self alloc] init] autorelease] )
	{
		theInstance->appleScriptObject = [anObject retain];
		theInstance->OK_Enough = 0;
	}
	return theInstance;
}

-(void)dealloc
{
	[appleScriptObject release];
}

/*
 * sendAppleEvent:sendMode:sendPriority:timeOutInTicks:idleProc:filterProc:
 */
- (NSAppleEventDescriptor *)sendAppleEvent:(NSAppleEventDescriptor *)theAppleEventDescriptor sendMode:(AESendMode)aSendMode sendPriority:(AESendPriority)aSendPriority timeOutInTicks:(long)aTimeOutInTicks idleProc:(AEIdleUPP)anIdleProc filterProc:(AEFilterUPP)aFilterProc
{	
	OK_Enough++;
	if( OK_Enough < 2 )
		printf("sending say event to %s...\n\n", [theAppleEventDescriptor isTargetCurrentProcess] ? "self" : "Finder" );
	else if( OK_Enough == 2 )
		printf("sending open event to %s...\t\tyou get the idea.\n\n", [theAppleEventDescriptor isTargetCurrentProcess] ? "self" : "Finder" );

	return [appleScriptObject sendAppleEvent:theAppleEventDescriptor sendMode:aSendMode sendPriority:aSendPriority timeOutInTicks:aTimeOutInTicks idleProc:anIdleProc filterProc:aFilterProc];
}

- (BOOL)appleScriptActive
{
	printf("* active\n");
	return [appleScriptObject appleScriptActive];
}

@end
