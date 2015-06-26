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
#import <Three20/Three20.h>
#import "InternetResource.h"
#import "Global.h"
#import "eZoeAppDelegate.h"
#import "MKStoreManager.h"
#import "YLUIKitAddition.h"



@class ASINetworkQueue;
@class DownloadTestModel;//UIViewController

@interface SimpleController : TTViewController <TTModelDelegate,UIScrollViewDelegate> {
    NSUInteger        _defaultMaxContentLength;
    TTActivityLabel   *_activityLabel;
    DownloadTestModel *_loadingModel;
    NSTimer           *_progressTimer;
    UILabel           *_statusLabel;
    NSArray           *iResources;
    
    NSString          *_bookid;
    NSString          *_booktype;
    NSString          *_storeType;
    NSString          *_batchNumber;
    TTButton          *_downloadButton;
    TTButton          *_dismissButton;
    
    ASINetworkQueue *networkQueue;
    UIProgressView *progressIndicator;
    BOOL failed;
    
    BOOL hasPackageFiles;
    NSMutableArray *packageList;
   
}
@property(nonatomic, retain) NSArray *iResources;
@property(nonatomic, retain)IBOutlet UILabel *_statusLabel;
@property(nonatomic, retain)NSString *bookid;
@property(nonatomic, retain)NSString *booktype;
@property(nonatomic, retain)NSString *storeType;
@property(nonatomic, retain)NSString *batchNumber;

@property(nonatomic, assign) BOOL hasPackageFiles;
@property(nonatomic, assign) NSMutableArray *packageList;

- (void)loadWithUrl:(NSString*)url;

//-(void)downloadZipFile;
@end
