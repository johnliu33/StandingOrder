//
//  KNModalTableViewController.h
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20.h>
#import "MyCustomDataSource.h"

@protocol TTTableViewDataSource;
@class TTActivityLabel;

@interface KNModalTableViewController : TTTableViewController <UISearchBarDelegate>{
    UISearchBar *searchBar;
    NSString *findString;
    
    NSDictionary *_bibleDict;
}
@property(nonatomic, retain)UISearchBar *searchBar;
@property(nonatomic,retain)NSString *findString;
@property(nonatomic, retain)NSDictionary *_bibleDict;

- (void)hideKeyboard;
- (void)findKeywords:(NSString *)myfindString;
- (void)findVerse:(NSString *)myfindVerse;
- (void)tableWithSearch;
- (NSString *)verseConvert:(int)book chapter:(int)chapter section:(int)section column:(int)column;
@end
