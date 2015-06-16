//
//  MyCustomStylesheet.m
//  eZoe
//
//  Created by John Liu on 2011/11/1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MyCustomStylesheet.h"


@implementation MyCustomStylesheet
- (TTStyle*)launcherButton:(UIControlState)state {
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
   // {
        return
        [TTPartStyle styleWithName:@"image" style:TTSTYLESTATE(launcherButtonImage:, state) next:
         [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11] color:RGBCOLOR(180, 180, 180)
                    minimumFontSize:11 shadowColor:nil
                       shadowOffset:CGSizeZero next:nil]];
    /*}else
    {
        return
        [TTPartStyle styleWithName:@"image" style: TTSTYLESTATE(launcherButtonImage:, state) next:
         
         [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11] color:RGBCOLOR(180, 180,180)
                    minimumFontSize:11 shadowColor:nil shadowOffset:CGSizeZero
                      textAlignment:UITextAlignmentCenter verticalAlignment:UIControlContentVerticalAlignmentBottom
                      lineBreakMode:UILineBreakModeClip numberOfLines:1 next:nil]];
    }*/
}

// Our launcher button image style
- (TTStyle*)launcherButtonImage:(UIControlState)state {
    /*if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        TTStyle* style =
        [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-7, 0, 11, 0) next:
         [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:0] next:
          [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeCenter
                                     size:CGSizeZero next:nil]]];
        
        if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
            [style addStyle:
             [TTBlendStyle styleWithBlend:kCGBlendModeSourceAtop next:
              [TTSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.5) next:nil]]];
        }
        
        return style;
    }else
    {*/
        TTStyle* style =
        [TTShapeStyle styleWithShape:[TTRoundedRectangleShape
                                      shapeWithRadius:0] next:
         [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(-8, 0, 0, 0)
                             padding:UIEdgeInsetsMake(16, 16, 16, 16)
                             minSize:CGSizeMake(0, 0)
                            position:TTPositionStatic next:
          [TTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeScaleAspectFit
                                     size:CGSizeMake(200, 200) next:nil
           ]]];
        
        if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
            [style addStyle:
             [TTBlendStyle styleWithBlend:kCGBlendModeSourceAtop next:
              [TTSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.5) next:nil]]];
        }
        
        return style;
    //}
}
@end
