#define kMinimumPinchDelta 50
#define kMinimumGestureLength	25
#define kMaximumVariance		10

#import <Three20/Three20.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Global.h"
//#import "Three20UI/TTModelViewController.h"
#import "TTLauncherViewController.h"
#import "Three20UICommon/Three20UICommon+Additions.h"
#import "ParseHtml.h"
//#import "ELCSlider.h"
#import "TransparentToolbar.h"
#import "YLUIKitAddition.h"
#import "eZoeAppDelegate.h"
//for popover test
#import "SetMainViewController.h"
#import "SetDetailViewController.h"
//#import "DataMainViewController.h"
#import "DataDetailViewController.h"
#import "SearchTableViewController.h"
#import "SearchDetailViewController.h"

#import "MyUIWebView.h"
#import "WEPopoverController.h"
#import "TSAlertView.h"
//Javascript Queue Library
#import "TGJSBridge.h"

//Audio library
#import "CReader.h"
#import "StreamPlayer.h"
#import "AQPlayer.h"

//for scroll index
//#import "IndexViewController.h"

//Self ToolBar
#import <MessageUI/MessageUI.h>
#import "MyReaderMainToolbar.h"
#import "MyWebViewReaderPagebar.h"

//Popover
#import "FPPopoverController.h"
#import "ARCMacros.h"

#import "FPPopoverKeyboardResponsiveController.h"

//HUD
#import "MBProgressHUD.h"

//MKStoreManager
#import "MKStoreManager.h"

@class MyWebViewController;
@class MyReaderMainToolbar;

@protocol MyWebViewControllerDelegate <NSObject>

@optional // Delegate protocols
//@required

- (void)dismissMyWebViewController:(MyWebViewController *)viewController;

@end

@interface UIBarButtonItem(MyCategory)

+ (UIBarButtonItem*)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

@end

@class KNModalTableViewController;

//UIViewController  //TTWebController
@interface MyWebViewController : TTWebController <MBProgressHUDDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,UIScrollViewDelegate,MyReaderMainToolbarDelegate,MyWebViewControllerDelegate,MyWebViewReaderPagebarDelegate,SetDetailViewControllerDelegate,DataDetailViewControllerDelegate,SearchDetailViewControllerDelegate,TSAlertViewDelegate,TGJSBridgeDelegate,CReaderDelegate, StreamPlayerDelegate,FPPopoverControllerDelegate> //SearchTableViewControllerDelegate,
{
    //Tool bar
    MyReaderMainToolbar *mainToolbar;
    MyWebViewReaderPagebar *mainPagebar;
    
    //Scroll controll
    CGRect screenBounds;
    
    NSString *documentsBookPath;
	NSString *bundleBookPath;
    
    NSMutableArray *pagesNumberForShowInTheBottom;
	NSString *pageNameFromURL;
	NSString *anchorFromURL;
    
    UIScrollView *scrollView;
    NSMutableArray *pageSpinners;
    
    MyUIWebView *prevPage;
	MyUIWebView *currPage;
	MyUIWebView *nextPage;
    //MyUIWebView *nextPage1;
    
    CGRect leftTapArea;
	CGRect rightTapArea;
    
    int totalPages;
    int lastPageNumber;
	int currentPageNumber;
	
    int pageWidth;
	int pageHeight;
    int currentPageHeight;
	
    int tapNumber;
    int stackedScrollingAnimations;
    
	BOOL currentPageFirstLoading;
	BOOL currentPageIsDelayingLoading;
	BOOL discardNextStatusBarToggle;
    
    UIColor *_bColor;
    UIColor *_spinnerColor;
    
    CGFloat delayLoadingTime;
    
    //IndexViewController *indexViewController;
    
	//Gesture controll and touch
	CGFloat		initialDistance;
	CGPoint		gestureStartPoint;
	BOOL		swiped;
    UISwipeGestureRecognizer *swipeRight;
    UISwipeGestureRecognizer *swipeLeft;
    UITapGestureRecognizer *recognizer;

    UIView *viewTouch;
    NSInteger iTouchTopBound;
    NSInteger iTouchBottomBound;
    NSInteger iTouchLeftBound;
    NSInteger iTouchRightBound;
	
	//WebView and content
    UIImageView *backImageView;
	//UIWebView	*webView1;
	//UIWebView   *webView2;
	NSURL	*pdfUrl;
	NSString *saveDirectory;
	NSString *finalPath;
	NSString *saveFileName;
	
	NSString *sMark;
    //book change
    NSString *sBookName;
    NSInteger _iFontSize; 
    NSInteger _iFontType;//0 for STKaiti 1 for Default
    NSInteger _iBGType;//background type:0~4
    NSInteger _iVoiceType;
    NSInteger _iVoiceSpeed;
    

    
    
    //tradition chinese to simplified chinese
    BOOL bTransSimpChin;
    
    //voice speech ON/OFF
    BOOL bVoicePlaying;
	
	//html file parsing
	NSMutableArray *arrayForStoreTheContentPage;
    NSArray *arrayForStoreThePrefacePage;

	ParseHtml *parseHtml;
    
    CGRect	rectFrame;
	
	//Page control
	NSInteger iPage;
    NSInteger _iContentPageCount;
    NSInteger _iPrefacePageCount;
    NSInteger _iIndexPageCount;
    NSInteger _iCoverPageCount;
    NSInteger _iPrepageTotal;  //封面+序言+目錄
    
    NSInteger iShowingPageIdx;
	BOOL bFinalPage;
    NSInteger iFlipDir; //0:default 1:left 2:right
    BOOL bJumped;
    BOOL bTransed;
    //Mark the text
    BOOL bMarked;
    
    //slider
    ELCSlider*        _slider;
    NSInteger   iSliderInitPosition;
    
    //rotation
    BOOL bRotate;
    
    
    //javascript and page links
    NSString *myurl;
    
  
    
    //UI
    UIBarButtonItem *audioControlButton;
    UIBarButtonItem *traButton;
    NSMutableArray* buttons;
    TransparentToolbar* toolbar;
    
    UIPopoverController* popController;
    
    //bookmark
    NSMutableArray *_bookMarkedPages;
    NSString *_lastPercent;
    
    //search
    SearchTableViewController *searchViewController;
    NSString *_menusearchText;
    
    //Mark the text
    NSMutableDictionary *_markedTextInfo;
    
    //semi model view for verse searching
    //KNModalTableViewController * modalVC;
    
    //Audio
    BOOL bVoicePurchased;
    CReader*         mCReader;
    BOOL            bPaused;

	
#ifdef SAVE_WAVE_TO_FILE    
    NSMutableData*  mSaveData;
#endif
    
    StreamPlayer*   mPlayer;
    BOOL          mIsPlaying;	
	AQPlayer*		mAQPlayer;
    
    NSInteger   audioPlayMode;
    
    //Popover
    FPPopoverKeyboardResponsiveController *popover;
    CGFloat _keyboardHeight;
    
    MBProgressHUD *HUD;


    
}
//scroll controll
@property (nonatomic, retain) NSMutableArray *arrayForStoreTheContentPage;
@property (nonatomic, retain) NSString *bundleBookPath;

@property (nonatomic, retain) NSMutableArray *pagesNumberForShowInTheBottom;
@property (nonatomic, retain) NSString *pageNameFromURL;
@property (nonatomic, retain) NSString *anchorFromURL;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSMutableArray *pageSpinners;

@property (nonatomic, retain) MyUIWebView *currPage;
@property (nonatomic, retain) MyUIWebView *prevPage;
@property (nonatomic, retain) MyUIWebView *nextPage;

@property (nonatomic, retain) NSString *_menusearchText;


@property int tapNumber;
@property int lastPageNumber;
@property int currentPageNumber;
//----------------

@property (nonatomic, retain) UIImageView *backImageView;
@property (nonatomic, retain) NSString  *sBookName;
@property (nonatomic, assign) NSInteger _iFontSize;
@property (nonatomic, assign) NSInteger _iFontType; 
@property (nonatomic, assign) NSInteger _iBGType;
@property (nonatomic, assign) NSInteger _iVoiceType;
@property (nonatomic, assign) NSInteger _iVoiceSpeed;
@property (nonatomic, retain) ParseHtml *parseHtml;

//Book Mark
@property (nonatomic, retain) NSMutableArray *_bookMarkedPages;

//Mark the Text
@property (nonatomic, retain) NSMutableDictionary *_markedTextInfo;

//JSBridge
//@property (retain, nonatomic) UIButton *btn; //for test the js result
@property (retain, nonatomic) TGJSBridge *jsBridge;

//Scroll controll

// ****** INIT
- (id)initWithBookName:(NSString *)sbookName;
- (void)setupWebView:(MyUIWebView *)webView;
- (void)checkPageSize;
- (void)setPageSize:(NSString *)orientation;
//- (void)initBook:(NSString *)path;
- (void)userDidScroll:(id)ignored;

- (void)initBook1;//by johnliu 20110613
// ****** LOADING
//- (NSDictionary*)loadManifest:(NSString*)file;
- (BOOL)changePage:(int)page;
- (void)gotoPageDelayer;
- (void)gotoPage;
- (void)initPageNumbersForPages:(int)count;
- (void)loadSlot:(int)slot withPage:(int)page;
- (BOOL)loadWebView:(MyUIWebView*)webview withPage:(int)page;

// ****** SCROLLVIEW
- (CGRect)frameForPage:(int)page;
- (void)spinnerForPage:(int)page isAnimating:(BOOL)isAnimating;
- (void)resetScrollView;

// ****** WEBVIEW
- (void)webView:(MyUIWebView *)webView hidden:(BOOL)status animating:(BOOL)animating;
- (void)revealWebView:(MyUIWebView *)webView;

// ****** PAGE SCROLLING
- (void)getPageHeight;
//- (void)goUpInPage:(NSString *)offset animating:(BOOL)animating;
//- (void)goDownInPage:(NSString *)offset animating:(BOOL)animating;
//- (void)scrollPage:(UIWebView *)webView to:(NSString *)offset animating:(BOOL)animating;
//- (void)handleAnchor:(BOOL)animating;

// ****** STATUS BAR
- (void)toggleStatusBar;
- (void)hideStatusBar;
- (void)hideStatusBarDiscardingToggle:(BOOL)discardToggle;
- (void)showStatusBar;
//---------------

//-(void)nextButtonPressed:(id)sender;
//-(void)previousButtonPressed:(id)sender;
-(void)changeBook:(NSString *)sBookNum type:(NSInteger)orientation fontSize:(NSInteger)fontSize BGType:(NSInteger)bgType fontType:(NSInteger)fontType; // BGType:0~4 font type 0:Kaiti 1:times
//-(void)loadPage;
//-(void)jumpPage:(UIWebView*)oldView;
//-(void)loadNextPage;
//-(void)loadPreviousPage;
- (BOOL)isShowingChrome;

//-(void)showOtherView:(UIWebView*)oldView type:(NSInteger)iDirRightOrLeft;
//-(void)showOtherViewJump:(UIWebView*)oldView type:(NSInteger)iDirRightOrLeft;
-(NSString*) produceImageReference:(NSString*) imgFileName withType:(NSString*) imgType;
// Tool bar
-(void)toggleBookMark;
-(void)audioSpeech;
-(void)transChi;
//-(void)uiControlPopover;
//-(void)dataControlPopover;
-(void)searchPopover;
-(void)searchTheBook:(NSInteger)iFromToolBar; //0:from toolbar
-(void)setBookLastPage;
// Book mark
-(void)initBookMark;
-(BOOL)checkBookMarked:(NSInteger)page;
-(void)saveBookMarked:(NSInteger)page AddOrDelete:(BOOL)addNew;

// Mark Text && Note Text
//If mark: type = 0 noteText = @"", If note: type = 1 noteText = @"What you type"
- (void)TargetTheText:(NSInteger)type noteText:(NSString *)noteText;
- (void)initMarkText;
//- (void)initNoteText;
- (void) myCopy: (id) sender;
- (void)saveMarkedText:(NSString*)rowId theRange:(NSRange)theRange theText:(NSString *)theText MarkOrNote:(NSString *)opt1 noteText:(NSString *)noteText noteNumber:(NSString *)noteNumber;
- (void) NoteOrMarkToDelete:(NSInteger)type noteNumber:(NSString *)noteNumber;

- (void) ShowTheNote:(NSString *)noteNumber;

-(void)delMarkedText:(NSString*)rowId theRange:(NSRange)theRange;
-(void)delNotedText:(NSString*)rowId noteNumber:(NSString *)noteNumber;


//- (NSInteger)getObjectIndex:(NSMutableArray *)array byStartOrEnd:(BOOL)bStart byName:(NSString *)theName;

//utility
-(CGFloat)convertPagePercent:(NSInteger)page pageCount:(NSInteger)count;
-(NSInteger)revertPagePercent:(CGFloat)percent pageCount:(NSInteger)count;
-(NSInteger)rangeProtection:(NSInteger)pageNumber;

//Audio
-(void)initAudio:(NSInteger)voicetype;
-(void)stopAudio;
-(void)stopPlayMode;
- (void)setAudioSession;

//Popover
//-(void)selectedTableRow:(NSUInteger)rowNum;

@end
