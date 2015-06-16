//
//  DownloadManager.h
//  TAAZEREADER
//
//  Created by gdx on 13/10/3.
//
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;
@class ASINetworkQueue;

@interface DownloadManager : NSObject {
    ASINetworkQueue *_queue;
    NSMutableDictionary *_requests;
}

+ (id)sharedManager;

- (BOOL)addDownload:(ASIHTTPRequest *)request key:(NSString *)key;
- (ASIHTTPRequest *)getDownload:(NSString *)key;

@end
