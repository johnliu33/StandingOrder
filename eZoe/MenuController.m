#import "MenuController.h"
#import "SimpleController.h"
//#import "SubscriptControllerViewController.h"
//#import "TTTableImageAndButtonItem.h"
#import "MKStoreManager.h"
/*zip file*/
#import "Objective_ZipViewController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "BookManager.h"

// Private stuff
@interface MenuController()
- (void)fileFetchComplete:(ASIHTTPRequest *)request;
- (void)fileFetchFailed:(ASIHTTPRequest *)request;
@end

@implementation MenuController

@synthesize page = _page;
@synthesize webView;
@synthesize hasPackageFiles;
@synthesize packageList;

@synthesize _booktype;
@synthesize _key;
///////////////////////////////////////////////////////////////////////////////////////////////////
// private
/*- (void)loadView {
    [super loadView];
    
    self.tableView.rowHeight = 90;
}*/

- (NSString*)nameForMenuPage:(MenuPage)page {
    switch (page) {
        case MenuPageBreakfast:
            return  NSLocalizedString(@"門市首頁",@"Mainpage");
        case MenuPageLunch:
            return NSLocalizedString(@"分類瀏覽",@"Catalogue");
        case MenuPageDinner:
            return NSLocalizedString(@"書報搜尋",@"Book Search");
        case MenuPageRestore:
            return NSLocalizedString(@"回復購買",@"Restore");
        case MenuPageAbout:
            return NSLocalizedString(@"關於",@"About");
            
        default:
            return @"";
    }
}
- (NSInteger)tagForMenuPage:(MenuPage)page {
    switch (page) {
        case MenuPageBreakfast:
            return 1;
        case MenuPageLunch:
            return 2;
        case MenuPageDinner:
            return 3;
        case MenuPageRestore:
            return 5;
        case MenuPageAbout:
            return 4;
        default:
            return 1;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithMenu:(MenuPage)page {
  if (self = [super init]) {
    self.page = page;
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWeb) name:@"RELOADWEB" object:nil];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
      _page = MenuPageNone;
      
  }
  return self;
}



- (void)dealloc {
    self.packageList = nil;
    self._key = nil;
    [networkQueue reset];
	[networkQueue release];
    [_booktype release];
    
    [webView release];
    [super dealloc];
}

- (void)ASIDownload:(id)sender
{
  
	HUD.labelText = @"下載中…";
    
    UIButton *clicked = (UIButton *) sender;
    NSNumber *_n = [NSNumber numberWithInteger:clicked.tag];
    [self myTask:_n];
    //[HUD showWhileExecuting:@selector(myTask:) onTarget:self withObject:_n animated:YES];
    [HUD show:YES];
    
}

- (void)myTask:(NSNumber *)tag
{

    _key = nil;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _key = [appDelegate.restoredBooks allKeys];
    NSString *mybookid = [[_key objectAtIndex:[tag integerValue]] substringFromIndex:23];
    appDelegate.dbookid = mybookid;
    NSLog(@"mybookid will be download:%@",mybookid);
    
    if([mybookid isEqualToString:@"b8889"])
    {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"回復購買" message:@"語音朗讀套件回復成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        [alert release];
        return;
    }
    
    
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];
	}
	failed = NO;
	[networkQueue reset];
	//[networkQueue setDownloadProgressDelegate:progressIndicator];
	[networkQueue setRequestDidFinishSelector:@selector(fileFetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(fileFetchFailed:)];
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request;
    
    NSString *_id = [[mybookid substringFromIndex:1] stringByReplacingOccurrencesOfString:@"_"
                                                                                   withString:@"-"];
    
    NSString *sDownloadFile = [NSString stringWithFormat:@"http://%@/subs_product_file/%@.zip",kSiteHttpRoot,_id];
    //NSLog(@"sDownloadFile:%@",sDownloadFile);
    
	request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sDownloadFile]];
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
	[request setDownloadDestinationPath:[documentsDir stringByAppendingPathComponent:@"tempdn.zip"]];
	//[request setDownloadProgressDelegate:progressIndicator];
    [request setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
	[networkQueue addOperation:request];
	
	
	[networkQueue go];

    
}

- (void)resetPurchase {
    [[MKStoreManager sharedManager] removeSOKeychainData];
    //NSLog(@"Remove Standing Order keychanData");
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"" message:@"重設購買完成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void)restorePurchase {

    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    
    
    HUD.labelText = @"回復中…";
    [HUD show:YES];
    NSLog(@"Start restore the phurchase");
    MKStoreManager  *_storemanager = [MKStoreManager sharedManager];
    [_storemanager restorePreviousTransactionsOnComplete:^(void) {
        NSLog(@"Purchased Item Restored.");
         [HUD hide:YES];
        
        [self setPage:MenuPageRestore];
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"" message:@"購買回復完成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alertView show];

    }
     onError:^(NSError *error) {
         NSLog(@"Restore failed: %@", [error localizedDescription]);
         [HUD hide:YES];
         UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"回復失敗" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
         [alertView show];
    
     }];

   

}

- (void)fileFetchComplete:(ASIHTTPRequest *)request
{
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
    NSString *downloadfn=@"tempdn.zip";
    NSString *filePath= [documentsDir stringByAppendingPathComponent:downloadfn];
	
    Objective_ZipViewController *_unzipobj = [Objective_ZipViewController alloc];
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSString *_bid = [[appDelegate.dbookid substringFromIndex:1] stringByReplacingOccurrencesOfString:@"_"
withString:@"-"];

    [_unzipobj unzip:filePath file_id:_bid];
    [_unzipobj release];
    
    NSFileManager *NSFm= [NSFileManager defaultManager];
    [NSFm removeItemAtPath:filePath error:NULL];
    NSString *_pklistpath = [documentsDir stringByAppendingPathComponent:@"pklist.plist"];
    if([NSFm fileExistsAtPath:_pklistpath])
    {
        hasPackageFiles = YES;
        packageList = [NSMutableArray arrayWithContentsOfFile:_pklistpath];
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *_thebookList = [appDelegate bookList];
        
        for(NSString *_pk in packageList)
        {
            [_thebookList addObject:_pk];
        }
        [NSFm removeItemAtPath:_pklistpath error:NULL];
        
        
    }
    
    NSMutableArray *_thebookList = [appDelegate bookList];
    //NSMutableArray *_installedList = [appDelegate bookInstalledList];
    if(![_thebookList containsObject:_bid])
    {
        if([[_bid substringToIndex:1] isEqualToString:@"z"]) //d for debug files
        {
            if(hasPackageFiles) //package files
            {
                //NSLog(@"Package data!");
                hasPackageFiles = NO;
            }else
            {
                NSString *_bd = [_bid substringFromIndex:1];
                [_thebookList addObject:_bd];
                NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];
                [_thebookList writeToFile:_dataPath atomically:YES];
                
                
            }
        }else
        {
            if(hasPackageFiles) //package files
            {
                //NSLog(@"Package data!");
                hasPackageFiles = NO;
            }else
            {
                [_thebookList addObject:_bid];
                NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];
                [_thebookList writeToFile:_dataPath atomically:YES];
                
            }
        }
        //NSString *dataPath = [[NSString stringWithString:@"bookInstalled.plist"] getDocPathWithPList];
        //[_installedList writeToFile:dataPath atomically:YES];
    }
    //_activityLabel.isAnimating = NO;
    
    //[_activityLabel setText:NSLocalizedString(@"下載完成",@"Finish Download")];
    //TT_RELEASE_SAFELY(_downloadButton);
    //_downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:@"已安裝"];
    //[_downloadButton setTitle:NSLocalizedString(@"安裝完成",@"Finish Install") forState:UIControlStateNormal];
    //[_downloadButton set:@"grayToolbarButton:" forState:UIControlStateNormal];
    //[_downloadButton setEnabled:NO];
    //_downloadButton.userInteractionEnabled = NO;
    //[_dismissButton setEnabled:YES];
    
    
    NSLog(@"ASIDownload Complete");
    [HUD hide:YES];
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"" message:@"下載完成" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alertView show];
}

- (void)fileFetchFailed:(ASIHTTPRequest *)request
{
	if (!failed) {
        NSLog(@"ASIDownload Failed");
        [HUD hide:YES];
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"下載失敗" message:@"請關閉下載頁後，再次下載" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
            //[_activityLabel setText:NSLocalizedString(@"下載失敗",@"Fail Download")];
            //[_activityLabel setProgress: 0.0f];
            //[_downloadButton setEnabled:YES];
            //[_dismissButton setEnabled:YES];
		}
		failed = YES;
	}
}

- (void)hudWasHidden {
    // Remove HUD from screen
    [HUD removeFromSuperview];
    
    // add here the code you may need
    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// TTViewController
- (void)changeToBookShelf
{
    //NSLog(@"test");
    //HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];//self.view.window];
    //[self.view.window addSubview:HUD];
    [HUD removeFromSuperview];
    [HUD release];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"載入書櫃中...", @"Loading Shelf");
    [HUD show:NO];
    [self performSelectorInBackground:@selector(myTask2)
                           withObject:nil];
//    [HUD showWhileExecuting:@selector(myTask2) onTarget:self withObject:nil animated:NO];
    //[self performSelectorOnMainThread:@selector(openURLFromButton:) withObject:@"tt://launcherSplashTest" waitUntilDone:YES];
    //openURLFromButton:
    //@"tt://launcherSplashTest"
    //[[self class] performSelectorOnMainThread:@selector(openURLFromButton:) withObject:nil waitUntilDone:[NSThread isMainThread]];
}

- (void)myTask2
{
    sleep(1);
    [self performSelectorOnMainThread:@selector(openTask) withObject:nil waitUntilDone:YES];
    [HUD hide:NO];
}

- (void)openTask
{
    //[self dismissViewControllerAnimated:NO completion:nil];
    //[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"tt://bookList"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OPENCHEST"
                                                        object:self
                                                      userInfo:nil];
}

- (void)setPage:(MenuPage)page {
    _page = page;
    
    NSInteger _tag = [self tagForMenuPage:page];
    

    if(_tag != 4)
        self.title = [self nameForMenuPage:page];
    else
    {
        NSString *_sAbout = [NSString stringWithFormat:@"%@v%@",[self nameForMenuPage:page],[[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"]];
        self.title = _sAbout;
    }
    

    if(_tag == 1)
    {
        UIImage* image = [UIImage imageNamed:@"favorite.png"];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:image tag:_tag] autorelease];
    }
    else if(_tag == 2)
    {
        UIImage* image = [UIImage imageNamed:@"catalogue.png"];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:image tag:_tag] autorelease];
    }
    else if(_tag == 3)
    {
        UIImage* image = [UIImage imageNamed:@"search.png"];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:self.title image:image tag:_tag] autorelease];
    }else if(_tag == 4)
    {
        
        UIImage* image = [UIImage imageNamed:@"about.png"];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"關於",@"About") image:image tag:_tag] autorelease];
        
    }else if(_tag == 5)
    {
        
        UIImage* image = [UIImage imageNamed:@"restore.png"];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"回復購買",@"Restore") image:image tag:_tag] autorelease];
        
    }
    
    
    
    
    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"書櫃",@"Chest") style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(changeToBookShelf)] autorelease];
    
    _key = nil;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _key = [NSArray arrayWithArray:[appDelegate.restoredBooks allKeys]];
    
    
    
    if (_page == MenuPageRestore) {
        
        self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"回復購買",@"Chest") style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(restorePurchase)] autorelease];
        
        NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
        
        
        /* eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableDictionary *_pdict = appDelegate.productBooks;
        
        
        if([_pdict count] == 0)
        {
            NSString *_bookNamePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bookName.plist"];
            _pdict = [NSMutableDictionary dictionaryWithContentsOfFile:_bookNamePath];

        }*/
        
    
        
        TTTableControlItem* buttonItem;

         if([_key count] > 0)
         {
             for(int i = 0; i < [_key count]; i++)//NSString* _id in _key
            {
                NSString *_id = [_key objectAtIndex:i];
                
                NSString *itemCaption = _id;
                if(![[_id substringToIndex:25] isEqualToString:[NSString stringWithFormat:@"%@SO",kProductPrefix]]) {
                    NSString *_id = [_key objectAtIndex:i];
                    
                    UIButton* button = [UIButton buttonWithType:UIButtonTypeContactAdd];//UIButtonTypeRoundedRect
                    
                    [button setTitle:@"" forState:UIControlStateNormal];
                    
                    button.tag = i;
                    [button addTarget:self action:@selector(ASIDownload:) forControlEvents:UIControlEventTouchUpInside];
                    
                    NSString *urlString = [NSString stringWithFormat:@"http://%@/subs_product_desc/%@.txt",kSiteHttpRoot,[[_id substringFromIndex:24] stringByReplacingOccurrencesOfString:@"_" withString:@"-"]];
                    NSLog(@"urlString:%@",urlString);
                    
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                                    [NSURL URLWithString:urlString]];
                    
                    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
                    
                    NSString *returnData = [[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding: NSUTF8StringEncoding];
                    
                    
                    NSString *stopBefore = @"</span></b>";
                    NSRange firstRange = [returnData rangeOfString:@"<b><span class='largeText'>"];
                    NSRange secondRange = [[returnData substringFromIndex:firstRange.location + 0] rangeOfString:stopBefore];
                    NSRange finalRange = NSMakeRange(firstRange.location + firstRange.length, secondRange.location - firstRange.length);
                    
                    NSString *match =  [returnData substringWithRange:finalRange];
                    NSLog(@"Found string '%@'", match);
                    
                    NSString *itemCaption = match;
                    
                    buttonItem = [TTTableControlItem itemWithCaption:itemCaption control:button];
                    [_itemarray addObject:buttonItem];

                    /*UIButton* button = [UIButton buttonWithType:UIButtonTypeContactAdd];//UIButtonTypeRoundedRect
                
                    [button setTitle:@"" forState:UIControlStateNormal];
                
                    button.tag = i;
                    [button addTarget:self action:@selector(ASIDownload:) forControlEvents:UIControlEventTouchUpInside];
                   
                    buttonItem = [TTTableControlItem itemWithCaption:itemCaption control:button];
                    [_itemarray addObject:buttonItem];*/
                } else {
                    NSString *p_ = [_id substringFromIndex:25];
                    NSString *batch_ = NSLocalizedString(@"梯次基本訂戶購買已回復",@"Batch Restore");
                    NSString *soCaption = [NSString stringWithFormat:@"%@%@",p_,batch_];
                    
                    buttonItem = [TTTableControlItem itemWithCaption:soCaption control:nil];
                    [_itemarray addObject:buttonItem];
                }
                
                
                
            }
         }
        
         self.dataSource = [TTListDataSource dataSourceWithItems:_itemarray];

        return;
    }
    
    
    CGRect rect;
     NSInteger iOSHeightPlus = 0;
    if(IS_IOS_7)
        iOSHeightPlus = self.navigationController.navigationBar.frame.size.height;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
        {
            rect = CGRectMake(0, iOSHeightPlus, 1024, 680);
        }
        else
        {
            rect = CGRectMake(0, iOSHeightPlus, 768, 950);
        }
    }else
    {
//        if(IS_IPHONE_5)
//            rect = CGRectMake(0, iOSHeightPlus, 320, 568);
//        else
//            rect = CGRectMake(0, iOSHeightPlus, 320, 480);
        
        rect = CGRectMake(0, iOSHeightPlus, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    }
    
    //if(webView != nil)
    //    [webView release];
    TT_RELEASE_SAFELY(webView);
    // TT_RELEASE_SAFELY(_scrollView1);
    // _scrollView1 = [[UIScrollView alloc] initWithFrame:rect];
    
    //_scrollView1.contentSize = _size;
    //_scrollView1.delegate = self;
    //[self.view addSubview:_scrollView1];
    webView = [[UIWebView alloc] initWithFrame:rect];
    [self.view addSubview:webView];//_scrollView
    webView.delegate = self;
        //[webView sizeToFit];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (_page == MenuPageBreakfast) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"main_url",@"Mainpage url")];
            
            
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            
            
        } else if (_page == MenuPageLunch) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"catalogue_url",@"Catalogue url")];
            //NSString *_address = [NSString stringWithString:NSLocalizedString(@"search_url",@"Search url iphone")];
            
            
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            
        } else if (_page == MenuPageDinner) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"search_url",@"Search url")];
            
            
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            
        } else if (_page == MenuPageDessert) {
            /* self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
             @"Yum",
             [TTTableTextItem itemWithText:@"Chocolate Cake" URL:@"tt://food/cake"],
             [TTTableTextItem itemWithText:@"Apple Pie" URL:@"tt://food/pie"],
             @"Other",
             [TTTableTextItem itemWithText:@"Complaints" URL:@"tt://about/complaints"],
             nil];*/
        } else if (_page == MenuPageAbout) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"about_url",@"About url")];
            
            #ifdef DEBUG
            
            self.navigationItem.leftBarButtonItem =
            [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"重設購買",@"Reset") style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(resetPurchase)] autorelease];
            #endif
            
            NSLog(@"%@",_address);
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];        }
    }else
    {
        if (_page == MenuPageBreakfast) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"main_url_iphone",@"Mainpage url iphone")];
            
            
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            [webView loadRequest:request];
            
            //[self.webView reload];
            
            
        } else if (_page == MenuPageLunch) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"catalogue_url_iphone",@"Catalogue url iphone")];
            
            
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            
        } else if (_page == MenuPageDinner) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"search_url_iphone",@"Search url iphone")];
            
            
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
            
            
        } else if (_page == MenuPageDessert) {
            /* self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
             @"Yum",
             [TTTableTextItem itemWithText:@"Chocolate Cake" URL:@"tt://food/cake"],
             [TTTableTextItem itemWithText:@"Apple Pie" URL:@"tt://food/pie"],
             @"Other",
             [TTTableTextItem itemWithText:@"Complaints" URL:@"tt://about/complaints"],
             nil];*/
        } else if (_page == MenuPageAbout) {
            NSString *_address = [NSString stringWithString:NSLocalizedString(@"about_url_iphone",@"About url iphone")];
            
            #ifdef DEBUG
    
            self.navigationItem.leftBarButtonItem =
            [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"重設購買",@"Reset") style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(resetPurchase)] autorelease];
            #endif
            
            NSLog(@"%@",_address);
            NSURL *url = [NSURL URLWithString:_address];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webView loadRequest:request];
        }
        

        
    }
    
}

- (void)setupPopupDialog:(SimpleController *)ctrl {
    
    ctrl.modalPresentationStyle = UIModalPresentationFormSheet;
    ctrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if(UIUserInterfaceIdiomPad) {
       
        //特別去處理這種狀況
        CGFloat prefHeight =  self.view.frame.size.height * 0.7;
        CGFloat prefWidth =  self.view.frame.size.width * 0.7;
        ctrl.preferredContentSize = CGSizeMake(prefWidth, prefHeight);
        [self presentViewController:ctrl animated:NO completion:nil];
        
        ctrl.view.superview.frame = CGRectMake(0, 0, prefWidth, prefHeight);
        
        ctrl.view.superview.center = self.view.center;
        
//        [ctrl.view.superview setFrame:CGRectMake(150.0, 350.0, 600.0, 480.0)];
//        [ctrl.view.superview setBackgroundColor:nil];
//        [ctrl.view setFrame:CGRectMake(0, 0, 600, 480)];
        
    } else {
    
        ctrl.preferredContentSize = UIScreen.mainScreen.bounds.size;
        
        [self presentViewController:ctrl animated:NO completion:nil];
        
        ctrl.view.superview.frame = UIScreen.mainScreen.bounds;
        
        ctrl.view.superview.center = self.view.center;
    }

}
/////////////////////////////////////////////////
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *url=[[request URL] absoluteString];
    // url = [[ request URL] retain];
    //NSLog(@"testURL:%@",url);
    
    if([url hasPrefix:@"http://ezoe"]==YES){
        
        NSString *content=[url substringFromIndex:13];
        //NSLog(@"content String: %@", content);
        NSArray *lines = [content componentsSeparatedByString:@"&"];
        NSMutableArray *_value = [NSMutableArray arrayWithCapacity:3];
        for(NSString *line in lines)
        {
            //NSLog(@"line String: %@", line);
            NSArray *value =[line componentsSeparatedByString:@"="];
            //NSLog(@"value is: %@",  [value objectAtIndex: 1] );
            [_value addObject:[value objectAtIndex: 1]];
        }
        
        NSString *_bookid = [_value objectAtIndex:0];
        NSString *_verLimit = [_value objectAtIndex:1];
        NSString *_contentType = [_value objectAtIndex:2];
        
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *_verNow = appDelegate.numVersion;
        NSInteger ivNow = [_verNow integerValue];
        NSInteger ivRequire = [_verLimit integerValue];
        if(ivRequire > ivNow)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Need_Upgrade1", @"Need Upgrade1")
                                                            message:NSLocalizedString(@"Need_Upgrade2", @"Need Upgrade2")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"關閉", @"Close")
                                                  otherButtonTitles: nil];
            [alert show];
            [alert release];
            return NO;
        }
        
        
        
        // = [url substringFromIndex:13];
        NSLog(@"%@ %@ %@",_bookid,_verLimit,_contentType);
        SimpleController *ctrl = [[[SimpleController alloc] init] autorelease];
        ctrl.bookid = _bookid;
        if([[_bookid substringToIndex:1] isEqualToString:@"d"]) //d for debug files
        {
            NSString *_type = @"debug";
            ctrl.booktype = _type;
            //ctrl.bookid = [_bookid substringFromIndex:1];
        }else
        {
            NSString *_type = @"normal";
            ctrl.booktype = _type;
            
        }
        
        [self setupPopupDialog:ctrl];
       
        return NO;
    }else if([url hasPrefix:@"http://bass"]==YES){
        
        NSString *content=[url substringFromIndex:13];
        //NSLog(@"content String: %@", content);
        NSArray *lines = [content componentsSeparatedByString:@"&"];
        //NSMutableArray *_value = [NSMutableArray arrayWithCapacity:3];
        NSMutableDictionary *_kv = [NSMutableDictionary dictionaryWithCapacity:3];
        for(NSString *line in lines)
        {
            //NSLog(@"line String: %@", line);
            NSArray *value =[line componentsSeparatedByString:@"="];
            //NSLog(@"value is: %@",  [value objectAtIndex: 1] );
            //[_value addObject:[value objectAtIndex: 1]];
            [_kv setObject:[value objectAtIndex: 1] forKey:[value objectAtIndex: 0]];
        }
        
        NSString *_bookid = [_kv objectForKey:@"product"];//[ objectAtIndex:0];
        
        NSString *_batchNumber = [_kv objectForKey:@"batch"];//[_value objectAtIndex:1];
        NSString *_storeType = [_kv objectForKey:@"type"];//[_value objectAtIndex:2];
        
        
        
        
        
        // = [url substringFromIndex:13];
        NSLog(@"%@ %@ %@",_bookid,_batchNumber,_storeType);
        SimpleController *ctrl = [[[SimpleController alloc] init] autorelease];
        ctrl.bookid = _bookid;
        NSString *_firstWord = [_bookid substringToIndex:1];
        if([_firstWord isEqualToString:@"z"]) //d for debug files
        {
            NSString *_type = @"debug";
            ctrl.booktype = _type;
        
        }
        else
        {
            //NSString *_type = @"debug";
            NSString *_type = @"";
            if([_storeType isEqualToString:@"002"]) {
                _type = @"Subscription";
                ctrl.productid = _bookid;
            } else if([_storeType isEqualToString:@"001"]) {
                _type = @"singleBooks";
                ctrl.productid = [[NSString stringWithFormat:@"b%@",_bookid] stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
            }

            ctrl.booktype = _type;
            ctrl.storeType = _storeType;
            ctrl.batchNumber = _batchNumber;
            
        }
        
        [self setupPopupDialog:ctrl];
        
        return NO;
        
    } else if([url hasPrefix:@"http://subscode"]==YES){
        
        NSString *content=[url substringFromIndex:17];
        //NSLog(@"content String: %@", content);
        NSArray *lines = [content componentsSeparatedByString:@"&"];
        NSMutableArray *_value = [NSMutableArray arrayWithCapacity:3];
        for(NSString *line in lines)
        {
            //NSLog(@"line String: %@", line);
            NSArray *value =[line componentsSeparatedByString:@"="];
            //NSLog(@"value is: %@",  [value objectAtIndex: 1] );
            [_value addObject:[value objectAtIndex: 1]];
        }
        
        NSString *_batch = [_value objectAtIndex:0];
        NSString *_option1 = [_value objectAtIndex:1];
        NSString *_option2 = [_value objectAtIndex:2];
        NSLog(@"%@ %@ %@",_batch,_option1,_option2);
        
        
        NSString *myMsg = [NSString stringWithFormat:@"%@期兌換成功！",_batch];
        
        [MKStoreManager setObject:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"%@SO%@",kProductPrefix,_batch]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"基本訂戶兌換" message:myMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        
        
        NSString *_address = [NSString stringWithString:NSLocalizedString(@"main_url",@"Mainpage url")];
        NSURL *url = [NSURL URLWithString:_address];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView  loadRequest:request];
        
        return NO;
        
    } else if([url hasPrefix:@"http://substore"]==YES){
        
        NSString *content=[url substringFromIndex:17];
        //NSLog(@"content String: %@", content);
        NSArray *lines = [content componentsSeparatedByString:@"&"];
        NSMutableArray *_value = [NSMutableArray arrayWithCapacity:3];
        for(NSString *line in lines)
        {
            //NSLog(@"line String: %@", line);
            NSArray *value =[line componentsSeparatedByString:@"="];
            //NSLog(@"value is: %@",  [value objectAtIndex: 1] );
            [_value addObject:[value objectAtIndex: 1]];
        }
        
        NSString *_bookid = [_value objectAtIndex:0];
        NSString *_batch = [_value objectAtIndex:1];
        NSString *_contentType = [_value objectAtIndex:2];
        
        // = [url substringFromIndex:13];
        NSLog(@"%@ %@ %@",_bookid,_batch,_contentType);
        SimpleController *ctrl = [[[SimpleController alloc] init] autorelease];
        ctrl.bookid = _bookid;
        ctrl.productid = _bookid;
        NSString *_firstWord = [_bookid substringToIndex:1];
        if([_firstWord isEqualToString:@"z"]) //d for debug files
        {
            NSString *_type = @"debug";
            ctrl.booktype = _type;
            
        }
        else
        {
            //SString *_type = @"debug";
            //NSString *_type = @"singlebook";
            NSString *_type = @"basicSubs";
            ctrl.booktype = _type;
            
        }
        
        [self setupPopupDialog:ctrl];
        
        return NO;
        
    } else if([url hasPrefix:@"http://link"]==YES){
        
        NSString *content=[url substringFromIndex:13];
        //NSLog(@"content String: %@", content);
        NSArray *lines = [content componentsSeparatedByString:@"&"];
        NSMutableArray *_value = [NSMutableArray arrayWithCapacity:3];
        for(NSString *line in lines)
        {
            //NSLog(@"line String: %@", line);
            NSArray *value =[line componentsSeparatedByString:@"="];
            //NSLog(@"value is: %@",  [value objectAtIndex: 1] );
            [_value addObject:[value objectAtIndex: 1]];
        }
        
        NSString *_selfhttp = [_value objectAtIndex:0];
        NSString *_verLimit = [_value objectAtIndex:1];
        NSString *_contentType = [_value objectAtIndex:2];
        NSLog(@"%@ %@ %@",_selfhttp,_verLimit,_contentType);
        
        NSString *_myurl = [NSString stringWithFormat:@"https://%@",_selfhttp];
        NSLog(@"url:%@",_myurl);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_myurl]];
        //[[TTNavigator navigator] openURLs:_myurl];
        
        return NO;
    }
    else return YES;
}

//for 6.0+
- (NSUInteger)supportedInterfaceOrientations{
    //if (landscapeModeOn) {
    //    return UIInterfaceOrientationMaskAllButUpsideDown;
   // } else {
        return UIInterfaceOrientationMaskPortrait;
   // }
}

- (BOOL)shouldAutorotate{
    UIInterfaceOrientation ori = [UIDevice currentDevice].orientation;
  //  if (landscapeModeOn) {
   //     return ori != UIInterfaceOrientationPortraitUpsideDown;
    //} else {
    return  NO;
   // }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)reloadWeb
{
    CGRect rect;
    NSUInteger iPlusHeight = 0;
    if(IS_IOS_7)
        iPlusHeight = 0;
    
     rect = CGRectMake(0, iPlusHeight, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
//        if(TTIsOrienLandscape())
//        {
//            rect = CGRectMake(0, 0+iPlusHeight, 1024, 680);
//            
//        }
//        else
//        {
//            rect = CGRectMake(0, 0+iPlusHeight, 768, 950);
//            
//        }
    }else
    {
        /*if(TTIsOrienLandscape())
         {
         rect = CGRectMake(0, 0, 480, 320);
         
         }
         else
         {*/
        rect = CGRectMake(0, iPlusHeight, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        //}
        
    }
    webView.frame = rect;
    [webView reload];
    
    
    
    //[self setPage:MenuPageLunch];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //[self setPage:MenuPageLunch];

    //[self setPage:_page];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self reloadWeb];
        if([self.presentedViewController isKindOfClass:SimpleController.class]) {
            SimpleController *vc = (SimpleController *)self.presentedViewController;
            CGSize frame = vc.preferredContentSize;
            vc.preferredContentSize = CGSizeMake(frame.height, frame.width);
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    
    if(_page == MenuPageRestore)
        [super viewWillAppear:YES];
    else
    {
              //[self setPage:_page];
    }
}


@end
