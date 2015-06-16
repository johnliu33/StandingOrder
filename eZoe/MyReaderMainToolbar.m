 //
//	MyReaderMainToolbar.m
//	Reader v2.5.4
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

#import "MyReaderConstants.h"
#import "MyReaderMainToolbar.h"
//#import "ReaderDocument.h"
#import "MKStoreManager.h"

#import <MessageUI/MessageUI.h>

@implementation MyReaderMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 2.0f//8.0f
#define BUTTON_HEIGHT 30.0f

#define ICON_BUTTON_WIDTH 40.0f

#define DONE_BUTTON_WIDTH 56.0f
#define THUMBS_BUTTON_WIDTH 40.0f
#define TRANSLATE_BUTTON_WIDTH 40.0f
#define VOICE_BUTTON_WIDTH 40.0f
#define SEARCH_BUTTON_WIDTH 40.0f
#define SETTING_BUTTON_WIDTH 40.0f
#define MARK_BUTTON_WIDTH 40.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark MyReaderMainToolbar instance methods

/*- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	return [self initWithFrame:frame document:nil];
}*/

/*-(void)popover:(id)sender
{
    //the controller we want to present as a popover
    DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
    
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:controller];
    [controller release];
    
    //popover.arrowDirection = FPPopoverArrowDirectionAny;
    popover.tint = FPPopoverDefaultTint;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover.contentSize = CGSizeMake(300, 500);
    }
    popover.arrowDirection = FPPopoverArrowDirectionAny;
    
    //sender is the UIButton view
    [popover presentPopoverFromView:sender];
}*/


- (id)initWithFrame:(CGRect)frame //document:(ReaderDocument *)object
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

    if([MKStoreManager isFeaturePurchased:@"tw.org.twgbr.HolyWords.b8889"])
        bVoicePurchased = YES;
    else
        bVoicePurchased = NO; //voice must change back before submit
	//assert(object != nil); // Check
    
	if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)]))
	{
		CGFloat viewWidth = self.bounds.size.width;

#if (READER_FLAT_UI == TRUE) // Option
        UIImage *buttonH = nil; UIImage *buttonN = nil;
#else
        UIImage *buttonH = [[UIImage imageNamed:@"Reader-Button-H"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        UIImage *buttonN = [[UIImage imageNamed:@"Reader-Button-N"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
#endif // end of READER_FLAT_UI Option
        
        BOOL largeDevice = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
        
        const CGFloat buttonSpacing = BUTTON_SPACE; const CGFloat iconButtonWidth = ICON_BUTTON_WIDTH;
        
        CGFloat titleX = BUTTON_X; CGFloat titleWidth = (viewWidth - (titleX + titleX));
        
        CGFloat leftButtonX = BUTTON_X; // Left-side button start X position

#if (READER_STANDALONE == FALSE) // Option

		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];

		doneButton.frame = CGRectMake(leftButtonX, BUTTON_Y, DONE_BUTTON_WIDTH, BUTTON_HEIGHT);
		[doneButton setTitle:NSLocalizedString(@"書櫃", @"button") forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
		[doneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[doneButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[doneButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
		doneButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:doneButton]; leftButtonX += (DONE_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (DONE_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (DONE_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_STANDALONE Option

#if (READER_ENABLE_INDEX == TRUE) // Option

		UIButton *thumbsButton = [UIButton buttonWithType:UIButtonTypeCustom];

		thumbsButton.frame = CGRectMake(leftButtonX, BUTTON_Y, THUMBS_BUTTON_WIDTH, BUTTON_HEIGHT);
		[thumbsButton setImage:[UIImage imageNamed:@"Reader-Thumbs-pub.png"] forState:UIControlStateNormal];
		[thumbsButton addTarget:self action:@selector(thumbsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[thumbsButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[thumbsButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		thumbsButton.autoresizingMask = UIViewAutoresizingNone;

		[self addSubview:thumbsButton]; //leftButtonX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

		titleX += (THUMBS_BUTTON_WIDTH + BUTTON_SPACE); titleWidth -= (THUMBS_BUTTON_WIDTH + BUTTON_SPACE);

#endif // end of READER_ENABLE_INDEX Option

		CGFloat rightButtonX = viewWidth; // Right button start X position

#if (READER_BOOKMARKS == TRUE) // Option

		rightButtonX -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];

		flagButton.frame = CGRectMake(rightButtonX, BUTTON_Y, MARK_BUTTON_WIDTH, BUTTON_HEIGHT);
		[flagButton setImage:[UIImage imageNamed:@"Reader-Mark-pub-N.png"] forState:UIControlStateNormal];
		[flagButton addTarget:self action:@selector(markButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[flagButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
		[flagButton setBackgroundImage:buttonN forState:UIControlStateNormal];
		flagButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

		[self addSubview:flagButton]; titleWidth -= (MARK_BUTTON_WIDTH + BUTTON_SPACE);

		markButton = [flagButton retain]; markButton.enabled = NO; markButton.tag = NSIntegerMin;

		markImageN = [[UIImage imageNamed:@"Reader-Mark-pub-N.png"] retain]; // N image
		markImageY = [[UIImage imageNamed:@"Reader-Mark-pub-Y.png"] retain]; // Y image

#endif // end of READER_BOOKMARKS Option

#if (READER_ENABLE_SETTING == TRUE) // Option
        
        rightButtonX -= (SETTING_BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        settingButton.frame = CGRectMake(rightButtonX, BUTTON_Y, SETTING_BUTTON_WIDTH, BUTTON_HEIGHT);
        [settingButton setImage:[UIImage imageNamed:@"setting.png"] forState:UIControlStateNormal];
        [settingButton addTarget:self action:@selector(settingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [settingButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [settingButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        settingButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [self addSubview:settingButton]; titleWidth -= (SETTING_BUTTON_WIDTH + BUTTON_SPACE);
        
#endif // end of READER_ENABLE_SETTING Option
#if (READER_ENABLE_TRANSLATE == TRUE) // Option
        rightButtonX -= (TRANSLATE_BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *translateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        translateButton.frame = CGRectMake(rightButtonX, BUTTON_Y, TRANSLATE_BUTTON_WIDTH, BUTTON_HEIGHT);
        [translateButton setImage:[UIImage imageNamed:@"sim.png"] forState:UIControlStateNormal];
        [translateButton addTarget:self action:@selector(translateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [translateButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [translateButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        translateButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [self addSubview:translateButton]; titleWidth -= (TRANSLATE_BUTTON_WIDTH + BUTTON_SPACE);
        
        transButton = [translateButton retain]; transButton.enabled = YES; transButton.tag = NSIntegerMin;
        
        transImageT = [[UIImage imageNamed:@"tra.png"] retain]; //Tradition Chinese image
        transImageS = [[UIImage imageNamed:@"sim.png"] retain]; //Simplify Chinese image
        
#endif // end of READER_ENABLE_TRANSLATE Option
#if (READER_ENABLE_SEARCH == TRUE) // Option
        rightButtonX -= (SEARCH_BUTTON_WIDTH + BUTTON_SPACE);
        
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        searchButton.frame = CGRectMake(rightButtonX, BUTTON_Y, SEARCH_BUTTON_WIDTH, BUTTON_HEIGHT);
        [searchButton setImage:[UIImage imageNamed:@"search1.png"] forState:UIControlStateNormal];
        [searchButton addTarget:self action:@selector(searchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [searchButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
        [searchButton setBackgroundImage:buttonN forState:UIControlStateNormal];
        searchButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [self addSubview:searchButton]; titleWidth -= (SEARCH_BUTTON_WIDTH + BUTTON_SPACE);
        

#endif // end of READER_ENABLE_SEARCH Option
#if (READER_ENABLE_VOICE == TRUE) // Option
        if(bVoicePurchased)
        {
            rightButtonX -= (VOICE_BUTTON_WIDTH + BUTTON_SPACE);
            
            UIButton *vButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            vButton.frame = CGRectMake(rightButtonX, BUTTON_Y, VOICE_BUTTON_WIDTH, BUTTON_HEIGHT);
            [vButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
            [vButton addTarget:self action:@selector(voiceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [vButton setBackgroundImage:buttonH forState:UIControlStateHighlighted];
            [vButton setBackgroundImage:buttonN forState:UIControlStateNormal];
            vButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            [self addSubview:vButton]; titleWidth -= (VOICE_BUTTON_WIDTH + BUTTON_SPACE);
            
            voiceButton = [vButton retain]; voiceButton.enabled = YES; voiceButton.tag = NSIntegerMin;
            
            voiceImagePlay = [[UIImage imageNamed:@"voice.png"] retain]; //Tradition Chinese image
            voiceImagePauced = [[UIImage imageNamed:@"pause.png"] retain]; //Simplify Chinese image
        }
        
#endif // end of READER_ENABLE_VOICE Option

		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			CGRect titleRect = CGRectMake(titleX, BUTTON_Y, titleWidth, TITLE_HEIGHT);

			UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];

			titleLabel.textAlignment = UITextAlignmentCenter;
			titleLabel.font = [UIFont systemFontOfSize:19.0f]; // 19 pt
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
			titleLabel.shadowColor = [UIColor colorWithWhite:0.65f alpha:1.0f];
			titleLabel.backgroundColor = [UIColor clearColor];
			titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
			titleLabel.adjustsFontSizeToFitWidth = YES;
			titleLabel.minimumFontSize = 14.0f;
            //NSString *_title = [object.fileName stringByDeletingPathExtension];//[NSString stringWithFormat:@"論壇報第%@期",[object.fileName stringByDeletingPathExtension]];
            NSString *_title = @"";
			titleLabel.text = _title;

			[self addSubview:titleLabel]; [titleLabel release];
		}
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[markButton release], markButton = nil;

	[markImageN release], markImageN = nil;
	[markImageY release], markImageY = nil;
    
    [transButton release], transButton = nil;
    
    [transImageT release], transImageT = nil;
    [transImageS release], transImageS = nil;

	[super dealloc];
}
- (void)setVoicePlayPauced:(BOOL)type
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
#if (READER_ENABLE_VOICE == TRUE) // Option
    
	if (type != voiceButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (type ? voiceImagePlay : voiceImagePauced);
            
			[voiceButton setImage:image forState:UIControlStateNormal];
		}
        
		voiceButton.tag = type; // Update bookmarked state tag
	}
    
	if (voiceButton.enabled == NO) voiceButton.enabled = YES;
    
#endif // end of READER_VOICE Option
}

- (void)setTranslateLang:(BOOL)langTra
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
#if (READER_ENABLE_TRANSLATE == TRUE) // Option
    
	if (langTra != transButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (langTra ? transImageT : transImageS);
            
			[transButton setImage:image forState:UIControlStateNormal];
		}
        
		transButton.tag = langTra; // Update bookmarked state tag
	}
    
	if (transButton.enabled == NO) transButton.enabled = YES;
    
#endif // end of READER_BOOKMARKS Option
}

- (void)setBookmarkState:(BOOL)state
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		//UIImage *image = (state ? markImageY : markImageN);
        UIImage *image = markImageN;

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

    //UIApplication *sharedApplication = [UIApplication sharedApplication];
    //[sharedApplication setStatusBarHidden:!sharedApplication.statusBarHidden withAnimation:UIStatusBarAnimationSlide];
    
	if (self.hidden == NO)
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

- (void)showToolbar
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	if (self.hidden == YES)
	{
        UIApplication *sharedApplication = [UIApplication sharedApplication];
		[sharedApplication setStatusBarHidden:!sharedApplication.statusBarHidden withAnimation:UIStatusBarAnimationSlide];
        
		[self updateBookmarkImage]; // First

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

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self thumbsButton:button];
}
//
- (void)voiceButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	[delegate tappedInToolbar:self voiceButton:button];
}
- (void)translateButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self translateButton:button];
}


- (void)settingButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
	NSLog(@"test");
   // [self popover:button];
    [delegate tappedInToolbar:self settingButton:button];
    
}

- (void)searchButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self searchButton:button];
}

- (void)markButtonTapped:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[delegate tappedInToolbar:self markButton:button];
}

@end
