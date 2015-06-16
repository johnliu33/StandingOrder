//
//  EVNavigationButton.h
//  Bible
//
//  Created by Yung-Luen Lan on 8/5/09.
//  Copyright 2009 yllan.org. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    EVNavigationButtonTypeNormal = 0, 
    EVNavigationButtonTypeBack
} EVNavigationButtonType;

@interface EVNavigationButton : UIButton {
    BOOL landscape;
    EVNavigationButtonType type;
}
@property BOOL landscape;
@property EVNavigationButtonType type;
@end
