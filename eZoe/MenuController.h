#import <Three20/Three20.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "MBProgressHUD.h"

typedef enum {
    MenuPageNone,
    MenuPageBreakfast,
    MenuPageLunch,
    MenuPageDinner,
    MenuPageDessert,
    MenuPageAbout,
    MenuPageRestore,
} MenuPage;
@class ASINetworkQueue;
@interface MenuController : TTTableViewController <UIWebViewDelegate,MBProgressHUDDelegate>{
    MenuPage _page;
    UIWebView	*webView;
    MBProgressHUD *HUD;
    
    NSArray *_key;
    
    
    NSString          *_booktype;
    BOOL failed;
    ASINetworkQueue *networkQueue;
    BOOL hasPackageFiles;
    NSMutableArray *packageList;
}

@property(nonatomic) MenuPage page;
@property (nonatomic, assign) UIWebView *webView;;

@property(nonatomic, retain) NSString *_booktype;
@property(nonatomic, retain) NSArray *_key;
@property(nonatomic, assign) BOOL hasPackageFiles;
@property(nonatomic, assign) NSMutableArray *packageList;

- (void)myTask:(NSNumber*)tag;
- (void)changeToBookShelf;

@end
