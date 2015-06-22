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

#import "SimpleController.h"
#import <Three20/Three20.h>
#import "DownloadTestModel.h"
#import "eZoeAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

/*zip file*/
#import "Objective_ZipViewController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"



@interface TextTestStyleSheet : TTDefaultStyleSheet
@end

@implementation TextTestStyleSheet

- (TTStyle*)blueText {
    return [TTTextStyle styleWithColor:[UIColor blueColor] next:nil];
}

- (TTStyle*)redText {
    return [TTTextStyle styleWithColor:[UIColor redColor] next:nil];
}

- (TTStyle*)largeText {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:32] next:nil];
    }else
    {
        return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:18] next:nil];
    }
    
}

- (TTStyle*)smallText {
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12] next:nil];
}

- (TTStyle*)floated {
    return [TTBoxStyle styleWithMargin:UIEdgeInsetsMake(0, 0, 5, 5)
                               padding:UIEdgeInsetsMake(0, 0, 0, 0)
                               minSize:CGSizeZero position:TTPositionFloatLeft next:nil];
}

- (TTStyle*)blueBox {
    return
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:6] next:
     [TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -5, -4, -6) next:
      [TTShadowStyle styleWithColor:[UIColor grayColor] blur:2 offset:CGSizeMake(1,1) next:
       [TTSolidFillStyle styleWithColor:[UIColor cyanColor] next:
        [TTSolidBorderStyle styleWithColor:[UIColor grayColor] width:1 next:nil]]]]];
}

- (TTStyle*)inlineBox {
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
}

@end

// Private stuff
@interface SimpleController()
- (void)fileFetchComplete:(ASIHTTPRequest *)request;
- (void)fileFetchFailed:(ASIHTTPRequest *)request;
@end

@implementation SimpleController



@synthesize iResources;
@synthesize _statusLabel;
@synthesize bookid = _bookid;
@synthesize booktype = _booktype;

@synthesize hasPackageFiles;
@synthesize packageList;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// initiation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Download Progress";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishedLoading:) name:FinishedLoading object:nil];
        //kSubscriptionsPurchasedNotification
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginDownloadBook:) name:BeginDownLoading object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeUI:) name:ResumeUI object:nil];//ResumeUI
        [TTStyleSheet setGlobalStyleSheet:[[[TextTestStyleSheet alloc] init] autorelease]];

    }
    return self;
}

-(void)handleFinishedLoading:(NSNotification*)notification{
    [self performSelectorOnMainThread:@selector(reloadTheData:) withObject:notification.object waitUntilDone:NO]; 
}
-(void)beginDownloadBook:(NSNotification*)notification{
    //[self downloadZipFile];
    [self ASIDownload:@""];
}

-(void)resumeUI:(NSNotification*)notification{
          
    [_downloadButton setEnabled:YES];
    [_dismissButton setEnabled:YES];
    [_activityLabel setText:@""];
    _activityLabel.isAnimating = NO;
    
}
/*
-(void)downloadZipFile
{
    //NSLog(@"Begin downloading books");
    NSString *dwnUrl = [NSString stringWithFormat:@"http://ipad.twgbr.org/product_file/%@.zip",_bookid];
    [self loadWithUrl:[dwnUrl copy]];//[dwnUrl copy]
    //[self downloadTest];
    _activityLabel.isAnimating = YES;
    NSString *sDownloadFile = [NSString stringWithFormat:@"http://ipad.twgbr.org/product_file/%@.zip",_bookid];
    NSString *_bid;
    if([_booktype isEqualToString:@"debug"])
        _bid = [_bookid substringFromIndex:1];
    else
        _bid = _bookid;
    self.iResources = [NSArray  arrayWithObjects:
                       [[[InternetResource alloc] initWithTitle:_bid andURL:sDownloadFile] autorelease],
                       nil];
    InternetResource  *iResource = [self.iResources objectAtIndex:0];
    [iResource start];
}*/

/*
- (void)downloadTest:(NSString *)product_id
{
    [_dismissButton setEnabled:NO];
    [_downloadButton setEnabled:NO];
    
    //in-app purchase
    if([_booktype isEqualToString:@"debug"]) //normal
    {
        //[self downloadZipFile];
        [self ASIDownload:product_id];
    }
    else
    {
        //[_downloadButton setTitle:@"購買中" forState:UIControlStateNormal];
        NSString *_apple_productid = [NSString stringWithFormat:@"%@%@",kProductPrefix,_bookid];
        [[MKStoreManager sharedManager] buyFeature:_apple_productid];
        [self ASIDownload:product_id];
        [_activityLabel setText:NSLocalizedString(@"處理中",@"Processing")];
        _activityLabel.isAnimating = YES;
        
    }
    
    
     
}*/
- (void)downloadTest:(NSString *)product_id
{
    [_dismissButton setEnabled:NO];
    [_downloadButton setEnabled:NO];
    
    //in-app purchase
    if([_booktype isEqualToString:@"debug"]) //normal
    {
        //[self downloadZipFile];
        [self ASIDownload:product_id];
    }
    else
    {
       
        [self ASIDownload:product_id];
        [_activityLabel setText:NSLocalizedString(@"處理中",@"Processing")];
        _activityLabel.isAnimating = YES;
        
    }
    
    
    
}

- (void)dealloc {
    self.packageList = nil;
    
    [progressIndicator release];
	[networkQueue reset];
	[networkQueue release];
    [TTStyleSheet setGlobalStyleSheet:nil];
   
    [_booktype release];
    [_bookid release];
    
    
    self.iResources = nil;
     [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)loadWithUrl:(NSString*)url {
    TT_RELEASE_SAFELY(_loadingModel);
    _loadingModel = [[DownloadTestModel alloc] init];
    [_loadingModel.delegates addObject: self];
    [_loadingModel setDownloadUrl: url];
    [_loadingModel load: TTURLRequestCachePolicyNoCache more: NO];
}

- (void)updateProgress:(NSTimer*)timer {
    [_activityLabel setProgress: [_loadingModel downloadProgress]];
}

- (void)subscriptionExpired:(NSNotification*)notification
{
    NSLog(@"It is expired!");
}

#pragma mark - setup button price
- (void)setupButtonPrice
{
    
    NSString *_apple_productid = [NSString stringWithFormat:@"%@%@",kProductPrefix,_bookid];
    
    //TT_RELEASE_SAFELY(_downloadButton);
    NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
    NSString *subPrice = [prices objectForKey:_apple_productid];
    
   /* _desc = [NSString stringWithString:NSLocalizedString(@"已安裝",@"Installed")];
    TT_RELEASE_SAFELY(_downloadButton);
    _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
    _downloadButton.userInteractionEnabled = YES;*/
    
    NSString *_coverName = [NSString stringWithFormat:@"%@l.png",_bookid];
    NSString *dataPath = [[NSString stringWithString:_coverName] getDocPathWithPList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:dataPath])
        [_downloadButton setTitle:NSLocalizedString(@"已安裝",@"Installed") forState:UIControlStateNormal];
    else
        [_downloadButton setTitle:subPrice forState:UIControlStateNormal];
    
   
    _downloadButton.userInteractionEnabled = YES;
    
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector (setupButtonPrice)
                                                 name: ksetupButtonPriceNotification
                                               object:nil];
    
    
    NSString *formattedString;// = [[NSString alloc] init];
    CGRect _rect;
    
    
    _rect = CGRectMake(0, 0, 600,480);
    
    
    [self setView: [[[UIView alloc] initWithFrame:_rect] autorelease]];
    
    //[self.view setBackgroundColor: [UIColor groupTableViewBackgroundColor]];
    //[self.view setBackgroundColor: [UIColor scrollViewTexturedBackgroundColor]];
    [self.view setBackgroundColor: [UIColor colorWithRed:252.0 green:251.0 blue:248.0 alpha:1.0]];//#FCFBF8
    
    
    
    TT_RELEASE_SAFELY(_downloadButton);
    if([_booktype isEqualToString:@"debug"])
        _downloadButton = [TTButton buttonWithStyle:@"toolbarButton:" title:@"免費下載"];
    else if([_booktype isEqualToString:@"normal"])
    {
        NSString *_desc;
        NSString *_coverName = [NSString stringWithFormat:@"%@l.png",_bookid];
        NSString *dataPath = [[NSString stringWithString:_coverName] getDocPathWithPList];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:dataPath])
        {
            /*_desc = [NSString stringWithString:NSLocalizedString(@"已安裝",@"Installed")];
            TT_RELEASE_SAFELY(_downloadButton);
            _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
            _downloadButton.userInteractionEnabled = YES;
             */
            
            NSString *_apple_productid = [NSString stringWithFormat:@"%@%@",kProductPrefix,_bookid];
            
            
            
            TT_RELEASE_SAFELY(_downloadButton);
            NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
            NSString *subPrice = [prices objectForKey:_apple_productid];
            
            //NSLog(@"Price of %@:%@",_apple_productid,subPrice);
            
            NSString *_version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] substringToIndex:1];
            
            if([_version integerValue] < 2 && [_bookid isEqualToString:@"8889"])
            {
                _desc = [NSString stringWithString:NSLocalizedString(@"請升級至最新版本",@"Update")];
                _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                _downloadButton.userInteractionEnabled = NO;
            }else if (!subPrice || [subPrice isKindOfClass:[NSNull class]])
            {
                //grayToolbarButton:
                _downloadButton = [TTButton buttonWithStyle:@"toolbarButton:" title:@"檢查中"];
                //_downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:@"查詢中"];
                _downloadButton.userInteractionEnabled = NO;
                [[MKStoreManager sharedManager] requestProductDataWithBookId:_bookid];
            }else
            {
                _desc = [NSString stringWithString:NSLocalizedString(@"已安裝",@"Installed")];
                _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                //_downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:subPric];
                _downloadButton.userInteractionEnabled = YES;
                
            }

            
        }else
        {
            
            NSString *_apple_productid = [NSString stringWithFormat:@"%@%@",kProductPrefix,_bookid];
        
            
            
            TT_RELEASE_SAFELY(_downloadButton);
            NSDictionary *prices = [[MKStoreManager sharedManager] pricesDictionary];
            NSString *subPrice = [prices objectForKey:_apple_productid];
            
            //NSLog(@"Price of %@:%@",_apple_productid,subPrice);
            
            NSString *_version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] substringToIndex:1];
            
            if([_version integerValue] < 2 && [_bookid isEqualToString:@"8889"])
            {
                _desc = [NSString stringWithString:NSLocalizedString(@"請升級至最新版本",@"Update")];
                _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                _downloadButton.userInteractionEnabled = NO;
            }else if (!subPrice || [subPrice isKindOfClass:[NSNull class]])
            {
                //grayToolbarButton:
               _downloadButton = [TTButton buttonWithStyle:@"toolbarButton:" title:@"查詢中"];
               //_downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:@"查詢中"];
               _downloadButton.userInteractionEnabled = NO;
                [[MKStoreManager sharedManager] requestProductDataWithBookId:_bookid];
            }else
            {
                _downloadButton = [TTButton buttonWithStyle:@"toolbarButton:" title:subPrice];
                //_downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:subPric];
                _downloadButton.userInteractionEnabled = YES;
            
            }
         
        }
    }
    else
    {
        NSString *_desc;
        NSString *_coverName = [NSString stringWithFormat:@"%@l.png",_bookid];
        NSString *dataPath = [[NSString stringWithString:_coverName] getDocPathWithPList];

        
        
        
        /*
        MKStoreManager *_mkmanager = [MKStoreManager sharedManager];
        
        NSString *_apple_productid = [NSString stringWithFormat:@"tw.org.ct.iReadCT.b%@",_bookid];
        SKProduct *p = [_mkmanager.purchasableObjects valueForKey:_apple_productid];
        //NSLog(@"Feature: %@, Cost: %f, ID: %@",[p localizedTitle],[[p price] doubleValue], [p productIdentifier]);
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:p.priceLocale];
		formattedString = [numberFormatter stringFromNumber:p.price];
		[numberFormatter release];
        */
                     
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:dataPath])
        {
            _desc = [NSString stringWithString:NSLocalizedString(@"已安裝",@"Installed")];
            TT_RELEASE_SAFELY(_downloadButton);
            _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
            _downloadButton.userInteractionEnabled = YES;
            
        }else
        {
            TT_RELEASE_SAFELY(_downloadButton);
            //NSString *_subsid = _subscriptId;
           
            
            /*[_storemanager restorePreviousTransactionsOnComplete:^(void) {
                NSLog(@"Purchased Item Restored.");
                
                
            }onError:^(NSError *error) {
                NSLog(@"Restore failed: %@", [error localizedDescription]);
                                 
            }];*/
            
            /*
            eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
            if([appDelegate.auto_renew_status integerValue] == 0)
            {
               
                _downloadButton = [TTButton buttonWithStyle:@"toolbarCusButton:" title:@"下載報刊"];
                _downloadButton.userInteractionEnabled = YES;
                
            }else{
                if([appDelegate.auto_renew_status integerValue] == 21006)
                    _desc = [NSString stringWithString:NSLocalizedString(@"請再續訂",@"ReSubscription")];
                else
                    _desc = [NSString stringWithString:NSLocalizedString(@"請先訂閱",@"Subscription")];
                _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                _downloadButton.userInteractionEnabled = NO;
              
            }
            NSLog(@"auto-renew status:%d,expire-date:%@",[appDelegate.auto_renew_status integerValue],appDelegate.expireDate);
            */
            
            
            /*
            if([[MKStoreManager sharedManager] isSubscriptionActive:kSubscription3MonthIdentifier] || [[MKStoreManager sharedManager] isSubscriptionActive:kSubscription6MonthIdentifier] || [[MKStoreManager sharedManager] isSubscriptionActive:kSubscription12MonthIdentifier])
            {
                _downloadButton = [TTButton buttonWithStyle:@"toolbarCusButton:" title:@"下載報刊"];
                _downloadButton.userInteractionEnabled = YES;

            }else{
                
                _desc = [NSString stringWithString:NSLocalizedString(@"請先訂閱",@"Subscription")];
                _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                _downloadButton.userInteractionEnabled = NO;

            }*/

            
            /*
            if([MKStoreManager isFeaturePurchased:_apple_productid])
                _desc = [NSString stringWithString:NSLocalizedString(@"已購買",@"Purchased")];
            else
            {
                if(!formattedString)
                    _desc = [NSString stringWithString:NSLocalizedString(@"查詢中",@"Checking")];
                else
                    _desc = [NSString stringWithFormat:@"%@",formattedString];
            }
            TT_RELEASE_SAFELY(_downloadButton);
            
            if(!formattedString)
            {
                _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                _downloadButton.userInteractionEnabled = NO;
            }
            else
            {
                NSString *_version = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] substringToIndex:1];
                //NSLog(@"Version first word:%@",_version);
                
                if([_version integerValue] < 2 && [_bookid isEqualToString:@"8888"])
                {
                    _desc = [NSString stringWithString:NSLocalizedString(@"請升級至最新版本",@"Update")];
                    _downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:_desc];
                    _downloadButton.userInteractionEnabled = NO;
                }else
                {
                    _downloadButton = [TTButton buttonWithStyle:@"toolbarButton:" title:_desc];
                    _downloadButton.userInteractionEnabled = YES;
                }
            }*/
            
        }
        
    }

    
    
    
    
    
    TT_RELEASE_SAFELY(_activityLabel);
    _activityLabel = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleGray];//TTActivityLabelStyleWhite];
    [_activityLabel setText: @""];
    _activityLabel.isAnimating = NO;//
   
    
    TTImageView* imageView;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        imageView = [[[TTImageView alloc] initWithFrame:CGRectMake(25,20,0, 0)]
                                autorelease];
        imageView.autoresizesToImage = YES;
    }else
    {
        imageView = [[[TTImageView alloc] initWithFrame:CGRectMake(100,5,0, 180)]
                     autorelease];
        //imageView.autoresizesToImage = NO;
    }
    
    NSString *_coverurl = [NSString stringWithFormat:@"http://%@/subs_product_pic/%@.jpg",kSiteHttpRoot,_bookid];
    imageView.urlPath = _coverurl;
    [self.view addSubview:imageView];
    
    

    UIScrollView* _scrollView;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(285, 20, 300, 300)]; 
    }else
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 190 , 300, 180)]; //170
    }
   
    
     
    _scrollView.delegate = self;  
    [self.view addSubview:_scrollView];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/subs_product_desc/%@.txt",kSiteHttpRoot,_bookid];
  
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:urlString]];
  
    NSData *data = [ NSURLConnection sendSynchronousRequest:request returningResponse: nil error: nil ];
    
    NSString *returnData = [[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding: NSUTF8StringEncoding];
    
    
   // NSString *stopBefore = @"</span></b>";
    //NSRange firstRange = [returnData rangeOfString:@"<b><span class='largeText'>"];
    //NSRange secondRange = [[returnData substringFromIndex:firstRange.location + 0] rangeOfString:stopBefore];
    //NSRange finalRange = NSMakeRange(firstRange.location + firstRange.length, secondRange.location - firstRange.length);
    
    //NSString *match =  [returnData substringWithRange:finalRange];
    //NSLog(@"Found string '%@'", match);
   
    CGFloat contentHeight;
    TTStyledTextLabel* label1;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        contentHeight = (([returnData length]/16.0) + 10)*22;
        _scrollView.contentSize = CGSizeMake(300, contentHeight);
        
        label1 = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 300)] autorelease];//self.view.bounds
        label1.font = [UIFont systemFontOfSize:17];
        
        
    }else
    {
        contentHeight = (([returnData length]/12.0))*18;
        _scrollView.contentSize = CGSizeMake(300, contentHeight);
        
        label1 = [[[TTStyledTextLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 300)] autorelease];//self.view.bounds
        label1.font = [UIFont systemFontOfSize:14];
    }
    //label1.textColor = [UIColor whiteColor];
    label1.textColor = [UIColor blackColor];
    
    NSString *_lang = NSLocalizedString(@"lang",@"lang");
    if([_lang isEqualToString:@"Simplify"])
    {
        NSString *_trans = [[NSString stringWithString:returnData] simplifiedChineseString];
        label1.text = [TTStyledText textFromXHTML:_trans lineBreaks:YES URLs:YES];
    }else
    {
        label1.text = [TTStyledText textFromXHTML:returnData lineBreaks:YES URLs:YES];
    }
    
    
    label1.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    label1.backgroundColor = [UIColor clearColor];
    [label1 sizeToFit];
    [_scrollView addSubview:label1];
    [returnData release];
  
     [self.view addSubview: _activityLabel];
    
    
    TT_RELEASE_SAFELY(_dismissButton);
    _dismissButton = [TTButton buttonWithStyle:@"toolbarButton:" title:NSLocalizedString(@"關閉",@"Close")];
    [_dismissButton setFont: [UIFont systemFontOfSize: 18.0f]];
    [_downloadButton setFont: [UIFont systemFontOfSize: 18.0f]];
    
    [_downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents: UIControlEventTouchUpInside];
    [_downloadButton sizeToFit];
    [_downloadButton setFrame:CGRectMake(160, 410,145, 40)];
    [self.view addSubview:_downloadButton];
    
    [_dismissButton addTarget:self action:@selector(dismissButtonAction:) forControlEvents: UIControlEventTouchUpInside];
     [_dismissButton sizeToFit];
    [_dismissButton setFrame:CGRectMake(10, 410, 145, 40)];
    [self.view addSubview:_dismissButton];

    
     
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (!progressIndicator) {
			progressIndicator = [[UIProgressView alloc] initWithFrame:CGRectMake(25, 350, 550, 50)];
		} else {
			[progressIndicator setFrame:CGRectMake(25, 350, 550, 50)];
		}
        [self.view addSubview:progressIndicator];
        
        
        [_activityLabel setFrame:CGRectMake(25, 360, 550, 50)];
        [_downloadButton setFrame:CGRectMake(305, 410,265, 40)];
        [_dismissButton setFrame:CGRectMake(25, 410, 265, 40)];
    }else
    {
        if (!progressIndicator) {
			progressIndicator = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 375, 300, 50)];
		} else {
			[progressIndicator setFrame:CGRectMake(10, 375, 300, 50)];
		}
        [self.view addSubview:progressIndicator];

        if( IS_IPHONE_5 )
            [_activityLabel setFrame:CGRectMake(25, 435, 550, 50)];
        else
            [_activityLabel setFrame:CGRectMake(25, 385, 550, 50)];//10, 390, 300, 40
        //[_downloadButton setFrame:CGRectMake(160, 410,145, 40)];
        //[_dismissButton setFrame:CGRectMake(10, 410, 145, 40)];
    }
    
    
    
    [_scrollView release];
    
}



- (void)viewDidAppear:(BOOL)animated {
    _defaultMaxContentLength = [[TTURLRequestQueue mainQueue] maxContentLength];
    [[TTURLRequestQueue mainQueue] setMaxContentLength: 0];
    [[TTURLRequestQueue mainQueue] setSuspended: NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    TT_RELEASE_SAFELY(_loadingModel);
    [[TTURLRequestQueue mainQueue] setMaxContentLength: _defaultMaxContentLength];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)downloadButtonAction:(TTButton*)button {
    
    if([_booktype isEqualToString:@"normal"])
    {
    
        [_dismissButton setEnabled:NO];
        [_downloadButton setEnabled:NO];
        
        [_activityLabel setText:NSLocalizedString(@"處理中",@"Processing")];
        _activityLabel.isAnimating = YES;
        
        //NSString *_subsid = _subscriptId;
        NSString *_apple_productid = [NSString stringWithFormat:@"%@%@",kProductPrefix,_bookid];
        MKStoreManager  *_storemanager = [MKStoreManager sharedManager];
        [_storemanager buyFeature:_apple_productid onComplete:^(NSString* purchasedFeature, NSData*purchasedReceipt, NSArray* availableDownloads) {
            
            _activityLabel.isAnimating = NO;
            //[_activityLabel setText:NSLocalizedString(@"請至報刊下載處下載報刊!",@"Finish Download")];
            [self downloadTest:purchasedFeature];
            [_dismissButton setEnabled:YES];
            
            NSLog(@"Purchased: %@", purchasedFeature);
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"訂閱完成", @"Subscription Finished")
             message:NSLocalizedString(@"請至報刊下載處下載您的報刊", @"Subscription Description")
             delegate:self
             cancelButtonTitle:NSLocalizedString(@"關閉", @"Close")
             otherButtonTitles: nil];
             
             [alert show];
             */
            
        } onCancelled:^
         {
             
             
             _activityLabel.isAnimating = NO;
             [_activityLabel setText:@""];
             
             [_dismissButton setEnabled:YES];
             [_downloadButton setEnabled:YES];
             
             NSLog(@"User cancel phurchasing");
         }];
    }else
    {
        [self downloadTest:@""];
    }

    
        
}

- (void)fileFetchComplete:(ASIHTTPRequest *)request
{
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
    NSString *downloadfn=@"tempdn.zip";
    NSString *filePath= [documentsDir stringByAppendingPathComponent:downloadfn];
	
    Objective_ZipViewController *_unzipobj = [Objective_ZipViewController alloc];
    
    NSString *_bid;
    if([_booktype isEqualToString:@"debug"])
        _bid = [_bookid substringFromIndex:1];
    else
        _bid = _bookid;
    
    NSLog(@"_bid:%@",_bid);
    
    [_unzipobj unzip:filePath file_id:_bid];
    [_unzipobj release];
    
    NSFileManager *NSFm= [NSFileManager defaultManager];
    [NSFm removeItemAtPath:filePath error:NULL];
    NSString *_pklistpath = [documentsDir stringByAppendingPathComponent:@"pklist.plist"];
    if([NSFm fileExistsAtPath:_pklistpath])
    {
        hasPackageFiles = YES;
        packageList = [NSMutableArray arrayWithContentsOfFile:_pklistpath];
        eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSMutableArray *_thebookList = [appDelegate bookList];
        
        for(NSString *_pk in packageList)
        {
            [_thebookList addObject:_pk];
        }
        [NSFm removeItemAtPath:_pklistpath error:NULL];
        
        
    }
    
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *_thebookList = [appDelegate bookList];
    //NSMutableArray *_installedList = [appDelegate bookInstalledList];
    if(![_thebookList containsObject:_bookid])
    {
        if([[_bookid substringToIndex:1] isEqualToString:@"z"]) //d for debug files
        {
            if(hasPackageFiles) //package files
            {
                //NSLog(@"Package data!");
                hasPackageFiles = NO;
            }else
            {
                NSString *_bd = [_bookid substringFromIndex:1];
                [_thebookList addObject:_bd];
                NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];
                [_thebookList writeToFile:_dataPath atomically:YES];
                
                
            }
        }else
        {
            if(hasPackageFiles) //package files
            {
                //NSLog(@"Package data!");
                hasPackageFiles = NO;
            }else
            {
                [_thebookList addObject:_bookid];
                NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];
                [_thebookList writeToFile:_dataPath atomically:YES];
                
            }
        }
        //NSString *dataPath = [[NSString stringWithString:@"bookInstalled.plist"] getDocPathWithPList];
        //[_installedList writeToFile:dataPath atomically:YES];
    }
    _activityLabel.isAnimating = NO;

    [_activityLabel setText:NSLocalizedString(@"下載完成",@"Finish Download")];
    //TT_RELEASE_SAFELY(_downloadButton);
    //_downloadButton = [TTButton buttonWithStyle:@"grayToolbarButton:" title:@"已安裝"];
    [_downloadButton setTitle:NSLocalizedString(@"安裝完成",@"Finish Install") forState:UIControlStateNormal];
    //[_downloadButton set:@"grayToolbarButton:" forState:UIControlStateNormal];
    [_downloadButton setEnabled:NO];
    //_downloadButton.userInteractionEnabled = NO;
    [_dismissButton setEnabled:YES];

    
    //NSLog(@"ASIDownload Complete");
}

- (void)fileFetchFailed:(ASIHTTPRequest *)request
{
	if (!failed) {
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"下載失敗" message:@"請關閉下載頁後，再次下載" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
            [_activityLabel setText:NSLocalizedString(@"下載失敗",@"Fail Download")];
            //[_activityLabel setProgress: 0.0f];
            [_downloadButton setEnabled:YES];
            [_dismissButton setEnabled:YES];
		}
		failed = YES;
	}
}



- (void)ASIDownload:(NSString*)product_id
{
   
	if (!networkQueue) {
		networkQueue = [[ASINetworkQueue alloc] init];
	}
	failed = NO;
	[networkQueue reset];
	[networkQueue setDownloadProgressDelegate:progressIndicator];
	[networkQueue setRequestDidFinishSelector:@selector(fileFetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(fileFetchFailed:)];
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request;
   
     /*save download data to file*/
    NSString *sDownloadFile = [NSString stringWithFormat:@"http://%@/subs_product_file/%@.zip",kSiteHttpRoot,_bookid];
    NSLog(@"sDownloadFile:%@",sDownloadFile);
   	request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sDownloadFile]];
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
	[request setDownloadDestinationPath:[documentsDir stringByAppendingPathComponent:@"tempdn.zip"]];
	//[request setDownloadProgressDelegate:progressIndicator];
    [request setUserInfo:[NSDictionary dictionaryWithObject:@"request1" forKey:@"name"]];
	[networkQueue addOperation:request];
	
	
	[networkQueue go];
    
    

}

- (void)dismissButtonAction:(TTButton*)button {
    
    [self dismissModalViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTURLRequestDelegate


- (void)modelDidStartLoad:(id <TTModel>)model {
    TT_INVALIDATE_TIMER(_progressTimer);
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0f/24.0f) target:self selector:@selector(updateProgress:) userInfo:nil repeats: YES];
    [_activityLabel setText:NSLocalizedString(@"開始下載",@"Start Download")];
    [_downloadButton setTitle:NSLocalizedString(@"下載中",@"Downloading") forState:UIControlStateNormal];
    [_downloadButton setEnabled:NO];
    [_activityLabel setProgress: 0.0f];
}

- (void)modelDidFinishLoad:(id <TTModel>)model {
    TT_INVALIDATE_TIMER(_progressTimer);
    //[_activityLabel setText:@"Download Finished"];
    [_activityLabel setProgress: 1.0f];
}

- (void)model:(id <TTModel>)model didFailLoadWithError:(NSError *)error {
    TT_INVALIDATE_TIMER(_progressTimer);
    [_activityLabel setText:NSLocalizedString(@"下載失敗",@"Fail Download")];
    [_activityLabel setProgress: 0.0f];
    [_downloadButton setEnabled:YES];
    [_dismissButton setEnabled:YES];
}

- (void)modelDidCancelLoad:(id <TTModel>)model {
    TT_INVALIDATE_TIMER(_progressTimer);
    [_activityLabel setText:NSLocalizedString(@"下載取消",@"Cancel Download")];
    [_activityLabel setProgress: 0.0f];
    [_downloadButton setEnabled:YES];
    [_dismissButton setEnabled:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end
