#import "eZoeAppDelegate.h"
#import "CatalogController.h"
#import "LauncherViewTestController.h"
#import "LauncherViewSplashController.h"
#import "TableItemTestController.h"
#import "MyWebViewController.h"
///////////////////////////////////////////////////////
#import "TabBarController.h"
#import "MenuController.h"
#import "ContentController.h"
#import "MyCustomStylesheet.h"
///////////////////////////////////////////////////////
#import "KNModalTableViewController.h"
///////////////////////////////////////////////////////
#import <Parse/Parse.h>



@interface eZoeAppDelegate ()

// Used for sending Google Analytics traffic in the background.
@property(nonatomic, assign) BOOL okToWait;
@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);

@end

@implementation eZoeAppDelegate
@synthesize sBookLastOpened;
@synthesize tazzecuid;
@synthesize sIdForRef;
@synthesize iBookLastPagePercent;
@synthesize iBookLastShowingPageIdx;
@synthesize iBookLastLang;
@synthesize iFontLastSize;
@synthesize iFontLastType;
@synthesize iBGLastType;
@synthesize iVoiceLastType;
@synthesize iVoiceLastSpeed;

@synthesize setting;
@synthesize bookList;
@synthesize pageList;

@synthesize iLastLoginStatus;

@synthesize numVersion;

@synthesize _bookpageCount;
@synthesize _bookprepareTotal;

@synthesize searchPageDictionary;
//@synthesize _pageCountLandscape;
@synthesize selectedCharacter;
@synthesize dbHelper;
@synthesize dbHelperEngDict;

@synthesize arrayIndexPagenum;
@synthesize arrayIndexText;

@synthesize dbookid;
@synthesize productBooks;


@synthesize restoredBooks;

@synthesize curtableNumberDict;
@synthesize downtableNumberDict;

@synthesize displaypageMode;
@synthesize pdfRectageMode;
@synthesize bookDirectionMode;

- (void)dealloc {
    arrayIndexPagenum = nil;
    arrayIndexText = nil;
    searchPageDictionary = nil;
    setting = nil;
    bookList = nil;
    productBooks = nil;

    restoredBooks = nil;
    curtableNumberDict = nil;
    downtableNumberDict = nil;
    pageList = nil;
    [numVersion release];
	[sBookLastOpened release];
    [tazzecuid release];
    [sIdForRef release];
    [dbookid release];
    [super dealloc];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
//parse
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //Test for 64bit
    
     /*if (sizeof(void*) == 4) {
         NSLog(@"You're running in 32 bit");
     } else if (sizeof(void*) == 8) {
         NSLog(@"You're running in 64 bit");
     }*/
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    //[GAI sharedInstance].optOut = @{kAllowTracking: @(YES)};
    // If your app runs for long periods of time in the foreground, you might consider turning
    // on periodic dispatching.  This app doesn't, so it'll dispatch all traffic when it goes
    // into the background instead.  If you wish to dispatch periodically, we recommend a 120
    // second dispatch interval.
    [GAI sharedInstance].dispatchInterval = 120;
    //[GAI sharedInstance].dispatchInterval = -1;
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    self.tracker = [[GAI sharedInstance] trackerWithName:@"StandingOrder"
                                              trackingId:kTrackingId];
    
    
    [Parse setApplicationId:@"ChSMLWtqR4jlMjESLi13uHB8xEM6ahv49ACKVG9J"
                  clientKey:@"7tX9CXryVtkOLkasJJBef0cWQ57QLlUEac6LRNpe"]; 
    
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
   
    
    displaypageMode = 0;
    pdfRectageMode = 0;
    bookDirectionMode = 0;
    
    NSString *_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    //NSLog(@"version:%@",_version);
    NSArray *lines = [_version componentsSeparatedByString:@"."];
    NSMutableString *_numversion = [NSMutableString stringWithString:@""];
    for(NSString *line in lines)
    {
        //NSLog(@"line String: %@", line); 
        [_numversion appendString:line];
    }
    
    self.dbookid = @"";
    
   
    
    self.productBooks = [NSMutableDictionary dictionaryWithCapacity:10];
    
    self.restoredBooks = [NSMutableDictionary dictionaryWithCapacity:10];
    
    self.curtableNumberDict = [NSMutableDictionary dictionaryWithCapacity:10];
    self.downtableNumberDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    self.numVersion = _numversion;
    NSLog(@"num version:%@",self.numVersion);
    [self backupFromOldVersion];
    [self initSetting];
    [self initBookList];
    [self initIndexArray];
    
    //for search
    self.searchPageDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    
    
    TTNavigator* navigator = [TTNavigator navigator];
    navigator.supportsShakeToReload = YES;
    navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    
    TTURLMap* map = navigator.URLMap;
    
    [map from:@"*" toViewController:[TTWebController class]];
    [map from:@"tt://catalog" toViewController:[CatalogController class]];
    [map from:@"tt://tableItemTest" toViewController:[TableItemTestController class]];
    //Verse search result TTTable controller
    //[map from:@"tt://verseSerchResult" toModalViewController:[KNModalTableViewController class]];
    //TabBar Test
    ///////////////////////////////////////////////////////////////////////////////////////
    [map from:@"tt://tabBar" toModalViewController:[TabBarController class]];//toSharedViewController
    // Menu controllers are also shared - we only create one to show in each tab, so opening
    // these URLs will switch to the tab containing the menu
    [map from:@"tt://menu/(initWithMenu:)" toSharedViewController:[MenuController class]];//toSharedViewController
   
    
    // A new food controllers will be created each time you open a food URL
    //[map from:@"tt://food/(initWithFood:)" toViewController:[ContentController class]];
    
    // By specifying the parent URL, we are saying that the tab containing menu #5 will be
    // selected before opening this URL, ensuring that about controllers are only pushed
    // inside the tab containing the about menu
    //[map from:@"tt://about/(initWithAbout:)" parent:@"tt://menu/5"
//toViewController:[ContentController class] selector:nil transition:0];
    
    // This is an example of how to use a transition.  Opening the nutrition page will do a flip
    //[map from:@"tt://food/(initWithNutrition:)/nutrition" toViewController:[ContentController class]
   //transition:UIViewAnimationTransitionFlipFromLeft];
    
    // The ordering controller will appear as a modal view controller, animated from bottom to top
    //[map from:@"tt://order?waitress=(initWithWaitress:)"
//toModalViewController:[ContentController class]];
    
    // This is a hash URL - it will simply invoke the method orderAction: on the order controller,
    // and it will open the order controller first if it was not already visible
    //[map from:@"tt://order?waitress=()#(orderAction:)" toViewController:[ContentController class]];
    
    // This will show the post controller to prompt to type in their order
    [map from:@"tt://order/food" toViewController:[TTPostController class]];
    
    // This will call the confirmOrder method on this app delegate and ask it to return a
    // view controller to be opened.  In this case, it will return an alert view controller. 
    // This kind of URL mapping gives you the chance to configure your controller before
    // it is opened.
    [map from:@"tt://order/confirm" toViewController:self selector:@selector(confirmOrder)];
    
    // This will simply call the sendOrder method on this app delegate
    [map from:@"tt://order/send" toObject:self selector:@selector(sendOrder)];
    //////////////////////////////////////////////////////////////////////////////////////
    
    //[map from:@"tt://launcherTest" toViewController: [LauncherViewTestController class]];
    //[map from:@"tt://launcherSplashTest" toModalViewController:[LauncherViewSplashController class]]; //toViewController
    [map from:@"tt://bookList" toModalViewController:[BookListViewController class]];
    
    //[map from:@"tt://myWebViewController" toViewController:[MyWebViewController class]];
    
    //if (![navigator restoreViewControllers]) {
     
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
        //[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://menu/1"]];
        //[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://catalog"]];//tableItemTest catalog  verseSerchResult
        //[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://launcherSplashTest"]];
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://bookList"]];
        //tabBar
    
    /*mainWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]; // Main application window
    
	booklistViewController = [[BookListViewController alloc] initWithNibName:nil bundle:nil]; // Demo controller
    
	navigationController = [[UINavigationController alloc] initWithRootViewController:booklistViewController];
    
	mainWindow.backgroundColor = [UIColor grayColor]; // Neutral gray window background color
    
	navigationController.navigationBar.barStyle = UIBarStyleBlack; navigationController.navigationBar.translucent = YES;
    
	mainWindow.rootViewController = navigationController; // Set the root view controller
    
	[mainWindow makeKeyAndVisible];
    
	return YES;*/
       
   // }
    
    
    //Init Database access helper
    dbHelper = [DBHelper newInstance];
    dbHelperEngDict = [DBHelperEngDict newInstance];

    return YES;
}

// In case the app was sent into the background when there was no network connection, we will use
// the background data fetching mechanism to send any pending Google Analytics data.  Note that
// this app has turned on background data fetching in the capabilities section of the project.
-(void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self sendHitsInBackground];
    completionHandler(UIBackgroundFetchResultNewData);
}

// We'll try to dispatch any hits queued for dispatch as the app goes into the background.
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self sendHitsInBackground];
}

// This method sends hits in the background until either we're told to stop background processing,
// we run into an error, or we run out of hits.  We use this to send any pending Google Analytics
// data since the app won't get a chance once it's in the background.
- (void)sendHitsInBackground {
    self.okToWait = YES;
    __weak eZoeAppDelegate *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTaskId =
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        weakSelf.okToWait = NO;
    }];
    
    if (backgroundTaskId == UIBackgroundTaskInvalid) {
        return;
    }
    
    self.dispatchHandler = ^(GAIDispatchResult result) {
        // If the last dispatch succeeded, and we're still OK to stay in the background then kick off
        // again.
        if (result == kGAIDispatchGood && weakSelf.okToWait ) {
            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskId];
        }
    };
    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}


//TabBar test
///////////////////////////////////////////////////////////////////////////////////////////////////

- (UIViewController*)confirmOrder {
    
    TTAlertViewController* alert = [[[TTAlertViewController alloc]
                                     initWithTitle:@"確認"
                                     message:@"是否下載?"] autorelease];
    [alert addButtonWithTitle:@"Yes" URL:@"tt://order/send"];
    [alert addCancelButtonWithTitle:@"No" URL:nil];
    return alert;
}

- (void)sendOrder {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadBook" object:nil];
    TTDINFO(@"SENDING THE ORDER...");
}

///////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
    return YES;
}

- (void)initIndexArray
{
    self.arrayIndexPagenum = [NSMutableArray arrayWithObjects: nil];
    self.arrayIndexText = [NSMutableArray arrayWithObjects: nil];
}

- (void)initBookList
{
    //NSString *dataPath = [[NSString stringWithString:@"bookInstalled.plist"] getDocPathWithPList];
    //NSString *dataPath1 = [[NSString stringWithString:@"pagelist.arc"] getDocPathWithPList];
    self.bookList = [NSMutableArray arrayWithObjects: nil];
    
    
}

- (void)moveFileFromDoc:(NSString *)fileName
{
	BOOL success;
	
    
    NSString *desPath = [fileName getDocPathWithPList];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:desPath];
	
	if(success) return;
	
	NSString *srcPath = [fileName getUserDocPathWithPList];	
    
	[fileManager moveItemAtPath:srcPath toPath:desPath error:nil];
	
}



- (void)backupFromOldVersion
{
    
    [self moveFileFromDoc:@"setting.plist"];
    [self moveFileFromDoc:@"pagelist.arc"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError * error = nil;
    NSArray *origContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory 
                                                                                error:&error];
    //找出所有含png檔名者，並搬移到private documents
    
    for (NSString* file in origContents) {
        NSString * ext = [file pathExtension];
        if ([ext compare:@"png"]==0)
        {
            
            [self moveFileFromDoc:file];
        }
    }
    
    
    
}

- (void)readSetting
{
    NSString *_sfn = @"setting.plist";
	NSString *dataPath = [_sfn getDocPathWithPList];
    
	
	//NSFileManager *fileManager = [NSFileManager defaultManager];
	setting = [NSMutableDictionary dictionaryWithContentsOfFile:dataPath];
    
    NSString *_cuid = [setting objectForKey:@"lastCuid"];
    NSLog(@"_cuid:%@",_cuid);
    tazzecuid = _cuid;
    NSLog(@"tazzecuid:%@",tazzecuid);
    
}

- (void)initSetting
{
    NSString *_sfn = @"setting.plist";
	NSString *dataPath = [_sfn getDocPathWithPList];
   // NSLog(@"dataPath:%@",dataPath);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:dataPath])
	{	
        NSString *_l = NSLocalizedString(@"lang",@"lang");
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if([_l isEqualToString:@"Traditional"])
            {
                setting = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"lastLoginStatus",@"",@"lastCuid",@"0",@"lastLang",@"26",@"lastFontSize",@"1",@"lastFontType",@"0",@"lastBGType",@"1",@"option0",@"1",@"option1",@"1",@"option2",@"1",@"option3",@"1",@"option4",@"1",@"option5",nil];
            }else
            {
                setting = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"lastLoginStatus",@"",@"lastCuid",@"1",@"lastLang",@"26",@"lastFontSize",@"1",@"lastFontType",@"0",@"lastBGType",@"1",@"option0",@"1",@"option1",@"1",@"option2",@"1",@"option3",@"1",@"option4",@"1",@"option5",nil];
            }
        }else
        {
            if([_l isEqualToString:@"Traditional"])
            {
                setting = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"lastLoginStatus",@"",@"lastCuid",@"0",@"lastLang",@"16",@"lastFontSize",@"1",@"lastFontType",@"0",@"lastBGType",@"1",@"option0",@"1",@"option1",@"1",@"option2",@"1",@"option3",@"1",@"option4",@"1",@"option5",nil];
            }else
            {
                setting = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"lastLoginStatus",@"",@"lastCuid",@"1",@"lastLang",@"16",@"lastFontSize",@"1",@"lastFontType",@"0",@"lastBGType",@"1",@"option0",@"1",@"option1",@"1",@"option2",@"1",@"option3",@"1",@"option4",@"1",@"option5",nil];
            }

        }
        
		[setting writeToFile:dataPath atomically:YES];
        
	}
	else 
	{
		setting = [NSMutableDictionary dictionaryWithContentsOfFile:dataPath];
		/*
         NSString *s = [setting objectForKey:@"playMode"];
         NSLog(@"palyMode:%@",s);
         */
	}
    
    NSString *_loginStatus = [setting objectForKey:@"lastLoginStatus"];
    iLastLoginStatus = [_loginStatus integerValue];
    
    //if(iLastLoginStatus == 1)
    NSString *_cuid = [setting objectForKey:@"lastCuid"];
    NSLog(@"_cuid:%@",_cuid);
    tazzecuid = _cuid;
    NSLog(@"tazzecuid:%@",tazzecuid);
    
    NSString *_lang = [setting objectForKey:@"lastLang"];
	iBookLastLang = [_lang integerValue];
    
    NSString *_lastFontSize = [setting objectForKey:@"lastFontSize"];
    iFontLastSize = [_lastFontSize integerValue];
    
    NSString *_lastFontType = [setting objectForKey:@"lastFontType"];
    iFontLastType = [_lastFontType integerValue];
    
    NSString *_lastBGType = [setting objectForKey:@"lastBGType"];
    iBGLastType = [_lastBGType integerValue];
    
    NSString *_lastVoiceType = [setting objectForKey:@"option0"];
    iVoiceLastType = [_lastVoiceType integerValue];
    
    NSString *_lastVoiceSpeed = [setting objectForKey:@"option1"];
    iVoiceLastSpeed = [_lastVoiceSpeed integerValue];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[DBHelper newInstance] openDatabase];
    [[DBHelperEngDict newInstance] openDatabase];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
     //[FBAppCall handleDidBecomeActiveWithSession:self.fbSession];
     [[DBHelper newInstance] openDatabase];
     [[DBHelperEngDict newInstance] openDatabase];
    
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    //[[DBHelper newInstance] closeDatabase];
      //[self.fbSession close];
}



@end
