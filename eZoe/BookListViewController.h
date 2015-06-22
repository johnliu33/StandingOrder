//
//  BookListViewController.h
//  TAAZEREADER
//
//  Created by gdx on 12/26/13.
//
//

#import "TUKit.h"
#import "BookManagerDelegate.h"
#import "MBProgressHUD.h"
#import "BookListDataSource.h"
#import "ReaderViewController.h"

#import "MFSideMenu.h"

#import "CustomSegmentedControl.h"
@class CustomSegmentedControl;
@class Reachability;

typedef enum {
    BookSortByGroup,
    BookSortByName,
    BookSortByBookId,
    BookSortBySearch
} BookListSortType;

@interface BookListViewController : UITableViewController <MBProgressHUDDelegate,TETableViewActionDelegate, BookManagerDelegate,UISearchBarDelegate,TETableViewDataSourceDelegate,ReaderViewControllerDelegate> {
    TETableViewSectionDataSource *_dataSource;
    TETableViewDelegate *_delegate;
    BOOL bLoginStatus;//johnliu
    MBProgressHUD *HUD;
    
    Reachability* hostReach;
    NSInteger iMsgCount;
    
    UIView *bg;
    UISearchBar *sb;
    UILabel *eZoeTitle;
}

@property (assign, nonatomic) BookListSortType listSortType;

//- (void)tableViewWithGroup;
//- (void)tableViewWithName;
//- (void)tableViewWithNumber;
//- (void)tableViewWithSearch:(NSString *)searchString;

@end
