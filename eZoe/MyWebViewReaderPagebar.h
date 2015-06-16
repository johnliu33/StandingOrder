//
//  MyWebViewReaderPagebar.h
//  holmes
//
//  Created by Mac on 13/1/23.
//  Copyright (c) 2013年 SAMOUNTECH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCSlider.h"
#import "WEPopoverController.h"
#import <QuartzCore/QuartzCore.h>
@class MyWebViewReaderPagebar;

@protocol MyWebViewReaderPagebarDelegate <NSObject>

@required // Delegate protocols

- (void)pagebar:(MyWebViewReaderPagebar *)pagebar gotoPage:(NSInteger)page;
- (void)slideAction;
@end

@interface MyWebViewReaderPagebar : UIView
{
    ELCSlider*        _slider;
}

@property (nonatomic, assign, readwrite) id <MyWebViewReaderPagebarDelegate> delegate;
//- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame pageCount:(NSInteger)pageCount iprePageTotal:(NSInteger)iprePageTotal;
- (void)hidePagebar;
- (void)showPagebar;
- (void)updateSliderPage:(NSInteger)pages;

@end

#pragma mark -

//
//	ReaderPagebarShadow class interface
//

@interface MyWebViewReaderPagebarShadow : UIView
{
@private // Instance variables
}

@end
