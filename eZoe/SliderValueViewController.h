//
//  sliderValueViewController.h
//  ftl-sales-app
//
//  Created by Collin Ruffenach on 10/19/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eZoeAppDelegate.h"
#import <Three20/Three20.h>

@interface SliderValueViewController : UIViewController {

	IBOutlet UILabel *sliderValue;
}

@property (nonatomic, retain) IBOutlet UILabel *sliderValue;

-(void)updateSliderValueTo:(int)_value index_page_num:(int)_pagenum;

@end
