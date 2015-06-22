//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "Global.h"


@implementation SideMenuViewController

#pragma mark -
#pragma mark - readIndexFromPlist

-(void)setBookId:(NSString *)bookId {
    pdfBookId = bookId;
    NSLog(@"pdfBookId:%@",pdfBookId);
}

- (void)readBookInfoFromPlistData {
    
    NSString *plistName = [NSString stringWithFormat:@"%@.plist",pdfBookId];
    
    
    NSString *myPath = [plistName getDocPathWithPList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:myPath])
    {
        
        NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
        
        [fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
        
        
    }
    //[fileManager release];
    
    //NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    //NSString *_modifyBookNumber = [bookSetting objectForKey:@"bookNumber"];
    
    //NSString *_rS = [NSString stringWithFormat:@"%@",[bookSetting objectForKey:@"bookName"]];
    //return _rS;
    
    NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    bookName =  [bookSetting objectForKey:@"bookName"];
    arrayIndex = [bookSetting objectForKey:@"Index"];
    //NSLog(@"%@",[arrayIndex[0] objectForKey:@"Title"]);
    //NSLog(@"%@",[arrayIndex[0] objectForKey:@"PageNum"]);
    
}

#pragma mark -
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readBookInfoFromPlistData];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"目錄";//[NSString stringWithFormat:@"Section %d", section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[arrayIndex[indexPath.row] objectForKey:@"Title"]];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *indexCount = [NSString stringWithFormat:@"%@",[arrayIndex[indexPath.row] objectForKey:@"PageNum"]];
    //NSLog(@"index Count: %ld",(long)indexPath.row);
    
    
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

    [[NSNotificationCenter defaultCenter] postNotificationName:kBookDidJumpIndex
                                                        object:indexCount];
    /*DemoViewController *demoController = [[DemoViewController alloc] initWithNibName:@"DemoViewController" bundle:nil];
    demoController.title = [NSString stringWithFormat:@"Demo #%d-%d", indexPath.section, indexPath.row];
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:demoController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];*/
}

@end
