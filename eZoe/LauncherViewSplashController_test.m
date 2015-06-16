
//
//  LauncherViewSplashController.m
//  TTCatalog
//
//  Created by Rodrigo Mazzilli on 10/7/09.
//

#import "LauncherViewSplashController.h"
#import "YLUIKitAddition.h"
#import "eZoeAppDelegate.h"
#import "Reachability.h"
#import "LoadingView.h"
#import "MyCustomStylesheet.h"




static NSString* kLoremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do\
eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud\
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

#define BUTTON_WIDTH 54.0
#define BUTTON_SEGMENT_WIDTH 51.0
#define CAP_WIDTH 5.0

@implementation LauncherViewSplashController


- (void) configureTextField: (UITextField*) textField imageView: (UIImageView*) imageView reachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;  
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            imageView.image = [UIImage imageNamed: @"WWAN5.png"];
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            imageView.image = [UIImage imageNamed: @"Airport.png"];
            break;
        }
    }
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }
    textField.text= statusString;
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
		//[self configureTextField: remoteHostStatusField imageView: remoteHostIcon reachability: curReach];
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];
        
        //summaryLabel.hidden = (netStatus != ReachableViaWWAN);
        //NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            //baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            //baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }
        
        if(netStatus != NotReachable)
        {
            
            //[[MKStoreManager sharedManager] release];
            
            
            //[[MKStoreManager sharedManager] requestProductData];
            [self dismissModalViewControllerAnimated:NO];


        }else
        {
            //NSLog(@"Network should be prepared!");
            iMsgCount+=1;
            if(iMsgCount <= 1)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"無網路連線", @"No Network")
                                                                message:NSLocalizedString(@"Need_Network", @"Need Network")
                                                               delegate:self 
                                                      cancelButtonTitle:NSLocalizedString(@"關閉", @"Close")
                                                      otherButtonTitles: nil];
                if(![alert isVisible])
                    [alert show];
                [alert release];
                
            }
            
        }
        //summaryLabel.text= baseLabel;
    }
	/*if(curReach == internetReach)
	{	
		[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
	}
	if(curReach == wifiReach)
	{	
		[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
	}*/
	
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
 
}

- (void) pickOne:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    //label.text = [segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    NSInteger _selectedSegment = [segmentedControl selectedSegmentIndex];
    NSLog(@"You have changed to pick segment control index:%i",_selectedSegment);
    
    switch (_selectedSegment) {
        case 0:
            [self tableViewWithGroup];
            break;
        case 1:
            [self tableViewWithName];
            break;    
        case 2:
            [self tableViewWithNumber];
            break; 
        default:
             [self tableViewWithGroup];
            break;
    }
}
#pragma mark read book Plist methods
- (NSInteger *)readBookTypeFromPlist:(NSString *)bookNumber_
{
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *bookType =  [bookSetting objectForKey:@"bookType"];
    if([bookType isEqualToString:@"book"])
        return 0;
    else if([bookType isEqualToString:@"magazine"])
        return 1;
    else
        return 0;
}

- (NSArray *)readBookDirectionFromPlist:(NSString *)bookNumber_
{
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *pdfDir =  [bookSetting objectForKey:@"pdfDirection"];
    NSString *pdfWidth = [bookSetting objectForKey:@"pdfWidth"];
    NSString *pdfHeight = [bookSetting objectForKey:@"pdfHeight"];
    
    return [NSArray arrayWithObjects:pdfDir,pdfWidth,pdfHeight, nil];
}


- (NSString*)readBookNameFromPlist:(NSString *)bookNumber_
{
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{	
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    return [bookSetting objectForKey:@"bookName"];
}

- (NSString *)readFromPlistData:(NSString *)bookNumber_
{
    
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{	
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
	//[fileManager release];
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *_modifyBookNumber = [bookSetting objectForKey:@"bookNumber"];
    //NSString *_rS = [NSString stringWithFormat:@"%@ %@",[_modifyBookNumber stringByReplacingOccurrencesOfString:@"_" withString:@"-"],[bookSetting objectForKey:@"bookName"]];
    NSString *_rS = [NSString stringWithFormat:@"%@",[bookSetting objectForKey:@"bookName"]];
	return _rS;
    
}

- (void)tableViewWithName
{
    
    
    self.variableHeightRows = YES;
    NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
    NSInteger _pageCount = [_launcherView.pages count];
    NSInteger _itemCount;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for(int p = 0; p < _pageCount; p++)
    {
        _itemCount= [[_launcherView.pages objectAtIndex:p] count] ;
        for(int i = 0; i < _itemCount; i++)
        {
            NSString *_s = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
            //_firstS = [_s substringToIndex:1];
            NSString *_sName = [self readFromPlistData:_s];
            
            NSString* localImage = [NSString stringWithFormat:@"documents://%@l.png",_s];
            
            TTTableImageItem *item;
            NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",_s] getDocPathWithPList];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            }else
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
                //URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s]];
            }
            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
            NSString *_bookName = [self readBookNameFromPlist:_s];
            [dict setObject:item forKey:_bookName];
            [_dict setObject:_s forKey:_bookName];
            
        }
        
    }
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *_array = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys)
    {
        [_itemarray addObject:[dict objectForKey:key]];
        [_array addObject:[_dict objectForKey:key]];
    }
    [appDelegate.curtableNumberDict setObject:_array forKey:@"0"];
    
    self.dataSource = [TTListDataSource dataSourceWithItems:_itemarray];
}

- (void)tableViewWithSearch:(NSString *)searchString
{
    self.variableHeightRows = YES;
    NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
    NSInteger _pageCount = [_launcherView.pages count];
    NSInteger _itemCount;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for(int p = 0; p < _pageCount; p++)
    {
        _itemCount= [[_launcherView.pages objectAtIndex:p] count] ;
        for(int i = 0; i < _itemCount; i++)
        {
            NSString *_s = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
            
            NSString *_sName = [self readFromPlistData:_s];
        
            
            NSString* localImage = [NSString stringWithFormat:@"documents://%@l.png",_s];
            //TTTableImageItem *item = [TTTableImageItem itemWithText:_sName imageURL:localImage
            //                                                    URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s]];
            
            TTTableImageItem *item;
            NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",_s] getDocPathWithPList];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            }else
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
                //URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s]];
            }

            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
            
            NSRange r = [_sName rangeOfString:searchString];
            if(r.location != NSNotFound)
            {
                NSString *_bookName = [self readBookNameFromPlist:_s];
                [dict setObject:item forKey:_bookName];
                [_dict setObject:_s forKey:_bookName];
            }
            
        }
        
    }
    
    
     NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
     
     eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
     
     NSMutableArray *_array = [NSMutableArray arrayWithCapacity:10];
     for (NSString *key in sortedKeys)
     {
     [_itemarray addObject:[dict objectForKey:key]];
     [_array addObject:[_dict objectForKey:key]];
     }
     [appDelegate.curtableNumberDict setObject:_array forKey:@"0"];
     
     self.dataSource = [TTListDataSource dataSourceWithItems:_itemarray];
    
    
    /*NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
   
    for (NSString *key in sortedKeys)
    {
        //[sortedValues addObject: [dict objectForKey: key]];
        [_itemarray addObject:[dict objectForKey:key]];
    }
    
    
    
    self.dataSource = [TTListDataSource dataSourceWithItems:_itemarray];
     */
}

- (void)tableViewWithGroup
{
    self.variableHeightRows = YES;
    
    NSMutableDictionary *dict1_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict2_ = [NSMutableDictionary dictionaryWithCapacity:0];
   
    
    NSMutableArray *_itemsarray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *_sectionarray = [NSMutableArray arrayWithObjects:@"書籍",@"雜誌",nil];
    NSInteger _pageCount = [_launcherView.pages count];
    NSInteger _itemCount;
    
    for(int p = 0; p < _pageCount; p++)
    {
        _itemCount= [[_launcherView.pages objectAtIndex:p] count] ;
        
        
        for(int i = 0; i < _itemCount; i++)
        {
            NSString *_s = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
            
            NSString *_sName = [self readFromPlistData:_s];
            
            NSString* localImage = [NSString stringWithFormat:@"documents://%@l.png",_s];
            
            NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",_s] getDocPathWithPList];
            TTTableImageItem *item;
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            }else
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
                                                 // URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s,nil]];
            }
            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
            
            NSInteger iSec_ = [self readBookTypeFromPlist:_s];
            
            switch (iSec_) {
                case 0:
                {
                    [dict1_ setObject:item forKey:_s];
                    
                    break;
                }
                case 1:
                    [dict2_ setObject:item forKey:_s];
                    
                    break;
                    
                default:
                    [dict1_ setObject:item forKey:_s];
                    break;
            }
            
        }
    }
    
    [_itemsarray addObject:[self sortMyArray:dict1_]];
    [_itemsarray addObject:[self sortMyArray:dict2_]];
    
    NSArray *sortedKeys = [[dict1_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
     eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
     
     NSMutableArray *_array = [NSMutableArray arrayWithCapacity:10];
     for (NSString *key in sortedKeys)
     {
         //NSLog(@"key:%@",key);
         [_array addObject:key];
     }
     [appDelegate.curtableNumberDict setObject:_array forKey:@"0"];
    
    NSArray *sortedKeys1 = [[dict2_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array1 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys1)
    {
        //NSLog(@"key:%@",key);
        [_array1 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array1 forKey:@"1"];
    
    
    self.dataSource = [TTSectionedDataSource dataSourceWithItems:_itemsarray sections:_sectionarray];
    
}


- (void)tableViewWithNumber
{
    self.variableHeightRows = YES;
    NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
    NSInteger _pageCount = [_launcherView.pages count];
    NSInteger _itemCount;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for(int p = 0; p < _pageCount; p++)
    {
        _itemCount= [[_launcherView.pages objectAtIndex:p] count] ;
        for(int i = 0; i < _itemCount; i++)
        {
            NSString *_s = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
            //_firstS = [_s substringToIndex:1];
            NSString *_sName = [self readFromPlistData:_s];
            
            NSString* localImage = [NSString stringWithFormat:@"documents://%@l.png",_s];
            TTTableImageItem *item;
            
            NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",_s] getDocPathWithPList];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            }else
            {
                item = [TTTableImageItem itemWithText:_sName imageURL:localImage ];
                                                                //URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s]];
            }
            /*TTTableSubtextItem *item = [TTTableSubtitleItem itemWithText:_sName subtitle:@"2148"
             imageURL:localImage defaultImage:nil
             URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s] accessoryURL:nil];
             */
            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
            
            
            //[_itemarray addObject:item];
            [dict setObject:item forKey:_s];
            
            
        }
        
    }
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    for (NSString *key in sortedKeys)
    {
        //[sortedValues addObject: [dict objectForKey: key]];
        [_itemarray addObject:[dict objectForKey:key]];
    }
    
    self.dataSource = [TTListDataSource dataSourceWithItems:_itemarray];
}

- (NSArray *)sortMyArray:(NSMutableDictionary*)dict
{
    NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    for (NSString *key in sortedKeys)
    {
        //[sortedValues addObject: [dict objectForKey: key]];
        [_itemarray addObject:[dict objectForKey:key]];
    }
    return _itemarray;
}


- (void)changeTableView:(NSInteger)iType {
    NSLog(@"Chage to Table view");
    //[_launcherView removeFromSuperview];
    if(iType == 0)
    {
        [self hideKeyboard];
      
        
        [[self navigationController] setToolbarHidden:YES animated:NO];
        [_tableView removeFromSuperview];
        _tableView = nil;
       
        [_launcherView setFrame:self.view.bounds];
        //[self loadView];// problem here
        [self.sb setAlpha:0.0];
       
        
        return;
    }
    else
    {
       
        [self tableView];
        //Create an array to hold the list of bar button items
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:3];
        [self.sb setAlpha:1.0];
        /*
        //Add buttons
        
        //load the image
        UIImage *buttonImage ;

        buttonImage = [UIImage imageNamed:@"launcher.png"];
         
        //create the button and assign the image for window width and level
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(WWL:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:buttonImage forState:UIControlStateNormal];
        //set the frame of the button to the size of the image (see note below)
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        */
        
        /*
         UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
         [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, settingsButton,deleteButton,aboutButton, flexibleSpace, nil]];
         [flexibleSpace release];
        */
        //create a UIBarButtonItem with the button as a custom view
        
        NSArray *statusItems = [[NSArray alloc] initWithObjects:@"分類",@"書名", nil];
        UISegmentedControl *statusSegments_ = [[[UISegmentedControl alloc] initWithItems:statusItems] autorelease];
        statusSegments_.frame = CGRectMake(35, 200, 250, 30);
        statusSegments_.segmentedControlStyle = UISegmentedControlStyleBar;
        if( IS_IOS_7 )
            statusSegments_.tintColor = [UIColor whiteColor];
        else
            statusSegments_.tintColor = [UIColor grayColor];
        statusSegments_.selectedSegmentIndex = 0;
        
        [statusSegments_ addTarget:self
                             action:@selector(pickOne:)
                   forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:statusSegments_] autorelease];
        //UIBarButtonItem *WindowWidthZoom = [[UIBarButtonItem alloc]  initWithCustomView:statusSegments_]autorelease  ];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [items addObject:flexibleSpace];
        [items addObject:item ];
        [items addObject:flexibleSpace];
        
        [self setToolbarItems:items];
        
        [flexibleSpace release];
        
        self.navigationController.toolbar.barStyle    = UIBarStyleBlack;
        [[self navigationController] setToolbarHidden:NO animated:NO];
    }
    
    [self tableViewWithGroup];
}


- (void)dismiss {
    //TTNavigator* navigator = [TTNavigator navigator];
    //[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
    LoadingView *loadingView =
    [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
    
    [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:2.0];
   
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    hostReach = [[Reachability reachabilityWithHostName: @"www.taaze.tw"] retain];
    iMsgCount = 0;
    [hostReach startNotifier];
    
         
	//[self updateInterfaceWithReachability: hostReach];
    
    //NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //BOOL connectionRequired= [curReach connectionRequired];
  }

- (void)copyFileFromResource:(NSString *)fileName
{
	BOOL success;
	
	NSString *desPath = [fileName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:desPath];
	
	if(success) return;
	
	NSString *souPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	
	[fileManager copyItemAtPath:souPath toPath:desPath error:nil];
	
	//[fileManager release];
	
}

- (void)dealloc {
    [super dealloc];
    //[bg release];
    //[sb release];
    [segmentControlTitles release];
}

- (void)rotateView {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        if(TTIsOrienLandscape())
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest_L.png"]]]];
            _launcherView.columnCount = 5;
            _launcherView.rowCount = 4;
            [_launcherView setFrame:CGRectMake(0, 0, 1024, 748)]; //add 20120109 by johnliu33
        }else
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest.png"]]]];
            [_launcherView setFrame:CGRectMake(0, 0, 748, 1024)]; //add 20130910 by johnliu33
            _launcherView.columnCount = 4;
            _launcherView.rowCount = 5;
        }
        _launcherView.currentPageIndex = 0;
    }
    
    
}

- (void)viewDidLoad
{
    if (![@"1" isEqualToString:[[NSUserDefaults standardUserDefaults]
                                objectForKey:@"HasSeenTutorial"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"HasSeenTutorial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIImage *image = [UIImage imageNamed:@"login_cloud.png"];
        //Action here
        UIImageView *tutialImgView = [[[UIImageView alloc] initWithImage:image] autorelease];
        [tutialImgView setFrame:CGRectMake(15, 0, image.size.width, image.size.height)];
        [self.view addSubview:tutialImgView];
        self.view.userInteractionEnabled = NO;
    
    }
}


- (void)loadView {
   
	[super loadView];
    
    if(IS_IOS_7)
    {
        ios7statusbarhide = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
   
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5.0)
    {
        
        if(IS_IOS_7)
            [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"navbar7.png"] forBarMetrics: UIBarMetricsDefault];
        else
            [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics: UIBarMetricsDefault];
        
    }
     eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *_title1 = [NSString stringWithString:NSLocalizedString(@"雲端", @"Cloud")];
    CGSize size = [_title1 sizeWithFont: [UIFont systemFontOfSize: 16]];
    
    EVNavigationButton *button = [[EVNavigationButton alloc] initWithFrame: CGRectMake(0, 9, MIN(13 + size.width + 5, 100), 30)];
    button.type = EVNavigationButtonTypeBack;
    [button setTitleForAllState: _title1];
    
    [button addTarget: self action: @selector(dismiss) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    
    [button release];
    
    self.navigationItem.leftBarButtonItem = [backItem autorelease];
    
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest_L.png"]]]];	
            _launcherView.columnCount = 5;
            _launcherView.rowCount = 4;
            [_launcherView setFrame:CGRectMake(0, 0, 1024, 748-40)]; //add 20120109 by johnliu33
        }else
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest.png"]]]];
            [_launcherView setFrame:CGRectMake(0, 0, 748, 1024-60)]; //add 20130910 by johnliu33
            _launcherView.columnCount = 4;
            _launcherView.rowCount = 5;
        }
    }else
    {
        UIScreen *screen = [UIScreen mainScreen];
        if(screen.scale*screen.bounds.size.height >= 1136.0)
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest_iphone-568h@2x.png"]]]];
             [_launcherView setFrame:CGRectMake(0, 0, 320, 568-60)];
            _launcherView.columnCount = 3;
            _launcherView.rowCount = 4;
        }else
        {
            
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest_iphone.png"]]]];
            [_launcherView setFrame:CGRectMake(0, 0, 320, 480-40)];
            _launcherView.columnCount = 3;
            _launcherView.rowCount = 3;
        }

    }
    
    _launcherView.backgroundColor = [UIColor clearColor];
	_launcherView.delegate = self;
    
    
     //[self copyFileFromResource:@"25109999996l@2x.png"];
    //[self copyFileFromResource:@"00100000001.jpg"];
    //[self copyFileFromResource:@"00100000001l.png"];
    //[self copyFileFromResource:@"00100000001.plist"];
    //[self copyFileFromResource:@"00100000002.jpg"];
    //[self copyFileFromResource:@"00100000002l.png"];
    //[self copyFileFromResource:@"00100000002.plist"];
    //[self copyFileFromResource:@"00100000003.jpg"];
    //[self copyFileFromResource:@"00100000003l.png"];
    //[self copyFileFromResource:@"00100000003.plist"];
    //[self copyFileFromResource:@"00200000001.jpg"];
    //[self copyFileFromResource:@"00200000001l.png"];
    //[self copyFileFromResource:@"00200000001.plist"];
    //[self copyFileFromResource:@"00200000002.jpg"];
    //[self copyFileFromResource:@"00200000002l.png"];
    //[self copyFileFromResource:@"00200000002.plist"];
    //[self copyFileFromResource:@"00200000003.jpg"];
    //[self copyFileFromResource:@"00200000003l.png"];
    //[self copyFileFromResource:@"00300000001.plist"];
    //[self copyFileFromResource:@"00300000001.jpg"];
    //[self copyFileFromResource:@"00300000001l.png"];
    //[self copyFileFromResource:@"00300000001.plist"];
    //[self copyFileFromResource:@"00300000002.jpg"];
    //[self copyFileFromResource:@"00300000002l.png"];
    //[self copyFileFromResource:@"00300000002.plist"];
    //[self copyFileFromResource:@"00300000003.jpg"];
    //[self copyFileFromResource:@"00300000003l.png"];
    //[self copyFileFromResource:@"00300000003.plist"];
    //[self copyFileFromResource:@"00400000001.jpg"];
    //[self copyFileFromResource:@"00400000001l.png"];
    //[self copyFileFromResource:@"00400000001.plist"];
    //[self copyFileFromResource:@"00400000002.jpg"];
    //[self copyFileFromResource:@"00400000002l.png"];
    //[self copyFileFromResource:@"00400000002.plist"];
    //[self copyFileFromResource:@"00500000001.jpg"];
    //[self copyFileFromResource:@"00500000001l.png"];
    //[self copyFileFromResource:@"00500000001.plist"];
   
    [self copyFileFromResource:@"2019l.png"];
    [self copyFileFromResource:@"1044l.png"];
    [self copyFileFromResource:@"2148l.png"];
    
    
    
  
    
    
    
    
    //NSMutableArray *_thebookList = [appDelegate bookList];
    NSString *dataPath = [@"pagelist.arc" getDocPathWithPList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dataPath])
	{	
       
        
	

        NSArray *_initArray = [NSArray arrayWithObjects:@"1044",@"2019",@"2148",nil];//@"25109999999",
        //@"1222",@"1223",@"1044",@"1045",@"32396",@"11100203453",@"9789862214046",nil];//@"14100003332",
        
        TTLauncherItem *_it;
        NSMutableArray *_t = [NSMutableArray arrayWithObjects:nil];

        for(int i = 0; i < [_initArray count]; i++)
        {
            
            BOOL bcanDel = YES;
            NSString *_s = [NSString stringWithString:[_initArray objectAtIndex:i]];
            //if([_s isEqualToString:@"1221"] || [_s isEqualToString:@"1222"] || [_s isEqualToString:@"1223"] || [_s isEqualToString:@"1044"]   ||  [_s isEqualToString:@"32396"] || [_s isEqualToString:@"1045"]   || [_s isEqualToString:@"11100203453"] || [_s isEqualToString:@"9789862214046"])//||
           //     bcanDel = NO;
            
           
            //if([_s isEqualToString:@"1044"] || [_s isEqualToString:@"1045"]  || [_s isEqualToString:@"32396"] || [_s isEqualToString:@"9789862214046"])
            //{
                
                _it = [[[TTLauncherItem alloc] initWithTitle:@""
                                                      image:[NSString stringWithFormat:@"documents://%@l.png",_s]
                                                        URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s] canDelete:bcanDel count:[NSString stringWithFormat:@"%d",i] bookid:_s] autorelease];
            //}else
            //{
            //   _it = [[[TTLauncherItem alloc] initWithTitle:@""
            //                                           image:[NSString stringWithFormat:@"documents://%@l.png",_s]
            //                                             URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s] canDelete:bcanDel count:[NSString stringWithFormat:@"%d",i] bookid:_s] autorelease];
            //}

        
            [_t addObject:_it];
        }
        
        _launcherView.pages = [NSArray arrayWithObjects:_t,nil];
        [NSKeyedArchiver archiveRootObject:_launcherView.pages toFile:dataPath];
    }
    else
    {
        NSMutableArray *_thebookList= [appDelegate bookList];
        NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];

        if([_thebookList count] == 0 && [fileManager fileExistsAtPath:_dataPath])
        {
            _thebookList = nil;
            _thebookList = [NSMutableArray arrayWithContentsOfFile:_dataPath];
            [fileManager removeItemAtPath:_dataPath error:NULL];
        }
        
        _launcherView.pages = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
        if([_thebookList count] > 0)
        {
            TTLauncherItem *_it;
            //NSMutableArray *_t = [_launcherView.pages objectAtIndex:0];
            
            for(int i = 0; i < [_thebookList count]; i++)
            {
                BOOL bcanDel = YES;
                NSString *_s = [NSString stringWithString:[_thebookList objectAtIndex:i]] ;
                
                //排除破音字庫
                //if([_s isEqualToString:@"8888"])
                //    continue;
                //NSLog(@"Book Voice:%@",_s);
                
                _it = [[[TTLauncherItem alloc] initWithTitle:@""
                                                           image:[NSString stringWithFormat:@"documents://%@l.png",_s]
                                                             URL:[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s] canDelete:bcanDel count:[NSString stringWithFormat:@"%d",i] bookid:_s] autorelease];
              
                //[_t insertObject:_it atIndex:0];
                
                [_launcherView removeItem:_it animated:NO];
                

                [_launcherView addItem:_it animated:NO];
                //_it.badgeValue = @"新";
                //[_launcherView scrollToItem:_it animated:NO];
                //[_it release];
            }
            /*for(NSArray *_p in _launcherView.pages)
            {
                for(int i = 0; i < [_p count]; i++)
                {
                    TTLauncherItem *_item = [_p objectAtIndex:i];
                    NSLog(@"index:%d item count:%@ item bookid:%@",i,[_item count],[_item bookid]);
                }
            }*/

            [NSKeyedArchiver archiveRootObject:_launcherView.pages toFile:dataPath];
        }
        [appDelegate.bookList removeAllObjects]; //Why here rmoeve? 20120516 johnliu
    }
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self name:@"dissmissMyWebViewController" object:nil];
    
    [nc addObserver: self
           selector: @selector(dismissMyModalViewController)
               name: @"dissmissMyWebViewController"
             object: nil];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLauncherViewDelegate
/*- (void)loadingData
{
    HUD = [[MBProgressHUD alloc] initWithView:_launcherView.window];
    [_launcherView.window addSubview:HUD];
	
    HUD.delegate = self;
    HUD.labelText = @"Loading";
	
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    //[HUD show:YES];
   



}*/
- (void)loadPDFDocument:(NSString *)sBookNumber
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
    //NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",sBookNumber] getDocPathWithPList];
    
	eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"appDelegate.bookDirectionMode:%d",appDelegate.bookDirectionMode);
    //ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:filePath password:nil flipMode:appDelegate.bookDirectionMode];
    //ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase flipMode:0];
    //NSLog(@"filePath:%@",filePath);
    NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",sBookNumber] getDocPathWithPList];
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase flipMode:appDelegate.bookDirectionMode];
    
    NSLog(@"filePath:%@",filePath);


	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
        [self presentModalViewController:readerViewController animated:YES];
        //[self presentViewController:readerViewController animated:YES completion:nil];
        //[self presentModalViewController:readerViewController animated:YES];
        //#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
		//[[TTNavigator navigator] pushViewController:readerViewController animated:YES];
        //[[self view] addSubview:readerViewController];
        
        /*#else // present in a modal view controller
         
         readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
         readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
         
         [self presentModalViewController:readerViewController animated:YES];
         
         #endif // DEMO_VIEW_CONTROLLER_PUSH
         */
		[readerViewController release]; // Release the ReaderViewController
	}
}

- (void)openItem:(TTLauncherView*)launcher
{
    
    
    if(IS_IOS_7)
    {
        ios7statusbarhide = YES;
      
        [self setNeedsStatusBarAppearanceUpdate];
    }
    NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",sbooknumber_] getDocPathWithPList];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *bookInfo  = [self readBookDirectionFromPlist:sbooknumber_];
        NSInteger iDir_ = [[bookInfo objectAtIndex:0] integerValue];
        
        appDelegate.bookDirectionMode = iDir_;
        [self loadPDFDocument:sbooknumber_];
    }else
    {
        
        
        MyWebViewController *_mwreadViewContoller = [[[MyWebViewController alloc] initWithBookName:sbooknumber_] autorelease];
        
        
        LeftViewController* leftController = [[[LeftViewController alloc] init] autorelease];
        
        
        IIViewDeckController* deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:_mwreadViewContoller leftViewController:nil
                                                                                       rightViewController:leftController] autorelease];
        
        
        deckController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        deckController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
        [self presentViewController:deckController animated:YES completion:nil];
       
    }
    
}

- (NSArray *)_listFileInDir:(NSString *)subfilename{
	
	NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:documentsDir error];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:NULL];
    int num=[dirContents count];
    
    if (num < 1)
		return [[[NSArray alloc] init] autorelease];
	NSMutableArray *files= [[[NSMutableArray alloc] initWithCapacity:num] autorelease];
    NSString *reffilename = [NSString stringWithFormat:@"_%@",subfilename];
    
    for (NSString *tString in dirContents) {
        if ([tString hasPrefix:subfilename] || [tString hasPrefix:reffilename]) {
            
            [files addObject:tString];
            
        }
    }  
    
    return files;
}


- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item {
    
    /*NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(myThreadMainMethod)
                                                   object:nil];
    [myThread start];  // Actually create the thread
   
    */
    
    selectedURL = item.URL;
    
    //Copy old version files if the db data is not exist
    NSString *_bookid = [item bookid];
    sbooknumber_ = _bookid;
    NSString *_fn = [NSString stringWithFormat:@"%@.db",_bookid];
    //NSLog(@"file name:%@",_fn);
    NSFileManager *NSFm= [NSFileManager defaultManager];
    if(![NSFm fileExistsAtPath:[_fn getDocPathWithPList]])
    {
        
        NSArray *_filearray = [self _listFileInDir:_bookid];
        
        
        NSString *desDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
        NSString *srcDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        
        for(NSString *_f in _filearray)
        {
            NSString *srcPath= [srcDir stringByAppendingPathComponent:_f];
            NSString *desPath = [desDir stringByAppendingPathComponent:_f];
            //NSLog(@"srcPath:%@,desPath:%@",srcPath,desPath);
           
            [NSFm moveItemAtPath:srcPath toPath:desPath error:NULL];
        }
        
    }
    //////////////////////////////////////////////////////
    
    //[self.view setBackgroundColor:[UIColor clearColor]];
    iLauncherLastRotatePage = [_launcherView currentPageIndex];
 
    
    //[launcher removeFromSuperview];
    //[self loadView];
    [_launcherView setCurrentPageIndex:iLauncherLastRotatePage];
    
     
    //UINavigationBar *navbar = [self.navigationController navigationBar];
    //[navbar setAlpha:0];    //navbar消失
    //[self.view setAlpha:0.1]; //書櫃消失
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
	
   
    HUD.delegate = self;
    
   [HUD showWhileExecuting:@selector(myTask:) onTarget:self withObject:launcher animated:YES];   
    
    /*HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    
	HUD.delegate = self;
    HUD.labelText = @"Loading";
	
	// myProgressTask uses the HUD instance to update progress
    [HUD showWhileExecuting:@selector(myProgressTask:) onTarget:self withObject:launcher animated:YES];
     */
    
     
}

- (void)myProgressTask:(TTLauncherView*)launcher {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(30000);
    }
    [self performSelectorOnMainThread:@selector(openItem:) withObject:launcher waitUntilDone:NO];

}


- (void)myTask:(TTLauncherView*)launcher {
    // Do something usefull in here instead of sleeping ...
    //
     sleep(1);
    [self performSelectorOnMainThread:@selector(openItem:) withObject:launcher waitUntilDone:NO];
    
    
}

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
    //UIImage *imageUIControl = [UIImage imageNamed:@"launcher.png"];
    
    //UIBarButtonItem *_d = [UIBarButtonItem barItemWithImage:imageUIControl target:_launcherView action:@selector(endEditing)];
    //UIBarButtonItem *_d = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:_launcherView action:@selector(endEditing)] autorelease];
    NSString *_title1 = NSLocalizedString(@"確定", @"OK");//[NSString stringWithString:@"確定"];
    CGSize size = [_title1 sizeWithFont: [UIFont systemFontOfSize: 16]];
    EVNavigationButton *button = [[EVNavigationButton alloc] initWithFrame: CGRectMake(0, 9, MIN(100, size.width + 12), 30)];
    button.type = EVNavigationButtonTypeNormal;
    [button setTitleForAllState: _title1];
    [button addTarget:_launcherView action: @selector(endEditing) forControlEvents: UIControlEventTouchUpInside];
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    [button release];

	[self.navigationItem setRightBarButtonItem:[doneItem autorelease] animated:YES];

    UINavigationBar *navbar = [self.navigationController navigationBar];
    UIImageView *t;
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5.0)
        t = [[navbar subviews] objectAtIndex:0];
    else
        t = [[navbar subviews] objectAtIndex:1];
    [navbar sendSubviewToBack:t];

}



- (void)launcherView:(TTLauncherView *)launcher didRemoveItem:(TTLauncherItem *)item
{


    NSString *dataPath = [@"pagelist.arc" getDocPathWithPList];
    
    [NSKeyedArchiver archiveRootObject:_launcherView.pages toFile:dataPath];

   
    
    //NSString *_itemBookid = [item bookid];
    //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSInteger _i = [appDelegate.bookInstalledList indexOfObject:_itemBookid];
    //[appDelegate.bookInstalledList removeObjectAtIndex:_i];
    //for(NSString *_s in appDelegate.bookInstalledList)
    //    NSLog(@"book in booklist:%@",_s);
    
    //NSString *_dataPath = [[NSString stringWithString:@"bookInstalled.plist"] getDocPathWithPList];
    //[appDelegate.bookInstalledList writeToFile:_dataPath atomically:YES];

}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
    //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSMutableArray *_thepageList = [appDelegate pageList];
    //NSMutableArray *_thebookList = [appDelegate bookList];
    //NSArray *_t = _launcherView.pages;
    
    /*NSMutableArray *_thepageList = [NSMutableArray arrayWithArray:_t];
    for(NSArray *_p in _thepageList)
    {
        for(int i = 0; i < [_p count]; i++)
        {
            TTLauncherItem *_item = [_p objectAtIndex:i];
            NSLog(@"index:%d item count:%@ item bookid:%@",i,[_item count],[_item bookid]);
        }
    }*/
    /*[_thepageList removeAllObjects];
    for(NSArray *_p in _t)
    {
        
    }
    NSArray *_p1 = [_t objectAtIndex:0];
     
    [_thebookList removeAllObjects];
   
    for(int i = 0; i < [_p1 count]; i++)
    {
        TTLauncherItem *_item = [_p1 objectAtIndex:i];
        [_thebookList addObject:[_item bookid]];
        //NSLog(@"index:%d item count:%@ item bookid:%@",i,[_item count],[_item bookid]);
    }
    */
    NSString *dataPath = [@"pagelist.arc" getDocPathWithPList];

    [NSKeyedArchiver archiveRootObject:_launcherView.pages toFile:dataPath];

	[self.navigationItem setRightBarButtonItem:nil animated:YES];
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //[self.view setBackgroundColor:[UIColor clearColor]];
    //currentPage = [_launcherView currentPageIndex];
    //[_launcherView removeFromSuperview];  
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self loadView]; 
    
}*/

- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex
{
    /*[[[[UIAlertView alloc] initWithTitle:[segmentControlTitles objectAtIndex:segmentIndex]
     message:nil
     delegate:nil
     cancelButtonTitle:nil 
     otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease] show];*/
    self.segmentIndexOfView = [NSNumber numberWithInt:segmentIndex];
    [self changeTableView:segmentIndex];
}


- (void)showSpinnerInTable:(TTTableView *)tableView idxPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexpath.row:%i",indexPath.row);
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    //TTTableImageItem *cell = [tableItem 
    UIActivityIndicatorView *activityView = 
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView startAnimating];
    [cell setAccessoryView:activityView];
    //[cell setEditingAccessoryView:activityView];
    [activityView release];

   

}


- (void)showSpinnerInTable1:(NSArray *)argArray {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self showSpinnerInTable:[argArray objectAtIndex:0] 
                     idxPath:[argArray objectAtIndex:1]];
    [pool release];
}


- (void) didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
    if(IS_IOS_7)
    {
        ios7statusbarhide = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }

    //NSLog(@"selected section:%i,index:%i",indexPath.section,indexPath.row);
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *_dict = appDelegate.curtableNumberDict;
    NSArray *allKey = [_dict allKeys];

    NSString *myKey;
    if([allKey count] == 1)
        myKey = @"0";
    else
        myKey = [NSString stringWithFormat:@"%i",indexPath.section];
    
    NSMutableArray *myArray_ = [_dict objectForKey:myKey];
    NSString *_s = [myArray_ objectAtIndex:indexPath.row];
    NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",_s] getDocPathWithPList];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        
        NSArray *bookInfo  = [self readBookDirectionFromPlist:_s];
        NSInteger iDir_ = [[bookInfo objectAtIndex:0] integerValue];
        //NSInteger iWidth_ = [[bookInfo objectAtIndex:1] integerValue];
        //NSInteger iHeight_ = [[bookInfo objectAtIndex:2] integerValue];
        
        appDelegate.bookDirectionMode = iDir_;
        /*if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(((float)iWidth_/(float)iHeight_) >= 0.75)
                appDelegate.pdfRectageMode = 0;
            else
                appDelegate.pdfRectageMode = 1;
            if(TTIsOrienLandscape())
            {
                appDelegate.displaypageMode = 1;
            }
            else
            {
                appDelegate.displaypageMode = 0;
                
            }
        }else
        {
            appDelegate.displaypageMode = 0;
        }
        */
        
        [self loadPDFDocument:_s];
        
    }else
    {
        
        MyWebViewController *_mwreadViewContoller = [[[MyWebViewController alloc] initWithBookName:_s] autorelease];
        
        
        LeftViewController* leftController = [[[LeftViewController alloc] init] autorelease];
        
        
        IIViewDeckController* deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:_mwreadViewContoller leftViewController:nil
                                                                                       rightViewController:leftController] autorelease];
        
    
        
        deckController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        deckController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
        [self presentViewController:deckController animated:YES completion:nil];//_mwreadViewContoller //deckController
        
    }
     
 }

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"the search bar text is %@",searchBar.text);
    [self tableViewWithSearch:searchBar.text];
    [self hideKeyboard];
}

- (BOOL)prefersStatusBarHidden
{
    return ios7statusbarhide;//YES;
}

#pragma mark dismissModalViewController methods
- (void)dismissMyModalViewController
{
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.searchPageDictionary = nil;
    
    
    //[self dismissModalViewControllerAnimated:YES];
    //[self rotateView];
    [self loadView];
    
     [_launcherView setCurrentPageIndex:iLauncherLastRotatePage];
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    [self loadView];
    //NSLog(@"iLauncherLastRotatePage:%d",iLauncherLastRotatePage);
    [_launcherView setCurrentPageIndex:iLauncherLastRotatePage];

#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    //#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
	//[self.navigationController popViewControllerAnimated:YES];
    
    /*#else // dismiss the modal view controller
     
     [self dismissModalViewControllerAnimated:YES];
     
     #endif // DEMO_VIEW_CONTROLLER_PUSH
     */
}


@end
