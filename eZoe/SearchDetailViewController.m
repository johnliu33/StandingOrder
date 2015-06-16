/******************************************************************************
 * Copyright (c) 2010, Maher Ali <maher.ali@gmail.com>
 * Advanced iOS 4 Programming: Developing Mobile Applications for Apple iPhone, iPad, and iPod touch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

#import "SearchDetailViewController.h"
#import "eZoeAppDelegate.h"
@interface SearchTextStyleSheet : TTDefaultStyleSheet
@end

@implementation SearchTextStyleSheet

/*- (TTStyle*)blueText {
 return [TTTextStyle styleWithColor:[UIColor blueColor] next:nil];
 }
 
 - (TTStyle*)redText {
 return [TTTextStyle styleWithColor:[UIColor redColor] next:nil];
 }
 
 - (TTStyle*)largeText {
 return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:32] next:nil];
 }
 
 - (TTStyle*)smallText {
 return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12] next:nil];
 }
 
 - (TTStyle*)floated {
 return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 5, 5)
 padding:UIEdgeInsetsMake(0, 0, 0, 0)
 minSize:CGSizeZero position:TTPositionFloatLeft next:nil];
 }*/

- (TTStyle*)myyellowBox {
    return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
      [TTShadowStyle styleWithColor:[UIColor grayColor] blur:2 offset:CGSizeMake(1,1) next:
       [TTSolidFillStyle styleWithColor:[UIColor yellowColor] next:
        [TTSolidBorderStyle styleWithColor:[UIColor grayColor] width:1 next:nil]]]]];
}

/*- (TTStyle*)inlineBox {
 return
 [TTSolidFillStyle styleWithColor:[UIColor blueColor] next:
 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(5,13,5,13) next:
 [TTSolidBorderStyle styleWithColor:[UIColor blackColor] width:1 next:nil]]];
 }
 
 - (TTStyle*)inlineBox2 {
 return
 [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
 [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(5,50,0,50)
 padding:UIEdgeInsetsMake(0,13,0,13) next:nil]];
 }*/

@end

@implementation SearchDetailViewController
@synthesize content;
@synthesize keywords1;
@synthesize caller;
@synthesize searchedPage;

- (id)init
{
	if ((self = [super init])) {
		//eZoeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		self.title =  NSLocalizedString(@"快速瀏覽",@"SnapShot");//@"快速瀏覽";//[delegate characterNameForShowIndex:delegate.selectedShow.row atIndex:delegate.selectedCharacter.row];
        //[TTStyleSheet setGlobalStyleSheet:[[[TextTestStyleSheet alloc] init] autorelease]];
        [TTStyleSheet setGlobalStyleSheet:[[[SearchTextStyleSheet alloc] init] autorelease]];
	}
	return self;
}

- (void)jumpButtonAction:(TTButton*)button {
    //NSLog(@"Page Jump %@",self.keyword1);
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *_sText;
    if(appDelegate.iBookLastLang == 1)
    {    
        _sText = [[NSString stringWithString:[keywords1 objectAtIndex:0]] traditionalChineseString];
    }else
        _sText = [keywords1 objectAtIndex:0];
    [self.caller didClickJumpButton:[self searchedPage] searchText:_sText];
}

- (void)loadView {
	//eZoeAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	theView   = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	theView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
	theView.backgroundColor = [UIColor  whiteColor];
	CGFloat contentHeight = (([content length]/12.0) + 10)*22;
    
    NSString *_boxBegin = @"<span class=\"myyellowBox\">";//spans with backgrounds</span>"];
    NSString *_boxEnd = @"</span>";
    NSMutableString *_content = [NSString stringWithString:content];
    NSString *_insertString;
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];

    for(NSString *_key in keywords1)
    {
        if(appDelegate.iBookLastLang == 1)
        {
            _key = [_key simplifiedChineseString];
        }
        _insertString = [NSString stringWithFormat:@"%@%@%@",_boxBegin,_key,_boxEnd];
        _content = [NSString stringWithString:[_content stringByReplacingOccurrencesOfString:_key withString:_insertString]];//content;
    }
    
    CGRect _theRectDetail;
    CGRect _theRectButton;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(TTIsOrienLandscape())
        {
            _theRectDetail = CGRectMake(10, 10, 300, 574);
            _theRectButton = CGRectMake(10, 589, 300, 40);
        }
        else
        {
            _theRectDetail = CGRectMake(10, 10, 300, 830);
            _theRectButton = CGRectMake(10, 845, 300, 40);
        }
    }else
    {
        if(TTIsOrienLandscape())
        {
            _theRectDetail = CGRectMake(10, 10, 300, 574);
            _theRectButton = CGRectMake(10, 589, 300, 40);
        }
        else
        {
            _theRectDetail = CGRectMake(10, 40, 300, 360);
            _theRectButton = CGRectMake(10, 410, 300, 40);
        }
    }
    
    UIScrollView* _scrollView = [[UIScrollView alloc] 
                                 initWithFrame:_theRectDetail]; 
    //_scrollView.pagingEnabled = NO; 
    //_scrollView.directionalLockEnabled = YES;
    NSLog(@"Content Height:%f",contentHeight);
    
    _scrollView.contentSize = CGSizeMake(300, contentHeight); 
    _scrollView.delegate = self;  
    [theView addSubview:_scrollView];
    
    TTStyledTextLabel* label1 = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 300)] autorelease];//self.view.bounds
    label1.font = [UIFont systemFontOfSize:22];
    
    /*NSString *_lang = NSLocalizedString(@"lang",@"lang");
    if([_lang isEqualToString:@"Simplify"])
    {
        NSString *_trans = [[NSString stringWithString:_content] simplifiedChineseString];
        label1.text = [TTStyledText textFromXHTML:_trans lineBreaks:YES URLs:YES];
    }else
    {*/
        label1.text = [TTStyledText textFromXHTML:_content lineBreaks:YES URLs:YES];
    //}
    
    
    label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    label1.backgroundColor = [UIColor clearColor];
    [label1 sizeToFit];
    [_scrollView addSubview:label1];
    
    TT_RELEASE_SAFELY(_jumpButton);
    _jumpButton = [TTButton buttonWithStyle:@"toolbarButton:" title:NSLocalizedString(@"跳轉至該頁",@"SearchJump")];
    [_jumpButton setFont: [UIFont systemFontOfSize: 22.0f]];
    [_jumpButton addTarget:self action:@selector(jumpButtonAction:) forControlEvents: UIControlEventTouchUpInside];
    [theView addSubview:_jumpButton];

    [_jumpButton sizeToFit];
    [_jumpButton setFrame:_theRectButton];
    
    [theView addSubview:_scrollView];
	/*CGRect labelFrame =  CGRectMake(80, 10, 190, 50);
	nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
    nameLabel.font = [UIFont systemFontOfSize:25.0];
	nameLabel.textColor = [UIColor  blackColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.textAlignment = UITextAlignmentLeft;   
	nameLabel.lineBreakMode = UILineBreakModeWordWrap;
	NSString  *theName = @"hurley";//[delegate characterNameForShowIndex:delegate.selectedShow.row atIndex:delegate.selectedCharacter.row];
	nameLabel.text = [NSString stringWithFormat:@"%@:  %@", @"Name", theName];
    [theView addSubview: nameLabel];
	UIImageView   *imgView = [[UIImageView alloc] 
								initWithImage:[UIImage
												imageNamed:[NSString stringWithFormat:@"%@.jpg",  theName]]];
	imgView.frame = CGRectMake(30, 70, 250, 300);
	[theView addSubview:imgView];
	[imgView release];*/
	
	self.view = theView;
    [_scrollView release];
}
 

- (void)dealloc {
    [TTStyleSheet setGlobalStyleSheet:nil];
	[nameLabel release];
	[theView release];
    [content release];
	[super dealloc];
}


@end
