//
//  sliderValueViewController.m
//  ftl-sales-app
//
//  Created by Collin Ruffenach on 10/19/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "SliderValueViewController.h"


@implementation SliderValueViewController

@synthesize sliderValue;
-(NSString *)checkTheIndexTitle:(int)page
{
    page-=1;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *_a = [appDelegate arrayIndexPagenum];
    if([_a count] <= 1)
        return @"";
    int indexOfCaption = [_a count]-1;
    for(int i = 0; i < [_a count]; i++)
    {
        int _t = [[_a objectAtIndex:i] integerValue];
        if(page < _t)
        {
            indexOfCaption = i;
            break;
        }
    }
    if(indexOfCaption == 0)
        NSLog(@"Error");
    return [appDelegate.arrayIndexText objectAtIndex:indexOfCaption-1];
}


-(void)updateSliderValueTo:(int)_value index_page_num:(int)_pagenum{
    
    int iShow = _value-_pagenum;
    if(iShow <= 0)
    {
        [sliderValue setText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"內封",@"Preface")]];
        //[sliderValue setText:[NSString stringWithFormat:@"%d", _value-_pagenum]];
    }
    else     
    {
        int iSliderPage = _value-_pagenum;
        int _iSliderPage;
        NSString *_caption = @"";//[self checkTheIndexTitle: iSliderPage];
        if(TTIsOrienLandscape() && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _iSliderPage = iSliderPage*2-1;
        }else
        {
            _iSliderPage = iSliderPage;
        }
        //NSLog(@"chapter1:%@ _iSliderPage:%i",[appDelegate.arrayIndexPagenum objectAtIndex:1],_iSliderPage-1);
        
        [sliderValue setText:[NSString stringWithFormat:@"%d頁 %@",_iSliderPage,_caption]];
        //NSLog(@"slider value:@%d = iPageIndex+1:%d - iArrayIndexCount:%d",_value-_pagenum,_value,_pagenum);
    }
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
