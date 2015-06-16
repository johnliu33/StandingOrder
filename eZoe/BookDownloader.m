//
//  BookDownloader.m
//  TAAZEREADER
//
//  Created by gdx on 12/23/13.
//
//

#import "BookDownloader.h"
#import "FileDownloadManager.h"
#import "BookHelper.h"
#import "NSString+Path.h"
#import "Objective_ZipViewController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
//#import "FBEncryptorAES.h"
//#import "RNCryptManager.h"
//#import "CPCryptController.h"
#import "ASIHTTPRequest.h"

#import "eZoeAppDelegate.h"



@implementation BookDownloader

//static NSString *kBookDownloadLink = @"https://ebook.taaze.tw/api/ebook/GetEbook.ashx?cuid=%@&pid=%@&orderid=%@&sn=%@&token=%@";
static NSString *kBookDownloadLink = @"http://ebook.taaze.tw/api/ebook/b/%@/%@.bin?cuid=%@&orderId=%@&pid=%@&sn=%@&token=%@";

#pragma mark - Static methods

+ (id)sharedManager {
    static dispatch_once_t onceToken;
    static BookDownloader *instance;
    dispatch_once(&onceToken, ^{
        instance = [BookDownloader new];
    });
    return instance;
}

#pragma mark - Lifecycle

- (id)init {
    if (self = [super init]) {
        _downloadManager = [FileDownloadManager new];
        _requests = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadDidFinishedNotification:)
                                                     name:kFDMDidFinished
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadDidUpdateProgressNotification:)
                                                     name:kFDMDidUpdatedProgress
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadDidStartNotification:)
                                                     name:kFDMDidStarted
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadDidFailedNotification:)
                                                     name:kFDMDidFailed
                                                   object:nil];
        
      
    }
    return self;
}

- (void)dealloc {
    [_downloadManager release];
    for (ASIHTTPRequest *request in _requests) {
        [request cancel];
    }
    [_requests release];
    
    [super dealloc];
}

#pragma mark - Public methods

- (void)downloadBook:(NSString *)pid orderId:(NSString *)orderId {
    if (![_requests objectForKey:pid]) {
        NSString *sn = [BookHelper generateSN];
        NSString *afterSHA = [BookHelper getnerateSHA:sn
                                         functionName:@"GetEbook"];
        NSString *myCuid = [BookHelper CUID];
  
        NSString *requestUrl = [NSString stringWithFormat:kBookDownloadLink,
                                [pid substringWithRange:NSMakeRange(0, 2)],
                                pid,
                                myCuid,
                                orderId,
                                pid,
                                sn,
                                afterSHA
                                ];
        ASIHTTPRequest *request = [_downloadManager downloadUrl:requestUrl
                                                       userInfo:@{
                                                                  @"resumeHashKey": pid,
                                                                  @"bookId": pid,
                                                                  }];
        if (request) {
            [_requests setObject:request
                          forKey:pid];
        }
    }
}

- (void)pauseDownloadBook:(NSString *)pid {
    ASIHTTPRequest *request = [_requests objectForKey:pid];
    if (request) {
        [request cancel];
    }
}

- (BOOL)waitForDownload:(NSString*)bookId
{
    if([_requests objectForKey:bookId])
        return YES;
    else
        return NO;
}

- (CGFloat)downloadProgressByBookId:(NSString *)bookId {
    NSString *progressKey = [NSString stringWithFormat:@"Book%@Progress", bookId];
    NSNumber *progress = [[NSUserDefaults standardUserDefaults] objectForKey:progressKey];
    if (progress) {
        CGFloat p = [progress floatValue];
        if (!isnan(p) && !isinf(p)) {
            return p;
        }
    }
    return -1.0;
}

#pragma mark - DownloadManager notifications

- (void)downloadDidFinishedNotification:(NSNotification *)notification {
    ASIHTTPRequest *request = notification.object;
    NSDictionary *userInfo = request.userInfo;
    NSString *bookId = [userInfo objectForKey:@"bookId"];
    [_requests removeObjectForKey:bookId];
    NSString *progressKey = [NSString stringWithFormat:@"Book%@Progress", bookId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:1.0f]
                                              forKey:progressKey];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kBookDownloadDidFinished
    //                                                    object:bookId];
    

  
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self extractBook:request.downloadDestinationPath
                      pid:bookId];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TableRefreshBooks" object:nil];
        });
    });
    
    /*PFObject *saveObject = [PFObject objectWithClassName:@"TAAZELogObject"];
    saveObject[@"cuid"] = [BookHelper CUID];
    saveObject[@"pid"] = bookId;
    [saveObject saveInBackground];
    
    
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate LogSoonSendBack:[BookHelper CUID] pid:bookId];
    */
}

- (void)downloadDidUpdateProgressNotification:(NSNotification *)notification {
    NSNumber *totalBytesRead = [notification.userInfo objectForKey:@"totalBytesRead"];
    NSNumber *totalBytes = [notification.userInfo objectForKey:@"totalBytes"];
    CGFloat progress = (float)[totalBytesRead longLongValue] / (float)[totalBytes longLongValue];
    ASIHTTPRequest *request = notification.object;
    NSString *bookId = [request.userInfo objectForKey:@"bookId"];
    NSString *progressKey = [NSString stringWithFormat:@"Book%@Progress", bookId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:progress]
                                              forKey:progressKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBookDownloadDidUpdatedProgress
                                                        object:bookId
                                                      userInfo:@{
                                                                 @"bookSize": totalBytesRead,
                                                                 @"currentSize": totalBytes,
                                                                 @"progress": [NSNumber numberWithFloat:progress],
                                                                 }];
}

- (void)downloadDidFailedNotification:(NSNotification *)notification {
    ASIHTTPRequest *request = notification.object;
    NSString *bookId = [request.userInfo objectForKey:@"bookId"];
    [_requests removeObjectForKey:bookId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBookDownloadDidFailed
                                                        object:bookId
                                                      userInfo:nil];
}

- (void)downloadDidStartNotification:(NSNotification *)notification {
    ASIHTTPRequest *request = notification.object;
    NSString *bookId = [request.userInfo objectForKey:@"bookId"];
    NSString *progressKey = [NSString stringWithFormat:@"Book%@Progress", bookId];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:progressKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:0]
                                                  forKey:progressKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kBookDownloadDidFailed
                                                        object:bookId
                                                      userInfo:nil];
}

#pragma mark - Book file process

- (void)extractBook:(NSString *)downloadFilePath pid:(NSString *)pid {
    NSString *dBookId = [BookHelper dBookId:pid];
    NSString *documentsDir = [NSString privateDocumentPath];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HHmmssSSS"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theTime = [timeFormat stringFromDate:now];
    
    NSString *downloadfn = [NSString stringWithFormat:@"tempdn%@.zip",theTime];//tempdn.zip
    NSString *rmbinfn = downloadFilePath;
    NSString *filePath = [documentsDir stringByAppendingPathComponent:downloadfn];
    NSString *filePath1 = rmbinfn;
    [self AESDecrypt:[dBookId substringFromIndex:1]
        formFilePath:filePath1
          toFilePath:filePath];
    Objective_ZipViewController *_unzipobj = [Objective_ZipViewController alloc];
    
    [_unzipobj unzip:filePath file_id:dBookId];
    [_unzipobj release];
    
    NSFileManager *NSFm = [NSFileManager defaultManager];
    [NSFm removeItemAtPath:filePath error:NULL];
    [NSFm removeItemAtPath:filePath1 error:NULL];
    
    //將書塞進書櫃使用
    //johnliu----------------
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
  
    
    
    NSMutableArray *_thebookList = [appDelegate bookList];

    if(![_thebookList containsObject:dBookId])
    {
        if([[dBookId substringToIndex:1] isEqualToString:@"z"]) //d for debug files
        {
            
               NSString *_bd = [dBookId substringFromIndex:2];//TAAZE Has 1 character check code
                [_thebookList addObject:_bd];
                NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];
                [_thebookList writeToFile:_dataPath atomically:YES];

        }else{
        
                [_thebookList addObject:[dBookId substringFromIndex:1]]; //TAAZE Has 1 character check code
                NSString *_dataPath = [@"bookWillInstalled.plist" getDocPathWithPList];
                [_thebookList writeToFile:_dataPath atomically:YES];
            
        }
    }
    NSString *bookId = [dBookId substringFromIndex:1];
    NSString *progressKey = [NSString stringWithFormat:@"Book%@Progress", bookId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:-1.0f]
                                              forKey:progressKey];
    //johnliu----------------
    
    
}

- (void)AESDecrypt:(NSString *)bid_ formFilePath:(NSString *)from toFilePath:(NSString *)to {
    
    /*NSError *error;
    
    NSMutableString *sn = [NSMutableString stringWithString:bid_];
    NSInteger iMod = [BookHelper MakeStringSum:sn] % 10;
    [sn insertString:[NSString stringWithFormat:@"%i",iMod] atIndex:6];
    
    NSData* key = [sn dataUsingEncoding:NSUTF8StringEncoding];
    NSData* iv = [@"taazevector123" dataUsingEncoding:NSUTF8StringEncoding];
    
    if(![[CPCryptController sharedController] decryptData:from toFile:to key:key iv:iv error:&error])
    {
            NSAssert(NO, @"Couldn't decrypt: %@", error);
    }*/


}

@end
