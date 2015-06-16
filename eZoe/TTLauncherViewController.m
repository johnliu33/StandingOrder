//
//  TTLauncherViewController.m
//  Three20
//
//  Created by Rodrigo Mazzilli on 9/25/09.


#import "TTLauncherViewController.h"


// UI
#import "Three20UI/TTNavigator.h"
#import "Three20UI/TTActivityLabel.h"
#import "Three20UI/TTErrorView.h"
#import "Three20UI/TTListDataSource.h"
#import "Three20UI/TTTableView.h"
#import "Three20UI/TTTableViewDelegate.h"
#import "Three20UI/TTTableViewVarHeightDelegate.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20UI/UITableViewAdditions.h"

// UINavigator
#import "Three20UINavigator/TTURLObject.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/TTGlobalCoreLocale.h"
#import "Three20Core/TTGlobalCoreRects.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

#import "Three20/Three20.h"
#import "Three20Style/TTDefaultStyleSheet.h"
#import "Three20Network/TTURLCache.h"

#import "Three20UI/UIViewAdditions.h"
#import "Three20UICommon/UIViewControllerAdditions.h"
#define TTLAUNCHERVIEW_MAX_SIZE		CGSizeMake(1024.0f, 768.0f)
//CGSizeMake(320.0f, 426.0f)
//CGFloat degreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
//CGFloat radiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

#define BUTTON_WIDTH 54.0
#define BUTTON_SEGMENT_WIDTH 51.0
#define CAP_WIDTH 5.0

typedef enum {
    CapLeft          = 0,
    CapMiddle        = 1,
    CapRight         = 2,
    CapLeftAndRight  = 3
} CapLocation;


@interface TTLauncherViewController (Private)
- (void)removeFromSupercontroller:(BOOL)animated;
-(UIButton*)woodButtonWithText:(NSString*)buttonText stretch:(CapLocation)location;
-(UIBarButtonItem*)woodBarButtonItemWithText:(NSString*)buttonText;
@end


@implementation TTLauncherViewController
@synthesize segmentIndexOfView;
@synthesize tableView           = _tableView;
@synthesize tableBannerView     = _tableBannerView;
@synthesize tableOverlayView    = _tableOverlayView;
@synthesize loadingView         = _loadingView;
@synthesize errorView           = _errorView;
@synthesize emptyView           = _emptyView;
@synthesize menuView            = _menuView;
@synthesize tableViewStyle      = _tableViewStyle;
@synthesize variableHeightRows  = _variableHeightRows;
@synthesize showTableShadows    = _showTableShadows;
@synthesize dataSource          = _dataSource;

@synthesize launcherNavigationController = _launcherNavigationController;
@synthesize launcherView = _launcherView;

@synthesize bg;
@synthesize sb;
@synthesize eZoeTitle;



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    TT_RELEASE_SAFELY(_tableDelegate);
    TT_RELEASE_SAFELY(_tableView);
    [_tableBannerView removeFromSuperview];
    TT_RELEASE_SAFELY(_tableBannerView);
    [_tableOverlayView removeFromSuperview];
    TT_RELEASE_SAFELY(_tableOverlayView);
    [_loadingView removeFromSuperview];
    TT_RELEASE_SAFELY(_loadingView);
    [_errorView removeFromSuperview];
    TT_RELEASE_SAFELY(_errorView);
    [_emptyView removeFromSuperview];
    TT_RELEASE_SAFELY(_emptyView);
    [_menuView removeFromSuperview];
    TT_RELEASE_SAFELY(_menuView);
    [_menuCell removeFromSuperview];
    TT_RELEASE_SAFELY(_menuCell);

}

- (void)dealloc {
   	TT_RELEASE_SAFELY(_overlayView);
	TT_RELEASE_SAFELY(_launcherView);
	TT_RELEASE_SAFELY(_launcherNavigationController);
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    TT_RELEASE_SAFELY(_tableDelegate);
    TT_RELEASE_SAFELY(_dataSource);
    TT_RELEASE_SAFELY(_tableView);
    TT_RELEASE_SAFELY(_loadingView);
    TT_RELEASE_SAFELY(_errorView);
    TT_RELEASE_SAFELY(_emptyView);
    TT_RELEASE_SAFELY(_tableOverlayView);
    TT_RELEASE_SAFELY(_tableBannerView);
    [super dealloc];
}

//Datasource
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createInterstitialModel {
    self.dataSource = [[[TTTableViewInterstitialDataSource alloc] init] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addToOverlayView:(UIView*)view {
    if (!_tableOverlayView) {
        CGRect frame = [self rectForOverlayView];
        _tableOverlayView = [[UIView alloc] initWithFrame:frame];
        _tableOverlayView.autoresizesSubviews = YES;
        _tableOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleBottomMargin;
        NSInteger tableIndex = [_tableView.superview.subviews indexOfObject:_tableView];
        if (tableIndex != NSNotFound) {
            [_tableView.superview addSubview:_tableOverlayView];
        }
    }
    
    view.frame = _tableOverlayView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableOverlayView addSubview:view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTableDelegate {
    if (!_tableView.delegate) {
        [_tableDelegate release];
        _tableDelegate = [[self createDelegate] retain];
        
        // You need to set it to nil before changing it or it won't have any effect
        _tableView.delegate = nil;
        _tableView.delegate = _tableDelegate;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addSubviewOverTableView:(UIView*)view {
    NSInteger tableIndex = [_tableView.superview.subviews
                            indexOfObject:_tableView];
    if (NSNotFound != tableIndex) {
        [_tableView.superview addSubview:view];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutBannerView {
    if (_tableBannerView) {
        _tableBannerView.frame = [self rectForBannerView];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeOutView:(UIView*)view {
    [view retain];
    [UIView beginAnimations:nil context:view];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadingOutViewDidStop:finished:context:)];
    view.alpha = 0;
    [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadingOutViewDidStop:(NSString*)animationID finished:(NSNumber*)finished
                     context:(void*)context {
    UIView* view = (UIView*)context;
    [view removeFromSuperview];
    [view release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideMenuAnimationDidStop:(NSString*)animationID finished:(NSNumber*)finished
                         context:(void*)context {
    UIView* menuView = (UIView*)context;
    [menuView removeFromSuperview];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}


- (id)init {
	if ((self = [super init])) {
		_overlayView = nil;
		_launcherNavigationControllerTopViewController = nil;
        
        
        _tableViewStyle = UITableViewStylePlain;
	}
	return self;
}


#pragma mark -
#pragma mark UITableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetNavigationBar
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation))
            bg.frame = CGRectMake(0, 0, 1024, 45);
        else
            bg.frame = CGRectMake(0, 0, 768, 45);
        
        CGFloat sbLength = 135.0;
        CGFloat sbOffset = bg.frame.size.width-70-sbLength;
        
        sb.frame = CGRectMake(sbOffset, 0, sbLength, 44);
        
        eZoeTitle.frame = CGRectMake(bg.frame.size.width/2-130-20, 0, 130, 45);
    }
}


- (void)loadView {
	[super loadView];
    
    
    _launcherView = [[MyLauncherView alloc] initWithFrame:self.view.frame];
    _launcherView.backgroundColor = TTSTYLEVAR(launcherBackgroundColor);
   
    [self.view addSubview:_headerView];
    [self.view addSubview:_launcherView];
    [self.view addSubview:_footerView];
    
        
    

    
    //bg.backgroundColor = [UIColor blackColor];

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat hOffset;
    CGFloat fHeight;
    
    CGFloat sbOffset;
    CGFloat sbLength;
    

    
	if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            bg = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 45)] autorelease];
            eZoeTitle = [[[UILabel alloc] initWithFrame:CGRectMake(bg.frame.size.width/2-130-20, 0, 130, 45)] autorelease];
            eZoeTitle.text =  NSLocalizedString(@"電子書報eZoe", @"eZoe");
            eZoeTitle.textColor = [UIColor whiteColor];
            eZoeTitle.backgroundColor = [UIColor clearColor];
            [bg addSubview:eZoeTitle];

            hOffset = 0.0;
            fHeight = 8.0;
            
            sbLength = 135.0;
            sbOffset = bg.frame.size.width-70-sbLength;

        }
    }else
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            bg = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 45)] autorelease];
            eZoeTitle = [[[UILabel alloc] initWithFrame:CGRectMake(bg.frame.size.width/2-130, 0, 130, 45)] autorelease];
            eZoeTitle.text =  NSLocalizedString(@"電子書報eZoe", @"eZoe");
            eZoeTitle.textColor = [UIColor whiteColor];
            eZoeTitle.backgroundColor = [UIColor clearColor];
            [bg addSubview:eZoeTitle];

            
            hOffset = 0.0;
            fHeight = 8.0;
            sbLength = 135.0;
            sbOffset = bg.frame.size.width-70-sbLength;
           
        }else {
            bg = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)] autorelease];
            //for iphone
            eZoeTitle = [[[UILabel alloc] initWithFrame:CGRectMake(37, 0, 130, 45)] autorelease];
            eZoeTitle.text =  NSLocalizedString(@"電子書報eZoe", @"eZoe");
            eZoeTitle.textColor = [UIColor whiteColor];
            eZoeTitle.backgroundColor = [UIColor clearColor];
            [bg addSubview:eZoeTitle];

            hOffset = 45.0;
            fHeight = 8.0;
            
            sbOffset = 150.0;
            sbLength = 105.0;
        }

    }
       
    sb = [[[UISearchBar alloc] initWithFrame:CGRectMake(sbOffset, 0, sbLength, 44)] autorelease];
    
    
    if(IS_IOS_7)
    {
        for (UIView *subview in sb.subviews)
        {
            for (UIView *mySubView in subview.subviews){
                if ([mySubView isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
                {
                     [mySubView removeFromSuperview];
                    break;
                }
            }
        }
        
    }else
    {
        sb.barStyle                 = UIBarStyleBlackTranslucent;
    }
    sb.showsCancelButton        = NO;
    sb.autocorrectionType       = UITextAutocorrectionTypeNo;
    sb.autocapitalizationType   = UITextAutocapitalizationTypeNone;
    sb.delegate                 = self;

    [bg addSubview:sb];
    
    segmentControlTitles = [[NSArray arrayWithObjects:@"書櫃", @"表列", nil] retain];
    UIImage* dividerImage = nil;//[UIImage imageNamed:@"view-control-divider.png"];
    
    
    
    
    
    segmentview = [[[CustomSegmentedControl alloc] initWithSegmentCount:segmentControlTitles.count hOffset:hOffset height:fHeight segmentsize:CGSizeMake(BUTTON_SEGMENT_WIDTH, dividerImage.size.height) dividerImage:dividerImage tag:0 delegate:self] autorelease];
    
    [bg addSubview:segmentview];
    
    self.navigationItem.titleView = nil;
    self.navigationItem.titleView = bg;
    
    for (UIView *subview in sb.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    } 
    
    [self.view addSubview:_tableView];
    
    NSInteger _segIndex = [self.segmentIndexOfView intValue];
    if(_segIndex == 1)
        [(CustomSegmentedControl *)segmentview reverseSelectedButtons];
    
    if(_segIndex == 0.0)
    {
        [sb setAlpha:0.0];
        NSLog(@"You see the bookshelf");
    }
    else 
    {
        [sb setAlpha:1.0];
        NSLog(@"You see the tableview");
    }

    //[(CustomSegmentedControl *)segmentview reverseSelectedButtons];
        
}

- (void)reverseSegmentButtons:(NSInteger)iIndex
{
    if(iIndex == 1)
        [(CustomSegmentedControl *)segmentview reverseSelectedButtons];

}

- (void)viewWillAppear:(BOOL)animated {
    UINavigationBar *navbar = [self.navigationController navigationBar];
    [navbar setAlpha:1.0]; //navbar出現

    [self.view setAlpha:1.0];  //書櫃出現
	[super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	// We should NOT call this for _launcherNavigationController
	// otherwise the transition calls viewWillAppear: and viewDidAppear:
	// won't be called by the navigation controller.
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	// We should NOT call this for _launcherNavigationController
	// otherwise the transition calls viewWillAppear: and viewDidAppear:
	// won't be called by the navigation controller.	
}

- (CGAffineTransform)transformForOrientation {
	return TTRotateTransformForOrientation(TTInterfaceOrientation());
}

#pragma mark -
#pragma mark Overlay view

- (void)addOverlayView {
	if (!_overlayView) {
		CGRect frame = [self rectForOverlayView];
        //CGRect frame = CGRectMake(0, 0, 768, 1004);
		_overlayView = [[UIView alloc] initWithFrame:frame];
		_overlayView.backgroundColor = [UIColor blackColor];
		_overlayView.alpha = 0.0f;
		_overlayView.autoresizesSubviews = YES;
		_overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		[self.view addSubview:_overlayView];
	}
	self.view.frame = _overlayView.bounds;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)resetOverlayView {
	if (_overlayView && !_overlayView.subviews.count) {
		[_overlayView removeFromSuperview];
		TT_RELEASE_SAFELY(_overlayView);
	}
}

- (void)layoutOverlayView {
	if (_overlayView) {
		_overlayView.frame = [self rectForOverlayView];
	}
}

#pragma mark -
#pragma mark Animation delegates

- (void)showAnimationDidStop {
	// Notify super controller that it did disappear, since
	// a child was launched on top.
	[self viewDidDisappear:YES];
}

- (void)fadeAnimationDidStop {
	[[_launcherNavigationController topViewController] viewDidDisappear:YES];
	[self removeFromSupercontroller:NO];
	[self resetOverlayView];
}

- (void)fadeOut {
	[[_launcherNavigationController topViewController] viewWillDisappear:YES];
	
	UIView *viewToDismiss = [[_launcherNavigationController topViewController] view];
	viewToDismiss.transform = CGAffineTransformIdentity;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:TT_LAUNCHER_HIDE_TRANSITION_DURATION];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeAnimationDidStop)];
	viewToDismiss.alpha = 0;		
	viewToDismiss.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
	_overlayView.alpha = 0.0f;
	[UIView commitAnimations];	
    [_launcherView setCurrentPageIndex:iLauncherLastRotatePage]; 
}

- (void)hideKeyboard {
	// Hide keyboard if visible
	UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] findFirstResponder]; 
	[firstResponder resignFirstResponder];

}

- (void)launchChild {
	// Notify super controller that it will disappear, since
	// a child will be launched on top.
	[self viewWillDisappear:YES];
	
	UIView *viewToLaunch = [[_launcherNavigationController topViewController] view];
	
    [self hideKeyboard];
    /*UIResponder *theFirstResponder = [self findFirstResponder];
    if (theFirstResponder) {
        [theFirstResponder resignFirstResponder];
    }*/

	
	viewToLaunch.transform = [self transformForOrientation];
	
	[self.superController.view addSubview:[_launcherNavigationController view]];
	
	viewToLaunch.frame = self.view.bounds;//CGRectMake(0, 0, 1024, 768);//
   
	viewToLaunch.alpha = 0;		
	viewToLaunch.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
	
	// Add overlay view
	[self addOverlayView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:TT_LAUNCHER_SHOW_TRANSITION_DURATION];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];
	viewToLaunch.alpha = 1.0f;		
	viewToLaunch.transform = CGAffineTransformIdentity;
	_overlayView.alpha = 0.85f;
	[UIView commitAnimations];
}


- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated transition:(UIViewAnimationTransition)transition {
	if (!_launcherNavigationController) 
    {
		_launcherNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(TTInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft || TTInterfaceOrientation() == UIInterfaceOrientationLandscapeRight)
                [_launcherNavigationController.view setFrame:CGRectMake(0, 0, 1024, 768)];
            else
                  [_launcherNavigationController.view setFrame:CGRectMake(0, 0, 768, 1024)];
        }else
        {

            if(TTInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft || TTInterfaceOrientation() == UIInterfaceOrientationLandscapeRight)
                [_launcherNavigationController.view setFrame:CGRectMake(0, 0, 480, 320)];
            else
            {
                if(IS_IPHONE_5)
                    [_launcherNavigationController.view setFrame:CGRectMake(0, 0, 320, 568)];
                else
                    [_launcherNavigationController.view setFrame:CGRectMake(0, 0, 320, 480)];
                
            }


        }
		[_launcherNavigationController viewWillAppear:animated];
		[_launcherNavigationController viewDidAppear:animated];
		
		_launcherNavigationController.superController = self;
		_launcherNavigationController.delegate = self; 
		// Add default left-side button in navigation bar
		UIBarButtonItem *launcherBarButtonItem = [[UIBarButtonItem alloc] initWithImage:TTIMAGE(@"bundle://bookBox.png")
												  style:UIBarButtonItemStyleBordered
												  target:self
												  action:@selector(removeFromSupercontroller)];
		[controller.navigationItem setLeftBarButtonItem:launcherBarButtonItem];
		[launcherBarButtonItem release];
		
         
		// Launch child
		[self launchChild];
		
	} else {
		[_launcherNavigationController addSubcontroller:controller animated:animated transition:transition];
	}
    
}

- (void)removeFromSupercontroller:(BOOL)animated {
	if (animated) {
		[self fadeOut];
	} else {        
        
        
		[_launcherNavigationController.topViewController removeFromSupercontroller];
		[[_launcherNavigationController view] removeFromSuperview];
    
		// We need to keep this navigation controller
		// so that notifications viewWillAppear: and viewDidAppear:
		// continue to be dispatched.
		// Since we cannot fully remove the top view controller from
		// navigation controller, we set a 'nil' array. 
		if ([_launcherNavigationController.viewControllers count] == 1) {
			TT_RELEASE_SAFELY(_launcherNavigationController);
		}
		_launcherNavigationControllerTopViewController = nil;
        //[[[_launcherNavigationController topViewController] view] release];
        
		[self.superController viewWillAppear:animated];
		[self.superController viewDidAppear:animated];
	}
   
}

- (void)removeFromSupercontroller {
	[self removeFromSupercontroller:YES];
}

- (void)persistNavigationPath:(NSMutableArray*)path {
	if (_launcherNavigationController) {
		// We have controllers open inside the launcher controller, so persist it
		[_launcherNavigationController persistNavigationPath:path];
	}
}

- (UIViewController *)topSubcontroller {
	return _launcherNavigationControllerTopViewController;
}

#pragma mark -
#pragma mark Layout subviews

- (void)layoutSubviews {
   
	CGFloat headerHeight = 0.0f;
	CGFloat footerHeight = 0.0f;
	if (_headerView) {
		[_headerView setFrame:CGRectMake(0.0f, 0.0f, _headerView.frame.size.width,  _headerView.frame.size.height)];
		headerHeight = _headerView.frame.size.height;
        //NSLog(@"_headerView.frame.size.width:%f _headerView.frame.size.height:%f",_headerView.frame.size.width,_headerView.frame.size.height);
	}
	
	if (_footerView) {
		footerHeight = _footerView.frame.size.height;
		[_footerView setFrame:CGRectMake(0.0f, self.view.bounds.size.height - footerHeight, _footerView.frame.size.width,  footerHeight)];
	}	
	//[self.view addSubview:_headerView];
	//[self.view addSubview:_footerView];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
            [_launcherView setFrame:CGRectMake(0.0f, headerHeight, 1024.0f, 768.0f - footerHeight)];//320.0f
        else
            
            [_launcherView setFrame:CGRectMake(0.0f, headerHeight, 768.0f, 1024.0f - footerHeight)];//320.0f
    }else
    {
        if(TTIsOrienLandscape())
            [_launcherView setFrame:CGRectMake(0.0f, headerHeight, 480.0f, 320.0f - footerHeight)];//320.0f
        else
            
            [_launcherView setFrame:CGRectMake(0.0f, headerHeight, 320.0f, 480.0f - footerHeight)];//320.0f
    }
    ///NSLog(@"_launcherView setFrame:(0,%f,%f,%f,)",headerHeight,1024.0f,TTLAUNCHERVIEW_MAX_SIZE.height - footerHeight);
}

#pragma mark -
#pragma mark Public


- (void)setHeaderView:(UIView *)headerView {
	TT_RELEASE_SAFELY(_headerView);
	_headerView = (TTView*)[headerView retain];
	[self layoutSubviews];
}

- (UIView *)headerView {
	return _headerView;
}

- (void)setFooterView:(UIView *)footerView {
	TT_RELEASE_SAFELY(_footerView);
	_footerView = (TTView*)[footerView retain];
	[self layoutSubviews];
}

- (UIView *)footerView {
	return _footerView;
}

#pragma mark -
#pragma mark UIViewController (TTCategory)

- (BOOL)shouldAutorotate
{
    NSLog(@"launch rotate");
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return  UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    HUD = [[MBProgressHUD alloc] initWithView:_launcherView.window];
    [_launcherView.window addSubview:HUD];
    
    HUD.labelText = @"Loading";
    [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];

}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
   
    [UIView setAnimationsEnabled:NO];
 }

- (void)rotateLaunchView
{
    [_launcherView setFrame:self.view.bounds];
    
    [self rotateView];
    
    [_launcherView setCurrentPageIndex:iLauncherLastRotatePage];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.1];
    
    [self.view setAlpha:1];
    
    [UIView commitAnimations];
}

-(void)myTask
{

    [self performSelectorOnMainThread:@selector(rotateLaunchView) withObject:Nil waitUntilDone:NO];
    
}


- (void)rotateView {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        if(TTIsOrienLandscape())
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest_L.png"]]]];
            _launcherView.columnCount = 5;
            _launcherView.rowCount = 4;
            [_launcherView setFrame:CGRectMake(0, 0, 1024, 748)]; //add 20120109 by johnliu33
        }else
        {
            [self.view setBackgroundColor:
             [UIColor colorWithPatternImage:
              [UIImage imageWithContentsOfFile:
               [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
                @"chest.png"]]]];
            [_launcherView setFrame:CGRectMake(0, 0, 748, 1024)]; //add 20130910 by johnliu33
            _launcherView.columnCount = 4;
            _launcherView.rowCount = 5;
        }
        _launcherView.currentPageIndex = 0;
    }
    
    
}
/*
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
 
    
    if ([[_launcherNavigationController topViewController] isKindOfClass:[TTWebController class]]) 
    {
        
        MyWebViewController *_tview = (MyWebViewController *)[_launcherNavigationController topViewController];
        [_tview setBookLastPage];
        [self removeFromSupercontroller:NO];
        TTURLAction *action = [TTURLAction actionWithURLPath:@"tt://myWebViewController?book=rotate"];
        [action setAnimated:YES];

        [[TTNavigator navigator] openURLAction:action];
    }
   
    if((([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) || 
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)))
    {
        [self.view setBackgroundColor:
         [UIColor colorWithPatternImage:
          [UIImage imageWithContentsOfFile:
           [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
            @"chest_L.png"]]]];	
        _launcherView.columnCount = 5;
        _launcherView.rowCount = 4;
             
    }else
    {
        [self.view setBackgroundColor:
         [UIColor colorWithPatternImage:
          [UIImage imageWithContentsOfFile:
           [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:
            @"chest.png"]]]];	
        _launcherView.columnCount = 4;
        _launcherView.rowCount = 5;
    }
    iLauncherLastRotatePage = [_launcherView currentPageIndex];
}*/



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beginUpdates {
    [super beginUpdates];
    [_tableView beginUpdates];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endUpdates {
    [super endUpdates];
    [_tableView endUpdates];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canShowModel {
    if ([_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        NSInteger numberOfSections = [_dataSource numberOfSectionsInTableView:_tableView];
        if (!numberOfSections) {
            return NO;
            
        } else if (numberOfSections == 1) {
            NSInteger numberOfRows = [_dataSource tableView:_tableView numberOfRowsInSection:0];
            return numberOfRows > 0;
            
        } else {
            return YES;
        }
        
    } else {
        NSInteger numberOfRows = [_dataSource tableView:_tableView numberOfRowsInSection:0];
        return numberOfRows > 0;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [super didLoadModel:firstTime];
    [_dataSource tableViewDidLoadModel:_tableView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didShowModel:(BOOL)firstTime {
    [super didShowModel:firstTime];
    if (![self isViewAppearing] && firstTime) {
        [_tableView flashScrollIndicators];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showModel:(BOOL)show {
    //[self hideMenu:YES];
    if (show) {
        [self updateTableDelegate];
        _tableView.dataSource = _dataSource;
        
    } else {
        _tableView.dataSource = nil;
    }
    [_tableView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
    if (show) {
        if (!self.model.isLoaded || ![self canShowModel]) {
            /*
            NSString* title = _dataSource
            ? [_dataSource titleForLoading:NO]
            : [self defaultTitleForLoading];
            if (title.length) {
                TTActivityLabel* label =
                [[[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleWhiteBox]
                 autorelease];
                label.text = title;
                label.backgroundColor = _tableView.backgroundColor;
                self.loadingView = label;
            }*/
        }
        
    } else {
        self.loadingView = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
    if (show) {
        if (!self.model.isLoaded || ![self canShowModel]) {
            NSString* title = [_dataSource titleForError:_modelError];
            NSString* subtitle = [_dataSource subtitleForError:_modelError];
            UIImage* image = [_dataSource imageForError:_modelError];
            if (title.length || subtitle.length || image) {
                TTErrorView* errorView = [[[TTErrorView alloc] initWithTitle:title
                                                                    subtitle:subtitle
                                                                       image:image] autorelease];
                errorView.backgroundColor = _tableView.backgroundColor;
                self.errorView = errorView;
                
            } else {
                self.errorView = nil;
            }
            _tableView.dataSource = nil;
            [_tableView reloadData];
        }
        
    } else {
        self.errorView = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
    if (show) {
        NSString* title = [_dataSource titleForEmpty];
        NSString* subtitle = [_dataSource subtitleForEmpty];
        UIImage* image = [_dataSource imageForEmpty];
        if (title.length || subtitle.length || image) {
            TTErrorView* errorView = [[[TTErrorView alloc] initWithTitle:title
                                                                subtitle:subtitle
                                                                   image:image] autorelease];
            errorView.backgroundColor = _tableView.backgroundColor;
            self.emptyView = errorView;
            
        } else {
            self.emptyView = nil;
        }
        _tableView.dataSource = nil;
        [_tableView reloadData];
        
    } else {
        self.emptyView = nil;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    if (model == _model) {
        if (_flags.isShowingModel) {
            if ([_dataSource respondsToSelector:@selector(tableView:willUpdateObject:atIndexPath:)]) {
                NSIndexPath* newIndexPath = [_dataSource tableView:_tableView willUpdateObject:object
                                                       atIndexPath:indexPath];
                if (newIndexPath) {
                    if (newIndexPath.length == 1) {
                        TTDCONDITIONLOG(TTDFLAG_TABLEVIEWMODIFICATIONS,
                                        @"UPDATING SECTION AT %@", newIndexPath);
                        NSInteger sectionIndex = [newIndexPath indexAtPosition:0];
                        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationTop];
                        
                    } else if (newIndexPath.length == 2) {
                        TTDCONDITIONLOG(TTDFLAG_TABLEVIEWMODIFICATIONS, @"UPDATING ROW AT %@", newIndexPath);
                        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation:UITableViewRowAnimationTop];
                    }
                    [self invalidateView];
                    
                } else {
                    [_tableView reloadData];
                }
            }
            
        } else {
            [self refresh];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    if (model == _model) {
        if (_flags.isShowingModel) {
            if ([_dataSource respondsToSelector:@selector(tableView:willInsertObject:atIndexPath:)]) {
                NSIndexPath* newIndexPath = [_dataSource tableView:_tableView willInsertObject:object
                                                       atIndexPath:indexPath];
                if (newIndexPath) {
                    if (newIndexPath.length == 1) {
                        TTDCONDITIONLOG(TTDFLAG_TABLEVIEWMODIFICATIONS,
                                        @"INSERTING SECTION AT %@", newIndexPath);
                        NSInteger sectionIndex = [newIndexPath indexAtPosition:0];
                        [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationTop];
                        
                    } else if (newIndexPath.length == 2) {
                        TTDCONDITIONLOG(TTDFLAG_TABLEVIEWMODIFICATIONS, @"INSERTING ROW AT %@", newIndexPath);
                        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation:UITableViewRowAnimationTop];
                        
                        [_tableView scrollToRowAtIndexPath:newIndexPath
                                          atScrollPosition:UITableViewScrollPositionNone animated:NO];
                    }
                    [self invalidateView];
                    
                } else {
                    [_tableView reloadData];
                }
            }
            
        } else {
            [self refresh];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    if (model == _model) {
        if (_flags.isShowingModel) {
            if ([_dataSource respondsToSelector:@selector(tableView:willRemoveObject:atIndexPath:)]) {
                NSIndexPath* newIndexPath = [_dataSource tableView:_tableView willRemoveObject:object
                                                       atIndexPath:indexPath];
                if (newIndexPath) {
                    if (newIndexPath.length == 1) {
                        TTDCONDITIONLOG(TTDFLAG_TABLEVIEWMODIFICATIONS,
                                        @"DELETING SECTION AT %@", newIndexPath);
                        NSInteger sectionIndex = [newIndexPath indexAtPosition:0];
                        [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                  withRowAnimation:UITableViewRowAnimationLeft];
                        
                    } else if (newIndexPath.length == 2) {
                        TTDCONDITIONLOG(TTDFLAG_TABLEVIEWMODIFICATIONS, @"DELETING ROW AT %@", newIndexPath);
                        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    [self invalidateView];
                    
                } else {
                    [_tableView reloadData];
                }
            }
            
        } else {
            [self refresh];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView*)tableView {
    if (nil == _tableView) {
        _tableView = [[TTTableView alloc] initWithFrame:self.view.bounds style:_tableViewStyle];
        _tableView.autoresizingMask =  UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
        
        UIColor* backgroundColor = _tableViewStyle == UITableViewStyleGrouped
        ? TTSTYLEVAR(tableGroupedBackgroundColor)
        : TTSTYLEVAR(tablePlainBackgroundColor);
        if (backgroundColor) {
            _tableView.backgroundColor = backgroundColor;
            self.view.backgroundColor = backgroundColor;
        }
        [self.view addSubview:_tableView];
        
    }
    return _tableView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTableView:(UITableView*)tableView {
    if (tableView != _tableView) {
        [_tableView release];
        _tableView = [tableView retain];
        if (!_tableView) {
            self.tableBannerView = nil;
            self.tableOverlayView = nil;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTableBannerView:(UIView*)tableBannerView {
    [self setTableBannerView:tableBannerView animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTableBannerView:(UIView*)tableBannerView animated:(BOOL)animated {
    TT_INVALIDATE_TIMER(_bannerTimer);
    if (tableBannerView != _tableBannerView) {
        if (_tableBannerView) {
            if (animated) {
                [self fadeOutView:_tableBannerView];
                
            } else {
                [_tableBannerView removeFromSuperview];
            }
        }
        
        [_tableBannerView release];
        _tableBannerView = [tableBannerView retain];
        
        if (_tableBannerView) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, TTSTYLEVAR(tableBannerViewHeight), 0);
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
            _tableBannerView.frame = [self rectForBannerView];
            _tableBannerView.userInteractionEnabled = NO;
            _tableBannerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                                 | UIViewAutoresizingFlexibleTopMargin);
            [self addSubviewOverTableView:_tableBannerView];
            
            
            if (animated) {
                _tableBannerView.top += TTSTYLEVAR(tableBannerViewHeight);
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:TT_TRANSITION_DURATION];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                _tableBannerView.top -= TTSTYLEVAR(tableBannerViewHeight);
                [UIView commitAnimations];
            }
            
        } else {
            self.tableView.contentInset = UIEdgeInsetsZero;
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTableOverlayView:(UIView*)tableOverlayView animated:(BOOL)animated {
    if (tableOverlayView != _tableOverlayView) {
        if (_tableOverlayView) {
            if (animated) {
                [self fadeOutView:_tableOverlayView];
                
            } else {
                [_tableOverlayView removeFromSuperview];
            }
        }
        
        [_tableOverlayView release];
        _tableOverlayView = [tableOverlayView retain];
        
        if (_tableOverlayView) {
            _tableOverlayView.frame = [self rectForOverlayView];
            [self addToOverlayView:_tableOverlayView];
        }
        
        // XXXjoe There seem to be cases where this gets left disable - must investigate
        //_tableView.scrollEnabled = !_tableOverlayView;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<TTTableViewDataSource>)dataSource {
    if (dataSource != _dataSource) {
        [_dataSource release];
        _dataSource = [dataSource retain];
        _tableView.dataSource = nil;
        
        self.model = dataSource.model;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setVariableHeightRows:(BOOL)variableHeightRows {
    if (variableHeightRows != _variableHeightRows) {
        _variableHeightRows = variableHeightRows;
        
        // Force the delegate to be re-created so that it supports the right kind of row measurement
        _tableView.delegate = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLoadingView:(UIView*)view {
    if (view != _loadingView) {
        if (_loadingView) {
            [_loadingView removeFromSuperview];
            TT_RELEASE_SAFELY(_loadingView);
        }
        _loadingView = [view retain];
        if (_loadingView) {
            [self addToOverlayView:_loadingView];
            
        } else {
            [self resetOverlayView];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setErrorView:(UIView*)view {
    if (view != _errorView) {
        if (_errorView) {
            [_errorView removeFromSuperview];
            TT_RELEASE_SAFELY(_errorView);
        }
        _errorView = [view retain];
        
        if (_errorView) {
            [self addToOverlayView:_errorView];
            
        } else {
            [self resetOverlayView];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEmptyView:(UIView*)view {
    if (view != _emptyView) {
        if (_emptyView) {
            [_emptyView removeFromSuperview];
            TT_RELEASE_SAFELY(_emptyView);
        }
        _emptyView = [view retain];
        if (_emptyView) {
            [self addToOverlayView:_emptyView];
            
        } else {
            [self resetOverlayView];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
    if (_variableHeightRows) {
        return [[[TTTableViewVarHeightDelegate alloc] initWithController:(TTTableViewController *)self] autorelease];
        
    } else {
        return [[[TTTableViewDelegate alloc] initWithController:(TTTableViewController *)self] autorelease];
    }
}
/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}*/
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showMenu:(UIView*)view forCell:(UITableViewCell*)cell animated:(BOOL)animated {
    [self hideMenu:YES];
    
   
    _menuView = [view retain];
    _menuCell = [cell retain];
    
    // Insert the cell below all content subviews
    [_menuCell.contentView insertSubview:_menuView atIndex:0];
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    }
    
    // Move each content subview down, revealing the menu
    for (UIView* subview in _menuCell.contentView.subviews) {
        if (subview != _menuView) {
            subview.left -= _menuCell.contentView.width;
        }
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideMenu:(BOOL)animated {
    if (_menuView) {
        if (animated) {
            [UIView beginAnimations:nil context:_menuView];
            [UIView setAnimationDuration:TT_FAST_TRANSITION_DURATION];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(hideMenuAnimationDidStop:finished:context:)];
        }
        
        for (UIView* view in _menuCell.contentView.subviews) {
            if (view != _menuView) {
                view.left += _menuCell.contentView.width;
            }
        }
        
        if (animated) {
            [UIView commitAnimations];
            
        } else {
            [_menuView removeFromSuperview];
        }
        
        TT_RELEASE_SAFELY(_menuView);
        TT_RELEASE_SAFELY(_menuCell);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
    if ([object respondsToSelector:@selector(URLValue)]) {
        NSString* URL = [object URLValue];
        if (URL) {
            TTOpenURLFromView(URL, self.view);
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldOpenURL:(NSString*)URL {
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didBeginDragging {
    //[self hideMenu:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didEndDragging {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForOverlayView {
    return [_tableView frameWithKeyboardSubtracted:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForBannerView {
    CGRect tableFrame = [_tableView frameWithKeyboardSubtracted:0];
    const CGFloat bannerViewHeight = TTSTYLEVAR(tableBannerViewHeight);
    return CGRectMake(tableFrame.origin.x,
                      (tableFrame.origin.y + tableFrame.size.height) - bannerViewHeight,
                      tableFrame.size.width, bannerViewHeight);
}

#pragma mark -
#pragma mark CustomSegmentedControlDelegate
- (UIButton*) buttonFor:(CustomSegmentedControl*)segmentedControl atIndex:(NSUInteger)segmentIndex;
{
    CapLocation location;
    if (segmentIndex == 0)
        location = CapLeft;
    else if (segmentIndex == segmentControlTitles.count - 1)
        location = CapRight;
    else
        location = CapMiddle;
    
    UIButton* button = [self woodButtonWithText:[segmentControlTitles objectAtIndex:segmentIndex] stretch:location];
    if (segmentIndex == 0)
        button.selected = YES;
    return button;
}

- (void) touchDownAtSegmentIndex:(NSUInteger)segmentIndex
{
    /*[[[[UIAlertView alloc] initWithTitle:[segmentControlTitles objectAtIndex:segmentIndex]
     message:nil
     delegate:nil
     cancelButtonTitle:nil 
     otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease] show];*/
}


-(UIBarButtonItem*)woodBarButtonItemWithText:(NSString*)buttonText
{
    return [[[UIBarButtonItem alloc] initWithCustomView:[self woodButtonWithText:buttonText stretch:CapLeftAndRight]] autorelease];
}

-(UIImage*)image:(UIImage*)image withCap:(CapLocation)location capWidth:(NSUInteger)capWidth buttonWidth:(NSUInteger)buttonWidth
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(buttonWidth, image.size.height), NO, 0.0);
    
    if (location == CapLeft)
        // To draw the left cap and not the right, we start at 0, and increase the width of the image by the cap width to push the right cap out of view
        [image drawInRect:CGRectMake(0, 0, buttonWidth + capWidth, image.size.height)];
    else if (location == CapRight)
        // To draw the right cap and not the left, we start at negative the cap width and increase the width of the image by the cap width to push the left cap out of view
        [image drawInRect:CGRectMake(0.0-capWidth, 0, buttonWidth + capWidth, image.size.height)];
    else if (location == CapMiddle)
        // To draw neither cap, we start at negative the cap width and increase the width of the image by both cap widths to push out both caps out of view
        [image drawInRect:CGRectMake(0.0-capWidth, 0, buttonWidth + (capWidth * 2), image.size.height)];
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

-(UIButton*)woodButtonWithText:(NSString*)buttonText stretch:(CapLocation)location
{
    UIImage* buttonImage = nil;
    UIImage* buttonPressedImage = nil;
    NSUInteger buttonWidth = 0;
    if (location == CapLeftAndRight)
    {
        buttonWidth = BUTTON_WIDTH;
        buttonImage = [[UIImage imageNamed:@"nav_button_rect_new.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0];
        buttonPressedImage = [[UIImage imageNamed:@"nav_button_rect_active.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0];
    }
    else
    {
        buttonWidth = BUTTON_SEGMENT_WIDTH;
        
        buttonImage = [self image:[[UIImage imageNamed:@"nav_button_rect_new.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0] withCap:location capWidth:CAP_WIDTH buttonWidth:buttonWidth];
        buttonPressedImage = [self image:[[UIImage imageNamed:@"nav_button_rect_active.png"] stretchableImageWithLeftCapWidth:CAP_WIDTH topCapHeight:0.0] withCap:location capWidth:CAP_WIDTH buttonWidth:buttonWidth];
        
    }
    
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonWidth, buttonImage.size.height);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    
    [button setTitle:buttonText forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    button.adjustsImageWhenHighlighted = NO;
    
    return button;
}


/*- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"search text is %@",searchBar.text);
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}*/
@end
