#import <Three20/Three20.h>
#import "Global.h"
#import "DBHelper.h"
#import "DBHelperEngDict.h"
//#import <FacebookSDK/FacebookSDK.h>
//#import <GooglePlus/GooglePlus.h>
//#import <GoogleOpenSource/GoogleOpenSource.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "BookListViewController.h"

#import "GAI.h"

/******* Set your tracking ID here *******/
static NSString *const kTrackingId = @"UA-66094417-1";
static NSString *const kAllowTracking = @"allowTracking";

typedef enum {
    None,
    Facebook,
    Google,
    Tencent,
    Sinaweibo
} WaitingSocialLoginType;

@interface eZoeAppDelegate : UIResponder <UIApplicationDelegate>
{
    //setting
    NSMutableDictionary *setting;
    NSMutableArray  *bookList;
    NSMutableArray  *pageList;
    //NSMutableArray  *bookInstalledList;

    //history
    NSString *sBookLastOpened;
    NSString *sIdForRef; //for rotate calibration
    NSInteger iBookLastPagePercent;
    NSInteger iBookLastShowingPageIdx;
    NSInteger iBookLastLang; //0 tradition 1 simplify
    NSInteger iFontLastSize;
    NSInteger iFontLastType;
    NSInteger iBGLastType;
    NSInteger iVoiceLastType;
    NSInteger iVoiceLastSpeed;

    
    NSInteger iLastLoginStatus; //0 logout 1 login
    
    
    //NSInteger _pageCountPortrait;
    //NSInteger _pageCountLandscape;
    NSInteger _bookpageCount;
    NSInteger _bookprepareTotal;

    //version
    NSString *numVersion;
    
    //search
    NSMutableDictionary *searchPageDictionary;
    NSIndexPath  *selectedCharacter;
    
    //Global Database Access Helper
    DBHelper *dbHelper;
    DBHelperEngDict *dbHelperEngDict;
    
    //Current Book Index
    NSMutableArray *arrayIndexPagenum;
    NSMutableArray *arrayIndexText;
    
    //Account Information
    NSString *tazzecuid;
    
    //Book download
    NSString *dbookid;
   
    NSMutableDictionary *productBooks;

    //Book restore
    
    NSMutableDictionary *restoredBooks;
    
    //PDF reader
    NSInteger displaypageMode;  //0:portrait //1:landscape
    NSInteger pdfRectageMode; //0:fillby PDF page width //1:fillby PDF page height
    NSInteger bookDirectionMode;  //0:left to right  1:right to left
    
    //Log filter
    NSString *sLastAction;
    NSString *sLastPid;
    
    //table book view of BookShelf
    NSMutableDictionary *curtableNumberDict;
    //table book view of Download list
    NSMutableDictionary *downtableNumberDict;
    
    
    //test
    UIWindow *mainWindow; // Main App Window
    
	UINavigationController *navigationController;
    
    BookListViewController *booklistViewController;
    //test
	
}
@property (nonatomic, retain)NSMutableDictionary *setting;
@property (nonatomic, retain)NSMutableArray  *bookList;
//@property (nonatomic, retain)NSMutableArray  *bookInstalledList;

@property (nonatomic, retain)NSMutableArray  *pageList;
@property (nonatomic, retain)NSString *sBookLastOpened;
@property (nonatomic, retain)NSString *tazzecuid;
@property (nonatomic, retain)NSString *sIdForRef;
@property (nonatomic, assign)NSInteger iBookLastPagePercent;
@property (nonatomic, assign)NSInteger iBookLastShowingPageIdx;
@property (nonatomic, assign)NSInteger iBookLastLang;
@property (nonatomic, assign)NSInteger iFontLastSize;
@property (nonatomic, assign)NSInteger iFontLastType;
@property (nonatomic, assign)NSInteger iBGLastType;
@property (nonatomic, assign)NSInteger iVoiceLastType;
@property (nonatomic, assign)NSInteger iVoiceLastSpeed;


@property (nonatomic, assign)NSInteger iLastLoginStatus;

@property (nonatomic, retain)NSString *numVersion;
@property (nonatomic, retain)NSMutableDictionary *searchPageDictionary;
@property (nonatomic, retain) DBHelper *dbHelper;
@property (nonatomic, retain) DBHelperEngDict *dbHelperEngDict;
//@property NSInteger _pageCountPortrait;
//@property NSInteger _pageCountLandscape;
@property NSInteger _bookpageCount;
@property NSInteger _bookprepareTotal;

@property (nonatomic, retain)NSMutableArray  *arrayIndexPagenum;
@property (nonatomic, retain)NSMutableArray  *arrayIndexText;

@property(nonatomic, retain) NSIndexPath *selectedCharacter;
@property (nonatomic, retain)NSString *dbookid;

@property (nonatomic, retain)NSMutableDictionary *productBooks;
@property (nonatomic, retain)NSMutableDictionary *restoredBooks;

//PDF reader
@property (nonatomic, assign)NSInteger displaypageMode;
@property (nonatomic, assign)NSInteger pdfRectageMode;
@property (nonatomic, assign)NSInteger bookDirectionMode;

//Social Network
//@property (nonatomic) WaitingSocialLoginType waitingType;
//@property (strong,nonatomic) FBSession *fbSession;

@property (nonatomic, retain)NSMutableDictionary *curtableNumberDict;
@property (nonatomic, retain)NSMutableDictionary *downtableNumberDict;

@property(nonatomic, strong) id<GAITracker> tracker;

- (void)moveFileFromDoc:(NSString *)fileName;
- (void)backupFromOldVersion;
- (void)initSetting;
- (void)initBookList;
- (void)initIndexArray;
//- (void)LogSendBack;
//- (void)LogSavePlist:(NSString *)action_name pid:(NSString *)pid format:(NSString *)format;

@end
