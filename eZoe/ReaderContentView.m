//
//	ReaderContentView.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderContentView.h"
#import "ReaderContentPage.h"
#import "ReaderThumbCache.h"
#import "eZoeAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@implementation ReaderContentView
{
	ReaderContentPage *theContentView;
    ReaderContentPage *theContentView1;
	ReaderContentThumb *theThumbView;
    ReaderContentThumb *theThumbView1;

	UIView *theContainerView;

	CGFloat zoomAmount;
}

#pragma mark Constants

#define ZOOM_LEVELS 4

#if (READER_SHOW_SHADOWS == TRUE) // Option
	#define CONTENT_INSET 4.0f
#else
	#define CONTENT_INSET 2.0f
#endif // end of READER_SHOW_SHADOWS Option

#define PAGE_THUMB_LARGE 240
#define PAGE_THUMB_SMALL 144

static void *ReaderContentViewContext = &ReaderContentViewContext;

#pragma mark Properties

@synthesize message;

#pragma mark ReaderContentView functions

static inline CGFloat ZoomScaleThatFits(CGSize target, CGSize source)
{
	CGFloat w_scale; UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];

    if(UIInterfaceOrientationIsLandscape(orientation)){
        if(appDelegate.pdfRectageMode == 1)
            w_scale = (target.height/source.height);//fit by height
        else
            w_scale= ((target.width/2)/source.width);//fit by width
        
        //w_scale= ((target.width/2) / source.width);
    }
    else{
        
        if(appDelegate.pdfRectageMode == 1)
            w_scale = (target.height/source.height);//fit by height
        else
            w_scale= (target.width / source.width);//fit by width
        
    }
    return w_scale;
}

#pragma mark ReaderContentView instance methods

- (void)updateMinimumMaximumZoom
{
	CGRect targetRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

	CGFloat zoomScale = ZoomScaleThatFits(targetRect.size, theContentView.bounds.size);

	self.minimumZoomScale = zoomScale; // Set the minimum and maximum zoom scales

	self.maximumZoomScale = (zoomScale * ZOOM_LEVELS); // Max number of zoom levels

	zoomAmount = ((self.maximumZoomScale - self.minimumZoomScale) / ZOOM_LEVELS);
}

- (id)initWithFrameLandscape:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSUInteger)page pageCount:(NSUInteger)pageCount password:(NSString *)phrase
{
	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.delaysContentTouches = NO;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.autoresizesSubviews = NO;
		self.bouncesZoom = YES;
		self.delegate = self;

        NSLog(@"pageCount:%d",pageCount);
        
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        
        if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
            page-=1;
        else
            page+=1;
		theContentView = [[ReaderContentPage alloc] initWithURL:fileURL page:page password:phrase];
        //如果第一頁是左翻時，右邊空白

        if(appDelegate.bookDirectionMode == ReaderFlipModeLeft && page == 0)
            theContentView.frame=CGRectMake(theContentView.frame.size.width/2, theContentView.frame.origin.y,theContentView.frame.size.width/2, theContentView.frame.size.height/2);
        else
            theContentView.frame=CGRectMake(theContentView.frame.origin.x, theContentView.frame.origin.y,theContentView.frame.size.width/2, theContentView.frame.size.height/2);
		if (theContentView != nil) // Must have a valid and initialized content view
		{
            
             theContentView1=[[ReaderContentPage alloc]initWithURL:fileURL page:page+1 password:phrase];
               theContentView1.frame=CGRectMake(theContentView.frame.size.width, theContentView.frame.origin.y, theContentView.frame.size.width, theContentView.frame.size.height);
            NSInteger containViewWidth;
            //for first single page
            //if(appDelegate.bookDirectionMode == ReaderFlipModeLeft && page == 0)
            //    containViewWidth = theContentView.frame.size.width;
            //else if(appDelegate.bookDirectionMode == ReaderFlipModeRight  && page == pageCount)
            //    containViewWidth = theContentView.frame.size.width;
            //else
                containViewWidth = theContentView.frame.size.width*2;
            
			theContainerView = [[UIView alloc] initWithFrame:CGRectMake(theContentView.frame.origin.x, theContentView.frame.origin.y, containViewWidth, theContentView.frame.size.height)];
            
			theContainerView.autoresizesSubviews = NO;
			theContainerView.userInteractionEnabled = NO;
			theContainerView.contentMode = UIViewContentModeRedraw;
			theContainerView.autoresizingMask = UIViewAutoresizingNone;
			theContainerView.backgroundColor = [UIColor whiteColor];
            
#if (READER_SHOW_SHADOWS == TRUE) // Option
            
			theContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
			theContainerView.layer.shadowRadius = 4.0f; theContainerView.layer.shadowOpacity = 1.0f;
			theContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:theContainerView.bounds].CGPath;
            
#endif // end of READER_SHOW_SHADOWS Option
            
			self.contentSize = theContentView.bounds.size; // Content size same as view size
			self.contentOffset = CGPointMake((0.0f - CONTENT_INSET), (0.0f - CONTENT_INSET)); // Offset
			self.contentInset = UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
            
#if (READER_ENABLE_PREVIEW == TRUE) // Option
            
            CGRect rectV1 = CGRectMake(theContentView.bounds.size.width, theContentView.bounds.origin.y, theContentView.bounds.size.width,theContentView.bounds.size.height);
            CGRect rectV2 = CGRectMake(0, theContentView1.bounds.origin.y, theContentView1.bounds.size.width,theContentView1.bounds.size.height);
			theThumbView = [[ReaderContentThumb alloc] initWithFrame:rectV1];//theContentView.bounds]; // Page thumb view
            theThumbView1=[[ReaderContentThumb alloc] initWithFrame:rectV2];
			// Add the thumb view to the container view
             if(page > 1)
             {
                 if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
                     [theContainerView addSubview:theThumbView];
                 if(appDelegate.bookDirectionMode == ReaderFlipModeRight)
                     [theContainerView addSubview:theThumbView1];
             }
#endif // end of READER_ENABLE_PREVIEW Option
            
            if(!(appDelegate.bookDirectionMode == ReaderFlipModeRight && page == 0))//page == 0//tttt
               [theContainerView addSubview:theContentView];
            
            if(appDelegate.bookDirectionMode == ReaderFlipModeLeft && page > 1 && page < pageCount)//page < pageCount//tttt
            {
                    [theContainerView addSubview:theContentView1];// Add the content view to the container view
            }else{
                if(page < pageCount)
                    [theContainerView addSubview:theContentView1];
            }
            
			[self addSubview:theContainerView]; // Add the container view to the scroll view
            
			[self updateMinimumMaximumZoom]; // Update the minimum and maximum zoom scales
            
			self.zoomScale = self.minimumZoomScale; // Set zoom to fit page content
		}
        
		[self addObserver:self forKeyPath:@"frame" options:0 context:ReaderContentViewContext];
        
		self.tag = page; // Tag the view with the page number
	}
    
	return self;
}




- (id)initWithFrame:(CGRect)frame fileURL:(NSURL *)fileURL page:(NSUInteger)page password:(NSString *)phrase
{
	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.delaysContentTouches = NO;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.autoresizesSubviews = NO;
		self.bouncesZoom = YES;
		self.delegate = self;

		theContentView = [[ReaderContentPage alloc] initWithURL:fileURL page:page password:phrase];

		if (theContentView != nil) // Must have a valid and initialized content view
		{
			theContainerView = [[UIView alloc] initWithFrame:theContentView.bounds];

			theContainerView.autoresizesSubviews = NO;
			theContainerView.userInteractionEnabled = NO;
			theContainerView.contentMode = UIViewContentModeRedraw;
			theContainerView.autoresizingMask = UIViewAutoresizingNone;
			theContainerView.backgroundColor = [UIColor whiteColor];

#if (READER_SHOW_SHADOWS == TRUE) // Option

			theContainerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
			theContainerView.layer.shadowRadius = 4.0f; theContainerView.layer.shadowOpacity = 1.0f;
			theContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:theContainerView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option

			self.contentSize = theContentView.bounds.size; // Content size same as view size
			self.contentOffset = CGPointMake((0.0f - CONTENT_INSET), (0.0f - CONTENT_INSET)); // Offset
			self.contentInset = UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);

#if (READER_ENABLE_PREVIEW == TRUE) // Option

			theThumbView = [[ReaderContentThumb alloc] initWithFrame:theContentView.bounds]; // Page thumb view

			[theContainerView addSubview:theThumbView]; // Add the thumb view to the container view

#endif // end of READER_ENABLE_PREVIEW Option

			[theContainerView addSubview:theContentView]; // Add the content view to the container view

			[self addSubview:theContainerView]; // Add the container view to the scroll view

			[self updateMinimumMaximumZoom]; // Update the minimum and maximum zoom scales

			self.zoomScale = self.minimumZoomScale; // Set zoom to fit page content
		}

		[self addObserver:self forKeyPath:@"frame" options:0 context:ReaderContentViewContext];

		self.tag = page; // Tag the view with the page number
	}

	return self;
}

- (void)dealloc
{
//	[self removeObserver:self forKeyPath:@"frame" context:ReaderContentViewContext];

	[self removeObserver:self forKeyPath:@"frame"]; // Maintain iOS 4.x compatability
}

- (void)showPageThumb:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase guid:(NSString *)guid
{
#if (READER_ENABLE_PREVIEW == TRUE) // Option

	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad); // Page thumb size

	CGSize size = (large ? CGSizeMake(PAGE_THUMB_LARGE, PAGE_THUMB_LARGE) : CGSizeMake(PAGE_THUMB_SMALL, PAGE_THUMB_SMALL));

	ReaderThumbRequest *request = [ReaderThumbRequest newForView:theThumbView fileURL:fileURL password:phrase guid:guid page:page size:size type:0];

	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:request priority:YES]; // Request the page thumb

	if ([image isKindOfClass:[UIImage class]]) [theThumbView showImage:image]; // Show image from cache

#endif // end of READER_ENABLE_PREVIEW Option
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == ReaderContentViewContext) // Our context
	{
		if ((object == self) && [keyPath isEqualToString:@"frame"])
		{
			CGFloat oldMinimumZoomScale = self.minimumZoomScale;

			[self updateMinimumMaximumZoom]; // Update zoom scale limits

			if (self.zoomScale == oldMinimumZoomScale) // Old minimum
			{
				self.zoomScale = self.minimumZoomScale;
			}
			else // Check against minimum zoom scale
			{
				if (self.zoomScale < self.minimumZoomScale)
				{
					self.zoomScale = self.minimumZoomScale;
				}
				else // Check against maximum zoom scale
				{
					if (self.zoomScale > self.maximumZoomScale)
					{
						self.zoomScale = self.maximumZoomScale;
					}
				}
			}
		}
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGSize boundsSize = self.bounds.size;
	CGRect viewFrame = theContainerView.frame;

    if (viewFrame.size.width < boundsSize.width)
        viewFrame.origin.x = (((boundsSize.width - viewFrame.size.width) / 2.0f) + self.contentOffset.x);
    else
        viewFrame.origin.x = 0.0f;

    if (viewFrame.size.height < boundsSize.height)
        viewFrame.origin.y = (((boundsSize.height - viewFrame.size.height) / 2.0f) + self.contentOffset.y);
    else
        viewFrame.origin.y = 0.0f;


	theContainerView.frame = viewFrame;
}

- (id)processSingleTap:(UITapGestureRecognizer *)recognizer
{
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)){
        
        CGPoint point = [recognizer locationInView:self];
        if(point.x > self.frame.size.width/2)
            return [theContentView1 processSingleTap:recognizer];
        else
            return [theContentView processSingleTap:recognizer];
    }else
    {
        return [theContentView processSingleTap:recognizer];
    }

}

- (void)zoomIncrement
{
	CGFloat zoomScale = self.zoomScale;

	if (zoomScale < self.maximumZoomScale)
	{
		zoomScale += zoomAmount; // += value

		if (zoomScale > self.maximumZoomScale)
		{
			zoomScale = self.maximumZoomScale;
		}

		[self setZoomScale:zoomScale animated:YES];
	}
}

- (void)zoomDecrement
{
	CGFloat zoomScale = self.zoomScale;

	if (zoomScale > self.minimumZoomScale)
	{
		zoomScale -= zoomAmount; // -= value

		if (zoomScale < self.minimumZoomScale)
		{
			zoomScale = self.minimumZoomScale;
		}

		[self setZoomScale:zoomScale animated:YES];
	}
}

- (void)zoomReset
{
	if (self.zoomScale > self.minimumZoomScale)
	{
		self.zoomScale = self.minimumZoomScale;
	}
    
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return theContainerView;
}

#pragma mark UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event]; // Message superclass

	[message contentView:self touchesBegan:touches]; // Message delegate
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event]; // Message superclass
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event]; // Message superclass
}

@end

#pragma mark -

//
//	ReaderContentThumb class implementation
//

@implementation ReaderContentThumb

#pragma mark ReaderContentThumb instance methods

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) // Superclass init
	{
		imageView.contentMode = UIViewContentModeScaleAspectFill;

		imageView.clipsToBounds = YES; // Needed for aspect fill
	}

	return self;
}

@end
