#import "TabBarController.h"
//#import "MenuController.h"
//#import "eZoeAppDelegate.h"
//#import "LoadingView.h"
@implementation TabBarController
//@synthesize LastUpdateDate;
///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)viewWillAppear:(BOOL)animated {
    //In-app purchase
    
    
    if(self.viewControllers == nil)
    {
        
        [self setTabURLs:[NSArray arrayWithObjects:@"tt://menu/1", //基本訂戶
                          @"tt://menu/6", //回復購買
                          @"tt://menu/5", //關於
                          nil]];
        /*[self setTabURLs:[NSArray arrayWithObjects:@"tt://menu/1",
                      @"tt://menu/2",
                      @"tt://menu/3",
                      @"tt://menu/6",
                      @"tt://menu/5",
                      nil]];*/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openChest) name:@"OPENCHEST" object:nil];//johnliu
    }
    
}

- (void)openChest
{
    
    [self dismissViewControllerAnimated:NO completion:nil];

    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"tt://bookList"]];
}

- (void)dealloc {
//    TT_RELEASE_SAFELY(LastUpdateDate);
    
    [super dealloc];
}

/*
-(void)reloadWeb:(UIViewController*)controller
{
   /// MenuController *_m = (MenuController*)controller;
    //[_m reloadWeb];
}

-(NSMutableString *)_dateString
{
    NSDate *today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setDateFormat:@"yyyy.MM.dd.HH"];
    NSMutableString *dateString = [NSMutableString stringWithString:[dateFormat stringFromDate:today]];
    NSLog(@"Date: %@", dateString);
    return dateString;
}*/
/*



- (void) viewDidAppear:(BOOL)animated
{
    
    NSMutableString *_myDateString = [self _dateString];
    if(LastUpdateDate == nil)
        LastUpdateDate = [[NSMutableString alloc] initWithString:@""];
    NSLog(@"LastUpdate:%@",LastUpdateDate);
    if(![_myDateString isEqualToString:LastUpdateDate])
    {
        [LastUpdateDate setString:@""];
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        
        HUD.delegate = self;
        
        [HUD showWhileExecuting:@selector(myTask1) onTarget:self withObject:nil animated:YES];  
        
        [LastUpdateDate appendString:_myDateString];
    }

}*/

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADWEB"
                                                        object:self
                                                      userInfo:nil];
}

/*
- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
    NSLog(@"Controller is selected");
}*/
/*
 - (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
 {
 if (viewController == theControllerThatNeedsToBeReloaded)
 {
 [theControllerThatNeedsToBeReloaded methodToReloadYouViewsData];
 }
 }
*/
@end
