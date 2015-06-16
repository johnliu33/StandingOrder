//
//  MyUIWebView.m
//  eZoe
//
//  Created by John Liu on 2011/7/1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MyUIWebView.h"
#import "MyWebViewController.h"


@implementation MyUIWebView

/*- (void)myCopy:(id)sender
{
    //[[UIPasteboard generalPasteboard] setValue:@"test" forPasteboardType:@"public.utf8-plain-text"];
    MyWebViewController *_m = (MyWebViewController*)sender;
    [_m myCopy:self];
    
}*/

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    /*if (action == @selector(copy:)) {
     return NO;
     }
     else {
     return [super canPerformAction:action withSender:sender];
     }*/
    /*if ( action == @selector(MarkTheText:) )
    {
        // logic for showing/hiding command1
        BOOL show = YES;
        return show;
    }
    
    if ( action == @selector(SearchTheText:) )
    {
        // logic for showing/hiding command2
        BOOL show = YES;
        return show;
    }
    
    if ( action == @selector(myCopy: ) )
    {
        // always show our custom "copy" command
        return YES;
    }*/   
    
    return NO;
}



- (id)init {
    if ((self = [super init])) {
        //self.title = @"Launcher";
        NSLog(@"MyWebView init");
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}
@end
