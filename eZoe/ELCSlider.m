//
//  ELCSlider.m
//  ELCSiderController
//
//  Created by Collin Ruffenach on 10/27/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCSlider.h"
#import "WEPopoverController.h"
//#import "WEPopoverContentViewController.h"

@implementation ELCSlider
@synthesize iPageIndex,iArrayIndexCount;
@synthesize sArrayIndexCaption;
@synthesize arrayText,arrayPageNum;
@synthesize popoverController;
@synthesize wpopoverController;

-(id)initWithFrame:(CGRect)frame {
    
	if((self = [super initWithFrame:frame])) {
        [self addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
        //[self addTarget:self action:@selector(leaveChanged) forControlEvents:UIControlEventTouchUpOutside];
		
		sliderValueController = [[SliderValueViewController alloc] initWithNibName:@"SliderValueViewController" bundle:[NSBundle mainBundle]];
        //iphone###version todo
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {    
            popoverController = [[UIPopoverController alloc] initWithContentViewController:sliderValueController];
            [popoverController setPopoverContentSize:sliderValueController.view.frame.size];
        }else
        {
            wpopoverController = [[WEPopoverController alloc] initWithContentViewController:sliderValueController];
            [self.wpopoverController setPopoverContentSize:sliderValueController.view.frame.size];

            /*[self.wpopoverController presentPopoverFromRect:sliderValueController.view.frame
                                                    inView:sliderValueController.view
                                  permittedArrowDirections:UIPopoverArrowDirectionDown
                                                  animated:YES];*/
            //[contentViewController release];
            //[button setTitle:@"Hide Popover" forState:UIControlStateNormal];
        }
    }
    return self;
}

-(void)valueChanged {
    
    iPageIndex = lrintf(self.value);
	[sliderValueController updateSliderValueTo:iPageIndex+1 index_page_num:iArrayIndexCount];
    
	CGFloat sliderMin =  self.minimumValue;
	CGFloat sliderMax = self.maximumValue;
	CGFloat sliderMaxMinDiff = sliderMax - sliderMin;
	CGFloat sliderValue = self.value;
	
	if(sliderMin < 0.0) {

		sliderValue = self.value-sliderMin;
		sliderMax = sliderMax - sliderMin;
		sliderMin = 0.0;
		sliderMaxMinDiff = sliderMax - sliderMin;
	}
	
	CGFloat xCoord = ((sliderValue-sliderMin)/sliderMaxMinDiff)*[self frame].size.width-sliderValueController.view.frame.size.width/2.0;
	
	CGFloat halfMax = (sliderMax+sliderMin)/2.0;
	
	if(sliderValue > halfMax) {
		
		sliderValue = (sliderValue - halfMax)+(sliderMin*1.0);
		sliderValue = sliderValue/halfMax;
		sliderValue = sliderValue*11.0;
		
		xCoord = xCoord - sliderValue;
	}
	
	else if(sliderValue <  halfMax) {
		
		sliderValue = (halfMax - sliderValue)+(sliderMin*1.0);
		sliderValue = sliderValue/halfMax;
		sliderValue = sliderValue*11.0;
		
		xCoord = xCoord + sliderValue;
	}
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [popoverController presentPopoverFromRect:CGRectMake(xCoord, 0, sliderValueController.view.frame.size.width, sliderValueController.view.frame.size.height) inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }else
    {
        //[self.wpopoverController setPopoverContentSize:sliderValueController.view.frame.size];
        [self.wpopoverController presentPopoverFromRect:CGRectMake(xCoord, 0, sliderValueController.view.frame.size.width, sliderValueController.view.frame.size.height) inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];  
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [arrayText release];
    [arrayPageNum release];
    [sArrayIndexCaption release];
    [popoverController release];
    [wpopoverController release];
    [super dealloc];
}


@end
