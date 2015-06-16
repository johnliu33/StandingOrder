/******************************************************************************
 * Copyright (c) 2010, Maher Ali <maher.ali@gmail.com>
 * Advanced iOS 4 Programming: Developing Mobile Applications for Apple iPhone, iPad, and iPod touch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

//#import "CoreDataWrapper.h"
#import "eZoeAppDelegate.h"
#import <sqlite3.h>
#import "SearchDetailViewController.h"
/*@protocol SearchTableViewControllerDelegate

- (void) didSelectSearchItem:(NSString *)searchPercent selectedItem:(NSInteger)selectedItem;

@end*/

@interface SearchTableViewController : UITableViewController <UISearchDisplayDelegate,UISearchBarDelegate,SearchDetailViewControllerDelegate>{
  UISearchBar   *_searchBar;
  UISearchDisplayController *searchDisplayController;
  NSMutableArray *filteredListContent;
    NSMutableArray *searchedText;
  //CoreDataWrapper *cdw;
  NSArray *allStars;
    NSString *searchText;  
    
    NSMutableArray *searchlistItems;
    
    BOOL bWantBack;
    NSInteger _bookPreParePageTotal;
  id<SearchDetailViewControllerDelegate>      caller;
}
@property(nonatomic, retain) NSArray *allStars;
//@property(nonatomic, retain) CoreDataWrapper *cdw;
@property(nonatomic, retain) NSMutableArray *filteredListContent;
@property(nonatomic, retain) NSMutableArray *searchedText;
@property(nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property(nonatomic, retain) UISearchBar   *_searchBar;
@property(nonatomic, retain) NSString *searchText;
@property (nonatomic, assign) id <SearchDetailViewControllerDelegate>     caller;
@property (nonatomic, retain) NSMutableArray *searchlistItems;
-(void)searchDatabase;
@end
