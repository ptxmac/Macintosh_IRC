#import <Cocoa/Cocoa.h>
#import "PrefController.h"
#import "ChatWindowController.h"
#import "BuddyListController.h"
#import "SheetController.h"
#import "DrawerButtonController.h"
#import "Utils.h"
#import <string.h>
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <errno.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/wait.h>
#import <netdb.h>
#import <sys/uio.h>
#import <sys/time.h>


@interface IRCController : NSObject
{

    IBOutlet DrawerController *drawerController; // i need to open the drawer if the prefs are set that way
    IBOutlet PrefController *prefController; // I have to be able to get a few user defaults
    IBOutlet ChatWindowController *chatWindowController; // I need to be able to talk with the textView
    IBOutlet BuddyListController *buddyListController; // i need to check the status of the BuddyList
    IBOutlet SheetController *sheetController; // I have to be able to tell the sheetController to run a sheet
    IBOutlet Utils *utils;
    IBOutlet NSTextView *debuggerText;
    
    BOOL isConnected, receivingNames, sockConnected; // connected boolean
    int sockfd; // the socket file descriptor
    struct hostent *he; // for name lookups
    struct sockaddr_in their_addr; // for use in connect()
    NSFileHandle *theSocket; // the cocoa file descriptor - much easier to use
    NSString *tempHolder, *combinedString;
    NSMutableArray *nickList;
    NSString *theNickName;
    IBOutlet DrawerButtonController *drawerButtonController;
    NSMutableArray *pmNicks;
    NSConnection *con;
}
- (void)checkForMoreData:(NSNotification *)notification;
- (void)connectToIRCServer;
- (void)disconnectFromIRCServer;
- (void)sendData:(NSString *)theStringData;
- (void)parseString:(NSString *)theString;
- (void)separateLines:(NSString *)theString;
- (void)scrollToEnd;
- (void)debug:(NSString *)theString kind:(NSString *)defaultsColorName;
- (NSMutableArray *)nickList;
- (NSString *)theNickName;
- (BOOL)isConnected;
- (PrefController *)prefController;
- (void)setPMOpacity:(float)opacity font:(NSFont *)theFont color:(NSColor *)textColor bgColor:(NSColor *)bgColor;
- (NSMutableArray *)pmNicks;
- (void)appendCwc:(NSString *)s kind:(NSString *)k;
//- (void)ctcpiTunes:(NSString *)nickname;
@end
