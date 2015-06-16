//
//  FileDownloadManager.m
//  TAAZEREADER
//
//  Created by gdx on 13/10/3.
//
//

#import "FileDownloadManager.h"
#import "ASIHTTPRequest.h"
#import "NSString+Path.h"
#import "NSString+Sha1.h"

@implementation FileDownloadManager

- (ASIHTTPRequest *)downloadUrl:(NSString *)url userInfo:(NSDictionary *)userInfo {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *documentsDir = [NSString privateDocumentPath];
    NSString *hashKey = [userInfo objectForKey:@"resumeHashKey"] ? [userInfo objectForKey:@"resumeHashKey"] : url;
    NSString *tmpPath = [self temporaryDownloadPathByResumeHashKey:hashKey];
    request.temporaryFileDownloadPath = tmpPath;
    request.allowResumeForFileDownloads = YES;
	request.downloadDestinationPath = [documentsDir stringByAppendingPathComponent:[tmpPath lastPathComponent]];
    request.userInfo = userInfo;
    request.delegate = self;
    request.downloadProgressDelegate = self;
    request.showAccurateProgress = YES;
    
    if ([self addDownload:request
                      key:url]) {
        return request;
    }
    return nil;
}

- (ASIHTTPRequest *)downloadUrl:(NSString *)url {
    return [self downloadUrl:url
                    userInfo:nil];
}

- (NSString *)temporaryDownloadPathByResumeHashKey:(NSString *)resumeHashKey {
    NSString *sha1 = [resumeHashKey sha1];
    return [[NSString cachePath] stringByAppendingPathComponent:sha1];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFDMDidStarted
                                                        object:request];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFDMDidFailed
                                                        object:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFDMDidFinished
                                                        object:request];
}

#pragma mark - ASIProgressDelegate

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes {
    NSLog(@"recieve: %lld", bytes);
    NSLog(@"recieve: %lld", request.totalBytesRead);
    NSLog(@"content length: %lld", request.contentLength);
    unsigned long long contentSize = request.contentLength;
    if ([request.responseHeaders objectForKey:@"Content-Range"]) {
        NSString *contentRange = [request.responseHeaders objectForKey:@"Content-Range"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/(\\d+)$"
                                                                               options:0
                                                                                 error:nil];
        NSArray *ms = [regex matchesInString:contentRange
                                     options:0
                                       range:NSMakeRange(0, contentRange.length)];
        NSTextCheckingResult *m = [ms objectAtIndex:0];
        contentSize = [[contentRange substringWithRange:[m rangeAtIndex:1]] longLongValue];
    }
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:request.temporaryFileDownloadPath
                                                                              error:nil];
    if (contentSize > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFDMDidUpdatedProgress
                                                            object:request
                                                          userInfo:@{
                                                                     @"recieveBytes": [NSNumber numberWithLongLong:bytes],
                                                                     @"totalBytesRead": fileInfo ? [fileInfo objectForKey:NSFileSize] : @0,
                                                                     @"totalBytes": [NSNumber numberWithUnsignedLongLong:contentSize],
                                                                     @"incrementBytes": [NSNumber numberWithUnsignedLongLong:0]
                                                                     }];
    }
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength {
    NSLog(@"download size: %lld", newLength);
    unsigned long long contentSize = request.contentLength;
    if ([request.responseHeaders objectForKey:@"Content-Range"]) {
        NSString *contentRange = [request.responseHeaders objectForKey:@"Content-Range"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/(\\d+)$"
                                                                               options:0
                                                                                 error:nil];
        NSArray *ms = [regex matchesInString:contentRange
                                     options:0
                                       range:NSMakeRange(0, contentRange.length)];
        NSTextCheckingResult *m = [ms objectAtIndex:0];
        contentSize = [[contentRange substringWithRange:[m rangeAtIndex:1]] longLongValue];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFDMDidUpdatedProgress
                                                        object:request
                                                      userInfo:@{
                                                                 @"recieveBytes": [NSNumber numberWithLongLong:0],
                                                                 @"totalBytesRead": [NSNumber numberWithLongLong:request.totalBytesRead],
                                                                 @"totalBytes": [NSNumber numberWithUnsignedLongLong:contentSize],
                                                                 @"incrementBytes": [NSNumber numberWithLongLong:newLength]
                                                                 }];
}

@end
