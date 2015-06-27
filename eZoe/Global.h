//
//  Global.h
//  eZoe
//
//  Created by John Liu on 2011/5/7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
//  This is marked from Mac Mini
#define IS_IOS_8 (fabs( ( double )[[[UIDevice currentDevice] systemVersion] intValue]) >= 8.0)
#define IS_IOS_7 (fabs( ( double )[[[UIDevice currentDevice] systemVersion] intValue]) >= 7.0)
#define IS_IOS_ONLY_7 (fabs( ( double )[[[UIDevice currentDevice] systemVersion] intValue]) < 8.0)
#define IS_IOS_6 (fabs( ( double )[[[UIDevice currentDevice] systemVersion] intValue]) < 7.0)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define kSiteHttpRoot @"so.twgbr.org"
#define kProductPrefix @"tw.org.twgbr.BasicSubs."

#import <Foundation/Foundation.h>
@interface UIScreen(ZBScreenRetinaAdditions)

// Returns YES if this is a Retina display.
- (BOOL)zb_isRetina;

@end

@implementation UIScreen(ZBScreenRetinaAdditions)

- (BOOL)zb_isRetina {
    return [self respondsToSelector:@selector(displayLinkWithTarget:selector:)] && (self.scale == 2.0);
}

@end

//setting
@interface NSString (getDocPathWithPList)
-(NSString *) getDocPathWithPList;
@end

//setting
@interface NSString (getUserDocPathWithPList)
-(NSString *) getUserDocPathWithPList;
@end

@interface NSString (filterStringBeforeSpeech)
-(NSString *) filterStringBeforeSpeech;
@end

