
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
            
            [MKStoreManager sharedManager];
            
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
    // NSLog(@"You have changed to pick segment control index:%i",_selectedSegment);
    
    switch (_selectedSegment) {
        case 0:
            [self tableViewWithGroupByIndex];
            break;
        case 1:
            [self tableViewWithNameByIndex];
            break;
        case 2:
            [self tableViewWithNumberByIndex];
            break;
        default:
            [self tableViewWithGroupByIndex];
            break;
    }
    
    NSString *_sfn = @"setting.plist";
	NSString *settingPath = [_sfn getDocPathWithPList];
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
    
    NSString *_LastDisplayType = [NSString stringWithFormat:@"%d",_selectedSegment+1];
    [setting setObject:_LastDisplayType forKey:@"option3"]; //setting.plist option3 for table's segment change 1: Group 2: Name 3:Number 4:Recently read
    [setting writeToFile:settingPath atomically:YES];
    
    
    
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
		
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:myPath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",myPath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",myPath);
		
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

- (NSInteger *)readBookDirectionFromPlist:(NSString *)bookNumber_
{
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:myPath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",myPath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",myPath);
	}
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *pdfDir =  [bookSetting objectForKey:@"pdfDirection"];
    
    return [pdfDir integerValue];
}


- (NSInteger*)readBookNameFromPlist:(NSString *)bookNumber_
{
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:myPath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",myPath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",myPath);
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
        
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:myPath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",myPath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",myPath);
		
	}
	//[fileManager release];
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *_modifyBookNumber = [bookSetting objectForKey:@"bookNumber"];
    //NSString *_rS = [NSString stringWithFormat:@"%@ %@",[_modifyBookNumber stringByReplacingOccurrencesOfString:@"_" withString:@"-"],[bookSetting objectForKey:@"bookName"]];
    NSString *_rS = [NSString stringWithFormat:@"%@",[bookSetting objectForKey:@"bookName"]];
	return _rS;
    
}

#pragma mark - copyBookIdMethod methods
- (void)copyBookIdFromLauncher
{
    
    NSInteger _pageCount = [_launcherView.pages count];
    NSInteger _itemCount;
    NSMutableDictionary *bookIdDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    for(int p = 0; p < _pageCount; p++)
    {
        _itemCount= [[_launcherView.pages objectAtIndex:p] count] ;
        
        
        for(int i = 0; i < _itemCount; i++)
        {
            NSString *_s = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
            NSString *_sName = [self readFromPlistData:_s];
            [bookIdDict setObject:_sName forKey:_s];
        }
    }
    //NSString *_sName = [self readFromPlistData:_s];
    
    NSString *fileName = @"bookInfo.plist";
    [bookIdDict writeToFile:[fileName getDocPathWithPList] atomically:NO];
}

#pragma mark - tableSortMethod methods
- (void)tableViewWithNameByIndex
{
    
    self.variableHeightRows = YES;
    NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *fileName = @"bookInfo.plist";
    NSDictionary *bookIdDict = [NSDictionary dictionaryWithContentsOfFile:[fileName getDocPathWithPList]];
    NSArray *bookIdList = [bookIdDict allKeys];
    
    
    for(NSString *_s in bookIdList)
    {
        
        NSString *_sName = [bookIdDict objectForKey:_s];
        
        NSString* localImage = [NSString stringWithFormat:@"documents://%@l.png",_s];
        
        TTTableImageItem *item;
        
        NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
        item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
        
        
        
        item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
        //NSString *_bookName = [bookIdDict objectForKey:_s];
        [dict setObject:item forKey:_sName];
        [_dict setObject:_s forKey:_sName];
        
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
            
            //item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
            item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
            
            
            
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
            
            
            TTTableImageItem *item;
            
            NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
            
            item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
            
            if ([searchString isEqualToString:@""]) {
                NSString *_bookName = [self readBookNameFromPlist:_s];
                [dict setObject:item forKey:_bookName];
                [_dict setObject:_s forKey:_bookName];
            }else
            {
                NSRange r = [sFormatBookName rangeOfString:searchString];
                if(r.location != NSNotFound)
                {
                    NSString *_bookName = [self readBookNameFromPlist:_s];
                    [dict setObject:item forKey:_bookName];
                    [_dict setObject:_s forKey:_bookName];
                    
                }
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
    
}

- (void)tableViewWithGroupByIndex
{
    self.variableHeightRows = YES;
    
    NSMutableDictionary *dict1_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict2_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict3_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict4_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict5_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict6_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict7_ = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSMutableArray *_itemsarray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *_sectionarray = [NSMutableArray arrayWithObjects:@"福音類",@"造就類",@"教會事奉類",@"讀經類",@"傳記文學類",@"代售及期刊類",@"福音單張類",nil];
    NSString *fileName = @"bookInfo.plist";
    NSDictionary *bookIdDict = [NSDictionary dictionaryWithContentsOfFile:[fileName getDocPathWithPList]];
    NSArray *bookIdList = [bookIdDict allKeys];
    
    
    for(NSString *_s in bookIdList)
    {
        
        
        NSString *_sName = [bookIdDict objectForKey:_s];
        
        NSString* localImage = @"";//[NSString stringWithFormat:@"documents://%@l.png",_s];
        
        
        TTTableImageItem *item;
        
        
        NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
        
        item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
        item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
        
        item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];//CGSizeMake(37.5f, 52.5f)
        
        NSInteger iSec_ = [[_s substringToIndex:1] integerValue];
        NSInteger iSec2_ = [[_s substringToIndex:2] integerValue];
        
        switch (iSec_) {
            case 1:
            {
                if(iSec2_ == 12)
                    [dict7_ setObject:item forKey:_s];
                else
                    [dict1_ setObject:item forKey:_s];
                
                break;
            }
            case 2:
                [dict2_ setObject:item forKey:_s];
                break;
            case 3:
                [dict3_ setObject:item forKey:_s];
                break;
            case 4:
                [dict4_ setObject:item forKey:_s];
                break;
            case 5:
                [dict5_ setObject:item forKey:_s];
                break;
            case 6:
                [dict6_ setObject:item forKey:_s];
                break;
            case 7:
                [dict6_ setObject:item forKey:_s];
                break;
            case 8:
                [dict6_ setObject:item forKey:_s];
                break;
        }
        
    }
    
    
    [_itemsarray addObject:[self sortMyArray:dict1_]];
    [_itemsarray addObject:[self sortMyArray:dict2_]];
    [_itemsarray addObject:[self sortMyArray:dict3_]];
    [_itemsarray addObject:[self sortMyArray:dict4_]];
    [_itemsarray addObject:[self sortMyArray:dict5_]];
    [_itemsarray addObject:[self sortMyArray:dict6_]];
    [_itemsarray addObject:[self sortMyArray:dict7_]];
    
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
    
    NSArray *sortedKeys2 = [[dict3_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array2 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys2)
    {
        //NSLog(@"key:%@",key);
        [_array2 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array2 forKey:@"2"];
    
    NSArray *sortedKeys3 = [[dict4_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array3 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys3)
    {
        //NSLog(@"key:%@",key);
        [_array3 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array3 forKey:@"3"];
    
    NSArray *sortedKeys4 = [[dict5_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array4 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys4)
    {
        //NSLog(@"key:%@",key);
        [_array4 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array4 forKey:@"4"];
    
    NSArray *sortedKeys5 = [[dict6_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array5 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys5)
    {
        //NSLog(@"key:%@",key);
        [_array5 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array5 forKey:@"5"];
    
    NSArray *sortedKeys6 = [[dict7_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array6 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys6)
    {
        //NSLog(@"key:%@",key);
        [_array6 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array6 forKey:@"6"];
    
    self.dataSource = [TTSectionedDataSource dataSourceWithItems:_itemsarray sections:_sectionarray];
    
}


- (void)tableViewWithGroup
{
    self.variableHeightRows = YES;
    
    NSMutableDictionary *dict1_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict2_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict3_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict4_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict5_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict6_ = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *dict7_ = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSMutableArray *_itemsarray = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *_sectionarray = [NSMutableArray arrayWithObjects:@"福音類",@"造就類",@"教會事奉類",@"讀經類",@"傳記文學類",@"代售及期刊類",@"福音單張類",nil];
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
            
            
            TTTableImageItem *item;
            
            
            NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
            
            //item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];//CGSizeMake(37.5f, 52.5f)
            
            NSInteger iSec_ = [[_s substringToIndex:1] integerValue];
            NSInteger iSec2_ = [[_s substringToIndex:2] integerValue];
            
            switch (iSec_) {
                case 1:
                {
                    if(iSec2_ == 12)
                        [dict7_ setObject:item forKey:_s];
                    else
                        [dict1_ setObject:item forKey:_s];
                    
                    break;
                }
                case 2:
                    [dict2_ setObject:item forKey:_s];
                    break;
                case 3:
                    [dict3_ setObject:item forKey:_s];
                    break;
                case 4:
                    [dict4_ setObject:item forKey:_s];
                    break;
                case 5:
                    [dict5_ setObject:item forKey:_s];
                    break;
                case 6:
                    [dict6_ setObject:item forKey:_s];
                    break;
                case 7:
                    [dict6_ setObject:item forKey:_s];
                    break;
                case 8:
                    [dict6_ setObject:item forKey:_s];
                break;            }
            
        }
    }
    
    [_itemsarray addObject:[self sortMyArray:dict1_]];
    [_itemsarray addObject:[self sortMyArray:dict2_]];
    [_itemsarray addObject:[self sortMyArray:dict3_]];
    [_itemsarray addObject:[self sortMyArray:dict4_]];
    [_itemsarray addObject:[self sortMyArray:dict5_]];
    [_itemsarray addObject:[self sortMyArray:dict6_]];
    [_itemsarray addObject:[self sortMyArray:dict7_]];
    
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
    
    NSArray *sortedKeys2 = [[dict3_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array2 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys2)
    {
        //NSLog(@"key:%@",key);
        [_array2 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array2 forKey:@"2"];
    
    NSArray *sortedKeys3 = [[dict4_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array3 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys3)
    {
        //NSLog(@"key:%@",key);
        [_array3 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array3 forKey:@"3"];
    
    NSArray *sortedKeys4 = [[dict5_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array4 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys4)
    {
        //NSLog(@"key:%@",key);
        [_array4 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array4 forKey:@"4"];
    
    NSArray *sortedKeys5 = [[dict6_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array5 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys5)
    {
        //NSLog(@"key:%@",key);
        [_array5 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array5 forKey:@"5"];
    
    NSArray *sortedKeys6 = [[dict7_ allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array6 = [NSMutableArray arrayWithCapacity:10];
    for (NSString *key in sortedKeys6)
    {
        //NSLog(@"key:%@",key);
        [_array6 addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array6 forKey:@"6"];
    
    self.dataSource = [TTSectionedDataSource dataSourceWithItems:_itemsarray sections:_sectionarray];
    
}


- (void)tableViewWithNumberByIndex
{
    self.variableHeightRows = YES;
    NSMutableArray *_itemarray = [NSMutableArray arrayWithCapacity:10];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *fileName = @"bookInfo.plist";
    NSDictionary *bookIdDict = [NSDictionary dictionaryWithContentsOfFile:[fileName getDocPathWithPList]];
    NSArray *bookIdList = [bookIdDict allKeys];
    
    
    for(NSString *_s in bookIdList)
    {
        
        
        NSString *_sName = [bookIdDict objectForKey:_s];
        
        NSString* localImage = [NSString stringWithFormat:@"documents://%@l.png",_s];
        
        TTTableImageItem *item;
        
        NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
        
        //item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
        item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
        
        item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
        
        
        [_dict setObject:_s forKey:_sName];
        [dict setObject:item forKey:_s];
        
    }
    
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *_array = [NSMutableArray arrayWithCapacity:10];
    
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    for (NSString *key in sortedKeys)
    {
        
        [_itemarray addObject:[dict objectForKey:key]];
        [_array addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array forKey:@"0"];
    
    self.dataSource = [TTListDataSource dataSourceWithItems:_itemarray];
    
}


- (void)tableViewWithNumber
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
            
            NSString *sFormatBookName = [NSString stringWithFormat:@"%@\n%@",_sName,_s];
            
            //item = [TTTableImageItem itemWithText:_sName imageURL:localImage];
            item = [TTTableImageItem itemWithText:sFormatBookName imageURL:localImage];
            
            item.imageStyle = [TTImageStyle styleWithImage:nil defaultImage:nil contentMode:UIViewContentModeScaleToFill size:TableImageSize next:nil];
            NSString *_bookName = [self readBookNameFromPlist:_s];
            //[dict setObject:item forKey:_bookName];
            [_dict setObject:_s forKey:_bookName];
            [dict setObject:item forKey:_s];
            
        }
        
    }
    
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *_array = [NSMutableArray arrayWithCapacity:10];
    
    
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    for (NSString *key in sortedKeys)
    {
        
        [_itemarray addObject:[dict objectForKey:key]];
        [_array addObject:key];
    }
    [appDelegate.curtableNumberDict setObject:_array forKey:@"0"];
    
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
    NSInteger iIndex;
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
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];
        [self.sb setAlpha:1.0];
        
        NSArray *statusItems = [[NSArray alloc] initWithObjects:NSLocalizedString(@"書名", "BookName"),NSLocalizedString(@"書號", "BookId"), nil];
        UISegmentedControl *statusSegments_ = [[[UISegmentedControl alloc] initWithItems:statusItems] autorelease];
        statusSegments_.frame = CGRectMake(35, 200, 250, 30);
        statusSegments_.segmentedControlStyle = UISegmentedControlStyleBar;
        if( IS_IOS_7 )
            statusSegments_.tintColor = [UIColor whiteColor];
        else
            statusSegments_.tintColor = [UIColor grayColor];
        
        //Change to table view
        NSString *_sfn = @"setting.plist";
        NSString *settingPath = [_sfn getDocPathWithPList];
        NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
        NSString *_lastBookShelfDisplayType = [setting objectForKey:@"option3"];  //setting.plist option3 for table's segment change 1: Group 2: Name 3:Number 4:Recently read
        iIndex = [_lastBookShelfDisplayType integerValue]-1;
        
        statusSegments_.selectedSegmentIndex = iIndex;
        
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
    
    //[self copyBookIdFromLauncher];
    
    switch (iIndex) {
        case 0:
            [self tableViewWithGroupByIndex];//ByIndex
            break;
        case 1:
            [self tableViewWithNameByIndex];
            break;
        case 2:
            [self tableViewWithNumberByIndex];
            break;
        default:
            [self tableViewWithGroupByIndex];
            break;
    }
}

- (void)loadBookStore
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
	
    
    HUD.delegate = self;
    
    [HUD showWhileExecuting:@selector(myTaskDismiss) onTarget:self withObject:nil animated:YES];
}

- (void)mytaskDismiss
{
    sleep(1);
    [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:NO];
}

- (void)dismiss {
    //TTNavigator* navigator = [TTNavigator navigator];
    //[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
    
    /*LoadingView *loadingView =
     [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
     
     [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:2.0];*/
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    hostReach = [[Reachability reachabilityWithHostName: @"so.twgbr.org"] retain];
    iMsgCount = 0;
    [hostReach startNotifier];
    
    
	//[self updateInterfaceWithReachability: hostReach];
    
    //NetworkStatus netStatus = [curReach currentReachabilityStatus];
    //BOOL connectionRequired= [curReach connectionRequired];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
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
    
    BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:desPath]];
    if(successFix)
        NSLog(@"Can mark:%@ as don't save to iCloud",desPath);
    else
        NSLog(@"Can't mark:%@ as don't save to iCloud",desPath);
	
	//[fileManager release];
	
}

- (void)dealloc {
    [super dealloc];
    //[bg release];
    //[sb release];
    [segmentControlTitles release];
}
//

- (BOOL)shouldAutorotate
{
    NSLog(@"launch rotate");
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return  UIInterfaceOrientationPortrait;//UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationPortrait;
}


- (void)rotateView {
    /*
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
     _launcherView.currentPageIndex = 0;
     }
     */
    [self resetNavigationBar];
    [super loadView];
}

- (void)loadView {
    
	[super loadView];
    
    
    
    if(IS_IOS_7)
    {
        ios7statusbarhide = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics: UIBarMetricsDefault];
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
    NSString *_title1 = [NSString stringWithString:NSLocalizedString(@"門市", @"Cloud")];
    CGSize size = [_title1 sizeWithFont: [UIFont systemFontOfSize: 16]];
    
    EVNavigationButton *button = [[EVNavigationButton alloc] initWithFrame: CGRectMake(0, 9, MIN(13 + size.width + 5, 100), 30)];
    button.type = EVNavigationButtonTypeBack;
    [button setTitleForAllState: _title1];
    
    [button addTarget: self action: @selector(dismiss) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    
    [button release];
    
    self.navigationItem.leftBarButtonItem = [backItem autorelease];
    
    
    /*
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
     _launcherView.columnCount = 4;
     _launcherView.rowCount = 4;
     }else
     {
     
     [self.view setBackgroundColor:
     [UIColor colorWithPatternImage:
     [UIImage imageWithContentsOfFile:
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
     @"chest_iphone.png"]]]];
     [_launcherView setFrame:CGRectMake(0, 0, 320, 480-50)];
     _launcherView.columnCount = 4;
     _launcherView.rowCount = 3;
     }
     
     }*/
    
    _launcherView.backgroundColor = [UIColor clearColor];
	_launcherView.delegate = self;
    
    
    
    
    NSString *dataPath = [@"pagelist.arc" getDocPathWithPList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dataPath])
	{
        
        
        [self copyFileFromResource:@"8887l.png"];
        [self copyFileFromResource:@"voice.plist"];
        [self copyFileFromResource:@"bookInfo.plist"];
        
        
        NSArray *_initArray = [NSArray arrayWithObjects:@"8887", nil];
        
        TTLauncherItem *_it;
        NSMutableArray *_t = [NSMutableArray arrayWithObjects:nil];
        
        for(int i = 0; i < [_initArray count]; i++)
        {
            
            BOOL bcanDel = YES;
            NSString *_s = [NSString stringWithString:[_initArray objectAtIndex:i]];
            
            _it = [[[TTLauncherItem alloc] initWithTitle:@""
                                                   image:nil //[NSString stringWithFormat:@"documents://%@l.png",_s]//[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s]
                                                     URL:nil canDelete:bcanDel count:[NSString stringWithFormat:@"%d",i] bookid:_s] autorelease];
            
            
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
            
            for(int i = 0; i < [_thebookList count]; i++)
            {
                BOOL bcanDel = YES;
                NSString *_s = [NSString stringWithString:[_thebookList objectAtIndex:i]] ;
                
                //排除破音字庫
                if([_s isEqualToString:@"8889"])
                    continue;
                //NSLog(@"Book Voice:%@",_s);
                
                _it = [[[TTLauncherItem alloc] initWithTitle:@""//tt://myWebViewController?book=%@
                                                       image:nil//[NSString stringWithFormat:@"documents://%@l.png",_s]//[NSString stringWithFormat:@"tt://myWebViewController?book=%@",_s]
                                                         URL:nil canDelete:bcanDel count:[NSString stringWithFormat:@"%d",i] bookid:_s] autorelease];
                
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
    
    
    //Change to table view
    NSString *_sfn = @"setting.plist";
	NSString *settingPath = [_sfn getDocPathWithPList];
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
    NSString *_lastBookShelfDisplayType = [setting objectForKey:@"option2"];  //setting.plist option2 for table or launcher segment change 1 for launcher/2 for table
    NSInteger iIndex = 1;//[_lastBookShelfDisplayType integerValue]-1;
    
    
    [self reverseSegmentButtons:iIndex];//<--- remove the bookshelf / tableview switch here by johnliu33 201312
    [self changeTableView:iIndex];
    /*
     if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && TTIsOrienLandscape())
     {
     [self rotateView];
     }*/
}

- (void)loadPDFDocument:(NSString *)sBookNumber
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
    
	//NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    
	//NSString *filePath = [pdfs lastObject]; assert(filePath != nil); // Path to last PDF file
    NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",sBookNumber] getDocPathWithPList];
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    NSLog(@"filePath:%@",filePath);
    
	if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
	{
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:readerViewController animated:YES completion:nil];
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
NSString *sbooknumber_;
- (void)openItem:(TTLauncherView*)launcher
{
    if(IS_IOS_7)
    {
        ios7statusbarhide = YES;
        //[self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",sbooknumber_] getDocPathWithPList];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSLog(@"PDF is not yet supported");
        /*
         eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
         if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         {
         NSInteger iDir_ = [self readBookDirectionFromPlist:sbooknumber_];
         appDelegate.bookDirectionMode = iDir_;
         if(TTIsOrienLandscape())
         {
         appDelegate.displaypageMode = 1;
         }
         else
         appDelegate.displaypageMode = 0;
         }else
         appDelegate.displaypageMode = 0;
         
         [self loadPDFDocument:sbooknumber_];
         */
    }else
    {
        /* NSLog(@"selectedURL:%@",selectedURL);
         TTURLAction *action = [TTURLAction actionWithURLPath:selectedURL];
         [action setAnimated:YES];
         [[TTNavigator navigator] openURLAction:action];*/
        
        
        MyWebViewController *_mwreadViewContoller = [[[MyWebViewController alloc] initWithBookName:sbooknumber_] autorelease];
        
        
        LeftViewController* leftController = [[[LeftViewController alloc] init] autorelease];
        
        
        IIViewDeckController* deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:_mwreadViewContoller leftViewController:nil rightViewController:leftController] autorelease];
        
        
        //_mwreadViewContoller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //_mwreadViewContoller.modalPresentationStyle = UIModalPresentationFullScreen;
        
        deckController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        deckController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
        [self presentViewController:deckController animated:YES completion:nil];//_mwreadViewContoller//deckController
        //[self presentModalViewController:deckController animated:YES];
        
        
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
    NSString *_fn = [NSString stringWithFormat:@"%@_1.db",_bookid];
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


- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex
{
    /*[[[[UIAlertView alloc] initWithTitle:[segmentControlTitles objectAtIndex:segmentIndex]
     message:nil
     delegate:nil
     cancelButtonTitle:nil
     otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease] show];*/
    self.segmentIndexOfView = [NSNumber numberWithInt:segmentIndex];
    [self changeTableView:segmentIndex];
    
    NSString *_sfn = @"setting.plist";
	NSString *settingPath = [_sfn getDocPathWithPList];
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
    
    NSString *_LastDisplayType = [NSString stringWithFormat:@"%d",segmentIndex+1];
    [setting setObject:_LastDisplayType forKey:@"option2"]; //setting.plist option2 for table or launcher segment change 1 for launcher/2 for table
    [setting writeToFile:settingPath atomically:YES];
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

- (void) tableOpenItem:(NSString*)bookNumber
{
    //NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",bookNumber] getDocPathWithPList];
    //if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    // {
    //    NSLog(@"PDF is not yet supported");
    //[self loadPDFDocument:_s];
    //}else
    //{
    
    MyWebViewController *_mwreadViewContoller = [[[MyWebViewController alloc] initWithBookName:bookNumber] autorelease];
    
    
    //LeftViewController* leftController = [[[LeftViewController alloc] init] autorelease];
    
    
    IIViewDeckController* deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:_mwreadViewContoller leftViewController:nil rightViewController:nil] autorelease];
    
    
    //_mwreadViewContoller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //_mwreadViewContoller.modalPresentationStyle = UIModalPresentationFullScreen;
    
    deckController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    deckController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    
    [self presentViewController:deckController animated:YES completion:nil];//_mwreadViewContoller//deckController
    //[self presentModalViewController:deckController animated:YES];
    
    
    //}
    
}

- (void) myTask1:(NSString*)bookNumber
{
    sleep(1);
    [self performSelectorOnMainThread:@selector(tableOpenItem:) withObject:bookNumber waitUntilDone:YES];
    
}

- (void) didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if(IS_IOS_7)
    {
        ios7statusbarhide = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    NSLog(@"selected section:%i,index:%i",indexPath.section,indexPath.row);
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *_dict = appDelegate.curtableNumberDict;
    NSArray *allKey = [_dict allKeys];
    //if([allKey count] == 1)
    //{
    NSString *myKey;
    if([allKey count] == 1)
        myKey = @"0";
    else
        myKey = [NSString stringWithFormat:@"%i",indexPath.section];
    
    NSMutableArray *myArray_ = [_dict objectForKey:myKey];
    NSString *_s = [myArray_ objectAtIndex:indexPath.row];
    NSLog(@"selected index:%i,bookNumber:%@",indexPath.row,_s);
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
	
    HUD.labelText = @"載入書報中...";
    HUD.delegate = self;
    
    [HUD showWhileExecuting:@selector(myTask1:) onTarget:self withObject:_s animated:NO];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //[searchBar setShowsCancelButton:YES animated:YES];
    //self.tblView.allowsSelection = NO;
    //self.tblView.scrollEnabled = NO;
    /*
     UITextField *searchBarTextField = nil;
     for (UIView *subview in searchBar.subviews)
     {
     if ([subview isKindOfClass:[UITextField class]])
     {
     searchBarTextField = (UITextField *)subview;
     break;
     }
     }
     searchBarTextField.enablesReturnKeyAutomatically = NO;
     */
    UITextField *searchBarTextField = nil;
    if(IS_IOS_7)
    {
        for (UIView *subView in searchBar.subviews){
            for (UIView *Level2SubView in subView.subviews){
                if ([Level2SubView isKindOfClass:[UITextField class]])
                {
                    searchBarTextField = (UITextField *)Level2SubView;
                    break;
                }
            }
        }
    }else
    {
        for (UIView *subview in searchBar.subviews)
        {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)subview;
                break;
            }
        }
        
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"the search bar text is %@",searchBar.text);
    NSString *_text = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self tableViewWithSearch:_text];
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
    
    [self rotateView];
    //[self loadView];
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    //[self loadView];
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
