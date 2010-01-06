//
//  Globals.m
//  ThinkSecret Chat
//
//  Created by Nate Friedman on Thu Jun 20 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "Globals.h"

// you need to change a few things around before you can use this app in your channel.

// 1st we need to know what you are calling this chat app, it'll effect things like "so and so joined this chat"
    NSString *THIS_CHAT_APP = @"#Macintosh"; // chat program name

// next we need to know what the IRC channel is
    NSString *IRC_CHANNEL = @"#Macintosh"; // channel name

// what port does your IRC server(s) use? it's normaly 6667
    const int PORT = 6667;

// there are a few urls that this program refrences, here they are in one easy to change place :)
    // the webpage buton the toolbar and in the about window
        NSString *MAIN_URL = @"http://macintosh.irczone.dk/";

    // the channel guidlines in the help menu and initial nick choose window
        NSString *GUIDE_URL = @"http://macintosh.irczone.dk/retningslinier/";

    // the stats page in the toolbar
        NSString *STATS_URL = @"http://macintosh.irczone.dk/ircstats/";

    // the features request/support forum in the help menu
        NSString *SUPPORT_URL = @"http://macintosh.irczone.dk/kontakt/";

    // the main forum in the toolbar
        NSString *FORUM_URL = @"";

    // the email button on the toolbar
        NSString *EMAIL_ADDRESS = @"mailto:macintosh@irczone.dk";


    // if there is an error in the version checking, were does one go and look for a new version?
        NSString *APP_URL = @"http://macintosh.irczone.dk/"; // url to chat app's web site

// do you want to customise your toolbar?
    // click on the Find tab and Find "Setup The Toolbar" in This project

// do you want to change your default preffrences around?
    // search for "Setup the prefs"

// set up NickServ - it is currnetly set up for freenode.net
    // set up the keychain, what do you want to store your keychain variable under?
        NSString *KEYCHAIN_SERVICE = @"IRC: macintosh.irczone.dk";

    // what is the name of the NickServ? posible names are A, Q, NickServ, Servises
        NSString *NICKSERV_NAME = @"NickServ";

    // what string should trigger the identify sheet?
        NSString *NICKSERV_REGED_TRIGGER = @"This nick is owned by someone else. Please choose another.";

    // what string should trigger the bad password sheet?
        NSString *NICKSERV_BAD_PASSWORD = @"Password incorrect";

    // what string does the nickserv identify on? common strings include identify, authnick, and auth
        NSString *NICKSERV_IDENT = @"IDENTIFY";

    // how does nickserv take it's identifications? STR_PASS, (the above identify string followed byt the password) STR_NICK_PASS, (the above idententify string followed by the nick name and then the password) or NICK_STR_PASS (the user nickname followed by the above identify string and then the password)
        enum NickIdentStyle IDENT_STYLE = STR_PASS; // or STR_NICK_PASS or NICK_STR_PASS

// if you want to set up the register wizard for your nickserv, you are on your own.
// you probably want to register with freenode's nickserv and your own nickserv and compare strings, within this project.


// if you add to this guide, email me!

NSString * f(NSString *msgFormat, ...)
{
    va_list argList;
    NSString *msg;
    va_start(argList, msgFormat);
    msg = [[[NSString alloc] initWithFormat:msgFormat arguments:argList] autorelease];
    va_end(argList);
    return msg;
}


@implementation Globals

@end
