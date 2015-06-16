//
//  MyLauncherView.h
//  eZoe
//
//  Created by John Liu on 2011/5/13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "Global.h"
#import "eZoeAppDelegate.h"
#import <Three20/Three20.h>
#import <Foundation/Foundation.h>


@interface MyLauncherView : TTLauncherView {
    
}
- (void)removeItem:(TTLauncherItem*)item animated:(BOOL)animated;
- (NSArray *) listFileInDir:(NSString *)subfilename;
@end
