//
//  TTLauncherViewController.h
//  Three20
//
//  Created by Rodrigo Mazzilli on 9/25/09.

#import "Three20UI/TTView.h"
#import "Three20UI/TTModelViewController.h"
#import "Three20UI/TTLauncherView.h"
#import "MyWebViewController.h"
#import "MyLauncherView.h"
#import "CustomSegmentedControl.h"
#import "MyCustomDataSource.h"
#import "MBProgressHUD.h"

//#import "Three20/Three20.h"
// TODO: Adjust constants
#define	TT_LAUNCHER_SHOW_TRANSITION_DURATION	0.3
#define TT_LAUNCHER_HIDE_TRANSITION_DURATION	0.3

@protocol TTTableViewDataSource;
@class TTActivityLabel;


@interface TTLauncherViewController : TTModelViewController<UINavigationControllerDelegate,CustomSegmentedControlDelegate,UISearchBarDelegate> {
	UIView *_overlayView;
	TTView *_headerView;
	TTView *_footerView;
	//TTLauncherView *_launcherView;
    MyLauncherView *_launcherView;
    
	UINavigationController *_launcherNavigationController;
	UIViewController *_launcherNavigationControllerTopViewController;
    
    NSInteger iLauncherLastRotatePage;
    
    
    //tableview
    UITableView*  _tableView;
    UIView*       _tableBannerView;
    UIView*       _tableOverlayView;
    UIView*       _loadingView;
    UIView*       _errorView;
    UIView*       _emptyView;
    
    NSTimer*      _bannerTimer;
    
    UIView*           _menuView;
    UITableViewCell*  _menuCell;
    
    UITableViewStyle        _tableViewStyle;
    
    BOOL _variableHeightRows;
    BOOL _showTableShadows;
    
    
    UIView *bg;
    UISearchBar *sb;
    NSArray* segmentControlTitles;
    NSNumber* segmentIndexOfView;
    UILabel *eZoeTitle;
    
    id<TTTableViewDataSource> _dataSource;
    id<UITableViewDelegate>   _tableDelegate;
    
    MBProgressHUD *HUD;
    
    UIView *segmentview;
  
}
@property(nonatomic, retain) NSNumber* segmentIndexOfView;
@property(nonatomic, retain) UINavigationController *launcherNavigationController;
@property(nonatomic, readonly) MyLauncherView *launcherView;
@property(nonatomic, retain) UIView *headerView;
@property(nonatomic, retain) UIView *footerView;

@property(nonatomic,retain)UIView *bg;
@property(nonatomic,retain)UISearchBar *sb;
@property(nonatomic,retain)UILabel *eZoeTitle;

@property (nonatomic, retain) IBOutlet UITableView* tableView;

/**
 * A view that is displayed as a banner at the bottom of the table view.
 */
@property (nonatomic, retain) UIView* tableBannerView;

/**
 * A view that is displayed over the table view.
 */
@property (nonatomic, retain) UIView* tableOverlayView;

@property (nonatomic, retain) UIView* loadingView;
@property (nonatomic, retain) UIView* errorView;
@property (nonatomic, retain) UIView* emptyView;

@property (nonatomic, readonly) UIView* menuView;

/**
 * The data source used to populate the table view.
 *
 * Setting dataSource has the side effect of also setting model to the value of the
 * dataSource's model property.
 */
@property (nonatomic, retain) id<TTTableViewDataSource> dataSource;

/**
 * The style of the table view.
 */
@property (nonatomic) UITableViewStyle tableViewStyle;

/**
 * Indicates if the table should support non-fixed row heights.
 */
@property (nonatomic) BOOL variableHeightRows;

/**
 * When enabled, draws gutter shadows above the first table item and below the last table item.
 *
 * Known issues: When there aren't enough cell items to fill the screen, the table view draws
 * empty cells for the remaining space. This causes the bottom shadow to appear out of place.
 */
@property (nonatomic) BOOL showTableShadows;


/**
 * Creates an delegate for the table view.
 *
 * Subclasses can override this to provide their own table delegate implementation.
 */
- (id<UITableViewDelegate>)createDelegate;

/**
 * Sets the view that is displayed at the bottom of the table view with an optional animation.
 */
- (void)setTableBannerView:(UIView*)tableBannerView animated:(BOOL)animated;

/**
 * Shows a menu over a table cell.
 */
- (void)showMenu:(UIView*)view forCell:(UITableViewCell*)cell animated:(BOOL)animated;

/**
 * Hides the currently visible table cell menu.
 */
- (void)hideMenu:(BOOL)animated;

/**
 * Hides the keyboard
 */
- (void)hideKeyboard;

- (void)reverseSegmentButtons:(NSInteger)iIndex;


/**
 * Tells the controller that the user selected an object in the table.
 *
 * By default, the object's URLValue will be opened in TTNavigator, if it has one. If you don't
 * want this to be happen, be sure to override this method and be sure not to call super.
 */
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

/**
 * Tells the controller that the user began dragging the table view.
 */
- (void)didBeginDragging;

/**
 * Tells the controller that the user stopped dragging the table view.
 */
- (void)didEndDragging;

/**
 * The rectangle where the overlay view should appear.
 */
- (CGRect)rectForOverlayView;

/**
 * The rectangle where the banner view should appear.
 */
- (CGRect)rectForBannerView;

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;

- (void)resetNavigationBar;

@end
