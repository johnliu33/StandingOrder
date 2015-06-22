//
//	ReaderViewController.m
//	Reader v2.6.0
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
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

#import "eZoeAppDelegate.h"

#import <MessageUI/MessageUI.h>

#import "MFSideMenu.h"
#import "SideMenuViewController.h"



@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,
									ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate>
@end

@implementation ReaderViewController
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;

	UIPrintInteractionController *printInteraction;

	NSInteger currentPage;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL isVisible;
    
    NSString *bookNumber;
    NSString *bookName;
    NSString *bookType;
    BOOL bPrintable;
    BOOL bMailable;
    BOOL bBookmarkable;
    BOOL bThumbable;
    
    BOOL bSpecialRotate;

    
}

#pragma mark Constants

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark Support methods

- (void)updateScrollViewContentSize
{
	NSInteger count = [document.pageCount integerValue];

	if (count > PAGING_VIEWS)
    {
        UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
           if(appDelegate.bookDirectionMode == ReaderFlipModeLeft && [document.pageCount integerValue]%2 == 0)
               count = PAGING_VIEWS+1;//tttt12 // Limit
            else
                count = PAGING_VIEWS;
        }
        else
           count = PAGING_VIEWS;//tttt12 // Limit
    }

	CGFloat contentHeight = theScrollView.bounds.size.height;

	CGFloat contentWidth = (theScrollView.bounds.size.width * count);

	theScrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateScrollViewContentViews
{
	[self updateScrollViewContentSize]; // Update the content size

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSet]; // Page set

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object; [pageSet addIndex:contentView.tag];
		}
	];

	__block CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

	__block CGPoint contentOffset = CGPointZero; NSInteger page = [document.pageNumber integerValue];

	[pageSet enumerateIndexesUsingBlock: // Enumerate page number set
		^(NSUInteger number, BOOL *stop)
		{
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			contentView.frame = viewRect; if (page == number) contentOffset = viewRect.origin;

			viewRect.origin.x += viewRect.size.width; // Next view frame position
		}
	];

	if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
	{
		theScrollView.contentOffset = contentOffset; // Update content offset
	}
}

- (void)updateToolbarBookmarkIcon
{
    
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(UIInterfaceOrientationIsLandscape(orientation) && appDelegate.bookDirectionMode == ReaderFlipModeRight)
    {
        //special mode for landscape && Right Flip
        NSInteger totalPage = [document.pageCount integerValue];
        NSInteger page = totalPage - [document.pageNumber integerValue]-1;
        if(page%2 == 0) page++;
        //NSLog(@"The page is :%d",page);
        
        BOOL bookmarked = [document.bookmarks containsIndex:page];
        [mainToolbar setBookmarkState:bookmarked]; // Update

    }
    else
    {
        NSInteger page = [document.pageNumber integerValue];
        NSInteger totalPage = [document.pageCount integerValue];
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.bookDirectionMode == ReaderFlipModeRight)
            page = totalPage - page + 1 ; // Show the reverted page

        BOOL bookmarked = [document.bookmarks containsIndex:page];

    
        [mainToolbar setBookmarkState:bookmarked]; // Update
    }
}

- (void)showDocumentPage:(NSInteger)page
{
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    NSUInteger  totalPage = [document.pageCount integerValue];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(UIInterfaceOrientationIsLandscape(orientation)){

       
        
        if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
        {
            if(page > 1)
                page +=1;
        }else
        {
            NSLog(@"pagecount:%d",totalPage);
            if(page < totalPage)
                page -=1;
        }
        
        if(page%2==0){
            page=page-1;
        }
        else{
            page=page;
        }
        
        if(appDelegate.bookDirectionMode == ReaderFlipModeRight && totalPage%2 == 1)
            page = page-1;
       
        
        NSInteger minValue; NSInteger maxValue;
        NSInteger maxPage;
        
       
        if(totalPage%2==0 || (appDelegate.bookDirectionMode == ReaderFlipModeRight && totalPage%2 == 1)){
            maxPage = totalPage-1;
            /*if(page == totalPage+1 && totalPage%2 == 0)
            {
                maxPage+=5;
                
            }*/
            
        }
        else{
            maxPage=totalPage;
        }
        
        NSInteger minPage;
    
        //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
            minPage = 1;//tttt
        else
            minPage = -1;
        
        
        if ((page < minPage) || (page > maxPage)) return;
        
        
        
        if (maxPage <= PAGING_VIEWS) // Few pages
        {
            minValue = minPage;
            maxValue = maxPage;
        }
        else // Handle more pages
        {
                 //最後一頁很難搞
                if(page <= 0 && totalPage%2 == 1 && appDelegate.bookDirectionMode == ReaderFlipModeRight)
                {
                    page-=2;
                }
            
                    
                minValue=page-2;
                maxValue=page+2;
                if(minValue<minPage){
                    minValue=minValue+2;
                    maxValue=maxValue+2;
                }
                if (maxValue > maxPage)
                {
                    minValue= (minValue > 2) ? minValue-2 : 1;
                    maxValue=maxValue-2;
                }
            
        }
        NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];
        
        NSMutableDictionary *unusedViews = [contentViews mutableCopy];
        
        CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
        if (bSpecialRotate) {//解決一種特殊的翻轉情況，iPad先ThumbView直立，再翻轉，再開某一頁
            viewRect.size = CGSizeMake(1024, 768);
            page++;
           
        }
        NSInteger iAdditionPlus = 0;
        
        if(appDelegate.bookDirectionMode == ReaderFlipModeLeft && totalPage%2==0)
            iAdditionPlus = 2;
        
        
        for (NSInteger number = minValue; number <= maxValue+iAdditionPlus; number=number+2)//
        {
            NSString *key = [NSString stringWithFormat:@"%d-L",number]; // # key

            NSLog(@"%@",key);
            ReaderContentView *contentView = [contentViews objectForKey:key];
               
			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties
                ;
                NSLog(@"page number:%d",number);
				contentView = [[ReaderContentView alloc] initWithFrameLandscape:viewRect fileURL:fileURL page:number pageCount:totalPage password:phrase];
                
                
				[theScrollView addSubview:contentView];
                
                [contentViews setObject:contentView forKey:key];
				contentView.message = self;
                if(number < 0 && totalPage%2 == 1 && appDelegate.bookDirectionMode == ReaderFlipModeRight)
                {
                    //最後一頁很難搞
                    number = 0;
                    //viewRect.origin.x += viewRect.size.width;
                    contentView.frame = viewRect;
                    [contentView zoomReset];
                    
                    //[unusedViews removeObjectForKey:key];
        
                }
                [newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];
                
				[unusedViews removeObjectForKey:key];
			}

            
            viewRect.origin.x += viewRect.size.width;
            

        }
        [unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
           ^(id key, id object, BOOL *stop)
           {
               [contentViews removeObjectForKey:key];
               
               ReaderContentView *contentView = object;
               
               [contentView removeFromSuperview];
           }
           ];
        
        unusedViews = nil; // Release unused views
        
        CGFloat viewWidthX1 = viewRect.size.width;
        CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);
        
        CGPoint contentOffset = CGPointZero;
        
        if (maxPage >= PAGING_VIEWS)
        {
            if (page == maxPage)
                contentOffset.x = viewWidthX2;
            else
                if (page != minPage)
                    contentOffset.x = viewWidthX1;
        }
        else
            if (page == (PAGING_VIEWS - 1))
                contentOffset.x = viewWidthX1;
        
        if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
        {
            theScrollView.contentOffset = contentOffset; // Update content offset
        }
        
        if ([document.pageNumber integerValue] != page) // Only if different
        {
            document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
        }
        
        NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;
        
        if ([newPageSet containsIndex:page] == YES) // Preview visible page first
        {
            NSInteger previewLPage;
            
            
            if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
                previewLPage = page;
            else
                previewLPage = page;
            NSString *key =  [NSString stringWithFormat:@"%d-L",previewLPage]; // # key
            
            ReaderContentView *targetView = [contentViews objectForKey:key];
            
            [targetView showPageThumb:fileURL page:page password:phrase guid:guid];
            
            [newPageSet removeIndex:page]; // Remove visible page from set
        }
        
        [newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
         ^(NSUInteger number, BOOL *stop)
         {
             NSInteger previewLPage;
            if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
                 previewLPage = page+1;
             else
                 previewLPage = page-1;
             NSString *key =  [NSString stringWithFormat:@"%d-L",previewLPage];// # key
             
             ReaderContentView *targetView = [contentViews objectForKey:key];
             
             [targetView showPageThumb:fileURL page:number password:phrase guid:guid];
         }
         ];
 newPageSet = nil; // Release new page set
        
        [mainPagebar updatePagebar]; // Update the pagebar display
        
        [self updateToolbarBookmarkIcon]; // Update bookmark
        
        currentPage = page;
        NSLog(@"current page is %d",currentPage);
    }
    

    
    
    
    



    else{
    
		NSInteger minValue; NSInteger maxValue;
		NSInteger maxPage = totalPage;
		NSInteger minPage = 1;

		if ((page < minPage) || (page > maxPage)) return;

		if (maxPage <= PAGING_VIEWS) // Few pages
		{
			minValue = minPage;
			maxValue = maxPage;
		}
		else // Handle more pages
		{
			minValue = (page - 1);
			maxValue = (page + 1);

			if (minValue < minPage)
				{minValue++; maxValue++;}
			else
				if (maxValue > maxPage)
					{minValue--; maxValue--;}
		}

		NSMutableIndexSet *newPageSet = [NSMutableIndexSet new];

		NSMutableDictionary *unusedViews = [contentViews mutableCopy];

		CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;

		for (NSInteger number = minValue; number <= maxValue; number++)
		{
            NSLog(@"ADD Scrollview key:%d",number);
			NSNumber *key = [NSNumber numberWithInteger:number]; // # key

			ReaderContentView *contentView = [contentViews objectForKey:key];

			if (contentView == nil) // Create a brand new document content view
			{
				NSURL *fileURL = document.fileURL; NSString *phrase = document.password; // Document properties

				contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:number password:phrase];
                
				[theScrollView addSubview:contentView];
                
                [contentViews setObject:contentView forKey:key];
                
				contentView.message = self; [newPageSet addIndex:number];
			}
			else // Reposition the existing content view
			{
				contentView.frame = viewRect; [contentView zoomReset];

				[unusedViews removeObjectForKey:key];
			}

			viewRect.origin.x += viewRect.size.width;
		}

		[unusedViews enumerateKeysAndObjectsUsingBlock: // Remove unused views
			^(id key, id object, BOOL *stop)
			{
				[contentViews removeObjectForKey:key];

				ReaderContentView *contentView = object;

				[contentView removeFromSuperview];
			}
		];

		unusedViews = nil; // Release unused views

		CGFloat viewWidthX1 = viewRect.size.width;
		CGFloat viewWidthX2 = (viewWidthX1 * 2.0f);

		CGPoint contentOffset = CGPointZero;

		if (maxPage >= PAGING_VIEWS)
		{
			if (page == maxPage)
				contentOffset.x = viewWidthX2;
			else
				if (page != minPage)
					contentOffset.x = viewWidthX1;
		}
		else
			if (page == (PAGING_VIEWS - 1))
				contentOffset.x = viewWidthX1;

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == false)
		{
			theScrollView.contentOffset = contentOffset; // Update content offset
		}

		if ([document.pageNumber integerValue] != page) // Only if different
		{
			document.pageNumber = [NSNumber numberWithInteger:page]; // Update page number
		}

		NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid;

		if ([newPageSet containsIndex:page] == YES) // Preview visible page first
		{
			NSNumber *key = [NSNumber numberWithInteger:page]; // # key

			ReaderContentView *targetView = [contentViews objectForKey:key];

			[targetView showPageThumb:fileURL page:page password:phrase guid:guid];

			[newPageSet removeIndex:page]; // Remove visible page from set
		}

		[newPageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock: // Show previews
			^(NSUInteger number, BOOL *stop)
			{
				NSNumber *key = [NSNumber numberWithInteger:number]; // # key

				ReaderContentView *targetView = [contentViews objectForKey:key];

				[targetView showPageThumb:fileURL page:number password:phrase guid:guid];
			}
		];

		newPageSet = nil; // Release new page set

		[mainPagebar updatePagebar]; // Update the pagebar display

		[self updateToolbarBookmarkIcon]; // Update bookmark

		currentPage = page; // Track current page number
	}
     bSpecialRotate = NO;
}

- (void)showDocument:(id)object
{
	[self updateScrollViewContentSize]; // Set content size

	[self showDocumentPage:[document.pageNumber integerValue]];

	document.lastOpen = [NSDate date]; // Update last opened date

	isVisible = YES; // iOS present modal bodge
}

- (ReaderFlipMode)flipMode {
    return document.flipMode;
}

#pragma mark readFromPlistData methods
- (void)readFromPlistData
{
    
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",bookNumber];
	
	
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{
        
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
	//[fileManager release];
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
	bookName = [bookSetting objectForKey:@"bookName"];
    NSLog(@"bookName:%@",bookName);
    bPrintable = [[bookSetting objectForKey:@"printable"] boolValue];
    bMailable = [[bookSetting objectForKey:@"mailable"] boolValue];
    bBookmarkable = [[bookSetting objectForKey:@"bookmarkable"] boolValue];
    
    
    NSLog(@"printable:%@",bPrintable ? @"Yes" : @"No");
    NSLog(@"mailable:%@",bMailable ? @"Yes" : @"No");
    NSLog(@"bookmarkable:%@",bBookmarkable  ? @"Yes" : @"No");
   
}

#pragma mark -
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        NSLog(@"Menu Closed");
        //self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        NSLog(@"Menu Not Closed");
        //self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

#pragma mark -
#pragma mark - IndexJumpEvent

- (void)bookDidJumpIndex:(NSNotification *)notification {
    NSString *indexNumber = notification.object;
    NSLog(@"index %@",indexNumber);
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger totalPage = [document.pageCount integerValue];
    NSInteger value = [indexNumber integerValue]; // Number
    if(appDelegate.bookDirectionMode == ReaderFlipModeRight) {
        value = totalPage - value+1;
        
    }
    [self showDocumentPage:value]; // Show the page
    
    
}

#pragma mark UIViewController methods

- (id)initWithReaderDocument:(ReaderDocument *)object
{
	id reader = nil; // ReaderViewController object

	if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]]))
	{
		if ((self = [super initWithNibName:nil bundle:nil])) // Designated initializer
		{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];

			[object updateProperties]; document = object; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory

			reader = self; // Return an initialized ReaderViewController object
            
            bookNumber = [object.fileName stringByDeletingPathExtension];
		}
	}

	return reader;
}

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
    NSArray *bookInfo  = [self readBookDirectionFromPlist:bookNumber];
    NSInteger iDir_ = [[bookInfo objectAtIndex:0] integerValue];
    NSInteger iWidth_ = [[bookInfo objectAtIndex:1] integerValue];
    NSInteger iHeight_ = [[bookInfo objectAtIndex:2] integerValue];
    appDelegate.bookDirectionMode = iDir_;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
        
        
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            float rectRadio =(float)iHeight_/((float)iWidth_*2.0f);
            if(rectRadio <= 0.75)
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

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    
    [self checkBookPara];

	assert(document != nil); // Must have a valid ReaderDocument

	self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

	CGRect viewRect = self.view.bounds; // View controller's view bounds

	theScrollView = [[UIScrollView alloc] initWithFrame:viewRect]; // All

	theScrollView.scrollsToTop = NO;
	theScrollView.pagingEnabled = YES;
	theScrollView.delaysContentTouches = NO;
	theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.showsHorizontalScrollIndicator = NO;
	theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	theScrollView.backgroundColor = [UIColor clearColor];
	theScrollView.userInteractionEnabled = YES;
	theScrollView.autoresizesSubviews = NO;
	theScrollView.delegate = self;

	[self.view addSubview:theScrollView];

	CGRect toolbarRect = viewRect;
	toolbarRect.size.height = TOOLBAR_HEIGHT;
    
    [self readFromPlistData];
    

	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document title:bookName]; // At top

	mainToolbar.delegate = self;

	[self.view addSubview:mainToolbar];

	CGRect pagebarRect = viewRect;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (viewRect.size.height - PAGEBAR_HEIGHT);

	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // At bottom

	mainPagebar.delegate = self;

	[self.view addSubview:mainPagebar];

	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];

	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    
    [self setupMenuBarButtonItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookDidJumpIndex:)
                                                 name:kBookDidJumpIndex
                                               object:nil];

}




- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateScrollViewContentViews]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero)) // First time
	{
		[self performSelector:@selector(showDocument:) withObject:nil afterDelay:0.02];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
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

	mainToolbar = nil; mainPagebar = nil;

	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (isVisible == NO) return; // iOS present modal bodge
    [self checkBookPara];
	[self updateScrollViewContentViews]; // Update content views
    [self showDocumentPage:currentPage];
	lastAppearSize = CGSizeZero; // Reset view size tracking
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	//if (isVisible == NO) return; // iOS present modal bodge

	//if (fromInterfaceOrientation == self.interfaceOrientation) return;
}
*/

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	__block NSInteger page = 0;

	CGFloat contentOffsetX = scrollView.contentOffset.x;

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(id key, id object, BOOL *stop)
		{
			ReaderContentView *contentView = object;

			if (contentView.frame.origin.x == contentOffsetX)
			{
				page = contentView.tag; *stop = YES;
			}
		}
	];
    //special case by johnliu33
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation) &&appDelegate.bookDirectionMode == ReaderFlipModeRight && [document.pageCount integerValue]%2 == 1)
    {
        if(page == [document.pageCount integerValue])
            page +=2;
        else if(page > 1 && page != [document.pageCount integerValue])
            page +=1;
        
        
    }

	if (page != 0) [self showDocumentPage:page]; // Show the page
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self showDocumentPage:theScrollView.tag]; // Show page

	theScrollView.tag = 0; // Clear page number tag
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum
         UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
         eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDelegate.bookDirectionMode == ReaderFlipModeRight && UIInterfaceOrientationIsLandscape(orientation))
        {
            minPage = 0;
        }
		if ((maxPage > minPage) && (page != minPage))
		{
			CGPoint contentOffset = theScrollView.contentOffset;

            contentOffset.x -= theScrollView.bounds.size.width; // -= 1

			[theScrollView setContentOffset:contentOffset animated:YES];

           
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                NSInteger lPage;
                if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
                {
                    lPage = page - 2;
                }else{
                    lPage = page - 1;
                    if(lPage < minPage)
                        lPage = minPage;
                }
                theScrollView.tag = lPage;//2); // Decrement page number
            } else {
                theScrollView.tag = (page - 1); // Decrement page number
            }
		}
	}
}

- (void)incrementPageNumber
{
	if (theScrollView.tag == 0) // Scroll view did end
	{
		NSInteger page = [document.pageNumber integerValue];
		NSInteger maxPage = [document.pageCount integerValue];
		NSInteger minPage = 1; // Minimum

		if ((maxPage > minPage) && (page != maxPage))
		{
            UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
            if(UIInterfaceOrientationIsLandscape(orientation))
            {
                if(page == maxPage-1) return;
            }
            
			CGPoint contentOffset = theScrollView.contentOffset;
          
            contentOffset.x += theScrollView.bounds.size.width; // += 1
          

			[theScrollView setContentOffset:contentOffset animated:YES];

            eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                NSInteger lPage;
                if(appDelegate.bookDirectionMode == ReaderFlipModeLeft)
                {
                    lPage = page + 1;
                }
                else
                {
                    lPage = page + 3;
                    if(lPage > maxPage)
                        lPage = page+2;
                }
                 
    
                theScrollView.tag = (lPage); // Increment page number
            } else {
                theScrollView.tag = (page + 1); // Increment page number
            }
		}
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area

		if (CGRectContainsPoint(areaRect, point)) // Single tap is inside the area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #

            
			NSObject *key;
            
            UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
            if(UIInterfaceOrientationIsLandscape(orientation)){
                if(page == 2)
                    page = 0;
                key = [NSString stringWithFormat:@"%d-L",page];
                
            } else {
                key = [NSNumber numberWithInteger:page]; // Page number key
            }
            //NSArray *allkey = [contentViews allKeys];
            
			ReaderContentView *targetView = [contentViews objectForKey:key];

			id target = [targetView processSingleTap:recognizer]; // Target

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object

					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string

						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [NSString stringWithFormat:@"http://%@", www];

							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}

					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
						#ifdef DEBUG
							NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
						#endif
					}
				}
				else // Not a URL, so check for other possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
                        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
                        NSInteger totalPage = [document.pageCount integerValue];
						NSInteger value = [target integerValue]; // Number
                        if(appDelegate.bookDirectionMode == ReaderFlipModeRight) {
                            value = totalPage - value+1;
                            
                        }
						[self showDocumentPage:value]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.hidden == YES) || (mainPagebar.hidden == YES))
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
            
            [self incrementPageNumber]; return;
            
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
            
            [self decrementPageNumber]; return;
           
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view];

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE);

		if (CGRectContainsPoint(zoomArea, point)) // Double tap is in the zoom area
		{
			NSInteger page = [document.pageNumber integerValue]; // Current page #
            ReaderContentView *targetView;
            UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
            if(UIInterfaceOrientationIsLandscape(orientation))
            {
                NSString *key = [NSString stringWithFormat:@"%d-L",page];
                targetView = [contentViews objectForKey:key];
                
            }
            else{
                NSNumber *key = [NSNumber numberWithInteger:page];
                targetView = [contentViews objectForKey:key];// Page number key
            }

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom ++
				{
					[targetView zoomIncrement]; break;
				}

				case 2: // Two finger double tap: zoom --
				{
					[targetView zoomDecrement]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point)) // page++ area
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point)) // page-- area
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.hidden == NO) || (mainPagebar.hidden == NO))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide

		lastHideTime = [NSDate date];
	}
}

#pragma mark ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option

	[document saveReaderDocument]; // Save any ReaderDocument object changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController: error"
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}

#endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
	/*if (printInteraction != nil) [printInteraction dismissAnimated:NO]; // Dismiss

	ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];

	thumbsViewController.delegate = self; thumbsViewController.title = self.title;

	thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;

	[self presentModalViewController:thumbsViewController animated:NO];*/
    
    NSLog(@"present thumb");
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems];
    }];
    /*- (void)leftSideMenuButtonPressed:(id)sender {
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            [self setupMenuBarButtonItems];
        }];
    }*/
}




- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
#if (READER_ENABLE_PRINT == TRUE) // Option

	Class printInteractionController = NSClassFromString(@"UIPrintInteractionController");

	if ((printInteractionController != nil) && [printInteractionController isPrintingAvailable])
	{
		NSURL *fileURL = document.fileURL; // Document file URL

		printInteraction = [printInteractionController sharedPrintController];

		if ([printInteractionController canPrintURL:fileURL] == YES) // Check first
		{
			UIPrintInfo *printInfo = [NSClassFromString(@"UIPrintInfo") printInfo];

			printInfo.duplex = UIPrintInfoDuplexLongEdge;
			printInfo.outputType = UIPrintInfoOutputGeneral;
			printInfo.jobName = document.fileName;

			printInteraction.printInfo = printInfo;
			printInteraction.printingItem = fileURL;
			printInteraction.showsPageRange = YES;

			if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			{
				[printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
			else // Presume UIUserInterfaceIdiomPhone
			{
				[printInteraction presentAnimated:YES completionHandler:
					^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
					{
						#ifdef DEBUG
							if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
						#endif
					}
				];
			}
		}
	}

#endif // end of READER_ENABLE_PRINT Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
#if (READER_ENABLE_MAIL == TRUE) // Option

	if ([MFMailComposeViewController canSendMail] == NO) return;

	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

	unsigned long long fileSize = [document.fileSize unsignedLongLongValue];

	if (fileSize < (unsigned long long)15728640) // Check attachment size limit (15MB)
	{
		NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName; // Document

		NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];

		if (attachment != nil) // Ensure that we have valid document file attachment data
		{
			MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];

			[mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];

			[mailComposer setSubject:fileName]; // Use the document file name for the subject

			mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;

			mailComposer.mailComposeDelegate = self; // Set the delegate

			[self presentModalViewController:mailComposer animated:YES];
		}
	}

#endif // end of READER_ENABLE_MAIL Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
	if (printInteraction != nil) [printInteraction dismissAnimated:YES];

   
    UIInterfaceOrientation orientation= [[UIApplication sharedApplication] statusBarOrientation];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(UIInterfaceOrientationIsLandscape(orientation) && appDelegate.bookDirectionMode == ReaderFlipModeRight)
    {
       //special mode for landscape && Right Flip
        NSInteger totalPage = [document.pageCount integerValue];
        NSInteger page = totalPage - [document.pageNumber integerValue]-1;
        NSInteger page1;
        
        if(page%2 == 0)
            page1 = page+1;
        else
            page1 = page-1;
        
        if(page1 == totalPage-1)
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
        else if(page == 0)
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
        else
        {
            if ([document.bookmarks containsIndex:page] || [document.bookmarks containsIndex:page1])
            {
                [mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page];
                [mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page1];
            }else
            {
                [mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page];
                [mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page1];

            }
        }

    }
    else
    {
        NSInteger page = [document.pageNumber integerValue];

        NSInteger totalPage = [document.pageCount integerValue];
        if(appDelegate.bookDirectionMode == ReaderFlipModeRight)
        {
          
                page = totalPage - page + 1 ; // Show the reverted page
        }
        
        if ([document.bookmarks containsIndex:page]) // Remove bookmark
        {
            [mainToolbar setBookmarkState:NO]; [document.bookmarks removeIndex:page];
        }
        else // Add the bookmarked page index to the bookmarks set
        {
            [mainToolbar setBookmarkState:YES]; [document.bookmarks addIndex:page];
        }
    }
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	#ifdef DEBUG
		if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
	#endif

	[self dismissModalViewControllerAnimated:YES]; // Dismiss
}

#pragma mark ThumbsViewControllerDelegate methods

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
	[self updateToolbarBookmarkIcon]; // Update bookmark icon

	[self dismissModalViewControllerAnimated:NO]; // Dismiss
}

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
    
	[self showDocumentPage:page]; // Show the page
}

- (void)updateZoomSize:(ThumbsViewController *)viewController
{
    bSpecialRotate = YES;
}

#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
	[self showDocumentPage:page]; // Show the page
}

#pragma mark UIApplication notification methods

- (void)applicationWill:(NSNotification *)notification
{
	[document saveReaderDocument]; // Save any ReaderDocument object changes

	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		if (printInteraction != nil) [printInteraction dismissAnimated:NO];
	}
}

@end