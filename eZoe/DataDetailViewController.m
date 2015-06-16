//
//  DataDetailViewController.m
//  eZoe
//
//  Created by John Liu on 2011/6/22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "eZoeAppDelegate.h"
#import "DataDetailViewController.h"
#import "YLUIKitAddition.h"


@implementation DataDetailViewController
@synthesize data,note,dataPercent,dataRowId,caller1;
@synthesize iSettingType;

- (id) initWithStyle:(UITableViewStyle)style{
    if((self = [super initWithStyle:style])){
        self.title = NSLocalizedString(@"設定選項",@"Option Setting");
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if(iSettingType == 1 || iSettingType == 2)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        else
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSUInteger row = [indexPath row];
    
    if(iSettingType == 0)
    {   
        UIImage* theImage = [UIImage imageNamed:@"bookmark_small.png"];
        cell.imageView.image = theImage;
        NSString *_data = [data objectAtIndex:row];
        NSString *formatedPageInfo;
        if([_data isEqualToString:@"序言目錄"])
            formatedPageInfo = [NSString stringWithString:_data];
        else
            formatedPageInfo = [NSString stringWithFormat:@"%@%@%@",@"第",[data objectAtIndex:row],@"頁"];
        cell.textLabel.text = formatedPageInfo;
        NSString *_percent = [dataPercent objectAtIndex:row];
        NSString *_formatedPercent = [NSString stringWithFormat:@"%02.2f%%",[_percent integerValue]/100.0];
        NSLog(@"Formated Percent:%@",_formatedPercent);
        cell.detailTextLabel.text  = _formatedPercent;
    }else if(iSettingType == 1)
    {
        NSString *_s = [NSString stringWithString:[data objectAtIndex:row]];
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.iBookLastLang == 1)
        {
            _s = [_s simplifiedChineseString];
        }
        cell.textLabel.text = _s;
        NSNumber *_percent = [dataPercent objectAtIndex:row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02.2f%%",[_percent integerValue]/100.0];
    }else if(iSettingType == 2)
    {
        NSString *_s = [NSString stringWithString:[data objectAtIndex:row]];
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.iBookLastLang == 1)
        {
            _s = [_s simplifiedChineseString];
        }
        cell.textLabel.text = _s;
        //NSNumber *_percent = [dataPercent objectAtIndex:row];
        NSString *notetext = [NSString stringWithString:[note objectAtIndex:row]];
        //NSLog(@"note:%@",notetext);
        cell.detailTextLabel.text = notetext;
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%02.2f%%",[_percent integerValue]/100.0];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(iSettingType == 0)
        [self.caller1 didSelectDataItem:iSettingType selectedItem:indexPath.row];
    else if(iSettingType == 1 || iSettingType == 2)
    {
        NSString *_searchText = [self.data objectAtIndex:indexPath.row];
        NSNumber *_percent = [self.dataPercent objectAtIndex:indexPath.row];
        NSString *_rowId = [self.dataRowId objectAtIndex:indexPath.row];
        //NSLog(@"searchText:%@,percnet:%d",_searchText,[_percent integerValue]);
        [self.caller1 didSelectMarkDataItem:_searchText pagePercent:_percent rowId:_rowId];
    }
}

- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(300.0, 220.0);
}

- (void)dealloc {
    self.data = nil;
    self.note = nil;
    self.dataPercent = nil;
    self.dataRowId = nil;
    [super dealloc];
}

@end
