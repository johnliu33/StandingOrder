//
//  BookListViewController.m
//  TAAZEREADER
//
//  Created by gdx on 12/26/13.
//
//

#import "BookListViewController.h"
#import "BookManager.h"
#import "BookListItem.h"
#import "BookListDelegate.h"
#import "eZoeAppDelegate.h"//johnliu
//login
#import "EVNavigationButton.h"//johnliu

//reader
#import "MyWebViewController.h"
#import "IIViewDeckController.h"

#import "Reachability.h"
#import "LoadingView.h"

#import "MyLauncherView.h"


#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"


#define BUTTON_WIDTH 54.0
#define BUTTON_SEGMENT_WIDTH 51.0
#define CAP_WIDTH 5.0



@interface BookListViewController ()

@end

@implementation BookListViewController


#pragma mark - Reachability
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
            
            //[self dismissModalViewControllerAnimated:NO];
            [self dismissViewControllerAnimated:NO completion:nil];
            
            
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


#pragma mark - Private methods

- (void)requestBookListTask
{
	     BookManager *bookManager = [BookManager sharedManager];
	    [bookManager requestBookList];
}

- (void)tempParseBookPlist {
 
    NSString *fileName = @"bookInfo.plist";
    NSDictionary *bookIdDict = [NSDictionary dictionaryWithContentsOfFile:[fileName getDocPathWithPList]];
    NSArray *bookIdList = [bookIdDict allKeys];
    
    
    NSMutableArray *bookList = [NSMutableArray arrayWithCapacity:10];
    
    for(NSString *bookId in bookIdList)
    {
        NSMutableDictionary *newBookDict = [NSMutableDictionary dictionaryWithCapacity:10];
        NSString *_sName = [bookIdDict objectForKey:bookId];

        NSString *secOfBook = [bookId substringToIndex:2];
        if([secOfBook isEqualToString:@"12"])
            secOfBook = @"9";
        [newBookDict setObject:[secOfBook substringToIndex:1] forKey:@"section"];
        [newBookDict setObject:bookId forKey:@"bookId"];
        [newBookDict setObject:_sName forKey:@"title"];
        
        [bookList addObject:newBookDict];
        
    }
    
    NSString *newfileName = @"bookListInfo.plist";
    [bookList writeToFile:[newfileName getDocPathWithPList] atomically:NO];
}

- (void)loadBooks:(BookListSortType)sortType {
    //[self tempParseBookPlist];
    [HUD release];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = self;
    
    HUD.labelText = @"門市載入中";
    
    BookManager *bookManager = [BookManager sharedManager];
    bookManager.delegate = self;
    //[HUD showWhileExecuting:@selector(requestBookListTask) onTarget:self withObject:nil animated:YES];
    [HUD show:NO];
    [self requestBookListTask];
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iLastLoginStatus == 1)
        bLoginStatus = YES;
    else
    {
        bLoginStatus = NO;
        [HUD hide:NO];
    }
    if(bLoginStatus)
        self.navigationItem.leftBarButtonItem = nil;
    
    [self refreshBooks:sortType searchText:@""];
}

- (void)refreshBooks:(BookListSortType)listSortType searchText:(NSString*)seachText {
    
    if(bLoginStatus)
 		self.navigationItem.leftBarButtonItem.enabled = NO;

    
    _listSortType = listSortType;
    switch (listSortType) {
        case BookSortByGroup:
        {
            [self refreshByGroup];
            break;
        }
        case BookSortByName:
        {
            [self refreshByName];
            break;
        }
        case BookSortByBookId:
        {
            [self refreshByBookId];
            break;
        }
        case BookSortBySearch:
        {
            [self refreshBySearch:seachText];
        }
    }

    
    
    
    [self.tableView reloadData];
}
#pragma mark - refreshByBookId
- (void)refreshByName{
    //johnliu
    
    BookManager *bookManager = [BookManager sharedManager];
    [bookManager refreshBooksByName];
    
    TETableViewSection *gospelSection = [TETableViewSection new];
    NSInteger bookCount = [bookManager.gospelBooks count];
    gospelSection.title = [NSString stringWithFormat:@"書名排序：共%d本",bookCount];
    TETableViewSection *createSection = [TETableViewSection new];
    createSection.title = [NSString stringWithFormat:@"書名排序：共%d本",bookCount];
    
    
    NSMutableArray *gospelBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelBookItems addObject:item];
    }
    
    NSMutableArray *createBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.createBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [createBookItems addObject:item];
    }
    
    
    
    
    gospelSection.items = gospelBookItems;
    createSection.items = createBookItems;
    
    
    _dataSource.items = @[gospelSection, createSection];
    
}

#pragma mark - refreshByBookId
- (void)refreshByBookId{
    //johnliu
    
    BookManager *bookManager = [BookManager sharedManager];
    [bookManager refreshBooksByID];
    
    TETableViewSection *gospelSection = [TETableViewSection new];
    NSInteger bookCount = [bookManager.gospelBooks count];
    gospelSection.title = [NSString stringWithFormat:@"書號排序：共%d本",bookCount];
    TETableViewSection *createSection = [TETableViewSection new];
    createSection.title = [NSString stringWithFormat:@"書號排序：共%d本",bookCount];

    
    NSMutableArray *gospelBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelBookItems addObject:item];
    }
    
    NSMutableArray *createBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.createBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [createBookItems addObject:item];
    }
   
    
 
    
    gospelSection.items = gospelBookItems;
    createSection.items = createBookItems;
  

    _dataSource.items = @[gospelSection, createSection];

}
#pragma mark - refreshByGroup
- (void)refreshByGroup{
    //johnliu
    
    BookManager *bookManager = [BookManager sharedManager];
    [bookManager refreshBooksByGroup];
    
    TETableViewSection *gospelSection = [TETableViewSection new];
    gospelSection.title = @"福音類";
    TETableViewSection *createSection = [TETableViewSection new];
    createSection.title = @"造就類";
    TETableViewSection *churchSection = [TETableViewSection new];
    churchSection.title = @"教會事奉類";
    TETableViewSection *bibleSection = [TETableViewSection new];
    bibleSection.title = @"讀經類";
    TETableViewSection *biologySection = [TETableViewSection new];
    biologySection.title = @"傳記文學類";
    TETableViewSection *resalesSection = [TETableViewSection new];
    resalesSection.title = @"代售及期刊類";
    TETableViewSection *gospelPaperSection = [TETableViewSection new];
    gospelPaperSection.title = @"福音單張類";
    
    NSMutableArray *gospelBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelBookItems addObject:item];
    }
    
    NSMutableArray *createBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.createBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [createBookItems addObject:item];
    }
    
    NSMutableArray *churchBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.churchBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [churchBookItems addObject:item];
    }
    
    NSMutableArray *bibleBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.bibleBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [bibleBookItems addObject:item];
    }
    
    NSMutableArray *biologyBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.biologyBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [biologyBookItems addObject:item];
    }
    
    NSMutableArray *resalesBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.resalesBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [resalesBookItems addObject:item];
    }
    
    NSMutableArray *gospelPaperBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelPaperBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelPaperBookItems addObject:item];
    }
    
    gospelSection.items = gospelBookItems;
    createSection.items = createBookItems;
    churchSection.items = churchBookItems;
    bibleSection.items = bibleBookItems;
    biologySection.items = biologyBookItems;
    resalesSection.items = resalesBookItems;
    gospelPaperSection.items = gospelPaperBookItems;
    _dataSource.items = @[gospelSection, createSection, churchSection,bibleSection,biologySection,resalesSection,gospelPaperSection];

}

#pragma mark - refreshBySearch
- (void)refreshBySearch:(NSString*)searchText{
       
    BookManager *bookManager = [BookManager sharedManager];
    if([[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
        [bookManager refreshBooksByID];
    else
        [bookManager refreshBooksBySearch:searchText];
    
    NSInteger bookCount = [bookManager.gospelBooks count];
    TETableViewSection *gospelSection = [TETableViewSection new];
    gospelSection.title = [NSString stringWithFormat:@"共搜尋到%d本",bookCount];
    TETableViewSection *createSection = [TETableViewSection new];
    createSection.title = [NSString stringWithFormat:@"共搜尋到%d本",bookCount];
    
    NSMutableArray *gospelBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelBookItems addObject:item];
    }
    
    NSMutableArray *createBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.createBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [createBookItems addObject:item];
    }
    
    
    gospelSection.items = gospelBookItems;
    createSection.items = createBookItems;
    
    _dataSource.items = @[gospelSection, createSection];
    
}


#pragma mark - BookManagerDelegate

- (void)bookListDidDownload:(BookManager *)manager {
    [self refreshBooks:0 searchText:@""];
    [HUD hide:NO];
}

- (void)bookListDidDownloadFail:(BookManager *)manager error:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                    message:@"書籍載入失敗"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"確定", nil];
    [alert show];
    [alert release];
}

#pragma mark - search bar method
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
    
    [self refreshBooks:BookSortBySearch searchText:_text];
    //[self tableViewWithSearch:_text];
    [self hideKeyboard];
}

- (void)hideKeyboard {
	// Hide keyboard if visible
	UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] findFirstResponder];
	[firstResponder resignFirstResponder];
    
}

#pragma mark - TETableViewDatasourceActionDelegate

- (void)dataSource:(TETableViewSectionDataSource  *)dataSource withTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        NSLog(@"Delete!");
        
        //id deleteItem = [dataSource itemForIndexPath:indexPath];
        
     
        [self DeleteByGroup:indexPath];
        //[tableView reloadData];
        //dataSource
        //[tableView removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
     
     }
    
}

- (void)DeleteByGroup:(NSIndexPath *)indexPath{
    
    TETableViewSection *section = [_dataSource.items objectAtIndex:indexPath.section];
    //section.items
    
    
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:section.items];
    
    BookListItem *item = [newItems objectAtIndex:indexPath.row];
    
    NSDictionary *bookInfo = [item bookInfo];
    NSString *bookId = [bookInfo objectForKey:@"bookId"];
    [[BookManager sharedManager] deleteBook:bookId];
    [newItems removeObjectAtIndex:indexPath.row];
    
    TETableViewSection *newSection = [TETableViewSection new];
    newSection.title = section.title;
    newSection.items = newItems;
    
    NSMutableArray *newDatasource = [NSMutableArray arrayWithArray:_dataSource.items];
    
    [newDatasource removeObjectAtIndex:indexPath.section];
    [newDatasource insertObject:newSection atIndex:indexPath.section];
    
    
    
    _dataSource.items = newDatasource;
    
    //johnliu
    
    //NSLog(@"deleteItem:section%i",deleteItem )
    //BookManager *bookManager = [BookManager sharedManager];
    //[bookManager refreshBooksByGroup];
    
    
    /*
    TETableViewSection *gospelSection = [TETableViewSection new];
    gospelSection.title = @"福音類";
    TETableViewSection *createSection = [TETableViewSection new];
    createSection.title = @"造就類";
    TETableViewSection *churchSection = [TETableViewSection new];
    churchSection.title = @"教會事奉類";
    TETableViewSection *bibleSection = [TETableViewSection new];
    bibleSection.title = @"讀經類";
    TETableViewSection *biologySection = [TETableViewSection new];
    biologySection.title = @"傳記文學類";
    TETableViewSection *resalesSection = [TETableViewSection new];
    resalesSection.title = @"代售及期刊類";
    TETableViewSection *gospelPaperSection = [TETableViewSection new];
    gospelPaperSection.title = @"福音單張類";
    
    NSMutableArray *gospelBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelBookItems addObject:item];
        //[gospelBookItems removeAllObjects];
    }
    
    NSMutableArray *createBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.createBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [createBookItems addObject:item];
    }
    
    NSMutableArray *churchBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.churchBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [churchBookItems addObject:item];
    }
    
    NSMutableArray *bibleBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.bibleBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [bibleBookItems addObject:item];
    }
    
    NSMutableArray *biologyBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.biologyBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [biologyBookItems addObject:item];
    }
    
    NSMutableArray *resalesBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.resalesBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [resalesBookItems addObject:item];
    }
    
    NSMutableArray *gospelPaperBookItems = [NSMutableArray new];
    for (NSDictionary *bookInfo in bookManager.gospelPaperBooks) {
        BookListItem *item = [[[BookListItem alloc] initWithBookInfo:bookInfo] autorelease];
        [gospelPaperBookItems addObject:item];
    }
    
    gospelSection.items = gospelBookItems;
    createSection.items = createBookItems;
    churchSection.items = churchBookItems;
    bibleSection.items = bibleBookItems;
    biologySection.items = biologyBookItems;
    resalesSection.items = resalesBookItems;
    gospelPaperSection.items = gospelPaperBookItems;
    _dataSource.items = @[gospelSection, createSection, churchSection,bibleSection,biologySection,resalesSection,gospelPaperSection];
    */
}



- (void)dataSource:(TETableViewSectionDataSource  *)dataSource withTableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"Move");
}

#pragma mark - TETableViewActionDelegate

- (void)tableView:(UITableView *)tableView didSelectItem:(id<TETableViewItem>)item atIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - segment method
- (void)changeTableView:(NSInteger)iType {
    NSLog(@"Chage to Table view");
    //[_launcherView removeFromSuperview];
    NSInteger iIndex;
    if(iType == 0)
    {
        //[self hideKeyboard];
        
        
        /*[[self navigationController] setToolbarHidden:YES animated:NO];
        [_tableView removeFromSuperview];
        _tableView = nil;
        
        [_launcherView setFrame:self.view.bounds];
        //[self loadView];// problem here
        [self.sb setAlpha:0.0];
        
        
        return;*/
    }
    else
    {
        
        //[self tableView];
        //Create an array to hold the list of bar button items
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:2];
        //[self.sb setAlpha:1.0];
        
        NSArray *statusItems = [[NSArray alloc] initWithObjects:@"書名",@"書號", nil];
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
           [self loadBooks:1];
            break;
        case 1:
            [self loadBooks:2];
            break;
        //case 2:
        //    [self loadBooks:2];
        //    break;
        default:
            [self loadBooks:1];
            break;
    }
}

- (void) pickOne:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger _selectedSegment = [segmentedControl selectedSegmentIndex];
    NSLog(@"You have changed to pick segment control index:%i",_selectedSegment);
    
    switch (_selectedSegment) {
        case 0:
            [self loadBooks:1];//0
            break;
        case 1:
            [self loadBooks:2]; //
            break;
        //case 2:
        //    [self loadBooks:2];
        //    break;
        default:
            [self loadBooks:1];
            break;
    }

    NSString *_sfn = @"setting.plist";
	NSString *settingPath = [_sfn getDocPathWithPList];
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithContentsOfFile:settingPath];
    
    NSString *_LastDisplayType = [NSString stringWithFormat:@"%d",_selectedSegment+1];
    [setting setObject:_LastDisplayType forKey:@"option3"]; //setting.plist option3 for table's segment change 1: Group 2: Name 3:Number 4:Recently read
    [setting writeToFile:settingPath atomically:YES];
    
    
    
}

#pragma mark - Install Books
- (void)installBooks {
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];

    
    BookManager *bookManager = [BookManager sharedManager];
    
    NSString *dataPath = [@"bookListInfo.plist" getDocPathWithPList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:dataPath])
	{
        
        
	    [bookManager copyFileFromResource:@"4204_1l.png"];
        [bookManager copyFileFromResource:@"4204_2l.png"];
        [bookManager copyFileFromResource:@"4247l.png"];
        [bookManager copyFileFromResource:@"voice.plist"];
        //[bookManager copyFileFromResource:@"bookInfo.plist"];
        
        
        
        //NSString *_s = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
        //NSString *_sName = [self readFromPlistData:_s];
        //[bookIdDict setObject:_sName forKey:_s];
        
        
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"4204_1",@"bookId",@"2",@"section",@"初信餧養(一)",@"title", nil];
        
        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"4204_2",@"bookId",@"2",@"section",@"初信餧養(二)",@"title", nil];
        
         NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"4247",@"bookId",@"2",@"section",@"恢復基督在召會中作一切",@"title", nil];
        
        NSArray *initBooks = [NSArray arrayWithObjects:dict1,dict2,dict3, nil];
        [initBooks writeToFile:dataPath atomically:YES];
        
        
        /*NSArray *_initArray = [NSArray arrayWithObjects:@"1044",@"2019",@"2148", nil];
        
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
        */
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
        
        
        NSMutableArray *bookList = [NSMutableArray arrayWithContentsOfFile:dataPath];
        if([_thebookList count] > 0)
        {
            for(NSString *bookId in _thebookList)
            {
                
                if([bookId isEqualToString:@"8889"])
                    continue;
                
                NSString *plistFileName = [NSString stringWithFormat:@"%@.plist",bookId];
                NSDictionary *bookPlist = [NSDictionary dictionaryWithContentsOfFile:[plistFileName getDocPathWithPList]];
                
                NSString *_sName = [bookPlist objectForKey:@"bookName"];
                
                NSMutableDictionary *newBookDict = [NSMutableDictionary dictionaryWithCapacity:10];
                
                NSString *secOfBook = [bookId substringToIndex:2];
                if([secOfBook isEqualToString:@"12"])
                    secOfBook = @"9";
                [newBookDict setObject:[secOfBook substringToIndex:1] forKey:@"section"];
                [newBookDict setObject:bookId forKey:@"bookId"];
                [newBookDict setObject:_sName forKey:@"title"];
                
                NSUInteger objIdx = [bookList indexOfObject: newBookDict];
                if(objIdx == NSNotFound) {
                    [bookList addObject:newBookDict];
                }
                
               
            }
            [bookList writeToFile:dataPath atomically:NO];
        }
        
        [appDelegate.bookList removeAllObjects];
        
    }

}

#pragma mark - rotation

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    
    [self resetNavigationBar];
}


- (void)resetNavigationBar
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation))
            bg.frame = CGRectMake(0, 0, 1024, 45);
        else
            bg.frame = CGRectMake(0, 0, 768, 45);
        
        CGFloat sbLength = 135.0;
        CGFloat sbOffset = bg.frame.size.width-70-sbLength;
        
        NSInteger ios8Adjustment;
        if(IS_IOS_8) ios8Adjustment = 10;
        else ios8Adjustment = 0;
        sb.frame = CGRectMake(sbOffset-ios8Adjustment, 0, sbLength, 44);
        
        eZoeTitle.frame = CGRectMake(bg.frame.size.width/2-125, 0, 130, 45);
    }
    
}

#pragma mark - Old version compatibility
- (void)copyBooksFromOldLauncher
{
    MyLauncherView *_launcherView = [[MyLauncherView alloc] init];
    
    NSString *dataPath = [@"pagelist.arc" getDocPathWithPList];
    
    _launcherView.pages = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
    
    NSInteger _pageCount = [_launcherView.pages count];
    NSInteger _itemCount;
    NSMutableArray *bookList = [NSMutableArray array];
    
    for(int p = 0; p < _pageCount; p++)
    {
        _itemCount= [[_launcherView.pages objectAtIndex:p] count] ;
        
        
        for(int i = 0; i < _itemCount; i++)
        {
            NSString *bookId = [[[_launcherView.pages objectAtIndex:p] objectAtIndex:i] bookid];
            
            NSString *plistFileName = [NSString stringWithFormat:@"%@.plist",bookId];
            
            NSDictionary *bookPlist = [NSDictionary dictionaryWithContentsOfFile:[plistFileName getDocPathWithPList]];
            
            NSString *_sName = [bookPlist objectForKey:@"bookName"];
            
            NSMutableDictionary *newBookDict = [NSMutableDictionary dictionaryWithCapacity:10];
            
            NSString *secOfBook = [bookId substringToIndex:2];
            if([secOfBook isEqualToString:@"12"])
                secOfBook = @"9";
            [newBookDict setObject:[secOfBook substringToIndex:1] forKey:@"section"];
            [newBookDict setObject:bookId forKey:@"bookId"];
            if (!_sName || [_sName isKindOfClass:[NSNull class]])
                _sName = @"";
            [newBookDict setObject:_sName forKey:@"title"];
            
            NSUInteger objIdx = [bookList indexOfObject: newBookDict];
            if(objIdx == NSNotFound) {
                [bookList addObject:newBookDict];
            }
           // NSString *_sName = [self readFromPlistData:_s];
           // [bookIdDict setObject:_sName forKey:_s];
        }
    }
    //NSString *_sName = [self readFromPlistData:_s];
    
    NSString *fileName = @"bookListInfo.plist";
    [bookList writeToFile:[fileName getDocPathWithPList] atomically:NO];
    
    [_launcherView release];
}

#pragma mark - Lifecycle


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self resetNavigationBar];
    //BookManager *bookManager = [BookManager sharedManager];
    //if (nil == bookManager.books) {
    //[self loadBooks:0];
    //} else {
    //    [self refreshBooks];
    //}
}


- (void)viewDidLoad
{
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    //oldVersion
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    NSString *dataPath = [@"pagelist.arc" getDocPathWithPList];
    if([fileManager fileExistsAtPath:dataPath isDirectory:NO])
    {
        [self copyBooksFromOldLauncher];
        NSError *error;
        [fileManager removeItemAtPath:dataPath error:&error];
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBooks) name:@"TableLoadBooks" object:nil];//johnliu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBooks) name:@"TableRefreshBooks" object:nil];//johnlius
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showModal:)
                                                 name:@"show modal"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dissmissMyWebViewController" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
           selector: @selector(dismissMyModalViewController)
               name: @"dissmissMyWebViewController"
             object: nil];
    
    [super viewDidLoad];
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat hOffset;
    CGFloat fHeight;
    
    CGFloat sbOffset;
    CGFloat sbLength;
    
   
    
    
    
	if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            bg = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 45)] autorelease];
            eZoeTitle = [[[UILabel alloc] initWithFrame:CGRectMake(bg.frame.size.width/2-125, 0, 130, 45)] autorelease];
            eZoeTitle.text =  NSLocalizedString(@"電子書報eZoe", @"eZoe");
            eZoeTitle.textColor = [UIColor whiteColor];
            eZoeTitle.backgroundColor = [UIColor clearColor];
            [bg addSubview:eZoeTitle];
            
            hOffset = 0.0;
            fHeight = 8.0;
            
            sbLength = 135.0;
            sbOffset = bg.frame.size.width-70-sbLength;
            
        }
    }else
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            bg = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 45)] autorelease];
            eZoeTitle = [[[UILabel alloc] initWithFrame:CGRectMake(bg.frame.size.width/2-125, 0, 130, 45)] autorelease];
            eZoeTitle.text =  NSLocalizedString(@"電子書報eZoe", @"eZoe");
            eZoeTitle.textColor = [UIColor whiteColor];
            eZoeTitle.backgroundColor = [UIColor clearColor];
            [bg addSubview:eZoeTitle];
            
            
            hOffset = 0.0;
            fHeight = 8.0;
            sbLength = 135.0;
            sbOffset = bg.frame.size.width-70-sbLength-30;
            
        }else {
            bg = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)] autorelease];
            //for iphone
            eZoeTitle = [[[UILabel alloc] initWithFrame:CGRectMake(52, 0, 130, 45)] autorelease];
            eZoeTitle.text =  NSLocalizedString(@"電子書報eZoe", @"eZoe");
            eZoeTitle.textColor = [UIColor whiteColor];
            eZoeTitle.backgroundColor = [UIColor clearColor];
            [bg addSubview:eZoeTitle];
            
            hOffset = 45.0;
            fHeight = 8.0;
            
            sbOffset = 140.0;
            sbLength = 105.0;
        }
        
    }
    
    [self installBooks];
    
    sb = [[[UISearchBar alloc] initWithFrame:CGRectMake(sbOffset, 0, sbLength, 44)] autorelease];
    
    
    if(IS_IOS_7)
    {
        for (UIView *subview in sb.subviews)
        {
            for (UIView *mySubView in subview.subviews){
                if ([mySubView isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                    [mySubView removeFromSuperview];
                    break;
                }
            }
        }
        
    }else
    {
        [[sb.subviews objectAtIndex:0] removeFromSuperview];
    }
    sb.showsCancelButton        = NO;
    sb.autocorrectionType       = UITextAutocorrectionTypeNo;
    sb.autocapitalizationType   = UITextAutocapitalizationTypeNone;
    sb.delegate                 = self;
    
    [bg addSubview:sb];

    
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = bg;
    
    /*self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"書櫃",@"Chest")
                                      style:UIBarButtonItemStyleBordered
                                     target:@"tt://launcherSplashTest"
                                     action:@selector(openURLFromButton:)] autorelease];
    */
    
    //johnliu----
    
   /* NSString *_title1 = @"書櫃";
    CGSize size = [_title1 sizeWithFont: [UIFont systemFontOfSize: 16]];
    EVNavigationButton *button = [[EVNavigationButton alloc] initWithFrame: CGRectMake(0, 9, MIN(100, size.width + 17), 30)];
    button.type = EVNavigationButtonTypeNormal;
    //[button setTitleForAllState: _title1];
    [button setTitle:_title1 forState:UIControlStateNormal];
    [button addTarget:@"tt://launcherSplashTest" action: @selector(openURLFromButton:) forControlEvents: UIControlEventTouchUpInside];
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    [button release];
    
	[self.navigationItem setRightBarButtonItem:[doneItem autorelease] animated:YES];
    */
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iLastLoginStatus == 1)
        bLoginStatus = YES;
    else
        bLoginStatus = NO;
    
    if(!bLoginStatus)
    {
        /*self.navigationItem.leftBarButtonItem =
        [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"登入",@"Chest") style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(loginout)] autorelease];
        if(IS_IOS_7)
            [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        */
        
        NSString *_title1 = [NSString stringWithString:NSLocalizedString(@"門市", @"Cloud")];
        CGSize size = [_title1 sizeWithFont: [UIFont systemFontOfSize: 16]];
        EVNavigationButton *button = [[EVNavigationButton alloc] initWithFrame: CGRectMake(0, 9, MIN(100, size.width + 16), 30)];
        button.type = EVNavigationButtonTypeBack;
        [button setTitle:_title1 forState:UIControlStateNormal];
        //[button addTarget:self action: @selector(loginout) forControlEvents: UIControlEventTouchUpInside];
        [button addTarget:self action: @selector(dismiss) forControlEvents: UIControlEventTouchUpInside];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView: button];
        [button release];
        
        [self.navigationItem setLeftBarButtonItem:[doneItem autorelease] animated:YES];

    }
    
    //if(IS_IOS_7)
    //{
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        
    //}
    //johnliu---
    

    _dataSource = [TETableViewSectionDataSource new];
    _delegate = [BookListDelegate new];
    _delegate.actionDelegate = self;
    _dataSource.actionDelegate = self;

    
    self.tableView.dataSource = _dataSource;
    self.tableView.delegate = _delegate;
    
    [self changeTableView:1];
    
}


- (void)loginout
{
    NSLog(@"Login!");
    
    //[ASIAuthenticationDialogCustom performSelectorOnMainThread:@selector(presentAuthenticationDialogForRequest:) withObject:self waitUntilDone:[NSThread isMainThread]];
}

- (void)dismiss {
    
    /*LoadingView *loadingView =
     [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
     
     [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:2.0];*/
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    hostReach = [[Reachability reachabilityWithHostName: @"ipad.twgbr.org"] retain];
    iMsgCount = 0;
    [hostReach startNotifier];
    
    
    

    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RELOADWEB"
                                                        object:self
                                                      userInfo:nil];
    
    
    
}


- (void)gotoCloud
{

/*    [self dismissViewControllerAnimated:NO completion:^{
        NSLog(@"gotoCloud");
        
    }];*/
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"tt://tabBar"]];
    
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
    NSString *bookType =  [bookSetting objectForKey:@"section"];
    if([bookType isEqualToString:@"0"])
        return 0;
    else if([bookType isEqualToString:@"1"])
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


#pragma mark - open Modal reader
- (void)showModal:(NSNotification *)notification
{
    /*
    NSString *bookId = [[notification userInfo] objectForKey:@"bookId"];
    
    MyWebViewController *_mwreadViewContoller = [[MyWebViewController alloc] initWithBookName:bookId];
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:_mwreadViewContoller leftViewController:nil rightViewController:nil] ;
    
    
    deckController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    deckController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [[self navigationController] pushViewController:deckController animated:NO];
    [[self navigationController] setToolbarHidden:YES animated:NO];
    
    [_mwreadViewContoller release];
    [deckController release];
    */
  /*
    - (void)loadPDFDocument:(NSString *)sBookNumber
    {
#ifdef DEBUG
        NSLog(@"%s", __FUNCTION__);
#endif*/
    
     NSString *sbooknumber_= [[notification userInfo] objectForKey:@"bookId"];
    /*if(IS_IOS_7)
    {
        ios7statusbarhide = YES;
        
        [self setNeedsStatusBarAppearanceUpdate];
    }*/
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
        
      /*
        MyWebViewController *_mwreadViewContoller = [[[MyWebViewController alloc] initWithBookName:sbooknumber_] autorelease];
        
        
        LeftViewController* leftController = [[[LeftViewController alloc] init] autorelease];
        
        
        IIViewDeckController* deckController =  [[[IIViewDeckController alloc] initWithCenterViewController:_mwreadViewContoller leftViewController:nil
                                                                                        rightViewController:leftController] autorelease];
        
        
        deckController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        deckController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        
        [self presentViewController:deckController animated:YES completion:nil];
        */
    }
    
}
    
- (void)loadPDFDocument:(NSString *)sBookNumber
{
#ifdef DEBUG
        NSLog(@"%s", __FUNCTION__);
#endif
        
        NSString *phrase = nil;
    
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSLog(@"appDelegate.bookDirectionMode:%d",appDelegate.bookDirectionMode);
        NSString *filePath = [[NSString stringWithFormat:@"%@.pdf",sBookNumber] getDocPathWithPList];
        
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase flipMode:appDelegate.bookDirectionMode];
        
        NSLog(@"filePath:%@",filePath);
        
        
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
             
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            
            
            SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] init];
            [leftMenuViewController setBookId:sBookNumber];
            
            MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                            containerWithCenterViewController:readerViewController
                                                            leftMenuViewController:leftMenuViewController
                                                            rightMenuViewController:nil];
            
            [self presentViewController:container animated:YES completion:nil];
            [readerViewController release];
            
            /*ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            
            [self presentModalViewController:readerViewController animated:YES];
            [readerViewController release]; // Release the ReaderViewController*/
        }
}

#pragma mark dismissModalViewController methods
- (void)dismissMyModalViewController
{
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.searchPageDictionary = nil;
    
    //[self rotateView];
    //[self loadView];
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
}

#pragma mark ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.searchPageDictionary = nil;
    [self dismissModalViewControllerAnimated:YES];
    //[self loadView];
    //NSLog(@"iLauncherLastRotatePage:%d",iLauncherLastRotatePage);
    //[_launcherView setCurrentPageIndex:iLauncherLastRotatePage];
    //[_launcherView setCurrentPagerIndex:iLauncherLastRotatePage];
    
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
   
    NSLog(@"The bookListViewController released!");
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    [_dataSource release];
    [_delegate release];
    
    BookManager *bookManager = [BookManager sharedManager];
    bookManager.delegate = nil;
    
    
    
    [super dealloc];
}

@end
