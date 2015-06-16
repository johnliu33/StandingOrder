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

#import "SetMainViewController.h"
#import "SetDetailViewController.h"
#import "DataDetailViewController.h"
#import "MKStoreManager.h"

@implementation SetMainViewController

@synthesize caller;
@synthesize caller1;

- (id) initWithStyle:(UITableViewStyle)style{
    if((self = [super initWithStyle:style])){
        self.title = NSLocalizedString(@"設定",@"setting");
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL bVoicePurchased;
    
    if([MKStoreManager isFeaturePurchased:@"tw.org.twgbr.HolyWords.b8889"])
        bVoicePurchased = YES;
    else
        bVoicePurchased = NO; //voice on
    
    if(bVoicePurchased)
        return 8;
    else
        return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"字型大小",@"Font Size");
    }else if(indexPath.row == 1){
        cell.textLabel.text = NSLocalizedString(@"佈景主題",@"Background");
    }else if(indexPath.row == 2){
        cell.textLabel.text = NSLocalizedString(@"字體設定",@"Font Type");
    }else if(indexPath.row == 3){
        cell.textLabel.text = NSLocalizedString(@"書籤列表",@"Bookmark List");
    }else if(indexPath.row == 4){
        cell.textLabel.text = NSLocalizedString(@"標記列表",@"Marktext List");
    }else if(indexPath.row == 5){
        cell.textLabel.text = NSLocalizedString(@"筆記列表",@"Note List");
    }else if(indexPath.row == 6){
        cell.textLabel.text = NSLocalizedString(@"朗讀聲音",@"Voice Type");
    }else if(indexPath.row == 7){
        cell.textLabel.text = NSLocalizedString(@"朗讀速度",@"Voice Speed");
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //SetDetailViewController *detailViewController = [[[SetDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    SetDetailViewController *detailViewController = [[[SetDetailViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    //DataDetailViewController *detailDataViewController = [[[DataDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    DataDetailViewController *detailDataViewController = [[[DataDetailViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *_sbook = appDelegate.sBookLastOpened;

    detailViewController.caller = self;
    detailDataViewController.caller1 = self;
    if(indexPath.row == 0){
        detailViewController.iSettingType = 0;
        detailViewController.title = NSLocalizedString(@"字型大小",@"Font Size");
        detailViewController.data = [NSArray arrayWithObjects:NSLocalizedString(@"最小字",@"Font Level1"), NSLocalizedString(@"小字",@"Font Level2"), NSLocalizedString(@"標準",@"Font Level3"), NSLocalizedString(@"大字",@"Font Level4"), NSLocalizedString(@"最大字",@"Font Level5"), nil];
    }else if(indexPath.row == 1){
        detailViewController.iSettingType = 1;
        detailViewController.title = NSLocalizedString(@"佈景主題",@"Background");
        detailViewController.data = [NSArray arrayWithObjects:NSLocalizedString(@"米黃色",@"Back1"),NSLocalizedString(@"純白色",@"Back2"),NSLocalizedString(@"報紙灰",@"Back3"), NSLocalizedString(@"夜間黑",@"Back4"), NSLocalizedString(@"水藍色",@"Back5"), nil];
    }else if(indexPath.row == 2){
        detailViewController.iSettingType = 2;
        detailViewController.title = NSLocalizedString(@"字體設定",@"Font Type");
        detailViewController.data = [NSArray arrayWithObjects:NSLocalizedString(@"楷體",@"Font1"), NSLocalizedString(@"黑體",@"Font2"), nil];
    }else if(indexPath.row == 6){
        detailViewController.iSettingType = 3;
        detailViewController.title = NSLocalizedString(@"朗讀聲音",@"Voice Type");
        detailViewController.data = [NSArray arrayWithObjects:NSLocalizedString(@"女聲(普通話)",@"Female1"),NSLocalizedString(@"女聲(台灣口音)",@"Female2"),NSLocalizedString(@"男聲",@"Male"), nil];
    }else if(indexPath.row == 7){
        detailViewController.iSettingType = 4;
        detailViewController.title = NSLocalizedString(@"朗讀速度",@"Voice Speed");
        detailViewController.data = [NSArray arrayWithObjects:NSLocalizedString(@"慢速",@"Slow"),NSLocalizedString(@"一般",@"Normal"),NSLocalizedString(@"快速",@"Fast"), nil];
    }else if(indexPath.row == 3){
        detailDataViewController.iSettingType = 0;
        //detailViewController.title = NSLocalizedString(@"書籤",@"Bookmark");
        detailDataViewController.title = NSLocalizedString(@"書籤頁數",@"Bookmark Page Number");
        NSString *myPath = [[NSString stringWithFormat:@"_%@bookmark.plist",_sbook] getDocPathWithPList];
        if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            //_bookMarkedPages = [[NSMutableArray alloc] initWithContentsOfFile:myPath];
            //detailViewController.data = [NSArray arrayWithContentsOfFile:myPath];
            NSArray *_percentArray = [NSArray arrayWithContentsOfFile:myPath];
            NSMutableArray *_pageArray = [[NSMutableArray alloc] init];
            
            NSInteger pageCount = appDelegate._bookpageCount;
            NSInteger prepareTotal = appDelegate._bookprepareTotal;
             
            for(NSString *_ps in _percentArray)
            {
                NSInteger _ips = [_ps integerValue];
                
                NSInteger _iR = [self revertPagePercent:_ips pageCount:pageCount]-prepareTotal;
                NSString *_revertPage;
                if(_iR <= 0)
                    _revertPage = [NSString stringWithString:NSLocalizedString(@"內封",@"Preface")];
                else
                    _revertPage = [NSString stringWithFormat:@"%d",_iR];
                
                
                [_pageArray addObject:_revertPage];
                
            }
            detailDataViewController.data = [NSArray arrayWithArray:_pageArray];
            detailDataViewController.dataPercent = [NSArray arrayWithArray:_percentArray];
            [_pageArray release];
           
        }
    }else if(indexPath.row == 4){
        detailDataViewController.iSettingType = 1;
        detailDataViewController.title = NSLocalizedString(@"標記列表",@"Marktext List");
        NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",_sbook] getDocPathWithPList];
        if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            

            NSDictionary *_mark_dic = [NSDictionary dictionaryWithContentsOfFile:myPath];
            NSArray *allKeys = [_mark_dic allKeys];
            NSArray *sortedKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            NSMutableArray *_textArray = [[NSMutableArray alloc] init];
            NSMutableArray *_percentArray = [[NSMutableArray alloc] init];
            NSMutableArray *_rowIdArray = [[NSMutableArray alloc] init];
            //NSMutableArray *_rowIDArray = [[NSMutableArray alloc] init];
            for(NSString *_key1 in sortedKeys)
            {
                //NSLog(@"_key1:%@",_key1); 
                NSArray *_a = [_mark_dic valueForKey:_key1];
                for(NSDictionary *_d in _a)
                {
                    NSString *_opt1 = [_d valueForKey:@"opt1"];
                    if([_opt1 isEqualToString:@"0"]) //表示是標記 1的話是註解
                    {
                        //NSLog(@"text:%@",[_d valueForKey:@"text"]);
                        [_textArray addObject:[_d valueForKey:@"text"]];
                        [_percentArray addObject:[_d valueForKey:@"pagepercent"]];
                        NSString *_rd = [_d valueForKey:@"rowID"];
                        if(_rd == NULL)
                            _rd = @"";
                        [_rowIdArray addObject:_rd];
                    }
                }
            }
            
            detailDataViewController.data = [NSArray arrayWithArray:_textArray];
            detailDataViewController.dataPercent = [NSArray arrayWithArray:_percentArray];
            detailDataViewController.dataRowId = [NSArray arrayWithArray:_rowIdArray];
            [_textArray release];
            [_percentArray release];
            [_rowIdArray release];

        }
    }else if(indexPath.row == 5){
        detailDataViewController.iSettingType = 2;
        detailDataViewController.title = NSLocalizedString(@"筆記列表",@"Note List");
        NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",_sbook] getDocPathWithPList];
        if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
        {
            //Get the note number
            NSMutableDictionary *notelist = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSString stringWithFormat:@"_%@note.plist",_sbook] getDocPathWithPList]];
            
            
            
            NSDictionary *_mark_dic = [NSDictionary dictionaryWithContentsOfFile:myPath];
            NSArray *allKeys = [_mark_dic allKeys];
            NSArray *sortedKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            NSMutableArray *_textArray = [[NSMutableArray alloc] init];
            NSMutableArray *_noteArray = [[NSMutableArray alloc] init];
            NSMutableArray *_percentArray = [[NSMutableArray alloc] init];
            NSMutableArray *_rowIdArray = [[NSMutableArray alloc] init];
            //NSMutableArray *_rowIDArray = [[NSMutableArray alloc] init];
            for(NSString *_key1 in sortedKeys)
            {
                //NSLog(@"_key1:%@",_key1); 
                NSArray *_a = [_mark_dic valueForKey:_key1];
                for(NSDictionary *_d in _a)
                {
                    NSString *_opt1 = [_d valueForKey:@"opt1"];
                    if([_opt1 isEqualToString:@"1"]) //0表示是標記 1的話是註解
                    {
                        //NSLog(@"text:%@",[_d valueForKey:@"text"]);
                        NSString *_noteNumber = [_d objectForKey:@"opt2"];
                        NSString *_noteText = [NSString stringWithString:[notelist objectForKey:_noteNumber]];
                        [_textArray addObject:[_d valueForKey:@"text"]];
                        [_noteArray addObject:_noteText];
                        [_percentArray addObject:[_d valueForKey:@"pagepercent"]];
                        NSString *_rd = [_d valueForKey:@"rowID"];
                        if(_rd == NULL)
                            _rd = @"";
                        [_rowIdArray addObject:_rd];
                    }
                }
            }
            
            detailDataViewController.data = [NSArray arrayWithArray:_textArray];
            detailDataViewController.note = [NSArray arrayWithArray:_noteArray];
            detailDataViewController.dataPercent = [NSArray arrayWithArray:_percentArray];
            detailDataViewController.dataRowId = [NSArray arrayWithArray:_rowIdArray];
            [_textArray release];
            [_noteArray release];
            [_percentArray release];
            [_rowIdArray release];
            
        }

    }
    
    if(indexPath.row < 3 || indexPath.row > 5)
        [self.navigationController pushViewController:detailViewController animated:YES];
    else
        [self.navigationController pushViewController:detailDataViewController animated:YES];
}

- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(300.0, 220.0);
}

- (void) didSelectItem:(NSInteger)type selectedItem:(NSInteger)selectedItem{
    [self.caller didSelectItem:type selectedItem:selectedItem];
    
}

- (void) didSelectDataItem:(NSInteger)type selectedItem:(NSInteger)selectedItem{
    [self.caller1 didSelectDataItem:type selectedItem:selectedItem];
}

- (void) didSelectMarkDataItem:(NSString *)searchText pagePercent:(NSNumber *)pagePercent rowId:(NSString *)rowId{
    [self.caller1 didSelectMarkDataItem:searchText pagePercent:pagePercent rowId:(NSString *)rowId];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility
//utility
-(CGFloat)convertPagePercent:(NSInteger)page pageCount:(NSInteger)count
{
    //last Page percent
    NSInteger _array_count = count;
    CGFloat _x = page;
    CGFloat _y = _array_count;
    CGFloat _f = _x/_y*10000.0;
    NSLog(@"convert percent:%f",_f);
    //NSString *_s = [NSString stringWithFormat:@"%d",(NSInteger)_f];
    return _f;
}

-(NSInteger)revertPagePercent:(CGFloat)percent pageCount:(NSInteger)count
{
    CGFloat _ac =  count;
    CGFloat _iP = percent;
    NSLog(@"revert percent:%f",percent);
    CGFloat _iPage = (_iP/10000.0)*_ac;
    if(fmodf(_iPage, 1.0) >= 0.5)
        return (NSInteger)_iPage +1;
    else
        return (NSInteger)_iPage;
}


@end

