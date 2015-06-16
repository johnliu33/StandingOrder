//
//  DownloadManager.m
//  TAAZEREADER
//
//  Created by gdx on 13/10/3.
//
//

#import "DownloadManager.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@implementation DownloadManager

+ (id)sharedManager {
    static DownloadManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _queue = [ASINetworkQueue new];
        _queue.maxConcurrentOperationCount = 1;
        [_queue setShouldCancelAllRequestsOnFailure:NO];
        _queue.delegate = self;
        _queue.requestDidFinishSelector = @selector(_requestFinished:);
        _queue.requestDidFailSelector = @selector(_requestFailed:);
        _queue.showAccurateProgress = YES;
        [_queue go];
        _requests = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)addDownload:(ASIHTTPRequest *)request key:(NSString *)key {
    @synchronized (self) {
        if (![_requests objectForKey:key]) {
            [_requests setObject:request
                          forKey:key];
            [_queue addOperation:request];
            return YES;
        }
        return NO;
    }
}

- (ASIHTTPRequest *)getDownload:(NSString *)key {
    return [_requests objectForKey:key];
}

- (void)_requestFinished:(ASIHTTPRequest *)request {
    @synchronized (self) {
        [_requests removeObjectsForKeys:[_requests allKeysForObject:request]];
    }
}

- (void)_requestFailed:(ASIHTTPRequest *)request {
    @synchronized (self) {
        [_requests removeObjectsForKeys:[_requests allKeysForObject:request]];
    }
}

- (void)dealloc {
    [_queue release];
    [_requests release];
    
    [super dealloc];
}

@end
