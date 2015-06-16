#import <Three20/Three20.h>
#import "MyLauncherView.h"
@interface LauncherViewTestController : TTViewController <TTLauncherViewDelegate> {
  //TTLauncherView* _launcherView;
    MyLauncherView* _launcherView;
    NSInteger currentPage;
}

@end
