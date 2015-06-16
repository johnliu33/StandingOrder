//
//  FileDownloadManager.h
//  TAAZEREADER
//
//  Created by gdx on 13/10/3.
//
//

#import "DownloadManager.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"

#define kFDMDidFinished          @"FDMDidFinished"
#define kFDMDidStarted           @"FDMDidStarted"
#define kFDMDidFailed            @"FDMDidFailed"
#define kFDMDidUpdatedProgress   @"FDMDidUpdatedProgress"

@interface FileDownloadManager : DownloadManager <ASIHTTPRequestDelegate, ASIProgressDelegate>

- (ASIHTTPRequest *)downloadUrl:(NSString *)url;
- (ASIHTTPRequest *)downloadUrl:(NSString *)url userInfo:(NSDictionary *)userInfo;
- (NSString *)temporaryDownloadPathByResumeHashKey:(NSString *)resumeHashKey;

@end
