#import "MyWebViewController.h"
//#import "IIViewDeckController.h"
//ToolBar
#define TOOLBAR_HEIGHT 44.0f


//Dictionary look up
#import "KNThirdViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "KNModalTableViewController.h"
#import "KNModalEngDIctTableViewController.h"
//popover
#import "DemoTableController.h"

#import "FPPopoverController.h"
#import "FPDemoTableViewController.h"



// LOADER STYLE
// Configure this to change the color of the loader
#define SCROLLVIEW_BGCOLOR whiteColor
#define PAGE_NUMBERS_COLOR blackColor
#define PAGE_NUMBERS_ALPHA 0.2

// PINCH-TO-ZOOM
// Enable pinch-to-zoom on the book page.
//   NO (Default) - Because it creates a more uniform reading experience: you should zoom only specific items with JavaScript.
//   YES - Not recommended. You have to manually set the zoom in EACH of your HTML files.
#define PAGE_ZOOM_GESTURE NO

// VERTICAL BOUNCE
// Enable bounce effect on vertical scrolls.
// Should be set to NO only when the book pages don't need any vertical scrolling.
#define PAGE_VERTICAL_BOUNCE YES

// MEDIA PLAYBACK REQUIRES USER ACTION
// Enable automatic HTML5 media playback
//   YES (Default) - Media required user action to be started.
//   NO - Media can be played automatically.
#define MEDIA_PLAYBACK_REQUIRES_USER_ACTION YES

// TEXT LABELS
#define OPEN_BOOK_MESSAGE @"Do you want to download "
#define OPEN_BOOK_CONFIRM @"Open book"

#define CLOSE_BOOK_MESSAGE @"Do you want to close this book?"
#define CLOSE_BOOK_CONFIRM @"Close book"

#define ZERO_PAGES_TITLE @"Whoops!"
#define ZERO_PAGES_MESSAGE @"Sorry, that book had no pages."

#define ERROR_FEEDBACK_TITLE @"Whoops!"
#define ERROR_FEEDBACK_MESSAGE @"There was a problem downloading the book."
#define ERROR_FEEDBACK_CONFIRM @"Retry"

#define EXTRACT_FEEDBACK_TITLE @"Extracting..."

#define ALERT_FEEDBACK_CANCEL @"Cancel"

// AVAILABLE ORIENTATION
// Define the available orientation of the book
//	@"Any" (Default) - Book is available in both orientation
//	@"Portrait" - Book is available only in portrait orientation
//	@"Landscape" - Book is available only in landscape orientation
#define	AVAILABLE_ORIENTATION @"Any"

#define INDEX_FILE_NAME @"index.html"

#define PAGING_VIEWS 3

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define TAP_AREA_SIZE 48.0f

@implementation UIBarButtonItem(MyCategory)
+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];
    
    button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    
    [button addTarget:target action:action  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *forward = [[UIBarButtonItem alloc] initWithCustomView:button];
    return forward;
}
@end

@implementation MyWebViewController
@synthesize backImageView;
@synthesize sBookName;
@synthesize _iFontSize;
@synthesize _iFontType;
@synthesize _iBGType;
@synthesize _iVoiceType;
@synthesize _iVoiceSpeed;
//Book mark
@synthesize _bookMarkedPages;
//Mark the text
@synthesize _markedTextInfo;


//Scroll controll
//@synthesize documentsBookPath;
@synthesize bundleBookPath;

@synthesize pagesNumberForShowInTheBottom;
@synthesize pageNameFromURL;
@synthesize anchorFromURL;

@synthesize scrollView;
@synthesize pageSpinners;

@synthesize currPage;
@synthesize prevPage;
@synthesize nextPage;
//@synthesize nextPage1;


@synthesize tapNumber;
@synthesize lastPageNumber;
@synthesize currentPageNumber;

@synthesize _menusearchText;

@synthesize delegate;
@synthesize jsBridge = _jsBridge;

@synthesize parseHtml = _parseHtml;
@synthesize arrayForStoreTheContentPage;
//@synthesize btn = _btn;

//NSString *DB_NAME_ = @"TGJSBridge";
//NSString *DB_EXT_ = @".js";
//---------------
//pop over


#pragma mark -
#pragma mark jsBridge methods
- (void)buttonPressed:(id)sender {
    [self.jsBridge postNotificationName:@"test1" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"click by uibutton",@"message", nil] toWebView:self.currPage];
    
}

- (void)jsBridge:(TGJSBridge *)bridge didReceivedNotificationName:(NSString *)name userInfo:(NSDictionary *)userInfo fromWebView:(UIWebView *)webview
{
    //[self.btn setTitle:[userInfo objectForKey:@"message"] forState:UIControlStateNormal];
    NSString *jsMessage_ = [userInfo objectForKey:@"message"];
    NSString *jsType = [jsMessage_ substringToIndex:4];
    NSString *jsPara = [jsMessage_ substringFromIndex:5];
    NSLog(@"jsType:%@,jsPara:%@",jsType,jsPara);
    if([jsType isEqualToString:@"page"])
    {
        NSInteger jumpPageNum =  [jsPara intValue];
        iPage = jumpPageNum+_iPrepageTotal;
        int page = iPage + 1;
        delayLoadingTime = 0.5;
        [self changePage:page];
    }else if([jsType isEqualToString:@"note"])
    {
        //NSLog(@"jsPara:%@",jsPara);
        [self ShowTheNote:jsPara];
    }
}

/*- (NSString *) getJsFullPath{
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@%@",DB_NAME_, DB_EXT_]];
 return path;
 
 }*/
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


- (void) copyJsFileIfNeeded:(NSString *)DB_NAME_ extName:(NSString *)DB_EXT_{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *jsPath = [[NSString stringWithFormat:@"%@%@",DB_NAME_,DB_EXT_] getDocPathWithPList];//[self getJsFullPath];
    BOOL success = [fileManager fileExistsAtPath:jsPath]; 
	
    if(!success) {
		
        NSString *defaultJSPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@%@",DB_NAME_, @".txt"]];
        NSLog(@"defaultJSPath:%@",defaultJSPath);
        success = [fileManager copyItemAtPath:defaultJSPath toPath:jsPath error:&error];
        NSLog(@"Database file copied from bundle to %@", jsPath);
		
        if (!success){ 
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
        
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:jsPath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",jsPath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",jsPath);
        
    } else {
        
        NSLog(@"Database file found at path %@", jsPath);
		
    }
}

#pragma mark -
#pragma mark initial methods
//navigator的起始
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if ((self = [self initWithNibName:nil bundle:nil])) {
        NSString* request = [query objectForKey:@"book"];
        if (nil != request) {
            eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
            //[self openRequest:request];
            if(![request isEqualToString:@"rotate"])
            {
                sBookName = request;
                appDelegate.sBookLastOpened = sBookName;
                //_iFontSize = 26;
                //_iFontType = 0;
                //_iBGType = 0;
                //iPage = 0;
                //iSliderInitPosition = _iPrepageTotal*-1;
                bRotate = NO;
                
                
                
                
            }else
            {
                sBookName = appDelegate.sBookLastOpened;
                //_iFontSize = 26;
                //_iFontType = 0;
                //_iBGType = 0;
                //iPage = appDelegate.iBookLastPage;
                //iSliderInitPosition = iShowingPageIdx+_iPrepageTotal-1;
                bRotate = YES;
            }
            
            
            [self openURL:URL];
            //[self shouldAutorotateToInterfaceOrientation:self.interfaceOrientation];
        } else {
            [self openURL:URL];
        }
    }
    return self;
}
-(NSInteger)rangeProtection:(NSInteger)pageNumber
{
    if(pageNumber <= 0) 
        pageNumber = 1;
    else if(pageNumber > [arrayForStoreTheContentPage count])
        pageNumber = [arrayForStoreTheContentPage count] - 2;
    
    return  pageNumber;
}
//儲存rotate(或關閉前的資訊)
-(void)setBookLastPage
{
    [popController dismissPopoverAnimated:NO];
    [self stopAudio];
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!bRotate)
    {
        currentPageNumber = [self rangeProtection:currentPageNumber];
        NSString *_paraGraph = [arrayForStoreTheContentPage objectAtIndex:currentPageNumber-1];
        //NSLog(@"allHtml in currentpage:%@",_paraGraph);
        NSRange r = [_paraGraph rangeOfString:@"id=\""];
        if(r.location != NSNotFound)
        {
            NSRange _rforSave = NSMakeRange(r.location+4, 6);
            NSString *_idforSave = [_paraGraph substringWithRange:_rforSave];
            //NSLog(@"_idforSave:%@",_idforSave);
            appDelegate.sIdForRef = _idforSave;
        }else
        {
            appDelegate.sIdForRef = @"";
        }
        appDelegate.iBookLastPagePercent = (NSInteger)[self convertPagePercent:currentPageNumber pageCount:[arrayForStoreTheContentPage count]];
        appDelegate.iFontLastSize = _iFontSize;
        appDelegate.iFontLastType = _iFontType;
        appDelegate.iBGLastType = _iBGType;
        appDelegate.iVoiceLastType = _iVoiceType;
        appDelegate.iVoiceLastSpeed = _iVoiceSpeed;
        NSString *myPath = [@"setting.plist" getDocPathWithPList];
        
        NSMutableDictionary *mysetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
        NSString *_FontLastSize = [NSString stringWithFormat:@"%d",_iFontSize];
        [mysetting setObject:_FontLastSize forKey:@"lastFontSize"];
        NSString *_FontLastType = [NSString stringWithFormat:@"%d",_iFontType];
        [mysetting setObject:_FontLastType forKey:@"lastFontType"];
        NSString *_BGLastType = [NSString stringWithFormat:@"%d",_iBGType];
        [mysetting setObject:_BGLastType forKey:@"lastBGType"];
        NSString *_VoiceLastType = [NSString stringWithFormat:@"%d",_iVoiceType];
        [mysetting setObject:_VoiceLastType forKey:@"option0"];
        NSString *_VoiceLastSpeed = [NSString stringWithFormat:@"%d",_iVoiceSpeed];
        [mysetting setObject:_VoiceLastSpeed forKey:@"option1"];
        NSString *_lastLang = [NSString stringWithFormat:@"%d",appDelegate.iBookLastLang];
        [mysetting setObject:_lastLang forKey:@"lastLang"];
        
        [mysetting writeToFile:myPath atomically:YES];
        
    }
    //NSLog(@"[setBookLastPage]appDelegate.iBookLastPagePercent:%d,_f:%f = (iPage:%d)/_array_count:%d*100;",appDelegate.iBookLastPagePercent,_f,iPage,_array_count);
    /*if(!TTIsOrienLandscape())
     {
     appDelegate.iBookLastShowingPageIdx = iShowingPageIdx-1;
     NSLog(@"[setBookLastPage]appDelegate.iBookLastShowingPageIdx:%d = iShowingPageIdx:%d-1;",appDelegate.iBookLastShowingPageIdx,iShowingPageIdx);
     }
     else
     {
     appDelegate.iBookLastShowingPageIdx = iShowingPageIdx+1;
     NSLog(@"[setBookLastPage]appDelegate.iBookLastShowingPageIdx:%d = iShowingPageIdx:%d+1;",appDelegate.iBookLastShowingPageIdx,iShowingPageIdx);
     
     }*/
    
    
    

}

- (id)initWithBookName:(NSString *)sbookName
{
    self.sBookName = sbookName;
    if (self = [self initWithNibName:nil bundle:nil]) {
    }
    
    return self;
}

//nav bar起始
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    /*
        self.navigationItem.backBarButtonItem =
        [[[UIBarButtonItem alloc]
          initWithTitle:
          TTLocalizedString(@"返回",
                            @"Back to the book")
          style: UIBarButtonItemStylePlain
          target: nil
          action: nil] autorelease];
        
        self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
        
        self.navigationBarStyle = UIBarStyleBlackTranslucent;
        self.navigationBarTintColor = nil;
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self showBars:YES animated:NO];
        CGRect iS =  TTScreenBounds();
        
        bVoicePurchased = YES;
        // create a toolbar where we can place some buttons
        CGFloat _flexableWidth;
        CGFloat fBigWidth;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(TTIsOrienLandscape())
            {
                _flexableWidth = 960.0f;
                fBigWidth = 710.0f;
            }else
            {
                _flexableWidth = 700.0f;
                fBigWidth = 450.0f;
            }
        }else
        {
            _flexableWidth = 264.0f;
            fBigWidth =  17.0f;
        }
        
        toolbar = [[TransparentToolbar alloc]
                   initWithFrame:CGRectMake(0, 0, _flexableWidth, iS.size.height)];
        
        // create an array for the buttons
        
        buttons = [[NSMutableArray alloc] initWithCapacity:bVoicePurchased?11:9];
        
        UIImage *imageIndex = [UIImage imageNamed:@"index.png"];
        UIImage *imageSim = [UIImage imageNamed:@"sim.png"];
        UIImage *imageUIControl = [UIImage imageNamed:@"setting.png"];
        UIImage *imageBookmark = [UIImage imageNamed:@"toolbarmark.png"];
        UIImage *imageSearch = [UIImage imageNamed:@"search1.png"];
        UIImage *imageAudioControl = [UIImage imageNamed:@"voice.png"];
        
            
        // create a spacer between the buttons
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
        CGFloat fWidth = 3;//bVoicePurchased?3:10;
        [spacer setWidth:fWidth];
        
        UIBarButtonItem *spacerBig = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                   target:nil
                                   action:nil];
        
        [spacerBig setWidth:fBigWidth];
 
        UIBarButtonItem *cusButton = [UIBarButtonItem barItemWithImage:imageIndex target:self action:@selector(jumpToIndex)];
        [buttons addObject:cusButton];
        [buttons addObject:spacerBig];
        
        audioControlButton = [UIBarButtonItem barItemWithImage:imageAudioControl target:self action:@selector(audioSpeech)];
        [buttons addObject:audioControlButton];        
        [buttons addObject:spacer];
        
        UIBarButtonItem *searchButton = [UIBarButtonItem barItemWithImage:imageSearch target:self action:@selector(searchPopover)];
        [buttons addObject:searchButton];
        [buttons addObject:spacer];
        
        traButton = [UIBarButtonItem barItemWithImage:imageSim target:self action:@selector(transChi)];
        [buttons addObject:traButton];
        
        UIBarButtonItem *uiPopButton = [UIBarButtonItem barItemWithImage:imageUIControl target:self action:@selector(uiControlPopover)];
        [buttons addObject:uiPopButton];
        [buttons addObject:spacer];
        
        UIBarButtonItem *bookmarkButton = [UIBarButtonItem barItemWithImage:imageBookmark target:self action:@selector(toggleBookMark)];
        [buttons addObject:bookmarkButton];
        [buttons addObject:spacer];

        
        
        // put the buttons in the toolbar and release them
        [toolbar setItems:buttons animated:NO];
        
        [spacer release];
        [spacerBig release];
        // place the toolbar into the navigation bar
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithCustomView:toolbar];
        
        */
        
    }
    
    return self;
     
}

- (void)initBook1
{
    
    //backImageView = [[UIImageView alloc] initWithImage:_bImage];
    //[self.view addSubview:backImageView];
    
    
    // Count pages
	//if (pagesNumberForShowInTheBottom != nil) {
        //[pagesNumberForShowInTheBottom removeAllObjects];//字型調為大字會閃退問題
	//} else {
    
		pagesNumberForShowInTheBottom = [NSMutableArray array];
    //}
	
    
    for (int _p = 0; _p < [arrayForStoreTheContentPage count]; _p++) {
        NSString *_sp = [NSString stringWithFormat:@"%d",_p];
        [pagesNumberForShowInTheBottom addObject:_sp];//crash201404
    }
    
    totalPages = [pagesNumberForShowInTheBottom count];
	//NSLog(@"Pages in this book: %d", totalPages);
    
    if (totalPages > 0) {
        //Modify by johnliu
        if(currentPageNumber == 0)
            currentPageNumber = 1;
        
		//------------------
        currentPageIsDelayingLoading = YES;
        
        //NSLog(@"%d",[scrollView retainCount]);
		[self resetScrollView];
        //NSLog(@"%d",[scrollView retainCount]);
        [scrollView addSubview:currPage];
        [self loadSlot:0 withPage:currentPageNumber];
       // NSLog(@"%d",[scrollView retainCount]);
        if (currentPageNumber != totalPages) {
            if (nextPage.superview != scrollView) [scrollView addSubview:nextPage];
            [self loadSlot:+1 withPage:currentPageNumber + 1];
        } else if (currentPageNumber == totalPages && nextPage.superview == scrollView) {
            [nextPage removeFromSuperview];
        }
        
        if (currentPageNumber != 1) {
            if (prevPage.superview != scrollView) [scrollView addSubview:prevPage];
            [self loadSlot:-1 withPage:currentPageNumber - 1];
        } else if (currentPageNumber == 1 && prevPage.superview == scrollView) {
            [prevPage removeFromSuperview];
        }
		//NSLog(@"%d",[scrollView retainCount]);
	}
}

#pragma mark -
#pragma mark page change related method
- (BOOL)changePage:(int)page {
    bRotate = NO;
    BOOL pageChanged = NO;
    
    
    if (page == currentPageNumber && (bTransed || bMarked))
    {
        //if(currentPageFirstLoading)
        //    tapNumber = 1;
        //else
        tapNumber = 3;
        // While we are tapping, we don't want scrolling event to get in the way
        //scrollView.scrollEnabled = NO;
        //stackedScrollingAnimations++;
        //_slider.value = page-1;
        [mainPagebar updateSliderPage:page-1];
        //[self hideStatusBar];
        [self hideAllBar];
        [scrollView scrollRectToVisible:[self frameForPage:currentPageNumber] animated:YES];
        
        [self gotoPageDelayer];
        bTransed = NO;
        //bMarked = NO;
        
        pageChanged = YES;
    }
    else if (page < 1) {
		currentPageNumber = 1;
	} else if (page > totalPages) {
		currentPageNumber = totalPages;
	} else if (page != currentPageNumber) {
        
        lastPageNumber = currentPageNumber;
		currentPageNumber = page;
        
        tapNumber = tapNumber + (lastPageNumber - currentPageNumber);
        
        // While we are tapping, we don't want scrolling event to get in the way
        scrollView.scrollEnabled = NO;
        //NSLog(@"scrollView.scrollEnabled = NO!"); //scroller debug
        stackedScrollingAnimations++;
        //_slider.value = page-1;
        
        [mainPagebar updateSliderPage:page-1];
        
       // [self hideStatusBar];
        [self hideAllBar];
        [scrollView scrollRectToVisible:[self frameForPage:currentPageNumber] animated:YES];
        [self gotoPageDelayer];
        
        pageChanged = YES;
        
	} 
	/*if([self checkBookMarked:currentPageNumber])
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [backImageView setAlpha:1.0];
        else
            [backImageView setAlpha:0.6];
    }*/
    
    [self checkBookMarkShowOrNot:currentPageNumber];
	return pageChanged;	
}
- (void)gotoPageDelayer {
	// This delay is required in order to avoid stuttering when the animation runs.
	// The animation lasts 0.5 seconds: so we start loading after that.
	
	if (currentPageIsDelayingLoading) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gotoPage) object:nil];
    }
	
	currentPageIsDelayingLoading = YES;
    
    CGFloat delaySecond = 0.5;
    if(IS_IOS_7)
        delaySecond = 0.01;
    
	[self performSelector:@selector(gotoPage) withObject:nil afterDelay:delaySecond];
}

- (void)gotoPage {
	
    /****************************************************************************************************
	 * Opens a specific page
	 */
    
    
    if (tapNumber != 0) {
        
        //NSLog(@"Goto Page: book/%@", [[NSFileManager defaultManager] displayNameAtPath:path]);
        //NSLog(@"Goto Page: %@",_pageNum); //scroller debug
        
        // ****** THREE CARD VIEW METHOD
        
        // ****** Calculate move direction and normalize tapNumber
        int direction = 1;
        if (tapNumber < 0) {
            direction = -direction;
            tapNumber = -tapNumber;
        }
        
        //NSLog(@">>>>> TAP NUMBER: %d <<<<<", tapNumber); //scroller debug
        
        if (tapNumber > 2) {
            
            // ****** Moved away for more than 2 pages: RELOAD ALL pages
            tapNumber = 0;
            
            if (currPage.loading) [currPage stopLoading];
            [self loadSlot:0 withPage:currentPageNumber];
            
            if (currentPageNumber < totalPages) {
                if (nextPage.loading) [nextPage stopLoading];
                [self loadSlot:+1 withPage:currentPageNumber + 1];
            }
            
            if (currentPageNumber > 1) {
                if (prevPage.loading) [prevPage stopLoading];
                [self loadSlot:-1 withPage:currentPageNumber - 1];
            }
            
        } else {
            
            if (tapNumber == 2) {
                
                // ****** Moved away for 2 pages: RELOAD CURRENT page
                if (currPage.loading) [currPage stopLoading];
                [self loadSlot:0 withPage:currentPageNumber];
                
                if (direction < 0) {
                    // ****** Move RIGHT >>>
                    MyUIWebView *tmpView = prevPage;
                    prevPage = nextPage;
                    nextPage = tmpView;
                } else {
                    // ****** Move LEFT <<<
                    MyUIWebView *tmpView = nextPage; 
                    nextPage = prevPage;
                    prevPage = tmpView;
                }
                
            } else if (tapNumber == 1) {
                
                if (direction < 0) { 
                    // ****** Move RIGHT >>>往下一頁
                    MyUIWebView *tmpView = prevPage;
                    prevPage = currPage;
                    currPage = nextPage;
                    nextPage = tmpView;
                    if(audioPlayMode == 1)
                    {
                        [self audioSpeech];
                    }
                } else { 
                    // ****** Move LEFT <<<往上一頁
                    MyUIWebView *tmpView = nextPage;
                    nextPage = currPage;
                    currPage = prevPage;
                    prevPage = tmpView;
                }
                
                currentPageIsDelayingLoading = NO; // since we are not loading anything so we have to reset the delayer flag here
            }
            
            tapNumber = 0;
            if (direction < 0) {
                // PRELOAD NEXT page
                if (currentPageNumber < totalPages) {
                    if (nextPage.loading) [nextPage stopLoading];
                    [self loadSlot:+1 withPage:currentPageNumber + 1];
                }
            } else {
                // PRELOAD PREV page
                if (currentPageNumber > 1) {
                    if (prevPage.loading) [prevPage stopLoading];
                    [self loadSlot:-1 withPage:currentPageNumber - 1];
                }  
            }
        }
        //考慮最後一頁的情況
        if (currentPageNumber != totalPages && nextPage.superview != scrollView) {
            [scrollView addSubview:nextPage];
        } else if (currentPageNumber == totalPages && nextPage.superview == scrollView) {
            [nextPage removeFromSuperview];
        }
        //考慮第一頁的情況
        if (currentPageNumber != 1 && prevPage.superview != scrollView) {
            [scrollView addSubview:prevPage];
        } else if (currentPageNumber == 1 && prevPage.superview == scrollView) {
            [prevPage removeFromSuperview];
        }
    }
}

- (void)loadSlot:(int)slot withPage:(int)page {
	
	MyUIWebView *webView = nil;
	//CGRect frame;
	
	// ****** SELECT
	if (slot == -1) {
		webView = self.prevPage;
	} else if (slot == 0) {
		webView = self.currPage;
	} else if (slot == +1) {
		webView = self.nextPage;
        
	}
    
    webView.frame = [self frameForPage:page];
    
	[self loadWebView:webView withPage:page];
    webView = nil;
	[self spinnerForPage:page isAnimating:YES]; // spinner YES	
    
}
#pragma mark -
#pragma mark Pagenumber related method
- (void)initPageNumbersForPages:(int)count {
    [pageSpinners release];
	pageSpinners = [[NSMutableArray alloc] initWithCapacity:count];
	for (int i = 0; i < count; i++) {
        
		// ****** Spinners
        UIActivityIndicatorView *spinner;
        if(_iBGType > 2)
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        else
            spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.backgroundColor = [UIColor clearColor];
		
		CGRect frame = spinner.frame;
		frame.origin.x = pageWidth * i + (pageWidth + frame.size.width) / 2 - 40;
		frame.origin.y = (pageHeight + frame.size.height) / 2;
		spinner.frame = frame;
		
		[pageSpinners addObject:spinner];
		[[self scrollView] addSubview:spinner];
		[spinner release];
		
		// ****** Numbers
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        //[[NSString alloc] initWithFormat:@"%d", i + 1]; //real current page for debug
        NSInteger _iPage = i + 1 - appDelegate._bookprepareTotal;
        UILabel *label;
		NSString *labelText;
        if(_iPage > 0)
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(pageWidth * i + (pageWidth) / 2, pageHeight / 2 - 6, 100, 50)];
            NSInteger _pageN = i + 1 - appDelegate._bookprepareTotal;
            if(TTIsOrienLandscape() && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                _pageN = _pageN*2-1;
            labelText = [[NSString alloc] initWithFormat:@"%d",_pageN];
        }
        else
        {
            label = [[UILabel alloc] initWithFrame:CGRectMake(pageWidth * i + (pageWidth) / 2, pageHeight / 2 - 6, 170, 50)];
            labelText = @"";//[[NSString alloc] initWithString:NSLocalizedString(@"序言目錄",@"Preface")];
        }
		
		label.backgroundColor = [UIColor clearColor];
		label.textColor = _spinnerColor;//[UIColor PAGE_NUMBERS_COLOR];
		label.alpha = PAGE_NUMBERS_ALPHA;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            label.font = [UIFont fontWithName:@"Helvetica" size:40.0];
        else
            label.font = [UIFont fontWithName:@"Helvetica" size:26.0];
		label.textAlignment = UITextAlignmentLeft;
		label.text = labelText;
		//label.backgroundColor = [UIColor redColor];
		[labelText release];
		
		[[self scrollView] addSubview:label];
		[label release]; //該要改ARC了
	}
}

// ****** SCROLLVIEW
- (CGRect)frameForPage:(int)page {
	return CGRectMake(pageWidth * (page - 1), 0, pageWidth, pageHeight);
}

- (void)spinnerForPage:(int)page isAnimating:(BOOL)isAnimating {
	UIActivityIndicatorView *spinner = nil;
	if (page <= pageSpinners.count) spinner = [pageSpinners objectAtIndex:page - 1];
	
	if (isAnimating) {
		spinner.alpha = 0.0;
		[UIView beginAnimations:@"showSpinner" context:nil]; {
			//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:1.0];
			//[UIView setAnimationDelegate:self];
			//[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
			
			spinner.alpha = 1.0;
		}
		[UIView commitAnimations];	
		[spinner startAnimating];
	} else {
		[spinner stopAnimating];
	}
}
#pragma mark -
#pragma mark Scroll actions
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// This is called because this controller is the delegate for UIScrollView
	[self hideStatusBar];
    [self hideAllBar];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scroll willDecelerate:(BOOL)decelerate {
	// Nothing to do here...
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"scrollview did begin decelerating"); //scroller debug
	// Nothing to do here either...
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroll {
    
    
    int page = (int)(scrollView.contentOffset.x / pageWidth) + 1;
	//NSLog(@" <<< Swiping to page: %d >>>", page); //scroller debug
    
    if (currentPageNumber != page) {
        lastPageNumber = currentPageNumber;
        currentPageNumber = page;
        
        tapNumber = tapNumber + (lastPageNumber - currentPageNumber);
        [self gotoPageDelayer];
    }
    /*if([self checkBookMarked:page])
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [backImageView setAlpha:1.0];
        else
            [backImageView setAlpha:0.6];
    }*/
    [self checkBookMarkShowOrNot:page];
    
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	stackedScrollingAnimations--;
    if (stackedScrollingAnimations == 0) {
		self.scrollView.scrollEnabled = YES;
        //NSLog(@"scrollView.scrollEnabled = YES!");
        
	}
}


- (void)resetScrollView {
	for (id subview in scrollView.subviews) {
		if (![subview isKindOfClass:[MyUIWebView class]]) {
			[subview removeFromSuperview];
		}
	}
    
	scrollView.contentSize = CGSizeMake(pageWidth * totalPages, pageHeight);
	
	UIApplication *sharedApplication = [UIApplication sharedApplication];
	int scrollViewY = 0;
	if (!sharedApplication.statusBarHidden) {
        if(IS_IOS_7)
            scrollViewY = 0;
        else
            scrollViewY = -20;
	}
    [UIView animateWithDuration:0.2 animations:^{
        scrollView.frame = CGRectMake(0, scrollViewY, pageWidth, pageHeight);
    }];
	
	[self initPageNumbersForPages:totalPages];
    
    if (prevPage.superview == scrollView) {
        prevPage.frame = [self frameForPage:currentPageNumber - 1];
        [scrollView bringSubviewToFront:prevPage];
    }
    
    if (nextPage.superview == scrollView) {
        nextPage.frame = [self frameForPage:currentPageNumber + 1];
        [scrollView bringSubviewToFront:nextPage];
    }
    
    currPage.frame = [self frameForPage:currentPageNumber];
    [scrollView bringSubviewToFront:currPage];
	[scrollView scrollRectToVisible:[self frameForPage:currentPageNumber] animated:NO];
    
}

- (void)userDidScroll:(id)ignored
{
    //NSLog(@"User did scroll");
    CGPoint tapPoint = [recognizer locationInView:self.view];
    //NSLog(@"  .  1 tap [%f, %f]", tapPoint.x, tapPoint.y);
	//CGPoint tapPoint = [touch locationInView:self.view];
    [self stopPlayMode];
	// ...and swipe or scroll the page.
	if (CGRectContainsPoint(leftTapArea, tapPoint) || CGRectContainsPoint(rightTapArea, tapPoint)) {
		int page = 0;
		if (CGRectContainsPoint(leftTapArea, tapPoint)) {
			//NSLog(@"<-- TAP left!"); //scroller debug
			page = currentPageNumber - 1;
		} else if (CGRectContainsPoint(rightTapArea, tapPoint)) {
			//NSLog(@"--> TAP right!"); //scroller debug
			page = currentPageNumber + 1;
		}
        [self changePage:page];
    }
    //int page = currentPageNumber + 1;
    //[self changePage:page];
    
}

#pragma mark -
#pragma mark Webview related method
- (BOOL)loadWebView:(MyUIWebView*)webView withPage:(int)page {
	
    
    if(page > [arrayForStoreTheContentPage count])
        page = [arrayForStoreTheContentPage count]-2;
    NSMutableString *p = [arrayForStoreTheContentPage objectAtIndex:page-1]; //crash point
    //NSLog(@"[+] Loading: page%d",page);  //scroller debug
    webView.hidden = YES; // use direct property instead of [self webView:hidden:animating:] otherwise it won't work
    //[self webView:webView hidden:YES animating:YES];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int _modI = page%3;
    NSString *_htmlPath = [[NSString stringWithFormat:@"curTemp%i.html",_modI] getDocPathWithPList];
    NSError *error;
    
    if(appDelegate.iBookLastLang == 1)
    {
        
        const char *_b = [p UTF8String];
        NSString *_trans = [[NSString stringWithUTF8String:_b] simplifiedChineseString];
        
        //BOOL succeed =
        [_trans writeToFile:_htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        //[webView loadHTMLString:_trans baseURL:nil];
    }else
    {
        //BOOL succeed =
        [p writeToFile:_htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        //[webView loadHTMLString:p baseURL:nil];
    }
    NSURL *cururl = [NSURL fileURLWithPath:_htmlPath];
    [webView loadRequest:[NSURLRequest requestWithURL:cururl]];
    return YES;
	//NSString *path = [pages objectAtIndex:page-1];
    
	/*if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
     NSLog(@"[+] Loading: book/%@", [[NSFileManager defaultManager] displayNameAtPath:path]);
     webView.hidden = YES; // use direct property instead of [self webView:hidden:animating:] otherwise it won't work
     [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
     return YES;
     }
     return NO;*/
}


- (void)setupWebView:(MyUIWebView *)webView {
    
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webView.mediaPlaybackRequiresUserAction = MEDIA_PLAYBACK_REQUIRES_USER_ACTION;
	webView.scalesPageToFit = PAGE_ZOOM_GESTURE;
    [webView setBackgroundColor:_bColor];//[UIColor yellowColor]];
    [webView setOpaque:NO];
    webView.delegate = self;
	webView.alpha = 0.5;
    
    /*[webView release];
     webView = [[MyUIWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
     webView.scalesPageToFit = NO;
     webView.delegate = self;*/
    
    [[[webView subviews] lastObject] setScrollEnabled:NO];
	if (!PAGE_VERTICAL_BOUNCE) {
		for (id subview in webView.subviews)
			if ([[subview class] isSubclassOfClass: [UIScrollView class]])
				((UIScrollView *)subview).bounces = NO;
	}        
}

- (void)checkPageSize {
    if ([AVAILABLE_ORIENTATION isEqualToString:@"Portrait"] || [AVAILABLE_ORIENTATION isEqualToString:@"Landscape"]) {
		[self setPageSize:AVAILABLE_ORIENTATION];
	} else {
        if(TTIsOrienLandscape())
			[self setPageSize:@"Landscape"];
		else
			[self setPageSize:@"Portrait"];
        
	}
}
- (void)setPageSize:(NSString *)orientation {
	
	NSLog(@"Set size for orientation: %@", orientation);
	if ([orientation isEqualToString:@"Portrait"]) {
		pageWidth = screenBounds.size.width;
		pageHeight = screenBounds.size.height;//for status bar
	} else if ([orientation isEqualToString:@"Landscape"]) {
		pageWidth = screenBounds.size.height;
		pageHeight = screenBounds.size.width;
	}
}

// ****** PAGE SCROLLING
- (void)getPageHeight {
	for (id subview in currPage.subviews) {
		if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
			CGSize size = ((UIScrollView *)subview).contentSize;
			//NSLog(@"Current page height: %d", currentPageHeight);
			currentPageHeight = size.height;
		}
	}
}

// ****** WEBVIEW
- (void)webViewDidStartLoad:(MyUIWebView *)webView {
    webView.hidden = YES;
	// Sent before a web view begins loading content.
}
- (void)webViewDidFinishLoad:(MyUIWebView *)webView {
	// Sent after a web view finishes loading content.	
	
	if (webView == currPage) {
		// Get current page max scroll offset
		[self getPageHeight];
		
		// If is the first time i load something in the currPage web view...
		if (currentPageFirstLoading) {
			//NSLog(@"(1) currPage finished first loading"); //scroller debug
			
			// ...check if there is a saved starting scroll index and set it
			//NSString *currPageScrollIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastScrollIndex"];
			//if (currPageScrollIndex != nil) [self goDownInPage:currPageScrollIndex animating:NO];
			
			//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTouch:) name:@"onTouch" object:nil];
			//[self loadSlot:+1 withPage:currentPageNumber + 1];
			//[self loadSlot:-1 withPage:currentPageNumber - 1];
			
			currentPageFirstLoading = NO;
		}
		
		// Handle saved hash reference (if any)
		//[self handleAnchor:NO];
	}
	
	// /!\ hack to make it load at the right time and not too early
	// source: http://stackoverflow.com/questions/1422146/webviewdidfinishload-firing-too-soon
	//NSString *javaScript = @"<script type=\"text/javascript\">function myFunction(){return 1+1;}</script>";
	//[webView stringByEvaluatingJavaScriptFromString:javaScript];
	
	[self spinnerForPage:currentPageNumber isAnimating:NO]; // spinner YES
    if(currentPageNumber == 3)
        [self performSelector:@selector(revealWebView:) withObject:webView afterDelay:0.8];
    else if(currentPageNumber >  _iPrepageTotal+2 || currentPageNumber == 1)
    {
        [self performSelector:@selector(revealWebView:) withObject:webView afterDelay:delayLoadingTime];
        delayLoadingTime = 0.3;
    }
    else
        [self performSelector:@selector(revealWebView:) withObject:webView afterDelay:0.4]; // This seems fixing the WebView-Flash-Of-Old-Content-webBug    
}
- (void)webView:(MyUIWebView *)webView didFailLoadWithError:(NSError *)error {
	// Sent if a web view failed to load content.
    if (webView == currPage) {
		NSLog(@"currPage failed to load content with error: %@", error);
	} else if (webView == prevPage) {
		NSLog(@"prevPage failed to load content with error: %@", error);
	} else if (webView == nextPage) {
		NSLog(@"nextPage failed to load content with error: %@", error);
    }
}
- (BOOL)webView:(MyUIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// Sent before a web view begins loading content, useful to trigger actions before the WebView.	
	//_slider.value = currentPageNumber-1;
    [mainPagebar updateSliderPage:currentPageNumber-1];

    if (webView == self.prevPage || webView == self.nextPage) {
        
        //NSLog(@"Loading Prev or Next Page --> load page"); //scroller debug
        return YES;
        
    } else if (currentPageIsDelayingLoading) {
		
		//NSLog(@"Current Page IS delaying loading --> load page"); //scroller debug
		currentPageIsDelayingLoading = NO;
		return YES;
		
	} else {
        [self hideStatusBarDiscardingToggle:YES];
		
		        
		return NO;
    }
}
- (void)webView:(MyUIWebView *)webView hidden:(BOOL)status animating:(BOOL)animating {
	//NSLog(@"- webview hidden:%d animating:%d", status, animating); //scroller debug
	
	if (animating) {
		webView.alpha = 0.0;
		webView.hidden = NO;
		
		[UIView beginAnimations:@"webViewVisibility" context:nil]; {
			//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.5];
			//[UIView setAnimationDelegate:self];
			//[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
			
			webView.alpha = 1.0;	
		}
		[UIView commitAnimations];		
	} else {
		webView.alpha = 1.0;
		webView.hidden = NO;
	}
}
- (void)revealWebView:(MyUIWebView *)webView {
    if(bMarked)
    {
        [self webView:webView hidden:NO animating:NO];
        bMarked = NO;
    }
    else
        [self webView:webView hidden:NO animating:YES];  // Delayed run to fix the WebView-Flash-Of-Old-Content-Bug
}

#pragma mark -
#pragma mark status bar related method
// ****** STATUS BAR
- (void)toggleStatusBar {
	if (discardNextStatusBarToggle) {
		// do nothing, but reset the variable
		discardNextStatusBarToggle = NO;
	} else {
		NSLog(@"TOGGLE status bar");
		//UIApplication *sharedApplication = [UIApplication sharedApplication];
		//[sharedApplication setStatusBarHidden:!sharedApplication.statusBarHidden withAnimation:UIStatusBarAnimationSlide];
        [self showBars:NO animated:YES];
        //if(![indexViewController isDisabled]) 
        //    [indexViewController setIndexViewHidden:![indexViewController isIndexViewHidden] withAnimation:YES];
	}
}
- (void)hideStatusBar {

	[self hideStatusBarDiscardingToggle:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    
}

- (void)showStatusBar
{
    
}

- (void)hideStatusBarDiscardingToggle:(BOOL)discardToggle {
	//NSLog(@"HIDE status bar %@", (discardToggle ? @"discarding toggle" : @"")); //scroller debug
	discardNextStatusBarToggle = discardToggle;
	//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self showBars:NO animated:YES];
    //if(![indexViewController isDisabled]) 
    //    [indexViewController setIndexViewHidden:YES withAnimation:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBarsAnimationDidStop {
	self.navigationController.navigationBarHidden = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideBarsAnimationDidStop {
    if(IS_IOS_7)
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }else
    {
        self.navigationController.navigationBarHidden = YES;
    }
}

- (BOOL)isShowingChrome {
	//UINavigationBar* bar = self.navigationController.navigationBar;
    //NSLog(@"bar.alpha:%f",bar.alpha);
	return !mainToolbar.hidden;//bar ? bar.alpha != 0 : 1;
}

#pragma mark -
#pragma mark bookdoc reading related method
/////////////////////////////////////////////////////////////////
-(void)changeBook:(NSString *)sBookNum type:(NSInteger)orientation fontSize:(NSInteger)fontSize BGType:(NSInteger)bgType fontType:(NSInteger)fontType
{
    //type 0 portrait 1 landscape
    
	//initial 頁面 array
    
    //initial 頁數
    
    
    
	NSString *sSql = @"select type,text,chap,rowid from Content;";// where chap == '001'
    //NSInteger _array_count = 0;
    
    parseHtml = [ParseHtml withBookNumber:sBookNum fontSize:fontSize BGType:bgType fontType:fontType inPutsql:sSql orientation:orientation];
    
    arrayForStoreTheContentPage = [parseHtml.htmlPages mutableCopy];
    
    _iPrefacePageCount = [parseHtml iPrefacePageCount];
    _iIndexPageCount = [parseHtml iIndexPageCount];
    _iCoverPageCount = [parseHtml iCoverPageCount];
    
    [sSql release];
    //排版程式
	//do
	//{
		/*if(!parseHtml || bFinalPage)
		{
            [parseHtml release];
			parseHtml = //[[[ParseHtml alloc] initWithBookNumber:sBookNum fontSize:fontSize BGType:fontSize fontType:fontType] autorelease];
            //讀取user及書本描述檔
			[parseHtml readFromPlistData];
			parseHtml.sql = sSql;
			
			[parseHtml checkAndCreateDatabase];
            //load序言資料
            [parseHtml loadPrefaceFromDb];
			[parseHtml loadFromDb];
		}*/
		//開始排沒有序言的內容
        
        /*if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [_parseHtml convertToHtml:_array_count isPreFace:NO isLandscape:NO];
            else                //橫向
                bFinalPage = [_parseHtml convertToHtml:_array_count isPreFace:NO isLandscape:YES];
        }else
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [_parseHtml convertToHtml_iphone:_array_count isPreFace:NO isLandscape:NO];
            else                //橫向
                bFinalPage = [_parseHtml convertToHtml_iphone:_array_count isPreFace:NO isLandscape:YES];
            
        }
        
        //NSString *_sarray = @"teasdfasdfasdfasdfasdfasdf";//[parseHtml aHtml]
        [arrayForStoreTheContentPage addObject:@"teasdfasdfasdfasdfasdfasdf"];
        
        _array_count++;
        */
	//}while (!bFinalPage);
	
    
    /*@@
    //計數內文頁數
    _iContentPageCount = _array_count;
    bFinalPage = NO;
    
    //產生search page index dictionary
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.searchPageDictionary = [parseHtml array_row_page_index];
    
    //產生preface頁面
    _array_count = 0;
    parseHtml.bFinalMark = NO;
    //mem
    do {
        //排序言的內容
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [parseHtml convertToHtml:_array_count isPreFace:YES isLandscape:NO];
            else
                bFinalPage = [parseHtml convertToHtml:_array_count isPreFace:YES isLandscape:YES];
        }else
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [parseHtml convertToHtml_iphone:_array_count isPreFace:YES isLandscape:NO];
            else
                bFinalPage = [parseHtml convertToHtml_iphone:_array_count isPreFace:YES isLandscape:YES];
            
        }
        if(!bFinalPage)
        {
            NSString *_sarray = [NSString stringWithString:[parseHtml aHtml]];
            [array_pre_page addObject:_sarray];
            _array_count++;
        }
    } while (!bFinalPage);
    
    //計數序言頁數
    _iPrefacePageCount = _array_count;
    //產生目錄
	[parseHtml loadBookIndex_CoverPage];
    if(orientation == 0)//直向
        [parseHtml createIndexPage_:NO];
    else
        [parseHtml createIndexPage_:YES];
    //
        
    appDelegate.arrayIndexText =[parseHtml array_index_text];
    appDelegate.arrayIndexPagenum = [parseHtml array_index_pagenum];
    NSLog(@"test:%@",[appDelegate.arrayIndexPagenum objectAtIndex:0]);
    //計數目錄頁數
    _iIndexPageCount = [parseHtml.array_index_html count];
    
    //產生內外封
    if(!TTIsOrienLandscape())//直向
    {
        [parseHtml createCoverPage_:NO];
        [parseHtml createInnerCoverPage_:NO];
        //計數封面頁數
        _iCoverPageCount = 2;
        
    }
    else
    {
        [parseHtml createCoverPage_:YES];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            _iCoverPageCount = 1;
        }else
        {
            [parseHtml createInnerCoverPage_:YES];
            _iCoverPageCount = 2;
        }
    }
    
    
    //insert index page in front of main page array
    int _iCount = [parseHtml.array_index_html count];
    for (int i = _iCount-1; i >= 0; i--) 
    {
        NSMutableString *_s = [parseHtml.array_index_html objectAtIndex:i];
        [arrayForStoreTheContentPage insertObject:_s atIndex:0];
    }
    //insert preface pages in front of the index page
    _iCount = [array_pre_page count];
    for(int i = _iCount-1; i >=0; i--)
    {
        NSMutableString *_s = [array_pre_page objectAtIndex:i];
        [arrayForStoreTheContentPage insertObject:_s atIndex:0];
    }
    if(!TTIsOrienLandscape() || UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        //inner cover page內封
        NSMutableString *_ic = [NSMutableString stringWithString:[parseHtml iCHtml]];
        [arrayForStoreTheContentPage insertObject:_ic atIndex:0];//mem
    }
    //cover page
    NSMutableString *_c = [NSMutableString stringWithString:[parseHtml iHtml]];
    [arrayForStoreTheContentPage insertObject:_c atIndex:0];//mem
	//NSLog(@"Change book finished!");
    @@*/
	
}

#pragma mark -
#pragma mark uiview related method
- (void)viewDidLayoutSubviews
{
    self.navigationController.navigationBar.translucent = NO;
}


- (void) viewDidLoad {

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillTerminateNotification object:nil];
    
    [notificationCenter addObserver:self selector:@selector(applicationWill:) name:UIApplicationWillResignActiveNotification object:nil];
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.sBookLastOpened = sBookName;
    
    [self showBars:NO animated:NO];

    
    [self initMarkText];
    [self initBookMark];
    
    
    
	delayLoadingTime = 0.0;//0.5
    
    //[arrayForStoreTheContentPage release];
    //[array_pre_page release];
    //arrayForStoreTheContentPage = [[NSMutableArray alloc] init];
    //array_pre_page = [[NSMutableArray alloc] init];
	
    
    _iFontSize = appDelegate.iFontLastSize;
    _iFontType = appDelegate.iFontLastType;
    _iBGType = appDelegate.iBGLastType;
    _iVoiceType = appDelegate.iVoiceLastType;
    _iVoiceSpeed = appDelegate.iVoiceLastSpeed;
    
    [self initAudio:_iVoiceType];
    
    switch (_iBGType) {
        case 0:
            _bColor = [UIColor colorWithRed:242.0/255.0 green:228.0/255.0 blue:202.0/255.0 alpha:1.0];//淡黃
            _spinnerColor = [UIColor blackColor];
            break;
        case 1:
            _bColor = [UIColor whiteColor];//白色
            _spinnerColor = [UIColor blackColor];
            break;
        case 2:
            _bColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:225.0/255.0 alpha:1.0];//灰
            _spinnerColor = [UIColor blackColor];
            break;
        case 3:
            _bColor = [UIColor blackColor];//黑
            _spinnerColor = [UIColor whiteColor];
            break;
        case 4:
            _bColor = [UIColor colorWithRed:49.0/255.0 green:137.0/255.0 blue:201.0/255.0 alpha:1.0];//LSM藍
            _spinnerColor = [UIColor whiteColor];
            break;
    }
    

    screenBounds = [[UIScreen mainScreen] bounds];

    int iStatusbarSpace;
    if(IS_IOS_7)
        iStatusbarSpace = 0;
    else
        iStatusbarSpace = 20;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
        {
            rectFrame =  CGRectMake(0, 0, 1024, 748);
            iTouchTopBound = 100;
            iTouchBottomBound = 729;
            iTouchLeftBound = 85;
            iTouchRightBound = 940;
        }else
        {
            rectFrame =  CGRectMake(0, 0, 768, 1024);
            iTouchTopBound = 100;
            iTouchBottomBound = 985;
            iTouchLeftBound = 85;
            iTouchRightBound = 684;
            
        }
    }else
    {
        if( IS_IPHONE_5 )
            rectFrame =  CGRectMake(0, 0, 320, 568);
        else
            rectFrame =  CGRectMake(0, 0, 320, 480);
        iTouchTopBound = 100;
        iTouchBottomBound = 460;
        iTouchLeftBound = 30;
        iTouchRightBound = 290;
        
    }
    
    
    
 	UIView  *view = [[UIView alloc] initWithFrame:rectFrame];
    
    self.view = view;
    
    [self checkPageSize];
    
    tapNumber = 0;
    discardNextStatusBarToggle = NO;
    stackedScrollingAnimations = 0;
    
    // ****** SCROLLVIEW INIT
    
   // NSLog(@"%d",[scrollView retainCount]);
    
    scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, pageHeight)] autorelease];
    //NSLog(@"%d",[scrollView retainCount]);
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = _bColor;//[UIColor SCROLLVIEW_BGCOLOR];
    
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delaysContentTouches = NO;
    scrollView.pagingEnabled = YES;
    
    //-----------------------------

    // ****** CURR WEBVIEW INIT
    
    [currPage release];
    currPage = [[MyUIWebView alloc] init];
    [self setupWebView:currPage];
    
    // ****** PREV WEBVIEW INIT
    [prevPage release];
    prevPage = [[MyUIWebView alloc] init];
    [self setupWebView:prevPage];
    
    // ****** NEXT WEBVIEW INIT
    [nextPage release];
    nextPage = [[MyUIWebView alloc] init];
    [self setupWebView:nextPage];
    
    
    scrollView.delegate = self;
    
    
    currentPageFirstLoading = YES;
    currentPageIsDelayingLoading = YES;


    [[self view] addSubview:scrollView];
    [scrollView release];
    
    if(TTIsOrienLandscape())
    {
        [self changeBook:sBookName type:1 fontSize:_iFontSize BGType:_iBGType fontType:_iFontType];
       
        
    }else
    {
        [self changeBook:sBookName type:0 fontSize:_iFontSize BGType:_iBGType fontType:_iFontType];

    }
    
    
    ////////////////////
    
    if(bRotate)
    {
        //currentPageNumber = [self revertPagePercent:appDelegate.iBookLastPagePercent pageCount:[arrayForStoreTheContentPage count]];//(NSInteger)_iPage;
        NSInteger iPercent = appDelegate.iBookLastPagePercent+400;
        
        iPercent = iPercent>10000?10000:iPercent;
        
        NSInteger jumpPage = [self revertPagePercent:iPercent pageCount:[arrayForStoreTheContentPage count]];
        
        NSString *_containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1];
        //NSLog(@"_containCheck:%@",_containCheck);
        NSString *_newsearchText = [NSString stringWithFormat:@"%@",appDelegate.sIdForRef];
        //NSLog(@"_newsearchText:%@",_newsearchText);
        if(![_newsearchText isEqualToString:@""])
        {
            NSRange r = [_containCheck rangeOfString:_newsearchText];
            while (r.location == NSNotFound) {
                jumpPage -= 1;
                if(jumpPage == 0)
                    return;
                _containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1];
                r = [_containCheck rangeOfString:_newsearchText];
            }
            currentPageNumber = jumpPage;
        }else
            currentPageNumber = [self revertPagePercent:appDelegate.iBookLastPagePercent pageCount:[arrayForStoreTheContentPage count]];//(NSInteger)_iPage;
    }
    else
    {
        BOOL _isLastLandscape;
        if(parseHtml.iLastOrientation == 1)
            _isLastLandscape = YES;
        else
            _isLastLandscape = NO;
        
        if(TTIsOrienLandscape() == _isLastLandscape)
        {
            currentPageNumber = parseHtml.iLastPage;
        }else
        {

            currentPageNumber = [self revertPagePercent:parseHtml.iLastPercent pageCount:[arrayForStoreTheContentPage count]];
        }
    }
    
    if(appDelegate.iBookLastLang == 1)
    {
        if(bTransSimpChin)
            bTransSimpChin = NO;
        [self transChi];
    }
    
    
    _iPrepageTotal = (_iCoverPageCount+_iPrefacePageCount+_iIndexPageCount);
    if(!bRotate)
        iShowingPageIdx = 1 - _iPrepageTotal;
    
    
    //pagecount information
    
    appDelegate._bookpageCount = [arrayForStoreTheContentPage count];
    appDelegate._bookprepareTotal = _iPrepageTotal;
    
    
    //gesture
	swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidScroll:)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRight.delegate = self;
	[self.view addGestureRecognizer:swipeRight];
	[swipeRight release];
    
    //swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidScroll:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.delegate = self;
	[self.view addGestureRecognizer:swipeLeft];
	[swipeLeft release];
	
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    recognizer.delegate = self;
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];
 
   	
    
	iFlipDir = 0;
	
    //bookmark image;
    UIImage *_bImage = [UIImage imageNamed:@"bookmark_ipad.png"];
    
    backImageView = [[[UIImageView alloc] initWithImage:_bImage] autorelease];
    [backImageView setAlpha:0.0];
    
    CGRect frameRect = backImageView.frame;
    CGFloat newXPos = pageWidth - 100;
    backImageView.frame = CGRectMake(newXPos, 0.0f, frameRect.size.width, frameRect.size.height);
    
    [self.view addSubview:backImageView];
    

    
    //TOOL BAR
    CGRect _vx = rectFrame;
    CGRect toolbarRect;
    if(IS_IOS_7)
        toolbarRect = _vx;
    else
    {
        toolbarRect = CGRectMake(_vx.origin.x,_vx.origin.y+20, _vx.size.width, _vx.size.height);
    }
    
	toolbarRect.size.height = TOOLBAR_HEIGHT;
    
	mainToolbar = [[[MyReaderMainToolbar alloc] initWithFrame:toolbarRect] autorelease]; // At top// document:document
    
	mainToolbar.delegate = self;
    [self.view addSubview:mainToolbar];
    
    
    //Bottom BAR
    
    CGRect pagebarRect = _vx;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (_vx.size.height - PAGEBAR_HEIGHT);
    
    
    mainPagebar = [[[MyWebViewReaderPagebar alloc] initWithFrame:pagebarRect pageCount:[arrayForStoreTheContentPage count]-2  iprePageTotal:_iPrepageTotal] autorelease]; // At bottom
    
	mainPagebar.delegate = self;
    
	[self.view addSubview:mainPagebar];
    
    [self hideStatusBar];
    [mainToolbar hideToolbar]; [mainPagebar hidePagebar];
    
    
    [self initBook1];
    
    
    
    /*if([self checkBookMarked:currentPageNumber])
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [backImageView setAlpha:1.0];
        else
            [backImageView setAlpha:0.6];
    }
    else
        [backImageView setAlpha:0];
    */
    
    [self checkBookMarkShowOrNot:currentPageNumber];
    
    //for jsBridge 20120620 johnilu33--------------------------------------------
    
    self.jsBridge = [TGJSBridge jsBridgeWithDelegate:self];
    
    self.prevPage.delegate = self.jsBridge;
    self.currPage.delegate = self.jsBridge;
    self.nextPage.delegate = self.jsBridge;
    
    //the button can test the jsbridge input and output
	/*
     self.btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     [self.btn setTitle:@"Hello JS" forState:UIControlStateNormal];
     [self.btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
     [self.view insertSubview:self.btn aboveSubview:self.currPage];
     self.btn.frame = CGRectMake(95, 400, 130, 45);
     */
    
    
    [self copyJsFileIfNeeded:@"TGJSBridge" extName:@".js"];
    [self copyJsFileIfNeeded:@"selfjs" extName:@".js"];
    [self copyJsFileIfNeeded:@"jquery" extName:@".js"];

    //for jsBridge 20120620 johnilu33--------------------------------------------
 
    
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    //for uimenu
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *item1 = [[[UIMenuItem alloc] initWithTitle: NSLocalizedString(@"標記",@"MarkTheText")
                                                    action: @selector(MarkTheText:)] autorelease];
    UIMenuItem *item2 = [[[UIMenuItem alloc] initWithTitle: NSLocalizedString(@"移除標記",@"DelTheText")
                                                    action: @selector(DeleteTheMark:)] autorelease];
    UIMenuItem *item3 = [[[UIMenuItem alloc] initWithTitle: NSLocalizedString(@"筆記",@"NoteTheText")
                                                    action: @selector(NoteTheText:)] autorelease];
    //UIMenuItem *item4 = [[[UIMenuItem alloc] initWithTitle: NSLocalizedString(@"搜尋",@"Search")
    //                                                action: @selector(SearchTheText:)] autorelease];
    UIMenuItem *item5 = [[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"拷貝",@"CopyTheText")
                                                    action:@selector(myCopy:)] autorelease];
    UIMenuItem *item6 = [[[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"朗讀",@"SpeakText")
                                                    action:@selector(SpeakText:)] autorelease];
    UIMenuItem *item7 = [[[UIMenuItem alloc] initWithTitle: NSLocalizedString(@"引經",@"FindDictionary")
                                                    action: @selector(FindDictionary:)] autorelease];
    UIMenuItem *item8 = [[[UIMenuItem alloc] initWithTitle: NSLocalizedString(@"查英文",@"FindEnglish")
                                                    action: @selector(FindEnglish:)] autorelease];
    
    if([MKStoreManager isFeaturePurchased:@"tw.org.twgbr.HolyWords.b8889"])
        bVoicePurchased = YES;
    else
        bVoicePurchased = NO; //voice must change back before submit

    
    if(bVoicePurchased)
        [menuController setMenuItems: [NSArray arrayWithObjects: item1,item2,item3,item5,item6,item7,item8,nil]];
    else
        [menuController setMenuItems: [NSArray arrayWithObjects: item1,item2,item3,item5,item7,item8,nil]];

    
    
    
    //設定成語音背景播放模式(現階段還有問題，背景播放時翻頁後會如果解鎖會找不到頁面)
    //[self setAudioSession];
    //NSLog(@"%d",[scrollView retainCount]);
}


- (void)viewDidUnload {
    [super viewDidUnload];
    //TT_RELEASE_SAFELY(_slider);
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];

    
}

- (void) viewWillDisappear:(BOOL)animated
{
    //audio
    if(mIsPlaying)
    {
        [self stopAudio];
        audioPlayMode = 0;
    }
    
    TT_RELEASE_SAFELY(mCReader);
    //[mCReader release];
    TT_RELEASE_SAFELY(mPlayer);
    //[mPlayer release];
#ifdef SAVE_WAVE_TO_FILE
    TT_RELEASE_SAFELY(mSaveData);
    //[mSaveData release];
#endif
    TT_RELEASE_SAFELY(mAQPlayer);
	//[mAQPlayer release];
    
    [self saveLastPosition];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    //[super viewWillDisappear:animated];
    
}

#pragma mark -
#pragma mark Dictionary/Search/Mark method
- (void) FindDictionary:(id)sender
{
    NSString *findText = [self.currPage stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iBookLastLang == 1)
    {
        findText = [findText traditionalChineseString];
    }
    
    
    NSLog(@"please find the dictionary of this word:%@",findText);
    
    NSLog(@"There is something need to fix here");
    KNModalTableViewController * modalVC;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        modalVC = [[KNModalTableViewController alloc] initWithStyle:UITableViewStylePlain];
    else 
        modalVC = [[KNModalTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [modalVC setFindString:findText];
    [modalVC.searchBar setText:findText];
    [modalVC tableWithSearch];
    [self showBars:NO animated:NO];
    [_slider setAlpha:0.0];
    [self presentSemiViewController:modalVC];
    //[modalVC release];
    
    
}

#pragma mark -
#pragma mark FindEnglish method
- (void) FindEnglish:(id)sender {
    NSLog(@"Find English!");
    NSString *findText = [self.currPage stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iBookLastLang == 1)
    {
        findText = [findText traditionalChineseString];
    }
    
    
    NSLog(@"please find the dictionary of this word:%@",findText);
    
    KNModalEngDictTableViewController * modalVC;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        modalVC = [[KNModalEngDictTableViewController alloc] initWithStyle:UITableViewStylePlain];
    else
        modalVC = [[KNModalEngDictTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [modalVC setFindString:findText];
    [modalVC.searchBar setText:findText];
    [modalVC tableWithSearch];
    [self showBars:NO animated:YES];
    [_slider setAlpha:0.0];
    [self presentSemiViewController:modalVC];
    
}


- (void) SearchTheText: (id) sender {
    //NSLog(@"search the text");
    NSString *searchText = [self.currPage stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"];
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iBookLastLang == 1)
    {
        searchText = [searchText traditionalChineseString];
    }
    _menusearchText = searchText;
    //NSLog(@"searchText:%@",searchText);
    
    [self searchTheBook:1];
}

-(void)initMarkText
{
    NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",sBookName] getDocPathWithPList];
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        _markedTextInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath];
    }
    else
    {
        _markedTextInfo = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
}

-(void)saveMarkedText:(NSString*)rowId theRange:(NSRange)theRange theText:(NSString *)theText  MarkOrNote:(NSString *)opt1 noteText:(NSString *)noteText noteNumber:(NSString *)noteNumber
{
    
    NSMutableArray *_rangeArray;
    
    _rangeArray = [_markedTextInfo valueForKey:rowId];
    
    if(_rangeArray == nil)
        _rangeArray = [[[NSMutableArray alloc] init] autorelease];
    
    NSMutableDictionary *_updateDictionary = [[NSMutableDictionary alloc] init];
    
    [_updateDictionary setObject:[NSNumber numberWithInteger:theRange.location] forKey:@"astart"];
    [_updateDictionary setObject:[NSNumber numberWithInteger:theRange.location + theRange.length] forKey:@"aend"];
    //add some more information
    [_updateDictionary setObject:theText forKey:@"text"];
    NSInteger iPercent = (NSInteger)([self convertPagePercent:currentPageNumber pageCount:[arrayForStoreTheContentPage count]]);
    [_updateDictionary setObject:[NSNumber numberWithInteger:iPercent] forKey:@"pagepercent"];//add 1% for search
    [_updateDictionary setObject:rowId forKey:@"rowID"];
    [_updateDictionary setObject:@"0" forKey:@"markColor"];
    [_updateDictionary setObject:opt1 forKey:@"opt1"];
    [_updateDictionary setObject:noteNumber forKey:@"opt2"];
    [_updateDictionary setObject:@"0" forKey:@"opt3"];
    [_updateDictionary setObject:@"0" forKey:@"opt4"];
    [_updateDictionary setObject:@"0" forKey:@"opt5"];
    [_updateDictionary setObject:@"0" forKey:@"opt6"];
    [_updateDictionary setObject:@"0" forKey:@"opt7"];
    [_updateDictionary setObject:@"0" forKey:@"opt8"];
    [_updateDictionary setObject:@"0" forKey:@"opt9"];
    
    [_rangeArray addObject:_updateDictionary];
    
    NSSortDescriptor * descriptor = [[[NSSortDescriptor alloc] initWithKey:@"astart" 
                                                                 ascending:YES] autorelease]; // 1
    [_rangeArray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    [_markedTextInfo setObject:_rangeArray forKey:rowId];
    
    
    NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",sBookName] getDocPathWithPList];
    [_markedTextInfo writeToFile:myPath atomically:YES];
    [_updateDictionary release];
    
    //note text management
    if([opt1 isEqualToString:@"1"]) // has note
    {
        NSMutableDictionary *notelist;
        
        NSString *_sfn = [NSString stringWithFormat:@"_%@note.plist",sBookName];
        NSString *dataPath = [_sfn getDocPathWithPList];
        // NSLog(@"dataPath:%@",dataPath);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:dataPath])
        {	
            notelist = [NSMutableDictionary dictionaryWithObjectsAndKeys:noteText,noteNumber,nil];
        }else 
        {
            notelist = [NSMutableDictionary dictionaryWithContentsOfFile:dataPath];
            //if([notelist objectForKey:noteNumber] != nil)
            //    [notelist removeObjectForKey:noteNumber];
            
            [notelist setObject:noteText forKey:noteNumber];
            
            
        }
        
        [notelist writeToFile:dataPath atomically:YES];
    }
    
}

-(void)delNotedText:(NSString*)rowId noteNumber:(NSString *)noteNumber
{
    NSMutableArray *_rangeArray;
    
    _rangeArray = [_markedTextInfo valueForKey:rowId];
    
    for(int i = 0; i < [_rangeArray count]; i++)
    {
        NSDictionary *_d = [_rangeArray objectAtIndex:i];
        
        NSString *_opt2 =  [_d valueForKey:@"opt2"];
        if([_opt2 isEqualToString:noteNumber])
            [_rangeArray removeObjectAtIndex:i];
        /*NSInteger iStart = [[_d valueForKey:@"astart"] integerValue];
        if(iStart == theRange.location)
            [_rangeArray removeObjectAtIndex:i];
         */
    }
    
    [_markedTextInfo setObject:_rangeArray forKey:rowId];
    
    NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",sBookName] getDocPathWithPList];
    [_markedTextInfo writeToFile:myPath atomically:YES];
    
    
    NSString *dataPath = [[NSString stringWithFormat:@"_%@note.plist",sBookName] getDocPathWithPList];
    NSMutableDictionary *notelist = [NSMutableDictionary dictionaryWithContentsOfFile:dataPath];
    [notelist removeObjectForKey:noteNumber];
    [notelist writeToFile:dataPath atomically:YES];    
}


-(void)delMarkedText:(NSString*)rowId theRange:(NSRange)theRange
{
    NSMutableArray *_rangeArray;
    
    _rangeArray = [_markedTextInfo valueForKey:rowId];
   
    for(int i = 0; i < [_rangeArray count]; i++)
    {
        NSDictionary *_d = [_rangeArray objectAtIndex:i];
        
        NSInteger iStart = [[_d valueForKey:@"astart"] integerValue];
        if(iStart == theRange.location)
            [_rangeArray removeObjectAtIndex:i];
    }
    
    [_markedTextInfo setObject:_rangeArray forKey:rowId];
    
    NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",sBookName] getDocPathWithPList];
    [_markedTextInfo writeToFile:myPath atomically:YES];
    
}

- (void) NoteOrMarkToDelete:(NSInteger)type noteNumber:(NSString *)noteNumber
{
    NSLog(@"Delete The Mark");
    MyUIWebView *_mwb = self.currPage;
    NSString *_aid = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.parentNode.parentNode.getAttribute(\"id\")"]];
    if([_aid isEqualToString:@""])
        return;
    NSInteger _aidstart = [[_aid substringWithRange:NSMakeRange(6, 5)] integerValue];
    NSString *_id = [NSString stringWithFormat:@"%d",[[_aid substringToIndex:6] integerValue]];
    NSString *_parentNodeText = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.parentNode.parentNode.textContent"]];
    NSString *_anchorText = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.textContent"]];
    
    /*
    NSLog(@"aid=%@",_aid);
    NSLog(@"id=%@",_id);
    NSLog(@"aidstart:%d",_aidstart);
    NSLog(@"anchorNodeText=%@",_parentNodeText);
    NSLog(@"anchorText=%@",_anchorText);
    */
    
    NSString *_dtext;
    
    if(type == 0)
        _dtext = [NSString stringWithFormat:@"%@%@%@",@"<font class=\"hl\">",_anchorText,@"</font>"];
    else if (type == 1)
        _dtext =  [NSString stringWithFormat:@"%@%@%@%@%@",@"<font class=\"hlnote\" onclick=\"processNote(",noteNumber,@")\">",_anchorText,@"</font>"];
    
    NSMutableString *_paraGraph;// = [arrayForStoreTheContentPage objectAtIndex:currentPageNumber-1];;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iBookLastLang == 1)
    {
        _paraGraph = [NSMutableString stringWithString:[[arrayForStoreTheContentPage objectAtIndex:currentPageNumber-1] simplifiedChineseString]];    
    }
    else
    {
        _paraGraph = [arrayForStoreTheContentPage objectAtIndex:currentPageNumber-1];
    }
    _paraGraph = [NSString stringWithString:[_paraGraph stringByReplacingOccurrencesOfString:_dtext withString:_anchorText]];
    
    
    [arrayForStoreTheContentPage replaceObjectAtIndex:currentPageNumber-1 withObject:_paraGraph];
    
    NSRange r = [_parentNodeText rangeOfString:_anchorText];
    
    NSRange _rforDel = NSMakeRange(_aidstart+r.location, r.length);
    
    if(type == 0)
        [self delMarkedText:_id theRange:_rforDel];
    else if(type == 1)
        [self delNotedText:_id noteNumber:noteNumber];
    
    bMarked = YES;
    delayLoadingTime = 0.0;
    
    [self.jsBridge postNotificationName:@"test" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_paraGraph,@"message", nil] toWebView:self.currPage];
    
    [self showBars:NO animated:YES];

}

- (void) DeleteTheMark: (id) sender
{
    [self NoteOrMarkToDelete:0 noteNumber:@""];
    [self showBars:NO animated:YES];
}

- (void) TargetTheText:(NSInteger)type noteText:(NSString *)noteText
{
    NSLog(@"Mark the text");
    MyUIWebView *_mwb = self.currPage;
    NSString *_text = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"]];
    NSString *_aid = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.parentNode.getAttribute(\"id\")"]];
    NSString *_getParentString = [_mwb stringByEvaluatingJavaScriptFromString: @"getParent()"];
    if([_aid isEqualToString:@""] || [_getParentString rangeOfString:@"FONT"].location != NSNotFound)
        return;
    NSString *_id = [NSString stringWithFormat:@"%d",[[_aid substringToIndex:6] integerValue]];
    NSInteger _aidstart = [[_aid substringWithRange:NSMakeRange(6, 5)] integerValue];
    NSString *sStart = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorOffset"]];
    NSString *sEnd = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).focusOffset"]];
    
    NSString *_anchorText = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.textContent"]];
    NSString *_focusText = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).focusNode.textContent"]];
    NSString *_parentNodeText = [NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).anchorNode.parentNode.textContent"]];
    
    NSString *jsString = [NSString stringWithFormat:@"markData('%@')",_aid];
    NSString *_getmarkAreaText = [_mwb stringByEvaluatingJavaScriptFromString:jsString];
    
    NSMutableString *_paraGraph;
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.iBookLastLang == 1)
    {
        _paraGraph = [NSMutableString stringWithString:[[arrayForStoreTheContentPage objectAtIndex:currentPageNumber-1] simplifiedChineseString]];
    }else
    {
        _paraGraph = [arrayForStoreTheContentPage objectAtIndex:currentPageNumber-1];
    }
    NSRange r = [_parentNodeText rangeOfString:_anchorText];
    if(r.location != NSNotFound)
        NSLog(@"anchorText found in parentNodeText:%d,length:%d",r.location,r.length);
    else
    {
        NSLog(@"html id not found");
        return;
    }
    
    NSString *_rtext;
    NSString *_noteNumberFromDateTime = [self getDateTimeSecString];
    NSLog(@"_noteNumberFromDateTime:%@",_noteNumberFromDateTime);
    if(type == 0)
    {
        _rtext = [NSString stringWithFormat:@"%@%@%@",@"<font class=\"hl\">",_text,@"</font>"];
    } 
    else if(type == 1)
    {
        _rtext = [NSString stringWithFormat:@"%@%@%@%@%@",@"<font class=\"hlnote\" onclick=\"processNote(",_noteNumberFromDateTime,@")\">",_text,@"</font>"];
        //<font class=\"hl\" style=\"text-decoration: none;  border-bottom: 2px dashed #FF0000\" onclick = \"processNote(10)\"/>
    }
    //@"<a href=\"http://note=00001\" style=\"text-decoration: none;  border-bottom: 2px dashed #FF0000\">"
    NSUInteger _iStart = [sStart integerValue];
    NSUInteger _iEnd = [sEnd integerValue]; 
    NSUInteger _iLoc = _iStart < _iEnd ? _iStart : _iEnd;//[sStart integerValue];
    NSUInteger _iLength = abs(_iEnd-_iStart);
    //NSLog(@"iLoc:%d,iLength:%d",_iLoc,_iLength);
    NSRange _replaceRange = NSMakeRange(_iLoc,_iLength);
    if([_focusText rangeOfString:_text].location == NSNotFound)
        return;
    NSString *_newFocusText = [NSString stringWithString:[_focusText stringByReplacingOccurrencesOfString:_text withString:_rtext options:0 range:_replaceRange]];//_focusText
    
    NSString *_newgetmarkAreaText = [NSString stringWithString:[_getmarkAreaText stringByReplacingOccurrencesOfString:_focusText withString:_newFocusText]];
    
    NSString *_innerfocusText = [NSString stringWithFormat:@"id=\"%@\">%@",_aid,_getmarkAreaText];
    NSLog(@"_innerfocusText:%@",_innerfocusText);
    NSString *_innernewFocusText =  [NSString stringWithFormat:@"id=\"%@\">%@",_aid,_newgetmarkAreaText];
    NSLog(@"_innernewfocusText:%@",_innernewFocusText);
    
    _paraGraph = [NSMutableString stringWithString:[_paraGraph stringByReplacingOccurrencesOfString:_innerfocusText withString:_innernewFocusText]];
    
    /*if(appDelegate.iBookLastLang == 1)
     {
     _paraGraph = [NSMutableString stringWithString:[_paraGraph traditionalChineseString]];
     
     tapNumber = 3;
     }*/
    
    NSLog(@"count:%d",arrayForStoreTheContentPage.count);
    [arrayForStoreTheContentPage replaceObjectAtIndex:currentPageNumber-1 withObject:_paraGraph];
    
    NSRange _rforSave = NSMakeRange(_aidstart+r.location+_replaceRange.location, _replaceRange.length);
    //NSLog(@"Range for Save:location:%d,length:%d",_rforSave.location,_rforSave.length);
    if(appDelegate.iBookLastLang == 1)
        _text = [_text traditionalChineseString];
    NSString *_stype = [NSString stringWithFormat:@"%i",type];
    
    
    [self saveMarkedText:_id theRange:_rforSave theText:_text MarkOrNote:_stype noteText:noteText noteNumber:_noteNumberFromDateTime];
    
    
    bMarked = YES;
    delayLoadingTime = 0.0;
    //[self changePage:currentPageNumber];
    [self.jsBridge postNotificationName:@"test" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_paraGraph,@"message", nil] toWebView:self.currPage];
    
}

- (void) clearWebviewBlueSelection
{
    self.currPage.userInteractionEnabled = NO;
    self.currPage.userInteractionEnabled = YES;

}

- (void) MarkTheText: (id) sender
{
    [self TargetTheText:0 noteText:@""];//type 0 for mark the text /type 1 for note the text;
    //[self.jsBridge postNotificationName:@"test" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Hello",@"message", nil] toWebView:self.currPage];
    [self showBars:NO animated:YES];
    [self clearWebviewBlueSelection];
    //[self resignFirstResponder];
    
}

- (void) ShowTheNote:(NSString *)noteNumber
{
    //Get the note number
    NSMutableDictionary *notelist = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSString stringWithFormat:@"_%@note.plist",sBookName] getDocPathWithPList]];
    
    NSString *_noteText = [notelist objectForKey:noteNumber];
    //NSLog(@"_noteText:%@",_noteText);
    TSAlertView* av = [[[TSAlertView alloc] init] autorelease];
    av.delegate = self;
    av.title = @"筆記";
    av.message = _noteText;//@"\n\n\n";
    NSRange _r;
    _r.location =0;
    _r.length = 0;
    av.messageTextView.selectedRange = _r;
    
    av.noteNumber = noteNumber;
    
    [av addButtonWithTitle: [NSString stringWithString: NSLocalizedString(@"儲存",@"OK")]];
    [av addButtonWithTitle: [NSString stringWithString: NSLocalizedString(@"刪除",@"DELETE")]];
    
    av.style =  TSAlertViewStyleInput;
    av.buttonLayout = TSAlertViewButtonLayoutNormal;
    av.usesMessageTextView = YES;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        av.width = 600;
        av.maxHeight = 800;
    }else
    {
        av.width = 280.0;//[_widthTextField.text floatValue];
        av.maxHeight = 300.0;//[_maxHeightTextField.text floatValue];
    }
    
    [av show];
}

- (void) NoteTheText:(id)sender
{
    
    NSLog(@"I want to write note");
    TSAlertView* av = [[[TSAlertView alloc] init] autorelease];
    av.delegate = self;
    av.title = @"筆記";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        av.message = @"\n\n\n\n\n\n\n";
    else
        av.message = @"\n\n\n";
    NSRange _r;
    _r.location = 0;
    _r.length = 0;
    av.messageTextView.selectedRange = _r;
    
    
    
    [av addButtonWithTitle: [NSString stringWithString: NSLocalizedString(@"儲存",@"OK")]];
    [av addButtonWithTitle: [NSString stringWithString: NSLocalizedString(@"取消",@"Cancel")]];
    
    av.style =  TSAlertViewStyleInput;
    av.buttonLayout = TSAlertViewButtonLayoutNormal;
    av.usesMessageTextView = YES;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        av.width = 600;
        av.maxHeight = 800;
    }else
    {
        av.width = 280.0;//[_widthTextField.text floatValue];
        av.maxHeight = 300.0;//[_maxHeightTextField.text floatValue];
    }
    
    [av show];
    
    
    //[self TargetTheText:1];
    
    
}


- (void) myCopy: (id) sender
{
    //NSLog(@"my Copy");
    NSString *copyText = [self.currPage stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"];
    [[UIPasteboard generalPasteboard] setValue:copyText forPasteboardType:@"public.utf8-plain-text"];
}

-(void)initBookMark
{
    NSString *myPath = [[NSString stringWithFormat:@"_%@bookmark.plist",sBookName] getDocPathWithPList];
    [_bookMarkedPages release];
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        _bookMarkedPages = [[NSMutableArray alloc] initWithContentsOfFile:myPath];
    }
    else
    {
        _bookMarkedPages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
}

-(void)saveBookMarked:(NSInteger)page AddOrDelete:(BOOL)addNew
{
    NSInteger iPercent = (NSInteger)([self convertPagePercent:page pageCount:[arrayForStoreTheContentPage count]]);
    NSLog(@"iPercent:%d",iPercent);
    //NSString *_bnum = [NSString stringWithFormat:@"%d",page];
    NSString *_bnum = [NSString stringWithFormat:@"%d",iPercent];
    if(addNew)
    {
        //[_bookMarkedPages addObject:_bnum];
        
        if([_bookMarkedPages containsObject:_bnum])
            return;
        
        NSLog(@"AddNew Bookmark!");
        [_bookMarkedPages insertObject:_bnum atIndex:0];
    }
    else
    {
        NSUInteger _remove;
        //if([_bookMarkedPages containsObject:_lastPercent])
        //{
        if(_lastPercent == NULL)
            _lastPercent = _bnum;
        //NSLog(@"_lastPercent:%@",_lastPercent);
        if([_bookMarkedPages count] == 0)
            return;
        
        if(![_bookMarkedPages containsObject:_lastPercent])
            return;
        
        NSLog(@"Delete Bookmark!");
        _remove = [_bookMarkedPages indexOfObject:_lastPercent] ;
        NSLog(@"_remove:%d",_remove);
        [_bookMarkedPages removeObjectAtIndex:_remove];
        _lastPercent = NULL;
        
    }
    NSString *myPath = [[NSString stringWithFormat:@"_%@bookmark.plist",sBookName] getDocPathWithPList];
    
    [_bookMarkedPages writeToFile:myPath atomically:YES];
}

-(BOOL)checkBookMarked:(NSInteger)page
{
    NSInteger iPageConverted;
    //NSInteger iPercent = (NSInteger)([self convertPagePercent:page]);
    //NSString *_snum = [NSString stringWithFormat:@"%d",page];
    //NSString *_snum = [NSString stringWithFormat:@"%d",iPercent];
    BOOL bReturn = NO;
    for(NSString *_p in _bookMarkedPages)
    {
        iPageConverted = [self revertPagePercent:[_p integerValue] pageCount:[arrayForStoreTheContentPage count]];
        if(iPageConverted == page)
        {
            _lastPercent = _p;
            bReturn = YES;
        }
    }
    return bReturn;
    /*if([_bookMarkedPages containsObject:_snum])
     return YES;
     else
     return NO;
     */
}


#pragma mark -
#pragma mark audio related method
- (void)setAudioSession
{
    // Registers this class as the delegate of the audio session.
    [[AVAudioSession sharedInstance] setDelegate: self];
    
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError) {
        NSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
    }
    
    UInt32 doSetProperty = 0;
    AudioSessionSetProperty (
                             kAudioSessionProperty_OverrideCategoryMixWithOthers,
                             sizeof (doSetProperty),
                             &doSetProperty
                             );
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (activationError) {
        NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
    }
    
}

- (void) stopPlayMode
{
    if(mIsPlaying)
    {
        [self stopAudio];
        audioPlayMode = 0;
    }

}
- (void) stopAudio
{
    bVoicePlaying = YES;
    [self switchAudioImage];
    [mCReader stop];
    [mPlayer abort];
    
    mIsPlaying = NO;
}

- (void) SpeakText: (id) sender
{
    
    MyUIWebView *_mwb = self.currPage;
    NSString *_text = [[NSString stringWithString:[_mwb stringByEvaluatingJavaScriptFromString:@"(window.getSelection()).toString()"]] filterStringBeforeSpeech];
   
    [self stopPlayMode];
    //[mPlayer reset];
    NSData *audio = [[mCReader generateTTS:_text] retain];
	
	[mAQPlayer Play:audio andSampleRate:16000];
	[audio release];
    
    
}


- (void)initAudio:(NSInteger)voicetype
{
    // create CReader instance
    NSString* binChiProsody = [[NSBundle mainBundle] pathForResource:@"prosody_CHT_female_DaiYu_hts_char" ofType: @"txt"];
    NSString* binChiSynth = [[NSBundle mainBundle] pathForResource:@"synther_CHT_female_DaiYu_hts_char" ofType: @"txt"];
    
    NSString* binChiEngProsody = [[NSBundle mainBundle] pathForResource:@"prosody_ENU_female_DaiYu_hts_char" ofType: @"txt"];
    NSString* binChiEngSynth = [[NSBundle mainBundle] pathForResource:@"synther_ENU_female_DaiYu_hts_char" ofType: @"txt"];
    
	NSString* binChsProsody = [[NSBundle mainBundle] pathForResource:@"prosody_CHT_female_ZhiFen_hts_char" ofType: @"txt"];
    NSString* binChsSynth = [[NSBundle mainBundle] pathForResource:@"synther_CHT_female_ZhiFen_hts_char" ofType: @"txt"];
	
	
	NSString* binMChiProsody = [[NSBundle mainBundle] pathForResource:@"prosody_CHT_male_YouKan_hts_char" ofType: @"txt"];
    NSString* binMChiSynth = [[NSBundle mainBundle] pathForResource:@"synther_CHT_male_YouKan_hts_char" ofType: @"txt"];
	int error;
	
	// CHI and ENG example
    NSString* ttsBinArray[4] = { binChiProsody, binChiSynth, binChiEngProsody, binChiEngSynth };
    if(voicetype == 0)
    {
        ttsBinArray[0] = binChsProsody;
        ttsBinArray[1] = binChsSynth;

    }else if(voicetype == 1)
    {
        ttsBinArray[0] = binChiProsody;
        ttsBinArray[1] = binChiSynth;
    }else if(voicetype == 2)
    {
        ttsBinArray[0] = binMChiProsody;
        ttsBinArray[1] = binMChiSynth;

    }
    

    mCReader = [[CReader CReaderWithBinFiles:ttsBinArray andLang:CREADER_LANG_CHT_ENG
                                 andDelegate:self andError:&error] retain];
    
    
	if (error == CREADER_STATE_EXPIRED) {
		NSLog(@"CREADER_STATE_EXPIRED");
		
		UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Expire" message:@"SDK已過期" delegate:self cancelButtonTitle:@"confirm" otherButtonTitles:nil];
		[aView show];
		[aView release];
		
	}
	
	if (mCReader == nil) {
		NSLog(@"CReader open fail! error code=%d", error);
		//mPlayButton.enabled = NO;
		//mStopButton.enabled = NO;
	}
	
	
    // ------------------------------------------------
    // create CReaderStreamPlayer instance
    mPlayer = [[StreamPlayer alloc] initWithSampleRate:16000 samplePerBlock:1600];
    mPlayer.delegate = self;
    
    
	mAQPlayer = [[AQPlayer alloc] init];
	
    mIsPlaying = NO;
    
    audioPlayMode = 0;
}



#pragma mark - 
#pragma mark menu action related methods
- (void) didClickJumpButton:(NSInteger)jumpPage searchText:(NSString*)searchText1
{
    NSLog(@"keyword1 is %@",searchText1);
    //if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    //{
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    //}
    
    //[popController dismissPopoverAnimated:YES];
    [popover dismissPopoverAnimated:YES];
    NSString *_containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1] ;
    
    NSRange r = [_containCheck rangeOfString:searchText1];
    while (r.location == NSNotFound) {
        jumpPage -= 1;
        _containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1];
        r = [_containCheck rangeOfString:searchText1];
    }
    
    delayLoadingTime = 0.5;
    [self changePage:jumpPage];
    //NSLog(@"Data jump to page:%d",iPageConverted);
}

- (void) didSelectMarkDataItem:(NSString *)searchText pagePercent:(NSNumber *)pagePercent rowId:(NSString *)rowId{
    //NSLog(@"searchText%@",searchText);
    //if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    //{
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    //}
    
    //[popController dismissPopoverAnimated:YES];
    [popover dismissPopoverAnimated:YES];
    NSInteger iPercent = [pagePercent integerValue]+400;
    
    iPercent = iPercent>10000?10000:iPercent;
    
    NSInteger jumpPage = [self revertPagePercent:iPercent pageCount:[arrayForStoreTheContentPage count]];
    
    NSString *_containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1] ;
    NSString *_newsearchText = [NSString stringWithFormat:@"%@</font>",searchText];
    NSRange r = [_containCheck rangeOfString:_newsearchText];
    NSRange r1 = [_containCheck rangeOfString:rowId];
    while (r.location == NSNotFound || r1.location == NSNotFound) {
        jumpPage -= 1;
        if(jumpPage == 0)
            return;
        _containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1];
        r = [_containCheck rangeOfString:_newsearchText];
        r1 = [_containCheck rangeOfString:rowId];
    }
    
    delayLoadingTime = 0.5;
    [self changePage:jumpPage];
}

- (void) didSelectDataItem:(NSInteger)type selectedItem:(NSInteger)selectedItem{
    
    //imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", city]];
    //UIPopoverController *kCtrl = (UIPopoverController *)self;
    //if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    //{
        
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    //}
    
    //[popController dismissPopoverAnimated:YES];
    [popover dismissPopoverAnimated:YES];
    if(type == 0)
    {
        NSString *_p = [_bookMarkedPages objectAtIndex:selectedItem];
        NSInteger iPageConverted = [self revertPagePercent:[_p integerValue] pageCount:[arrayForStoreTheContentPage count]];
        //     delayLoadingTime = 0.5;
        [self changePage:iPageConverted];
        NSLog(@"Data jump to page:%d",iPageConverted);
    }else if(type == 1)
    {
    }else if(type == 2)
    {
    }
    //[self setBookLastPage];
    //bRotate = YES;
    //[self loadView];
    //bRotate = NO;
    
}


- (void) didSelectItem:(NSInteger)_type selectedItem:(NSInteger)_selectedItem{
    
    /*if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [self.navigationController popToRootViewControllerAnimated:NO];    
    }*/
    
    //[popController dismissPopoverAnimated:YES];
    [popover dismissPopoverAnimated:YES];
    if(_type == 0)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            switch (_selectedItem) {
                case 0:
                    _iFontSize = 18;
                    break;
                case 1:
                    _iFontSize = 22;
                    break;
                case 2:
                    _iFontSize = 26;
                    break;
                case 3:
                    _iFontSize = 30;
                    break;
                case 4:
                    _iFontSize = 35;
                    break;
            }
        }else
        {
            switch (_selectedItem) {
                case 0:
                    _iFontSize = 14;
                    break;
                case 1:
                    _iFontSize = 16;
                    break;
                case 2:
                    _iFontSize = 18;
                    break;
                case 3:
                    _iFontSize = 20;
                    break;
                case 4:
                    _iFontSize = 26;//22
                    break;
            }
            
        }
    }else if(_type == 1)
    {
        switch (_selectedItem) {
            case 0:
            {
                _iBGType = 0;
                
            }
                break;
            case 1:
            {
                _iBGType = 1;
            }
                break;
            case 2:
            {
                _iBGType = 2;
            }
                break;
            case 3:
            {
                _iBGType = 3;
            }
                break;
            case 4:
            {
                _iBGType = 4;
            }
                break;
                
        }
    }else if(_type == 2)
    {
        switch (_selectedItem) {
            case 0:
                _iFontType = 0;
                break;
            case 1:
                _iFontType = 1;
                break;
        }
    }else if(_type == 3)
    {
        //NSLog(@"Change Voice Type");
        if(mIsPlaying)
            [self stopAudio];
        
        switch (_selectedItem) {
            case 0:
                _iVoiceType = 0;
                break;
            case 1:
                _iVoiceType = 1;
                break;
            case 2:
                _iVoiceType = 2;
                break;
        }
        
    }else if(_type == 4)
    {
        //NSLog(@"Change Voice Speed");
        if(mIsPlaying)
            [self stopAudio];
        
        switch (_selectedItem) {
            case 0:
                _iVoiceSpeed = 0;
                break;
            case 1:
                _iVoiceSpeed = 1;
                break;
            case 2:
                _iVoiceSpeed = 2;
                break;
        }

    }
    [self setBookLastPage];
    bRotate = YES;
    //[self loadView];
    
    scrollView = nil;
    //NSLog(@"%d",[scrollView retainCount]);
    [self updateTheView];
    //NSLog(@"%d",[scrollView retainCount]);
    bRotate = NO;
    
    
    NSLog(@"UI reset");   
}


-(void)switchAudioImage
{
    //if(mIsPlaying)
    //   bVoicePlaying = NO;
    
    //UIImage *imageChange;
    //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(bVoicePlaying == NO)
    {
        bVoicePlaying = YES;
         [mainToolbar setVoicePlayPauced:NO];
        //imageChange = [UIImage imageNamed:@"pause.png"];
        //appDelegate.iBookLastLang = 1;
    }
    else
    {
        bVoicePlaying = NO;
        [mainToolbar setVoicePlayPauced:YES];
        //imageChange = [UIImage imageNamed:@"voice.png"];
        //appDelegate.iBookLastLang = 0;
    }
    
    if(!bVoicePurchased)
        return;
    
    //audioControlButton = [UIBarButtonItem barItemWithImage:imageChange target:self action:@selector(audioSpeech)];
    //[buttons replaceObjectAtIndex:2 withObject:audioControlButton];
    //[buttons addObject:traButton];
    
    //[toolbar setItems:buttons animated:NO];
}
/*
-(void)uiControlPopover
{
    
    SetMainViewController *setmainViewController = [[SetMainViewController alloc] initWithStyle:UITableViewStyleGrouped];
    setmainViewController.caller = self;
    setmainViewController.caller1 = self;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:setmainViewController];
        
        popController = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        CGFloat _hadjust = 410.0f;//bVoicePurchased?410.0:330.0;
        CGFloat _fadjust = 77.0f;//bVoicePurchased?127.0:143.0;
        popController.popoverContentSize = CGSizeMake(300.0,_hadjust);
        CGRect rect = CGRectMake(rectFrame.size.width-_fadjust,5.0,30.0,50.0);
        
        [popController presentPopoverFromRect:rect 
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
        
        [navCtrl release];
    }else
    {
        
        [self.navigationController pushViewController:setmainViewController animated:YES];
    }
    
    [setmainViewController release];
    [_slider setAlpha:0.0];
 
}
 */




-(void)audioSpeech
{

    //Start Log

    //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
    [self switchAudioImage];
    
    
    if (mIsPlaying)
    {
        
        if(bPaused)
        {
            //[mCReader resume];
            [mPlayer resume];
            bPaused = NO;
        }
        else {
            [mPlayer pause];
            bPaused = YES;
        }
        
        return;
    }
   
    [mPlayer reset];
    bPaused = NO;
	int val[2];
	
    CGFloat fSpeed;
    if(_iVoiceType == 0)
    {
        switch (_iVoiceSpeed) {
        case 0:
            fSpeed = 0.7;
            break;
        case 1:
            fSpeed = 0.85;
            break;
        case 2:
            fSpeed = 1.01;
            break;
        }

    }
    else if(_iVoiceType == 1)
    {
        switch (_iVoiceSpeed) {
            case 0:
                fSpeed = 0.65;
                break;
            case 1:
                fSpeed = 0.8;
                break;
            case 2:
                fSpeed = 1.0;
                break;
        }

       
    }
    else if(_iVoiceType == 2)
    {
        switch (_iVoiceSpeed) {
            case 0:
                fSpeed = 0.68;
                break;
            case 1:
                fSpeed = 0.85;
                break;
            case 2:
                fSpeed = 1.02;
                break;
        }

    }

    
	val[0] = 100.0/fSpeed; // first language
	val[1] = 100.0/fSpeed; // second language
    [mCReader setSpeed:val];
	
	val[0] = 100.0/1.0; // first language
	val[1] = 100.0/1.0; // second language
    [mCReader setBaseF0:val];
	
     
	val[0] = 100.0/1.0; // first language
	val[1] = 100.0/1.0; // second language
    [mCReader setVolume:val];
	
    
    NSString *html = [[currPage stringByEvaluatingJavaScriptFromString:@"$(\'div.main\').text();"] filterStringBeforeSpeech];
    
   
 
    [mCReader start:html];
    
    audioPlayMode = 1;
   
}

-(void)toggleBookMark
{

    if(![backImageView isHidden])
    {
        [mainToolbar setBookmarkState:NO];
        [backImageView setHidden:YES];
       
        [self saveBookMarked:currentPageNumber AddOrDelete:NO];
        
    }
    else
    {
        [mainToolbar setBookmarkState:YES];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [backImageView setHidden:NO];
            [backImageView setAlpha:1.0];
        }
        else
        {
            [backImageView setHidden:NO];
            [backImageView setAlpha:0.6];
        }
        [self saveBookMarked:currentPageNumber AddOrDelete:YES];
        
        
    }
}

-(void)transChi
{
    
    //UIImage *imageChange;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(bTransSimpChin == NO)
    {
        bTransSimpChin = YES;
        //imageChange = [UIImage imageNamed:@"tra.png"];
        [mainToolbar setTranslateLang:YES];
        appDelegate.iBookLastLang = 1;
    }
    else
    {
        bTransSimpChin = NO;
        //imageChange = [UIImage imageNamed:@"sim.png"];
         [mainToolbar setTranslateLang:NO];
        appDelegate.iBookLastLang = 0;
    }
    
    bTransed = YES;
    if(!currentPageFirstLoading)
        [self changePage:currentPageNumber];
    [self setBookLastPage];
    //bJumped = YES;
    //[self loadNextPage];
}

-(void)jumpToIndex
{
    //[self hideStatusBarDiscardingToggle:YES];
    [self stopAudio];
    
    NSInteger iT = _iCoverPageCount+_iPrefacePageCount;
    NSInteger iC = iShowingPageIdx;
    if(iC == iT)
        return;
    //NSLog(@"slider bar changed pageindex:%d",iT);
    iPage = iT;
    iShowingPageIdx = iT-_iPrepageTotal+1;
     [mainPagebar updateSliderPage:iShowingPageIdx];
    //_slider.value = iShowingPageIdx;
    
    [self changePage:iT+1];
    [self hideStatusBarDiscardingToggle:YES];
    //[self jumpPage:[[self.view subviews] objectAtIndex:1]];
    //NSLog(@"iShowingPageIdx:%d",iShowingPageIdx);
    /*if(iT > iC)
     {
     [self showOtherViewJump:[[self.view subviews] objectAtIndex:1] type:0];
     }
     else
     {
     [self showOtherViewJump:[[self.view subviews] objectAtIndex:1] type:1];
     }
     if(iFlipDir == 1)
     iFlipDir = 2;
     else if(iFlipDir == 2)
     iFlipDir = 1;
     */
    //_slider.alpha = 1;
    
    bTransed = NO;
}
/*
-(void)leaveChanged {
    NSInteger iT = [_slider iPageIndex];
    NSInteger iC = iShowingPageIdx;
    //NSLog(@"slider bar changed pageindex:%d",iT);
    // NSLog(@"iShowingPageIdx:%d",iShowingPageIdx);
    if(iC == iT-_iPrepageTotal+1)
    {
        swipeRight.enabled = YES;
        swipeLeft.enabled = YES;
        recognizer.enabled = YES;
        return;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [_slider.popoverController dismissPopoverAnimated:YES];
    else
        [_slider.wpopoverController dismissPopoverAnimated:YES];
    
    iPage = iT;
    iShowingPageIdx = iT-_iPrepageTotal+1;
    [self stopPlayMode];
    [self changePage:iT+1];
    swipeRight.enabled = YES;
    swipeLeft.enabled = YES;
    recognizer.enabled = YES;
    //NSLog(@"iShowingPageIdx:%d",iShowingPageIdx);
}
*/
-(void)leaveChanged:(NSInteger)iPageIndex{
    NSInteger iT = iPageIndex;//[_slider iPageIndex];
    NSInteger iC = iShowingPageIdx;
    //NSLog(@"slider bar changed pageindex:%d",iT);
    // NSLog(@"iShowingPageIdx:%d",iShowingPageIdx);
    if(iC == iT-_iPrepageTotal+1)
    {
        swipeRight.enabled = YES;
        swipeLeft.enabled = YES;
        recognizer.enabled = YES;
        return;
    }
    
    /*if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     [_slider.popoverController dismissPopoverAnimated:YES];
     else
     [_slider.wpopoverController dismissPopoverAnimated:YES];
     */
    [self hideStatusBar];
    [mainToolbar hideToolbar];[mainPagebar hidePagebar];
    
    iPage = iT;
    iShowingPageIdx = iT-_iPrepageTotal+1;
    [self changePage:iT+1];
    swipeRight.enabled = YES;
    swipeLeft.enabled = YES;
    recognizer.enabled = YES;
    //NSLog(@"iShowingPageIdx:%d",iShowingPageIdx);
}


#pragma mark -
#pragma mark MyReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
#if (READER_STANDALONE == FALSE) // Option
    
    /*if ([self isShowingChrome]) {
     [self showBars:NO animated:YES];
     } else {
     [self showBars:YES animated:YES];
     }*/
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [self.view.window addSubview:HUD];
	
    
    HUD.labelText = @"載入書櫃中";
    HUD.delegate = self;
    //[HUD show:NO];
    
    [HUD showWhileExecuting:@selector(myTask1) onTarget:self withObject:nil animated:NO];
    //[self myTask1];
    
    //[self showBars:YES animated:NO];
    
    
    
    
    //dissmissMyWebViewController
    
	/*if (  [delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
     {
     [delegate dismissMyWebViewController:self]; // Dismiss the ReaderViewController
     }
     else // We have a "Delegate must respond to -dismissReaderViewController: error"
     {
     NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
     }*/
    
#endif // end of READER_STANDALONE Option
}

- (void)myDissmisstask
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"dissmissMyWebViewController" object:nil];
    //[self dismissModalViewControllerAnimated:YES];
    [[self navigationController] setToolbarHidden:NO animated:NO];
    if(IS_IOS_6)
    {
        self.navigationController.navigationBar.alpha = 1.0;

    }
    
     //[self dismissViewControllerAnimated:NO completion:nil];
   
    [[self navigationController] popViewControllerAnimated:YES];//popToRootViewControllerAnimated:YES];
   

}

- (void) myTask1
{
    sleep(1);
    [self performSelectorOnMainThread:@selector(myDissmisstask) withObject:nil waitUntilDone:YES];
    
}

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    [self jumpToIndex];
}

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
    //NSInteger page = [document.pageNumber integerValue];
    
	//if ([document.bookmarks containsIndex:page])
	//{
	//	[mainToolbar setBookmarkState:NO];
    
	//	[document.bookmarks removeIndex:page];
	//}
	//else // Add the bookmarked page index
	//{
    //[mainToolbar setBookmarkState:YES];
    
    //[self.viewDeckController toggleRightViewAnimated:YES];
	//	[document.bookmarks addIndex:page];
	//}
    [self hideAllBar];
    [self toggleBookMark];
    
}

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar translateButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
    [self transChi];
}

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar searchButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    //[self uiControllerPopover:button];
    [self searchControllerPopover:button type:0];
    
}

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar settingButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    [self uiControllerPopover:button];
    
}


- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar voiceButton:(UIButton *)button
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
    [self audioSpeech];
}
#pragma mark -
#pragma mark rotation methods
/*
- (BOOL)shouldAutorotate
{
    NSLog(@"modal rotate");
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return  UIInterfaceOrientationMaskPortrait;//UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark ReaderMainPagebarDelegate methods

- (void)pagebar:(MyWebViewReaderPagebar *)pagebar gotoPage:(NSInteger)page
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif
    
    NSLog(@"goto page:%d",page);
    [self leaveChanged:page];
	//[self showDocumentPage:page]; // Show the page
}

- (void)slideAction
{
    [self sliderAction];
}

#pragma mark -
#pragma mark gesture related method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (void)tapAction:(id)ignoredh
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGPoint location = [recognizer locationInView:self.view];
    int xPos = location.x;
    int yPos = location.y;
    //NSLog(@"location:%f,%f",location.x,location.y);
    if(yPos > iTouchTopBound && yPos < iTouchBottomBound)
    {
        int page = 0;
		/*if (CGRectContainsPoint(leftTapArea, tapPoint)) {
         NSLog(@"<-- TAP left!");
         page = currentPageNumber - 1;
         } else if (CGRectContainsPoint(rightTapArea, tapPoint)) {
         NSLog(@"--> TAP right!");
         page = currentPageNumber + 1;
         }*/
        
        if(xPos < iTouchLeftBound)
        {
            //[self swipeRightAction:self];
            //NSLog(@"<-- TAP left!"); //scroller debug
			page = currentPageNumber - 1;
        }else if(xPos > iTouchRightBound)
        {
            //[self swipeLeftAction:self];
            //NSLog(@"--> TAP right!"); //scroller debug
			page = currentPageNumber + 1;
        }else
        {
           
            if ([self isShowingChrome]) {
                [self hideStatusBar];
                [mainToolbar hideToolbar];[mainPagebar hidePagebar];
                [self showBars:NO animated:YES];
            } else {
                [self showStatusBar];
                [mainToolbar showToolbar];[mainPagebar showPagebar];
                //[self showBars:YES animated:YES];
            }
            [self checkBookMarkShowOrNot:currentPageNumber];
            return;
        }
        [self stopPlayMode];
        [self changePage:page];
    }    
}

- (void)sliderAction
{
    swipeRight.enabled = NO;
    swipeLeft.enabled = NO;
    recognizer.enabled = NO;
}

#pragma mark -
#pragma mark Save Last position method
- (void)saveLastPosition
{
    
    //save last page information
    NSString *bookPath = [[NSString stringWithFormat:@"%@.plist",self.sBookName] getDocPathWithPList];
    NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:bookPath];
    //last Page
    NSString *_lastPage = [NSString stringWithFormat:@"%d",currentPageNumber];//iPage-1
    [bookSetting setObject:_lastPage forKey:@"lastPageNum"];
    //last Orientation
    NSString *_orientation;
    if(!TTIsOrienLandscape())
        _orientation = @"0";
    else
        _orientation = @"1";
    
    [bookSetting setObject:_orientation forKey:@"lastOrientation"];
    NSString *_lastPagePercent = [NSString stringWithFormat:@"%d",(NSInteger)[self convertPagePercent:currentPageNumber pageCount:[arrayForStoreTheContentPage count]]];
    
    [bookSetting setObject:_lastPagePercent forKey:@"lastPagePercent"];
    
    
    [bookSetting writeToFile:bookPath atomically:YES];
    //NSLog(@"%@.plst lastOrientation:%@,lastPageNum:%d,lastPagePercent:%@",self.sBookName,_orientation,iPage-1,_lastPagePercent);
}


- (void)applicationWill:(NSNotification *)notification
{
	[self saveLastPosition];
    
}


#pragma mark -
#pragma mark memory control

- (void)dealloc {
    //retain count check
    /*
    NSLog(@"bundleBookPath:%d",[bundleBookPath retainCount]);
    //NSLog(@"pagesNumberForShowInTheBottom:%d",[pagesNumberForShowInTheBottom retainCount]);
    NSLog(@"pageNameFromURL:%d",[pageNameFromURL retainCount]);
    NSLog(@"anchorFromURL:%d",[anchorFromURL retainCount]);
    NSLog(@"scrollView:%d",[scrollView retainCount]);
    NSLog(@"pageSpinners:%d",[pageSpinners retainCount]);
    NSLog(@"currPage:%d",[currPage retainCount]);
    NSLog(@"prevPage:%d",[prevPage retainCount]);
    NSLog(@"nextPage:%d",[nextPage retainCount]);
    NSLog(@"_menusearchText:%d",[_menusearchText retainCount]);
    NSLog(@"sBookName:%d",[sBookName retainCount]);
    NSLog(@"_bookMarkedPages:%d",[_bookMarkedPages retainCount]);
    NSLog(@"bundleBookPath:%d",[bundleBookPath retainCount]);
    NSLog(@"_markedTextInfo:%d",[_markedTextInfo retainCount]);
    NSLog(@"jsBridge:%d",[_jsBridge retainCount]);
    */
    //-----------------
    
    
    //memory check
    //NSLog(@"%d",[parseHtml retainCount]);
    //[parseHtml release];
    //parseHtml = nil;
    //[pagesNumberForShowInTheBottom release];
    [pageSpinners release];
    
    
    
    //memory check
    [_menusearchText release];
    [_bookMarkedPages release];

    
    [scrollView release];
    
    
    [mainToolbar release];
    [mainPagebar release];
    
    [_markedTextInfo release];

    
    
    [currPage release];
	[nextPage release];
	[prevPage release];

    
   
    
    [buttons release];
    [toolbar release];
    [sBookName release];
 
    [backImageView release];
    [recognizer release];
    [swipeLeft release];
	[swipeRight release];
    //release
    
    [_jsBridge release];
    
   
    
	[super dealloc];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBars:(BOOL)show animated:(BOOL)animated {
	[super showBars:show animated:animated];
	
	CGFloat alpha = show ? 1 : 0;
    //CGFloat _alpha = _slider.alpha;
	//if (alpha == _slider.alpha)
	//	return;
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:TT_TRANSITION_DURATION];
		[UIView setAnimationDelegate:self];
		if (show) {
			[UIView setAnimationDidStopSelector:@selector(showBarsAnimationDidStop)];
		} else {
			[UIView setAnimationDidStopSelector:@selector(hideBarsAnimationDidStop)];
		}
	} else {
		if (show) {
			[self showBarsAnimationDidStop];
		} else {
			[self hideBarsAnimationDidStop];
		}
	}
	
	//[self showCaptions:show];
	//if(animated == NO)
    //    _slider.alpha = _alpha;
    //else
    //    _slider.alpha = alpha;
    
	
	if (animated) {
		[UIView commitAnimations];
	}
}

/////////////////////////////////////////////////////////////////////////////////////
//index click jump page
/*- (BOOL)webView:(UIWebView *)webView
 shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType{
 
 url=[[request URL] absoluteString];
 // url = [[ request URL] retain];
 //NSLog(@"testURL:%@",url);
 if([url hasPrefix:@"http://page"])//navigationType == UIWebViewNavigationTypeLinkClicked
 {
 //int iIndexPageCount = [parseHtml.array_index_html count];
 NSInteger jumpPageNum = [[url substringFromIndex:12] intValue];
 //[self changePageWithNum:jumpPage];
 iPage = jumpPageNum+_iPrepageTotal;
 iShowingPageIdx = jumpPageNum+1;
 _slider.value = iShowingPageIdx+_iPrepageTotal-1;//?
 [self jumpPage:[[self.view subviews] objectAtIndex:1]];
 //NSLog(@"iShowingPageIdx:%d",iShowingPageIdx);
 [self showOtherViewJump:[[self.view subviews] objectAtIndex:1] type:0];
 
 return NO;
 }
 else return YES;
 //return YES;
 }*/
#pragma mark -
#pragma mark rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setBookLastPage];
    bRotate = YES;
    
    if(!scrollView)
        [scrollView removeFromSuperview];
    
    
    //NSLog(@"%d",[scrollView retainCount]);
    [self updateTheView];
    //NSLog(@"%d",[scrollView retainCount]);
    //[self loadView];
    
    bRotate = NO;
    NSLog(@"The page will rotated!");
}

- (void)updateTheView
{
     [popover dismissPopoverAnimated:NO];
    //for arc testing
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.sBookLastOpened = sBookName;
    //
    
    [self initMarkText];
    [self initBookMark];
    
    
    
	//delayLoadingTime = 0.0;//0.5
    //[arrayForStoreTheContentPage release];
    //[array_pre_page release];
    //arrayForStoreTheContentPage = [[NSMutableArray alloc] init];
    //array_pre_page = [[NSMutableArray alloc] init];

	
    
    _iFontSize = appDelegate.iFontLastSize;
    _iFontType = appDelegate.iFontLastType;
    _iBGType = appDelegate.iBGLastType;
    _iVoiceType = appDelegate.iVoiceLastType;
    _iVoiceSpeed = appDelegate.iVoiceLastSpeed;
    
    [self initAudio:_iVoiceType];
    
    switch (_iBGType) {
        case 0:
            _bColor = [UIColor colorWithRed:242.0/255.0 green:228.0/255.0 blue:202.0/255.0 alpha:1.0];//淡黃
            _spinnerColor = [UIColor blackColor];
            break;
        case 1:
            _bColor = [UIColor whiteColor];//白色
            _spinnerColor = [UIColor blackColor];
            break;
        case 2:
            _bColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:225.0/255.0 alpha:1.0];//灰
            _spinnerColor = [UIColor blackColor];
            break;
        case 3:
            _bColor = [UIColor blackColor];//黑
            _spinnerColor = [UIColor whiteColor];
            break;
        case 4:
            _bColor = [UIColor colorWithRed:49.0/255.0 green:137.0/255.0 blue:201.0/255.0 alpha:1.0];//LSM藍
            _spinnerColor = [UIColor whiteColor];
            break;
    }
    
    //rectFrame = self.view.bounds;
    //screenBounds = [[UIScreen mainScreen] bounds];
    //rectFrame = screenBounds;
   int iStatusbarSpace;
    if(IS_IOS_7)
        iStatusbarSpace = 0;
    else
        iStatusbarSpace = 20;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
        {
            
            rectFrame =  CGRectMake(0, 0, 1024, 768);
            iTouchTopBound = 100;
            iTouchBottomBound = 729;
            iTouchLeftBound = 85;
            iTouchRightBound = 940;
        }else
        {
            
            rectFrame =  CGRectMake(0, 0, 768, 1024);
            iTouchTopBound = 100;
            iTouchBottomBound = 985;
            iTouchLeftBound = 85;
            iTouchRightBound = 684;
            
        }
    }else
    {
        if( IS_IPHONE_5 )
            rectFrame =  CGRectMake(0, 0, 320, 568);
        else
            rectFrame =  CGRectMake(0, 0, 320, 480);
        iTouchTopBound = 100;
        iTouchBottomBound = 460;
        iTouchLeftBound = 30;
        iTouchRightBound = 290;
        
    }
    //[self.view removeFromSuperview];
 
 	UIView  *view = [[UIView alloc] initWithFrame:rectFrame];
    self.view = view;
    [self.view setFrame:rectFrame];
    //self.view.backgroundColor = [UIColor redColor];
    [view release];
    ////////////////////
    NSLog(@"Device Width: %f", screenBounds.size.width);
    NSLog(@"Device Height: %f", screenBounds.size.height);

    
    [self checkPageSize];
    //pageWidth = self.view.bounds.size.height;
    //pageHeight = self.view.bounds.size.width;
    
    NSLog(@"view Width: %f",  self.view.bounds.size.width);
    NSLog(@"view Height: %f", self.view.bounds.size.height);
    
    tapNumber = 0;
    discardNextStatusBarToggle = NO;
    stackedScrollingAnimations = 0;
    //[self hideStatusBar];
    
    // ****** SCROLLVIEW INIT
     //NSLog(@"%d",[scrollView retainCount]);
    [scrollView release];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, pageWidth, pageHeight)];
    [scrollView setFrame:CGRectMake(0, 0, pageWidth, pageHeight)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = _bColor;//[UIColor SCROLLVIEW_BGCOLOR];
    
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delaysContentTouches = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    
    // ****** CURR WEBVIEW INIT
    [currPage release];
    currPage = [[MyUIWebView alloc] init];
    [self setupWebView:currPage];
    
    [prevPage release];
    // ****** PREV WEBVIEW INIT
    prevPage = [[MyUIWebView alloc] init];
    [self setupWebView:prevPage];
    
    [nextPage release];
    // ****** NEXT WEBVIEW INIT
    nextPage = [[MyUIWebView alloc] init];
    [self setupWebView:nextPage];
    
    
    currentPageFirstLoading = YES;
    currentPageIsDelayingLoading = YES;
    
    [self.view addSubview:scrollView];
    
    
    if(TTIsOrienLandscape())
    {
        [self changeBook:sBookName type:1 fontSize:_iFontSize BGType:_iBGType fontType:_iFontType];
        
    }else
    {
        [self changeBook:sBookName type:0 fontSize:_iFontSize BGType:_iBGType fontType:_iFontType];
    }
    
    
    ////////////////////
    if(bRotate)
    {
        //currentPageNumber = [self revertPagePercent:appDelegate.iBookLastPagePercent pageCount:[arrayForStoreTheContentPage count]];//(NSInteger)_iPage;
        NSInteger iPercent = appDelegate.iBookLastPagePercent+400;
        
        iPercent = iPercent>10000?10000:iPercent;
        
        NSInteger jumpPage = [self revertPagePercent:iPercent pageCount:[arrayForStoreTheContentPage count]];
        
        NSString *_containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1];
        //NSLog(@"_containCheck:%@",_containCheck);
        NSString *_newsearchText = [NSString stringWithFormat:@"%@",appDelegate.sIdForRef];
        //NSLog(@"_newsearchText:%@",_newsearchText);
        if(![_newsearchText isEqualToString:@""])
        {
            NSRange r = [_containCheck rangeOfString:_newsearchText];
            while (r.location == NSNotFound) {
                jumpPage -= 1;
                if(jumpPage == 0)
                    return;
                _containCheck = [arrayForStoreTheContentPage objectAtIndex:jumpPage-1];
                r = [_containCheck rangeOfString:_newsearchText];
            }
            currentPageNumber = jumpPage;
        }else
            currentPageNumber = [self revertPagePercent:appDelegate.iBookLastPagePercent pageCount:[arrayForStoreTheContentPage count]];//(NSInteger)_iPage;
    }
    else
    {
        BOOL _isLastLandscape;
        if(parseHtml.iLastOrientation == 1)
            _isLastLandscape = YES;
        else
            _isLastLandscape = NO;
        
        if(TTIsOrienLandscape() == _isLastLandscape)
        {
            currentPageNumber = parseHtml.iLastPage;
        }else
        {
            currentPageNumber = [self revertPagePercent:parseHtml.iLastPercent pageCount:[arrayForStoreTheContentPage count]];
        }
    }
    
    if(appDelegate.iBookLastLang == 1)
    {
        if(bTransSimpChin)
            bTransSimpChin = NO;
        [self transChi];
    }
    
    
    _iPrepageTotal = (_iCoverPageCount+_iPrefacePageCount+_iIndexPageCount);
    if(!bRotate)
        iShowingPageIdx = 1 - _iPrepageTotal;
    
    
    //pagecount information
    appDelegate._bookpageCount = [arrayForStoreTheContentPage count];
    appDelegate._bookprepareTotal = _iPrepageTotal;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
            [self.view setFrame:CGRectMake(0, 0, 1024, 768)];
        else
            [self.view setFrame:CGRectMake(0,0,768,1024)];
        
    }
    //gesture
    swipeRight = nil;
    
	swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidScroll:)];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRight.delegate = self;
	[self.view addGestureRecognizer:swipeRight];

    swipeLeft = nil;
    
    //swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidScroll:)];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.delegate = self;
	[self.view addGestureRecognizer:swipeLeft];
	
	//[view release];
    
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    recognizer.delegate = self;
	[self.view addGestureRecognizer:recognizer];
	
    
    
   	
    
	iFlipDir = 0;
	
    //bookmark image;
    UIImage *_bImage = nil;
    
    _bImage = [UIImage imageNamed:@"bookmark_ipad.png"];
    
    backImageView = [[UIImageView alloc] initWithImage:_bImage];
    
    CGRect frameRect = backImageView.frame;
    CGFloat newXPos = pageWidth - 100;
    backImageView.frame = CGRectMake(newXPos, 0.0f, frameRect.size.width, frameRect.size.height);
    
    
    
    [self.view addSubview:backImageView];
    
    
    
    //TOOL BAR
    CGRect _vx = rectFrame;
    //CGRect viewRect = CGRectMake(_vx.origin.x,_vx.origin.y+20, _vx.size.width, _vx.size.height); // View bounds
    CGRect toolbarRect;
    if(IS_IOS_7)
        toolbarRect = _vx;
    else
        toolbarRect = CGRectMake(_vx.origin.x,_vx.origin.y+20, _vx.size.width, _vx.size.height);
    
	toolbarRect.size.height = TOOLBAR_HEIGHT;
    
	mainToolbar = [[MyReaderMainToolbar alloc] initWithFrame:toolbarRect]; // At top// document:document
    
    [mainToolbar setTag:166];
    
	mainToolbar.delegate = self;
    [self.view addSubview:mainToolbar];
    
    
    //Bottom BAR
    CGRect pagebarRect = _vx;
	pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (_vx.size.height - PAGEBAR_HEIGHT);
    
    mainPagebar = [[MyWebViewReaderPagebar alloc] initWithFrame:pagebarRect pageCount:[arrayForStoreTheContentPage count]-2  iprePageTotal:_iPrepageTotal]; // At bottom
    
	mainPagebar.delegate = self;
    
	[self.view addSubview:mainPagebar];
    [self hideStatusBar];
    [mainToolbar hideToolbar]; [mainPagebar hidePagebar];
    
    [self initBook1];
    
    
    
    [self checkBookMarkShowOrNot:currentPageNumber];

    
    
    //for jsBridge 20120620 johnilu33--------------------------------------------
    
    self.jsBridge = [TGJSBridge jsBridgeWithDelegate:self];
    
    self.prevPage.delegate = self.jsBridge;
    self.currPage.delegate = self.jsBridge;
    self.nextPage.delegate = self.jsBridge;
    
    
    [self copyJsFileIfNeeded:@"TGJSBridge" extName:@".js"];
    [self copyJsFileIfNeeded:@"selfjs" extName:@".js"];
    [self copyJsFileIfNeeded:@"jquery" extName:@".js"];
     
    //for jsBridge 20120620 johnilu33--------------------------------------------
}
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark BookMark
- (void)checkBookMarkShowOrNot:(NSUInteger)page
{
    if([self checkBookMarked:page])
    {
        [backImageView setHidden:NO];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [backImageView setAlpha:1.0];
        else
            [backImageView setAlpha:0.6];
    }
    else
    {
        [backImageView setHidden:YES];
        [backImageView setAlpha:0];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility
//utility
- (void)hideAllBar
{
    [self hideStatusBar];
    [mainToolbar hideToolbar];
    [mainPagebar hidePagebar];
}

-(CGFloat)convertPagePercent:(NSInteger)page pageCount:(NSInteger)count
{
    //last Page percent
    NSInteger _array_count = count;
    CGFloat _x = page;
    CGFloat _y = _array_count;
    CGFloat _f = _x/_y*10000.0;
    NSLog(@"convert percent:%f",_f);
    //NSString *_s = [NSString stringWithFormat:@"%d",(NSInteger)_f];
    return _f;
}

-(NSInteger)revertPagePercent:(CGFloat)percent pageCount:(NSInteger)count
{
    CGFloat _ac =  count;
    CGFloat _iP = percent;
    NSLog(@"revert percent:%f",percent);
    CGFloat _iPage = (_iP/10000.0)*_ac;
    if(fmodf(_iPage, 1.0) >= 0.5)
        return (NSInteger)_iPage +1;
    else
        return (NSInteger)_iPage;
}

- (NSString *)getDateTimeSecString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HHmmss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    
    
    NSString *formatedString = [NSString stringWithFormat:@"%@%@", theDate, theTime];
    
    [dateFormat release];
    [timeFormat release];
    [now release];
    
    return formatedString;
}
-(NSString*) produceImageReference:(NSString*) imgFileName withType:(NSString*) imgType{
	NSMutableString *returnString = [[[NSMutableString alloc] initWithCapacity:100] autorelease];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:imgFileName ofType:imgType];
	if(filePath){
		[returnString appendString:@"<IMG SRC=\"file://"];
		[returnString appendString:filePath];
		[returnString appendString:@"\" ALT=\""];
		[returnString appendString:imgFileName];
		[returnString appendString:@"\">"];
		return returnString;
	}
	else return @"";
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TSAlertView click event
- (void)alertView:(TSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        NSString *_noteText = [NSString stringWithString:alertView.messageTextView.text];
        
        NSLog(@"noteText:%@",_noteText);
        
        if(alertView.noteNumber != nil)
        {
            NSString *_noteNumber =[NSString stringWithString:alertView.noteNumber];
            NSMutableDictionary *notelist;
            
            NSString *_sfn = [NSString stringWithFormat:@"_%@note.plist",sBookName];
            NSString *dataPath = [_sfn getDocPathWithPList];
            // NSLog(@"dataPath:%@",dataPath);
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:dataPath])
            {	
                notelist = [NSMutableDictionary dictionaryWithObjectsAndKeys:_noteText,_noteNumber,nil];
            }else 
            {
                notelist = [NSMutableDictionary dictionaryWithContentsOfFile:dataPath];
                if([notelist objectForKey:_noteNumber] != nil)
                    [notelist removeObjectForKey:_noteNumber];
                
                [notelist setObject:_noteText forKey:_noteNumber];
                
                
            }
            
            [notelist writeToFile:dataPath atomically:YES];
        }else {
            
            [self TargetTheText:1 noteText:_noteText]; //type 0 for mark the txt,type 1 for note the text
        }
        
    }else if(buttonIndex == 1)
    {
        if(alertView.noteNumber != nil)
        {
             NSString *_noteNumber =[NSString stringWithString:alertView.noteNumber];
            [self NoteOrMarkToDelete:1 noteNumber:_noteNumber];
        }
    }
    [self showBars:NO animated:YES];
    [self clearWebviewBlueSelection];
}
#pragma mark -
#pragma mark Audio Speech event
-(void) onCReaderSynthProgress:(NSData *)audio
{
    if (mPlayer.isAbort)
        return;
    
    [audio retain];
    
#ifdef SAVE_WAVE_TO_FILE        
    [mSaveData appendData:audio];
#endif    
    
    // the audio data must be saved immediately, and then return ASAP.
    [mPlayer addSample:(short *)[audio bytes] numberOfSample:[audio length]/2];
    
    
    // when player's buffer has enough audio samples, start to play
    if (!mPlayer.isAbort && !mIsPlaying && [mPlayer enoughDataToPlay:9600])
    {
        NSLog(@"call startPlay() in progress");
        mIsPlaying = YES;
        [mPlayer startPlay];
    }
    
    [audio release];
}

-(void) onCReaderSynthBegin:(CReader *)sender
{
    NSLog(@"onCReaderSynthBegin");
    
#ifdef SAVE_WAVE_TO_FILE        
    if (mSaveData == nil)
        [mSaveData release];
    mSaveData = [[NSMutableData alloc] init];
#endif
    
}

-(void) onCReaderSynthFinish:(CReader *)sender
{
    NSLog(@"onCReaderSynthFinish");
    
#ifdef SAVE_WAVE_TO_FILE        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    [mSaveData writeToFile:[documentsDirectoryPath stringByAppendingString:@"/outAudio.pcm"] atomically:YES];
#endif
    
    // notify player that no audio data to add
    [mPlayer endOfData];
    
    // if not played after synth finished, start playing
    if (!mPlayer.isAbort && !mIsPlaying) {
        mIsPlaying = YES;
        [mPlayer startPlay];
        
    }
}

// called by StreamPlayer when it finishes the playback normally
- (void)playFinish:(id)sender
{
    NSLog(@"StreamPlayer: delegate playFinish");
    [self stopAudio];
    int page = currentPageNumber + 1;
    [self changePage:page];
  
   
}
#pragma mark -
#pragma mark Popover
-(void)uiControllerPopover:(id)sender
{
    SAFE_ARC_RELEASE(popover); popover=nil;
    
    //the controller we want to present as a popover
    //DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
    //SetMainViewController *controller = [[SetMainViewController alloc] initWithStyle:UITableViewStylePlain];//UITableViewStyleGrouped
    SetMainViewController *setmainViewController = [[SetMainViewController alloc] initWithStyle:UITableViewStylePlain];
    setmainViewController.caller = self;
    setmainViewController.caller1 = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:setmainViewController];
    SAFE_ARC_RELEASE(setmainViewController); setmainViewController=nil;
    
    popover = [[FPPopoverKeyboardResponsiveController alloc] initWithViewController:nc];
    popover.tint = FPPopoverDefaultTint;
    popover.arrowDirection = FPPopoverArrowDirectionUp;
    //popover.contentSize = CGSizeMake(300, 500);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover.contentSize = CGSizeMake(300, 480);
    }
    else {
        popover.contentSize = CGSizeMake(200, 440);
    }
    [popover presentPopoverFromView:sender];
    
    //CGRect nc_bar_frame = nc.navigationBar.frame;
    //nc_bar_frame.origin.y = 0;
    //nc.navigationBar.frame = nc_bar_frame;
}

-(void)searchControllerPopover:(id)sender type:(NSInteger)iFromToolBar
{
    SAFE_ARC_RELEASE(popover); popover=nil;
    
    searchViewController = [[SearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchViewController.caller = self;
    //SetMainViewController *setmainViewController = [[SetMainViewController alloc] initWithStyle:UITableViewStylePlain];
    //setmainViewController.caller = self;
    //setmainViewController.caller1 = self;
    if(iFromToolBar != 0)
    {
        [searchViewController._searchBar setText:_menusearchText];
    }
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:searchViewController];
       
    popover = [[FPPopoverKeyboardResponsiveController alloc] initWithViewController:nc];
    popover.tint = FPPopoverDefaultTint;
    popover.arrowDirection = FPPopoverArrowDirectionUp;
    //popover.contentSize = CGSizeMake(300, 500);
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        popover.contentSize = CGSizeMake(340, 950);
    }
    else {
        popover.contentSize = CGSizeMake(320, 520);
    }
    [popover presentPopoverFromView:sender];
    
   
    //    CGRect nc_bar_frame = nc.navigationBar.frame;
    //    nc_bar_frame.origin.y = 0;
    //    nc.navigationBar.frame = nc_bar_frame;
}

-(void)searchTheBook:(NSInteger)iFromToolBar
{
    searchViewController = [[SearchTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    searchViewController.caller = self;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        
        popController = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        
        popController.popoverContentSize = CGSizeMake(300.0,550.0);
        CGFloat _fadjust = 160.0f;//bVoicePurchased?170.0:188.0;
        CGRect rect = CGRectMake(rectFrame.size.width-_fadjust,5.0,30.0,50.0);
        
        [popController presentPopoverFromRect:rect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
        [navCtrl release];
    }else
    {
        //若iphone時，先把toolbar叫出來，以免push時navigator不見
        [self showBars:YES animated:NO];
        
        [self.navigationController pushViewController:searchViewController animated:YES];
        
    }
    
    if(iFromToolBar != 0)
    {
        [searchViewController._searchBar setText:_menusearchText];
    }
    [searchViewController release];
}

-(void)searchPopover
{
    
    [self searchTheBook:0];
    
}



/*-(void)selectedTableRow:(NSUInteger)rowNum
{
    NSLog(@"SELECTED ROW %d",rowNum);
    [popover dismissPopoverAnimated:YES];
}*/

@end

