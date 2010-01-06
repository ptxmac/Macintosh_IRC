//
//  Utils.h
//  ThinkSecret
//
//  Created by Nate Friedman on Mon Jun 17 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject
{
}

- (bool)isRunning:(NSString *)signiture;
- (NSString *)truncateNick:(NSString *)theNick;
- (NSString *)cleanNick:(NSString *)theNick;

@end
