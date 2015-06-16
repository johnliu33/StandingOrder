//
//  ELCSlider.h
//  ELCSiderController
//
//  Created by Collin Ruffenach on 10/27/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SliderValueViewController.h"
@class WEPopoverController;
@interface ELCSlider : UISlider {

	UIPopoverController *popoverController;
	SliderValueViewController *sliderValueController;
    NSInteger iPageIndex;
    NSInteger iArrayIndexCount;

    
    
    WEPopoverController *wpopoverController;

}
@property (nonatomic, assign) NSInteger iPageIndex;
@property (nonatomic, assign) NSInteger iArrayIndexCount;
@property (nonatomic, retain) NSArray *arrayText;
@property (nonatomic, retain) NSArray *arrayPageNum;
@property (nonatomic, retain) NSString* sArrayIndexCaption;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) WEPopoverController *wpopoverController;
@end
