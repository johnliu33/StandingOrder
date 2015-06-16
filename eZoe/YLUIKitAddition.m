//
//  YLUIKitAddition.m
//  Bible
//
//  Created by yllan on 6/2/09.
//  Copyright 2009 hypo.cc. All rights reserved.
//

#import "YLUIKitAddition.h"
//#import "EVNavigationButton.h"

@implementation UIButton (YLUIKitAddition)
- (void) setTitleForAllState: (NSString *)title
{
    [self setTitle: title forState: UIControlStateNormal];
    [self setTitle: title forState: UIControlStateHighlighted];
    [self setTitle: title forState: UIControlStateDisabled];
    [self setTitle: title forState: UIControlStateSelected];
}

- (void) setBackgroundImageforAllState: (UIImage *)image
{
    [self setBackgroundImage: image forState: UIControlStateNormal];
    [self setBackgroundImage: image forState: UIControlStateHighlighted];
    [self setBackgroundImage: image forState: UIControlStateDisabled];
    [self setBackgroundImage: image forState: UIControlStateSelected];
}
@end

@implementation NSString (SimplifiedChinese)
static NSMutableDictionary *t2sTable = nil;
static NSMutableDictionary *s2tTable = nil;
- (NSString *) simplifiedChineseString
{
	if (t2sTable == nil) {
		t2sTable = [NSMutableDictionary new];
		NSString *dictContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"T2Stable" ofType:@"dat"] encoding:NSUTF8StringEncoding error: nil];
		NSArray *arrContent = [dictContent componentsSeparatedByString:@"\n"];
		for (NSString* line in arrContent) {
			if ([line length] != 2) continue;
			NSString *tc = [line substringWithRange:NSMakeRange(0, 1)];
			NSString *sc = [line substringWithRange:NSMakeRange(1, 1)];
			[t2sTable setObject:sc forKey:tc];
		}
	}
	int length = [self length];
	NSMutableString *simplifiedString = [NSMutableString stringWithCapacity: length];
	for (int i = 0; i < length; i++) {
		NSString *org = [self substringWithRange: NSMakeRange(i, 1)];
		NSString *rep = [t2sTable objectForKey:org];
		[simplifiedString appendString: rep == nil ? org : rep];
	}
    return simplifiedString;
}
- (NSString *) traditionalChineseString
{
	if (s2tTable == nil) {
		s2tTable = [NSMutableDictionary new];
		NSString *dictContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"T2Stable" ofType:@"dat"] encoding:NSUTF8StringEncoding error: nil];
		NSArray *arrContent = [dictContent componentsSeparatedByString:@"\n"];
		for (NSString* line in arrContent) {
			if ([line length] != 2) continue;
			NSString *tc = [line substringWithRange:NSMakeRange(0, 1)];
			NSString *sc = [line substringWithRange:NSMakeRange(1, 1)];
			[s2tTable setObject:tc forKey:sc];
		}
	}
	int length = [self length];
	NSMutableString *traditionalString = [NSMutableString stringWithCapacity: length];
	for (int i = 0; i < length; i++) {
		NSString *org = [self substringWithRange: NSMakeRange(i, 1)];
		NSString *rep = [s2tTable objectForKey:org];
		[traditionalString appendString: rep == nil ? org : rep];
	}
    return traditionalString;
}
@end


@implementation NSMutableArray (QueueLikeOperation)
- (id) popFirstObject
{
    if ([self count] == 0) return nil;
    id firstObject = [[[self objectAtIndex: 0] retain] autorelease];
    [self removeObjectAtIndex: 0];
    return firstObject;
}

- (void) addObjectToFront: (id)object
{
    if (!object) return;
    [self insertObject: object atIndex: 0];
}

- (void) insertObjects: (NSArray *)objects atIndex: (NSUInteger)index
{
    if (!objects) return;
    for (id obj in [objects reverseObjectEnumerator])
        [self insertObject: obj atIndex: index];
}

- (void) addObjectsFromArrayToFront: (NSArray *)objects
{
    if (!objects) return;
    [self insertObjects: objects atIndex: 0];
}
@end

/* Hack: If you have tintColor, then using our background image. Otherwise, mocking the system default style. */
@implementation UINavigationBar (CustomImage)
- (void) drawRect: (CGRect)rect
{
    if (!self.tintColor) {
        UIImage *systemImage = [[UIImage imageNamed: @"system_navbar.png"] stretchableImageWithLeftCapWidth: 1 topCapHeight: 22];
        [systemImage drawInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        return;
    }
    
	UIImage *image = [UIImage imageNamed: @"navbar.png"];
	[image drawInRect: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
}
@end
/*
@implementation UIViewController (EVCustomTheme)

- (UIBarButtonItem *) themedBackButtonItemWithTitle: (NSString *)title
{
    CGSize size = [title sizeWithFont: [UIFont systemFontOfSize: 16]];
    
    EVNavigationButton *button = [[EVNavigationButton alloc] initWithFrame: CGRectMake(0, 9, MIN(13 + size.width + 5, 100), 30)];
    button.type = EVNavigationButtonTypeBack;
    [button setTitleForAllState: title];
    
    [button addTarget: self action: @selector(popupFromNavigationController) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView: button];
    
    [button release];
    return [backItem autorelease];
}

- (void) pushToNavigationControllerWithViewController: (UIViewController *)controller animated: (BOOL)animated
{
    if ([controller respondsToSelector: @selector(willBePushedToNavigationController:)]) 
        [controller performSelector: @selector(willBePushedToNavigationController:) withObject: self.navigationController];
    [controller view]; // force loading the view
    controller.navigationItem.leftBarButtonItem = [controller themedBackButtonItemWithTitle: self.navigationController.topViewController.title];
    [self.navigationController pushViewController: controller animated: animated];
}


- (void) popupFromNavigationController
{
    if ([self respondsToSelector: @selector(willBePoppedFromNavigationController:)]) {
        [self performSelector: @selector(willBePoppedFromNavigationController:) withObject: self.navigationController];
    }
    [self.navigationController popViewControllerAnimated: YES];
}
 
@end*/
