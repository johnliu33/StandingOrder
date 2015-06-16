//
//  LauncherViewSplashController.h
//  TTCatalog
//
//  Created by Rodrigo Mazzilli on 10/7/09.
//

#import <Three20/Three20.h>
#import "TTLauncherViewController.h"
#import "Global.h"
#import "EVNavigationButton.h"
#import "CustomSegmentedControl.h"
#import "MBProgressHUD.h"
#import "ReaderViewController.h"
//deck
#import "IIViewDeckController.h"
#import "LeftViewController.h"

#define TableImageSize CGSizeMake(57.12f, 80.00f)

//#import "eZoeAppDelegate.h"
@class Reachability;
@interface LauncherViewSplashController : TTLauncherViewController <TTLauncherViewDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,ReaderViewControllerDelegate>
{
    NSInteger currentPage;
    Reachability* hostReach;
    NSInteger iMsgCount;
    
    NSString *selectedURL;
    //MBProgressHUD *HUD;
    
    NSString *sbooknumber_;
   
    BOOL ios7statusbarhide;
   
}

- (NSArray *)_listFileInDir:(NSString *)subfilename;
- (void)openItem:(TTLauncherView*)launcher;
- (void)myProgressTask:(TTLauncherView*)launcher;
- (void)myTask:(TTLauncherView*)launcher;

- (NSString *)readFromPlistData:(NSString *)bookNumber_;
- (NSString *)readBookNameFromPlist:(NSString *)bookNumber_;
- (NSArray *)readBookDirectionFromPlist:(NSString *)bookNumber_;

//- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath;

//- (void)loadingData;
- (void)tableViewWithGroup;
- (void)tableViewWithName;
- (void)tableViewWithNumber;
- (void)tableViewWithSearch:(NSString *)searchString;
@end
