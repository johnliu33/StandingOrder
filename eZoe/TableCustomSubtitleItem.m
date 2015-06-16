//
//  TableCustomSubtitleItem.m
//  eZoe
//
//  Created by 劉 立山 on 12/5/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TableCustomSubtitleItem.h"

@implementation TableCustomSubtitleItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_imageView2) {
        _imageView2.frame = CGRectMake(0, 0, 92, 140);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
