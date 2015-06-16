//
//  BookListTitleView.m
//  TAAZEREADER
//
//  Created by gdx on 1/14/14.
//
//

#import "BookListTitleView.h"

@implementation BookListTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [_titleLabel release];
    
    [super dealloc];
}

@end
