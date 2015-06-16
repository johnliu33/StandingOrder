//
//  EVNavigationButton.m
//  Bible
//
//  Created by Yung-Luen Lan on 8/5/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import "EVNavigationButton.h"

@interface EVNavigationButton (Private)
- (void) _setAppearance;
@end

@implementation EVNavigationButton (Private)
- (void) _setAppearance
{
    // Center the text vertically and horizontally
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    UIImage *stretchImage = 
    (self.type == EVNavigationButtonTypeNormal) ?
    [[UIImage imageNamed: @"nav_button_rect.png"] stretchableImageWithLeftCapWidth: 5.0 topCapHeight: 0.0] :
    [[UIImage imageNamed: @"nav_button_back.png"] stretchableImageWithLeftCapWidth: 12.0 topCapHeight: 0.0];
    
    // Set the background to the stretchable image
    [self setBackgroundImage: stretchImage forState: UIControlStateNormal];
    
    
    // Set the font properties
    [self setTitleShadowColor: [UIColor blackColor] forState: UIControlStateNormal];
#ifdef __IPHONE_3_0
    self.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 13];
    self.titleLabel.textColor = [UIColor whiteColor];
#else
    self.titleShadowOffset = CGSizeMake(0, -1);
    self.font = [UIFont boldSystemFontOfSize: 13];
    [self setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
#endif
}
@end


@implementation EVNavigationButton
@synthesize landscape, type;

- (id) init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 36.0, 30.0);
        [self _setAppearance];
    }
    return self;
}

- (id) initWithFrame: (CGRect)frame
{
    if (self = [super initWithFrame: frame]) {
        [self _setAppearance];
    }
    return self;
}


- (id) initWithCoder: (NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder]) {
        [self _setAppearance];        
    }
    return self;
}

- (void) setType: (EVNavigationButtonType)newType
{
    type = newType;
    [self _setAppearance];
}

- (void) setLandscape: (BOOL)value
{
    CGRect frame = self.frame;
    
    if(value) {
        frame.size.height = 24;
    } else {
        frame.size.height = 30;
        frame.origin.y -= 3;
    }
    
    UIImage *stretchImage = 
    (self.type == EVNavigationButtonTypeNormal) ?
    [[UIImage imageNamed: @"nav_button_rect.png"] stretchableImageWithLeftCapWidth: 5.0 topCapHeight: 0.0] :
    [[UIImage imageNamed: @"nav_button_back.png"] stretchableImageWithLeftCapWidth: 13.0 topCapHeight: 0.0];
    
    self.frame = frame;
    [self setBackgroundImage: stretchImage forState: UIControlStateNormal];
}

- (CGRect) titleRectForContentRect: (CGRect)contentRect
{
    if (self.type == EVNavigationButtonTypeBack)
        return CGRectMake(contentRect.origin.x + 13 + 2, contentRect.origin.y, contentRect.size.width - 18, contentRect.size.height);
    return CGRectInset(contentRect, 2, 0);
}

/*
- (void) layoutSubviews
{
    [super layoutSubviews];
    if (self.type == EVNavigationButtonTypeBack) {
        CGRect frame = self.titleLabel.frame;
        frame.origin.x += 3;
        self.titleLabel.frame = frame;
    }
}
*/
@end
