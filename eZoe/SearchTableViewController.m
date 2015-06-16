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

#import "SearchTableViewController.h"

@implementation SearchTableViewController

@synthesize _searchBar, searchDisplayController, filteredListContent,searchedText, allStars;//cdw,
@synthesize caller;
@synthesize  searchText;
@synthesize searchlistItems;
- (id)initWithStyle:(UITableViewStyle)style{
  if((self = [super initWithStyle:style])){
    //self.cdw = [[[CoreDataWrapper alloc] init] autorelease];
    //self.allStars = [cdw allStars];
    self.title = NSLocalizedString(@"搜尋",@"Search");
      //searchText = [NSMutableString stringWithString:@""];
       }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
   //if(![searchBar.text isEqualToString:@""])
  //    [self searchBar:searchBar textDidChange:searchBar.text];
    self.filteredListContent = [NSMutableArray array];
    self.searchedText = [NSMutableArray array];
    self._searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    if(![self.searchText isEqualToString:@""])
        self._searchBar.text = searchText;
    //searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"All", @"Lost", @"Simpsons", nil];
    _searchBar.showsScopeBar = NO;
    _searchBar.delegate = self;
	_searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	_searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;  
    
    self.tableView.tableHeaderView = _searchBar;
    self.searchDisplayController =  [[[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self] autorelease];
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    
     eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    _bookPreParePageTotal = appDelegate._bookprepareTotal;
    
    searchlistItems = [[NSMutableArray alloc] init];

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    if(!bWantBack)
    {
        [bar setText:@""];
       
    }else
        bWantBack = NO;
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.filteredListContent count]; 
  /*if (tableView == searchDisplayController.searchResultsTableView) {
      NSLog(@"Table Rowcount:%d",filteredListContent.count);
      return filteredListContent.count;
      
  }else
  {
      NSLog(@"Default RowCount:10");
      return 10;
  }*/
	//else{
    //return allStars.count;
  //      return 0;
  //}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    
  }
  if (tableView == searchDisplayController.searchResultsTableView) {
    //cell.textLabel.text = [filteredListContent objectAtIndex:indexPath.row];
     
      cell.textLabel.text = [searchedText objectAtIndex:indexPath.row];
      NSString *_sd = [NSString stringWithFormat:@"%d頁",[[filteredListContent objectAtIndex:indexPath.row] integerValue] - _bookPreParePageTotal];
      cell.detailTextLabel.text = _sd;

  }
	//else {
    //cell.textLabel.text = [[allStars objectAtIndex:indexPath.row] name];
  //}
  return cell;
}

/*- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
	//[filteredListContent removeAllObjects];	
  if([scope isEqualToString:@"All"]){
    //[filteredListContent addObjectsFromArray:[self.cdw starsWithNameQuery:searchText]];	
  }
  else{
    //[filteredListContent addObjectsFromArray:[self.cdw starsWithNameQuery:searchText andSeries:scope]];
  }
}*/
/*- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}*/

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  //[self filterContentForSearchText:searchString scope:[[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]]];
    
    if([searchString hasSuffix:@" "])
    {    
        return NO;
    }else
    {
        NSArray *_si = [searchString componentsSeparatedByString:@" "];
        [searchlistItems removeAllObjects];
        for(NSString *_s in _si)
        {
            NSLog(@"Search Items:%@",_s);
            [searchlistItems addObject:_s];
        }
        [self searchDatabase];
        return YES;
    }
    //return NO;
}

/*- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  //[self filterContentForSearchText:[searchBar text] scope:[[searchBar scopeButtonTitles] objectAtIndex:searchOption]];
  return YES;
}*/

-(void)searchDatabase
{
    [filteredListContent removeAllObjects];
    [searchedText removeAllObjects];
    
    self.searchText = nil;
    self.searchText = [NSString stringWithString:_searchBar.text];
    if([self.searchText isEqualToString:@""])
        return;
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger iLang;
    NSString *_sText;
    if(appDelegate.iBookLastLang == 1)
    {    
        iLang = 1; //simplify
        _sText = [[NSString stringWithString:self.searchText] traditionalChineseString];
        /*NSString *simplifiedChineseNames = [[NSString alloc] initWithString:@"用开通网上银行”的银行卡付款"];//
        const char *_s2 = [simplifiedChineseNames UTF8String];
        _sText = [[NSString stringWithUTF8String: _s2] traditionalChineseString];
        NSLog(@"traditionalCH: %@",_sText);*/
    }
    else
    {
        iLang = 0;
        _sText = [NSString stringWithString:self.searchText];
    }
    NSInteger _preparePage  = appDelegate._bookprepareTotal;
    
    NSString *databaseName = [NSString stringWithFormat:@"%@_1.db",appDelegate.sBookLastOpened];
    
   // NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:databaseName];
    NSString *databasePath = [databaseName getDocPathWithPList];
    
    NSMutableString *conbineSearch = [[[NSMutableString alloc] init] autorelease];
    for(NSString *_sItem in searchlistItems)
    {
        NSString *_c = [NSString stringWithFormat:@" text like '%%%@%%' and ",[_sItem traditionalChineseString]];
        [conbineSearch appendString:_c];
        
    }
  
    
    NSString *sql = [NSString stringWithFormat:@"select rowid,text from Content where %@ text not like '%%.gif';",conbineSearch];//,_sText];//text like '%%%@%%' and
    //NSLog(@"sql:%@",sql);
    
    
    NSDictionary *_searchDictionary = [appDelegate searchPageDictionary];
    //NSMutableArray *array_findedpages = [[NSMutableArray alloc] init];
    sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		
		const char *sqlStatement = [sql UTF8String]; 
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				
                NSString *arowid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *mytext = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                //[array_rowid addObject:arowid];
				NSString *_pageReturn = [_searchDictionary valueForKey:arowid];
                //NSLog(@"adjusted return page of key:%d",[_pageReturn integerValue] + _preparePage+1);
                [filteredListContent addObject:[NSString stringWithFormat:@"%d",[_pageReturn integerValue] + _preparePage+1]];
                if(iLang == 1)
                    [searchedText addObject:[mytext simplifiedChineseString]];
                else
                     [searchedText addObject:mytext];
			}
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	//if([[array_type objectAtIndex:0] isEqualToString:@"b"])
	//	self.bookName = [array_text objectAtIndex:0];
	sqlite3_close(database);
    
    //[array_findedpages release];
    
    
    
    //NSString *findedRow = [NSString stringWithString:@"500"];
    //NSString *_pageReturn = [_searchDictionary valueForKey:findedRow];
    //NSLog(@"return page of key:%@",_pageReturn);
    //[filteredListContent addObject:_pageReturn];

    [searchDisplayController.searchResultsTableView reloadData];
    //[searchDisplayController.searchResultsTableView becomeFirstResponder];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{
	//[self searchDatabase];
    //[filteredListContent addObject:@"1111"];
    //[filteredListContent addObject:@"2222"];
   
    [self searchDatabase];
	//NSLog(@"Search button clicked!");

}


/*- (void) didSelectSearchItem:(NSString*)searchPercent selectedItem:(NSInteger)selectedItem{
    [self.caller didSelectSearchItem:searchPercent selectedItem:selectedItem];
}*/

- (void) didClickJumpButton:(NSInteger)jumpPage searchText:(NSString*)searchText1
{
    [self.caller didClickJumpButton:jumpPage searchText:searchText1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    eZoeAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.selectedCharacter = indexPath;
    NSInteger _row = indexPath.row;
    SearchDetailViewController *searchDetailController = [[SearchDetailViewController alloc] init];
    searchDetailController.caller = self;
    NSMutableString *_st = [NSMutableString stringWithString:[searchedText objectAtIndex:_row]];
    searchDetailController.content = _st;
    
    //NSMutableArray *_at = [[NSMutableArray alloc ] initWithArray:searchlistItems];
    
    searchDetailController.keywords1 = searchlistItems;//_at;//self.searchText;
    //[_at release];
    NSString *_s = [filteredListContent objectAtIndex:_row];
    searchDetailController.searchedPage = [_s intValue];
    
    [self.navigationController pushViewController:searchDetailController animated:YES];
    
    // characterController.view.superview.frame = CGRectMake(0, 0, 200, 480);
	[searchDetailController release];
    
    bWantBack = YES;
   // SearchDetailViewController *searchDetailViewController = [[[SearchDetailViewController alloc] init] autorelease];
  //UIViewController *infoViewController = [[[UIViewController alloc] init] autorelease];
  /*if (tableView == searchDisplayController.searchResultsTableView) {
    infoViewController.title = [filteredListContent objectAtIndex:indexPath.row];
  }
	else {
    infoViewController.title = [[allStars objectAtIndex:indexPath.row] name];
  }
  [[self navigationController] pushViewController:infoViewController animated:YES];
   */
    //[[self navigationController] pushViewController:searchDetailViewController animated:YES];

    
    /*NSInteger _row = indexPath.row;
    NSString *_s = [filteredListContent objectAtIndex:_row];
    //[self.caller didSelectSearchItem:_s selectedItem:_row];
    [self didSelectSearchItem:_s selectedItem:_row];*/
}


- (void)dealloc {
    self.searchlistItems = nil;
  self.allStars = nil;
  //self.cdw = nil;
  self.filteredListContent = nil;
  self.searchedText = nil;
  self.searchDisplayController = nil;
  self._searchBar = nil;

  [super dealloc];
}


@end

