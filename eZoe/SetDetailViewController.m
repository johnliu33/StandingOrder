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
#import "eZoeAppDelegate.h"
#import "SetDetailViewController.h"


@implementation SetDetailViewController

@synthesize data, caller;
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
    if(iSettingType == 0)
    {  
        NSInteger _iFontSize;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            switch (appDelegate.iFontLastSize) {
                case 18:
                    _iFontSize = 0;
                    break;
                case 22:
                    _iFontSize = 1;
                    break;
                case 26:
                    _iFontSize = 2;
                    break;
                case 30:
                    _iFontSize = 3;
                    break;
                case 35:
                    _iFontSize = 4;
                    break;
                default:
                    _iFontSize = 2;
                    break;
            }
        }
        else
        {
            switch (appDelegate.iFontLastSize) {
                case 14:
                    _iFontSize = 0;
                    break;
                case 16:
                    _iFontSize = 1;
                    break;
                case 18:
                    _iFontSize = 2;
                    break;
                case 20:
                    _iFontSize = 3;
                    break;
                case 26:
                    _iFontSize = 4;
                    break;
                default:
                    _iFontSize = 1;
                    break;
            }

        }
        
        if(row == _iFontSize) {
            NSLog(@"iLastFontSize:%d",appDelegate.iFontLastSize);
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
    }else if(iSettingType == 1)
    {
        if(row == appDelegate.iBGLastType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

    }else if(iSettingType == 2)
    {
        if(row == appDelegate.iFontLastType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if(iSettingType == 3)
    {
        if(row == appDelegate.iVoiceLastType) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if(iSettingType == 4)
    {
        if(row == appDelegate.iVoiceLastSpeed) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

/*- (void)doStuff:(NSString *)arg1 and:(NSString *)arg2 and:(NSString *)arg3 {
    ...
}

- (void)doStuff:(NSArray *)argArray {
    [self doStuff:[argArray objectAtIndex:0]
              and:[argArray objectAtIndex:1]
              and:[argArray objectAtIndex:2];
}*/


- (void)showSpinnerInTable:(UITableView *)tableView idxPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIActivityIndicatorView *activityView = 
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView startAnimating];
    [cell setAccessoryView:activityView];
    [activityView release];
    
    //[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

}



- (void)showSpinnerInTable1:(NSArray *)argArray {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self showSpinnerInTable:[argArray objectAtIndex:0] 
                     idxPath:[argArray objectAtIndex:1]];
    [pool release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSArray* foo = [[[NSArray alloc] initWithObjects:@"a", @"b", nil] autorelease];
    NSArray *argArray = [[[NSArray alloc] initWithObjects:tableView,indexPath, nil] autorelease];
    
    
    [self performSelectorInBackground:@selector(showSpinnerInTable1:) withObject:argArray];
    
    /*LoadingView *loadingView = [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0]];
    [loadingView
     performSelector:@selector(removeView)
     withObject:nil
     afterDelay:1.2];*/

    [self.caller didSelectItem:iSettingType selectedItem:indexPath.row];
    
}

- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(300.0, 220.0);
}

- (void)dealloc {
    self.data = nil;
    [super dealloc];
}


@end

