//
//  YLUIKitAddition.h
//  Bible
//
//  Created by yllan on 6/2/09.
//  Copyright 2009 hypo.cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "eZoeAppDelegate.h"
#define ARRAY(...) ([NSArray arrayWithObjects: __VA_ARGS__])

@interface UIButton (YLUIKitAddition)
- (void) setTitleForAllState: (NSString *)title;
- (void) setBackgroundImageforAllState: (UIImage *)image;
@end

@interface NSMutableArray (QueueLikeOperation)
- (id) popFirstObject;
- (void) addObjectToFront: (id)object;
- (void) insertObjects: (NSArray *)objects atIndex: (NSUInteger)index;
- (void) addObjectsFromArrayToFront: (NSArray *)objects;
@end

@interface NSString (SimplifiedChinese)
- (NSString *) simplifiedChineseString;
- (NSString *) traditionalChineseString;
@end


//@interface UIViewController (EVCustomTheme)
//- (UIBarButtonItem *) themedBackButtonItemWithTitle: (NSString *)title;
//- (void) pushToNavigationControllerWithViewController: (UIViewController *)controller animated: (BOOL)animated;
//- (void) popupFromNavigationController;
//@end
