#import <Cocoa/Cocoa.h>
#import "Utils.h"

@class ChatWindowController, NickChooseController, IRCController, BuddyListController, EmoticonController;

@interface PrefController : NSObject
{
    IBOutlet Utils *utils;

    IBOutlet NSButton *emotBox;
    IBOutlet NSButton *bufferBox;
    
    IBOutlet NSButton *autoConnectBox;

    IBOutlet NSSlider *truncateSlider;
    IBOutlet NSSlider *indentSlider;
    IBOutlet NSTextField *truncateField;
    IBOutlet NSTextField *indentField;

    /*begin Nate's ThinkSecret 1.1b5 sound prefs */
    IBOutlet NSButton *bellBeepBox;
    IBOutlet NSButton *soundCTCPBox;
    IBOutlet NSButton *soundPMBox;
    IBOutlet NSButton *soundPingBox;
    IBOutlet NSButton *soundJoinBox;
    IBOutlet NSButton *soundLeaveBox;
    IBOutlet NSButton *soundKickBox;
    /*end 1.1b5 sound prefs*/
    IBOutlet NSButton *soundBuddyBox;
    
    IBOutlet NSButton *ctcpEnabledBox;
    IBOutlet NSButton *showMOTDBox;
    IBOutlet NSTextField *nameField;
    IBOutlet NSTextField *nickField;
    IBOutlet NSWindow *prefWindow;
    IBOutlet NSWindow *chatWindow;
    IBOutlet NSTextField *quitMessageField;
    IBOutlet NSPopUpButton *serverPopUp;
    IBOutlet NSTextField *currentFontField;

				IBOutlet EmoticonController *emotCont;
    IBOutlet ChatWindowController *cwc;
    IBOutlet BuddyListController *buddyListController;
    IBOutlet IRCController *ircController;
				
    IBOutlet NSColorWell *textColorWell;
    IBOutlet NSColorWell *bgColorWell;
    IBOutlet NSColorWell *stripeColorWell;
    IBOutlet NSColorWell *myColorWell;
    IBOutlet NSColorWell *joinPartColorWell;
    IBOutlet NSColorWell *serverColorWell;
    IBOutlet NSColorWell *noticeColorWell;
    IBOutlet NSColorWell *buddyColorWell;
    IBOutlet NSSlider *opaqueSlider;
    IBOutlet NSSlider *pmOpaqueSlider;
    IBOutlet NSButton *pmNewWindowBox;
    IBOutlet NSColorWell *pmColorWell;
    IBOutlet NSMatrix *gestaltBox;

    BOOL emotTemp;
    BOOL bufferTemp;
    
    BOOL ctcpEnabledTemp;
    BOOL filterColorsTemp;
    BOOL filterStylesTemp;
    BOOL showMOTDTemp;
    BOOL pmNewWindowTemp;

    /*begin Nate's ThinkSecret 1.1b5 sound prefs */
    BOOL bellBeepTemp;
    BOOL soundCTCPTemp;
    BOOL soundMPTemp;
    BOOL soundPingTemp;
    BOOL soundJoinTemp;
    BOOL soundLeaveTemp;
    BOOL soundKickTemp;
    /*end 1.1b5 sound prefs*/
    BOOL soundBuddyTemp;

    bool autoConnectTemp;

    int truncateTemp;
    int indentTemp;
    
    int gestaltTemp;
    NSString *nameTemp;
    NSString *nicknameTemp;
    NSString *quitMessageTemp;
    NSFont *chatFontTemp, *newFont;
    NSColor *textColorTemp, *bgColorTemp, *stripeColorTemp, *myColorTemp, *joinPartColorTemp, *serverColorTemp, *noticeColorTemp, *pmColorTemp, *buddyColorTemp;
    float opaqueTemp;
    float pmOpaqueTemp;
    int NewServerPopUpTemp;
    NickChooseController *ncc;

// if i decide to put the toolbar back in...
    /*
    //For Toolbar
    NSMutableDictionary *toolbarItems;
    NSToolbar *toolbar;
     */
}
+ (void)initialize;
- (IBAction)openPrefWindow:(id)sender;
- (IBAction)prefWindowCancel:(id)sender;
- (IBAction)prefWindowOk:(id)sender;
- (IBAction)changeFontClick:(id)sender;
//- (IBAction)dragOpaqueSlider:(id)sender;
- (NSString *)whichServer:(int)index;
- (NSMutableArray *)ignoreList;
- (void)addIgnore:(NSString *)nick;
- (void)removeIgnore:(int)index;
- (BOOL)nickIsIgnored:(NSString *)nick;
- (void)changeFont:(id)fontManager;
@end
