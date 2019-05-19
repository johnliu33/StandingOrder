//
//	ThumbsViewController.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2011-09-01.
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
#import "ThumbsViewController.h"
#import "ReaderThumbRequest.h"
#import "ReaderThumbCache.h"
#import "ReaderDocument.h"
#import "ReaderAppearance.h"

#import "eZoeAppDelegate.h"

#import <QuartzCore/QuartzCore.h>

@interface ThumbsViewController () <ThumbsMainToolbarDelegate, ReaderThumbsViewDelegate>

@end

@implementation ThumbsViewController
{
	ReaderDocument *document;

	ThumbsMainToolbar *mainToolbar;

	ReaderThumbsView *theThumbsView;

	NSMutableArray *bookmarked;

	CGPoint thumbsOffset;
	CGPoint markedOffset;

	BOOL updateBookmarked;
	BOOL showBookmarked;
}

#pragma mark Constants

#define TOOLBAR_HEIGHT 44.0f

#define PAGE_THUMB_SMALL 160
#define PAGE_THUMB_LARGE 256

#define IPHONEX_SPACE 40.0f
#define STATUSBAR_HEIGHT 20.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id thumbs = nil; // ThumbsViewController object

	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			updateBookmarked = YES; bookmarked = [NSMutableArray new]; // Bookmarked pages

			document = object; // Retain the ReaderDocument object for our use

			thumbs = self; // Return an initialized ThumbsViewController object
		}
	}

	return thumbs;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	assert(delegate != nil); assert(document != nil);

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	//NSString *toolbarTitle = [document.fileName stringByDeletingPathExtension];

	CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
    
    toolbarRect.origin.y = UIApplication.sharedApplication.statusBarFrame.size.height;

	mainToolbar = [[ThumbsMainToolbar alloc] initWithFrame:toolbarRect title:@""]; //toolbarTitle// At top

	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

	CGRect thumbsRect = viewRect;
//    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    thumbsRect.origin.y += ( TOOLBAR_HEIGHT + toolbarRect.origin.y);
    thumbsRect.size.height -= thumbsRect.origin.y;

	theThumbsView = [[ReaderThumbsView alloc] initWithFrame:thumbsRect]; // Rest

	theThumbsView.delegate = self;

	[self.view insertSubview:theThumbsView belowSubview:mainToolbar];

	BOOL large = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);

	NSInteger thumbSize = (large ? PAGE_THUMB_LARGE : PAGE_THUMB_SMALL); // Thumb dimensions

	[theThumbsView setThumbSize:CGSizeMake(thumbSize, thumbSize)]; // Thumb size based on device
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    NSInteger totalPage = [document.pageCount integerValue];
    NSInteger page = [document.pageNumber integerValue]-1;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.bookDirectionMode == ReaderFlipModeRight)
        page = totalPage - page + 1 ; // Show the reverted page

	[theThumbsView reloadThumbsCenterOnIndex:page]; // Page
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	mainToolbar = nil; theThumbsView = nil;

	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
}
*/
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
     [self checkBookPara];
      [delegate updateZoomSize:self];
}


- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

#pragma mark ThumbsMainToolbarDelegate methods

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar showControl:(UISegmentedControl *)control
{
	switch (control.selectedSegmentIndex)
	{
		case 0: // Show all page thumbs
		{
			showBookmarked = NO; // Show all thumbs

			markedOffset = [theThumbsView insetContentOffset];

			[theThumbsView reloadThumbsContentOffset:thumbsOffset];

			break; // We're done
		}

		case 1: // Show bookmarked thumbs
		{
			showBookmarked = YES; // Only bookmarked

			thumbsOffset = [theThumbsView insetContentOffset];

			if (updateBookmarked == YES) // Update bookmarked list
			{
				[bookmarked removeAllObjects]; // Empty the list first

				[document.bookmarks enumerateIndexesUsingBlock: // Enumerate
					^(NSUInteger page, BOOL *stop)
					{
						[bookmarked addObject:[NSNumber numberWithInteger:page]];
					}
				];

				markedOffset = CGPointZero; updateBookmarked = NO; // Reset
			}

			[theThumbsView reloadThumbsContentOffset:markedOffset];

			break; // We're done
		}
	}
}

- (void)tappedInToolbar:(ThumbsMainToolbar *)toolbar doneButton:(UIButton *)button
{
	[delegate dismissThumbsViewController:self]; // Dismiss thumbs display
}

#pragma mark UIThumbsViewDelegate methods

- (NSUInteger)numberOfThumbsInThumbsView:(ReaderThumbsView *)thumbsView
{
	return (showBookmarked ? bookmarked.count : [document.pageCount integerValue]);
}

- (id)thumbsView:(ReaderThumbsView *)thumbsView thumbCellWithFrame:(CGRect)frame
{
	return [[ThumbsPageThumb alloc] initWithFrame:frame];
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView updateThumbCell:(ThumbsPageThumb *)thumbCell forIndex:(NSInteger)index
{
	CGSize size = [thumbCell maximumContentSize]; // Get the cell's maximum content size

	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));

	[thumbCell showText:[NSString stringWithFormat:@"%d", page]]; // Page number place holder
    [thumbCell showBookmark:[document.bookmarks containsIndex:page]]; // Show bookmarked status

	NSURL *fileURL = document.fileURL; NSString *guid = document.guid; NSString *phrase = document.password; // Document info

	ReaderThumbRequest *thumbRequest = [ReaderThumbRequest newForView:thumbCell fileURL:fileURL password:phrase guid:guid page:page size:size type:1];

	UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:thumbRequest priority:YES]; // Request the thumbnail

	if ([image isKindOfClass:[UIImage class]]) [thumbCell showImage:image]; // Show image from cache
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView refreshThumbCell:(ThumbsPageThumb *)thumbCell forIndex:(NSInteger)index
{
	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));


	[thumbCell showBookmark:[document.bookmarks containsIndex:page]]; // Show bookmarked status
}

#pragma mark -
#pragma mark check book parameter method
- (NSArray *)readBookDirectionFromPlist:(NSString *)bookNumber_
{
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber_];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *pdfDir =  [bookSetting objectForKey:@"pdfDirection"];
    NSString *pdfWidth = [bookSetting objectForKey:@"pdfWidth"];
    NSString *pdfHeight = [bookSetting objectForKey:@"pdfHeight"];
    
    return [NSArray arrayWithObjects:pdfDir,pdfWidth,pdfHeight, nil];
}


- (void)checkBookPara
{
    //
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *bookInfo  = [self readBookDirectionFromPlist:[document.fileName  stringByDeletingPathExtension]];
    NSInteger iDir_ = [[bookInfo objectAtIndex:0] integerValue];
    NSInteger iWidth_ = [[bookInfo objectAtIndex:1] integerValue];
    NSInteger iHeight_ = [[bookInfo objectAtIndex:2] integerValue];
    appDelegate.bookDirectionMode = iDir_;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
        
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            if(((float)iHeight_/(float)iWidth_*2) >= 0.75)
                appDelegate.pdfRectageMode = 0;
            else
                appDelegate.pdfRectageMode = 1;
            
            
            appDelegate.displaypageMode = 1;
        }
        else
        {
            if(((float)iWidth_/(float)iHeight_) >= 0.75)
                appDelegate.pdfRectageMode = 0;
            else
                appDelegate.pdfRectageMode = 1;
            
            appDelegate.displaypageMode = 0;
        }
        
    }else
        appDelegate.displaypageMode = 0;
    //
    
}

#pragma mark -
#pragma mark select/press index method

- (void)thumbsView:(ReaderThumbsView *)thumbsView didSelectThumbWithIndex:(NSInteger)index
{
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
   
        
	NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));
    
    
    NSInteger totalPage = [document.pageCount integerValue];
    NSUInteger jPage_;
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
    {
       
        if(UIInterfaceOrientationIsLandscape(orientation) && totalPage%2==0 && page == totalPage)
            page-=1;
        
        [delegate thumbsViewController:self gotoPage:page]; // Show the selected page
    }
    else
    {
        
        if(UIInterfaceOrientationIsLandscape(orientation) && totalPage%2 == 1)
        {
            jPage_ = totalPage - page+2; //NSLog(@"jPage:%d",jPage_);
            
            [delegate thumbsViewController:self gotoPage:jPage_]; // odd total page
        }
        else
            [delegate thumbsViewController:self gotoPage:totalPage - page+1]; // Show the selected page
    }

	[delegate dismissThumbsViewController:self]; // Dismiss thumbs display
}

- (void)thumbsView:(ReaderThumbsView *)thumbsView didPressThumbWithIndex:(NSInteger)index
{
    
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(UIInterfaceOrientationIsLandscape(orientation) && appDelegate.bookDirectionMode == ReaderFlipModeRight)
    {
        //special mode for landscape && Right Flip

         NSInteger totalPage = [document.pageCount integerValue];
        /*
         NSInteger page = totalPage - [document.pageNumber integerValue]-1;
        
         NSInteger page1;
         
         if(page%2 == 0)
         page1 = page+1;
         else
         page1 = page-1;
         
         if(page != 0)
         {
         if ([document.bookmarks containsIndex:page]) // Remove bookmark
         {
         [mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page];
         }
         else // Add the bookmarked page index to the bookmarks set
         {
         [mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page];
         }
         }
         
         if(page1 != totalPage-1)
         {
         if ([document.bookmarks containsIndex:page1]) // Remove bookmark
         {
         [mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page1];
         }
         else // Add the bookmarked page index to the bookmarks set
         {
         [mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page1];
         }
         }

        

        NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));
        NSInteger page1;
        
        if(page%2 == 0)
            page1 = page+1;
        else
            page1 = page-1;
        NSLog(@"The page is :%d,page1:%d",page,page1);
        if(page != 0)
        {
            if ([document.bookmarks containsIndex:page]) [document.bookmarks removeIndex:page]; else [document.bookmarks addIndex:page];
            updateBookmarked = YES; [thumbsView refreshThumbWithIndex:index]; // Refresh page thumb
        }
        
        if(page1 != totalPage-1)
        {
            if ([document.bookmarks containsIndex:page1]) [document.bookmarks removeIndex:page1]; else [document.bookmarks addIndex:page1];
             updateBookmarked = YES; [thumbsView refreshThumbWithIndex:index+1]; // Refresh page thumb
        }*/
        
        NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));
        
        if ([document.bookmarks containsIndex:page]) [document.bookmarks removeIndex:page]; else [document.bookmarks addIndex:page];
        
        updateBookmarked = YES; [thumbsView refreshThumbWithIndex:index]; // Refresh page thumb
    }
    else
    {
        NSInteger page = (showBookmarked ? [[bookmarked objectAtIndex:index] integerValue] : (index + 1));

        if ([document.bookmarks containsIndex:page]) [document.bookmarks removeIndex:page]; else [document.bookmarks addIndex:page];

        updateBookmarked = YES; [thumbsView refreshThumbWithIndex:index]; // Refresh page thumb
    }
}

@end

#pragma mark -

//
//	ThumbsPageThumb class implementation
//

@implementation ThumbsPageThumb
{
	UIView *backView;

	UIView *tintView;

	UILabel *textLabel;

	UIImageView *bookMark;

	CGSize maximumSize;

	CGRect defaultRect;
}

#pragma mark Constants

#define CONTENT_INSET 8.0f

#pragma mark ThumbsPageThumb instance methods

- (CGRect)markRectInImageView
{
	CGRect iconRect = bookMark.frame; iconRect.origin.y = (-2.0f);

	iconRect.origin.x = (imageView.bounds.size.width - bookMark.image.size.width - 8.0f);

	return iconRect; // Frame position rect inside of image view
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		imageView.contentMode = UIViewContentModeCenter;

		defaultRect = CGRectInset(self.bounds, CONTENT_INSET, CONTENT_INSET);

		maximumSize = defaultRect.size; // Maximum thumb content size

		CGFloat newWidth = ((defaultRect.size.width / 4.0f) * 3.0f);

		CGFloat offsetX = ((defaultRect.size.width - newWidth) / 2.0f);

		defaultRect.size.width = newWidth; defaultRect.origin.x += offsetX;

		imageView.frame = defaultRect; // Update the image view frame

		CGFloat fontSize = (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 19.0f : 16.0f);

		textLabel = [[UILabel alloc] initWithFrame:defaultRect];

		textLabel.autoresizesSubviews = NO;
		textLabel.userInteractionEnabled = NO;
		textLabel.contentMode = UIViewContentModeRedraw;
		textLabel.autoresizingMask = UIViewAutoresizingNone;
		textLabel.textAlignment = UITextAlignmentCenter;
		textLabel.font = [UIFont systemFontOfSize:fontSize];
		textLabel.textColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
		textLabel.backgroundColor = [UIColor whiteColor];

		[self insertSubview:textLabel belowSubview:imageView];

		backView = [[UIView alloc] initWithFrame:defaultRect];

		backView.autoresizesSubviews = NO;
		backView.userInteractionEnabled = NO;
		backView.contentMode = UIViewContentModeRedraw;
		backView.autoresizingMask = UIViewAutoresizingNone;
		backView.backgroundColor = [UIColor whiteColor];

#if (READER_SHOW_SHADOWS == TRUE) // Option

		backView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
		backView.layer.shadowRadius = 3.0f; backView.layer.shadowOpacity = 1.0f;
		backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option

		[self insertSubview:backView belowSubview:textLabel];

		tintView = [[UIView alloc] initWithFrame:imageView.bounds];

		tintView.hidden = YES;
		tintView.autoresizesSubviews = NO;
		tintView.userInteractionEnabled = NO;
		tintView.contentMode = UIViewContentModeRedraw;
		tintView.autoresizingMask = UIViewAutoresizingNone;
		tintView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];

		[imageView addSubview:tintView];

		UIImage *image = [UIImage imageNamed:@"Reader-Mark-Y"];

		bookMark = [[UIImageView alloc] initWithImage:image];

		bookMark.hidden = YES;
		bookMark.autoresizesSubviews = NO;
		bookMark.userInteractionEnabled = NO;
		bookMark.contentMode = UIViewContentModeCenter;
		bookMark.autoresizingMask = UIViewAutoresizingNone;
		bookMark.frame = [self markRectInImageView];

		[imageView addSubview:bookMark];
	}

	return self;
}

- (CGSize)maximumContentSize
{
	return maximumSize;
}

- (void)showImage:(UIImage *)image
{
	NSInteger x = (self.bounds.size.width / 2.0f);
	NSInteger y = (self.bounds.size.height / 2.0f);

	CGPoint location = CGPointMake(x, y); // Center point

	CGRect viewRect = CGRectZero; viewRect.size = image.size;

	textLabel.bounds = viewRect; textLabel.center = location; // Position

	imageView.bounds = viewRect; imageView.center = location; imageView.image = image;

	bookMark.frame = [self markRectInImageView]; // Position bookmark image

	tintView.frame = imageView.bounds; backView.bounds = viewRect; backView.center = location;

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)reuse
{
	[super reuse]; // Reuse thumb view

	textLabel.text = nil; textLabel.frame = defaultRect;

	imageView.image = nil; imageView.frame = defaultRect;

	bookMark.hidden = YES; bookMark.frame = [self markRectInImageView];

	tintView.hidden = YES; tintView.frame = imageView.bounds; backView.frame = defaultRect;

#if (READER_SHOW_SHADOWS == TRUE) // Option

	backView.layer.shadowPath = [UIBezierPath bezierPathWithRect:backView.bounds].CGPath;

#endif // end of READER_SHOW_SHADOWS Option
}

- (void)showBookmark:(BOOL)show
{
	bookMark.hidden = (show ? NO : YES);
}

- (void)showTouched:(BOOL)touched
{
	tintView.hidden = (touched ? NO : YES);
}

- (void)showText:(NSString *)text
{
	textLabel.text = text;
}

@end
