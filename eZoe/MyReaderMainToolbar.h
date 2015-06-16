//
//	ReaderMainToolbar.h
//	Reader v2.5.4
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

#import "UIXToolbarView.h"


@class MyReaderMainToolbar;

@class MyWebViewController;

@protocol MyReaderMainToolbarDelegate <NSObject>

@required // Delegate protocols

- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar doneButton:(UIButton *)button;
- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button;
- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar translateButton:(UIButton *)button;
- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar searchButton:(UIButton *)button;
- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar settingButton:(UIButton *)button;
- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar markButton:(UIButton *)button;
- (void)tappedInToolbar:(MyReaderMainToolbar *)toolbar voiceButton:(UIButton *)button;

@end

@interface MyReaderMainToolbar : UIXToolbarView//<FPPopoverControllerDelegate>
{
@private // Instance variables

	UIButton *markButton;

	UIImage *markImageN;
	UIImage *markImageY;
    
    UIButton *transButton;
    
    UIImage *transImageT;
    UIImage *transImageS;
    
    UIButton *voiceButton;
    UIImage *voiceImagePlay;
    UIImage *voiceImagePauced;
    
    BOOL bVoicePurchased;
}

@property (nonatomic, assign, readwrite) id <MyReaderMainToolbarDelegate> delegate;

//- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object;

- (void)setBookmarkState:(BOOL)state;
- (void)setTranslateLang:(BOOL)langTra;
- (void)setVoicePlayPauced:(BOOL)type;

- (void)hideToolbar;
- (void)showToolbar;

@end
