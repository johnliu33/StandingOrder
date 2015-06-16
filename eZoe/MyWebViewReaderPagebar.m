//
//  MyWebViewReaderPagebar.m
//  holmes
//
//  Created by Mac on 13/1/23.
//  Copyright (c) 2013年 SAMOUNTECH. All rights reserved.
//

#import "MyWebViewReaderPagebar.h"

@implementation MyWebViewReaderPagebar

@synthesize delegate;

#pragma mark ReaderPagebarShadow class methods

+ (Class)layerClass
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame pageCount:(NSInteger)pageCount iprePageTotal:(NSInteger)iprePageTotal//document:(ReaderDocument *)object
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	//assert(object != nil); // Check
    
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		self.backgroundColor = [UIColor clearColor];
        
		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		UIColor *liteColor = [UIColor colorWithWhite:0.82f alpha:0.8f];
		UIColor *darkColor = [UIColor colorWithWhite:0.32f alpha:0.8f];
		layer.colors = [NSArray arrayWithObjects:(id)liteColor.CGColor, (id)darkColor.CGColor, nil];
        
		CGRect shadowRect = self.bounds; shadowRect.size.height = 4.0f; shadowRect.origin.y -= shadowRect.size.height;
        
		MyWebViewReaderPagebarShadow *shadowView = [[MyWebViewReaderPagebarShadow alloc] initWithFrame:shadowRect];
        
		[self addSubview:shadowView]; //[shadowView release]; // Add the shadow to the view
        
        //Slider--------
        //NSInteger _iAdjust;
         //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         //{
            /*if(TTIsOrienLandscape())
                _iAdjust = 30;
            else
                _iAdjust = 25;*/
            
            //_slider = [[ELCSlider alloc] initWithFrame:self.bounds
            //CGRectMake(84, rectFrame.size.height - TT_ROW_HEIGHT-_iAdjust,
            //rectFrame.size.width-168, TT_ROW_HEIGHT)];
         //}else
         //{
            /*if(TTIsOrienLandscape())
                _iAdjust = 5;
            else
                _iAdjust = 10;*/
          
             //_slider = [[ELCSlider alloc] initWithFrame:self.bounds];
            //CGRectMake(30, rectFrame.size.height - TT_ROW_HEIGHT-_iAdjust,
            //rectFrame.size.width-60, TT_ROW_HEIGHT)];
         //}
        CGFloat sliderSpace = self.bounds.size.width*0.1;
        CGRect sliderRect = CGRectMake(self.bounds.origin.x+sliderSpace, self.bounds.origin.y, self.bounds.size.width*0.8, self.bounds.size.height);
         _slider = [[ELCSlider alloc] initWithFrame:sliderRect];
         _slider.iArrayIndexCount = iprePageTotal;//[parseHtml.array_index_html count]
         //if (self.navigationBarStyle == UIBarStyleDefault) {
         //_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
         //}
         [_slider addTarget:self action:@selector(sliderTouch) forControlEvents:UIControlEventTouchDown];
         [_slider addTarget:self action:@selector(leavedSlider) forControlEvents:UIControlEventTouchUpOutside];
         [_slider addTarget:self action:@selector(leavedSlider) forControlEvents:UIControlEventTouchUpInside];
         //[_slider setBackgroundColor:[UIColor clearColor]];//
         _slider.minimumValue = 1;
         _slider.maximumValue = pageCount;//[array_page count]-2;
         _slider.continuous = YES;
         
         [self addSubview:_slider];
        //---------
        
        /*
		CGFloat numberY = (0.0f - (PAGE_NUMBER_HEIGHT + PAGE_NUMBER_SPACE));
		CGFloat numberX = ((self.bounds.size.width - PAGE_NUMBER_WIDTH) / 2.0f);
		CGRect numberRect = CGRectMake(numberX, numberY, PAGE_NUMBER_WIDTH, PAGE_NUMBER_HEIGHT);
        
		pageNumberView = [[UIView alloc] initWithFrame:numberRect]; // Page numbers view
        
		pageNumberView.autoresizesSubviews = NO;
		pageNumberView.userInteractionEnabled = NO;
		pageNumberView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		pageNumberView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        
		//pageNumberView.layer.cornerRadius = 4.0f;
		pageNumberView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		pageNumberView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.6f].CGColor;
		pageNumberView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pageNumberView.bounds].CGPath;
		pageNumberView.layer.shadowRadius = 2.0f; pageNumberView.layer.shadowOpacity = 1.0f;
        
		CGRect textRect = CGRectInset(pageNumberView.bounds, 4.0f, 2.0f); // Inset the text a bit
        
		pageNumberLabel = [[UILabel alloc] initWithFrame:textRect]; // Page numbers label
        
		pageNumberLabel.autoresizesSubviews = NO;
		pageNumberLabel.autoresizingMask = UIViewAutoresizingNone;
		pageNumberLabel.textAlignment = UITextAlignmentCenter;
		pageNumberLabel.backgroundColor = [UIColor clearColor];
		pageNumberLabel.textColor = [UIColor whiteColor];
		pageNumberLabel.font = [UIFont systemFontOfSize:16.0f];
		pageNumberLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		pageNumberLabel.shadowColor = [UIColor blackColor];
		pageNumberLabel.adjustsFontSizeToFitWidth = YES;
		pageNumberLabel.minimumFontSize = 12.0f;
        
		[pageNumberView addSubview:pageNumberLabel]; // Add label view
        
		[self addSubview:pageNumberView]; // Add page numbers display view
        
		trackControl = [[ReaderTrackControl alloc] initWithFrame:self.bounds]; // Track control view
        
		[trackControl addTarget:self action:@selector(trackViewTouchDown:) forControlEvents:UIControlEventTouchDown];
		[trackControl addTarget:self action:@selector(trackViewValueChanged:) forControlEvents:UIControlEventValueChanged];
		[trackControl addTarget:self action:@selector(trackViewTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
		[trackControl addTarget:self action:@selector(trackViewTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        
		[self addSubview:trackControl]; // Add the track control and thumbs view
        
		document = [object retain]; // Retain the document object for our use
        
		[self updatePageNumberText:[document.pageNumber integerValue]];
        
		miniThumbViews = [NSMutableDictionary new]; // Small thumbs
         */
	}
    
	return self;
}

- (void)updateSliderPage:(NSInteger)pages
{
    _slider.value = pages;
}

- (void)sliderTouch
{
    [delegate slideAction];
}

- (void)leavedSlider
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [_slider.popoverController dismissPopoverAnimated:YES];
     else
         [_slider.wpopoverController dismissPopoverAnimated:YES];
     
    [delegate pagebar:self gotoPage:[_slider iPageIndex]];
    
}

- (void)hidePagebar
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.hidden == NO) // Only if visible
	{
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
	}
}

- (void)showPagebar
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.hidden == YES) // Only if hidden
	{
		//[self updatePagebarViews]; // Update views first
        
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end


#pragma mark -

//
//	ReaderPagebarShadow class implementation
//

@implementation MyWebViewReaderPagebarShadow

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderPagebarShadow class methods

+ (Class)layerClass
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	return [CAGradientLayer class];
}

#pragma mark ReaderPagebarShadow instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizesSubviews = NO;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];
        
		CAGradientLayer *layer = (CAGradientLayer *)self.layer;
		UIColor *blackColor = [UIColor colorWithWhite:0.42f alpha:1.0f];
		UIColor *clearColor = [UIColor colorWithWhite:0.42f alpha:0.0f];
		layer.colors = [NSArray arrayWithObjects:(id)clearColor.CGColor, (id)blackColor.CGColor, nil];
	}
    
	return self;
}

@end
