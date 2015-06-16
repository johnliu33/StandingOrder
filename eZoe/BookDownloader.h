//
//  BookDownloader.h
//  TAAZEREADER
//
//  Created by gdx on 12/23/13.
//
//

#import <Foundation/Foundation.h>
//#import <Parse/Parse.h>

//NSMutableArray+QueueAdditions.h

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end


//NSMutableArray+QueueAdditions.m

@implementation NSMutableArray (QueueAdditions)
// Queues are first-in-first-out, so we remove objects from the head
- (id) dequeue {
    // if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [[headObject retain] autorelease]; // so it isn't dealloc'ed on remove
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}
@end

#define kBookDownloadDidFinished          @"BookDownloadDidFinished"
#define kBookDownloadDidStarted           @"BookDownloadDidStarted"
#define kBookDownloadDidFailed            @"BookDownloadDidFailed"
#define kBookDownloadDidUpdatedProgress   @"BookDownloadDidUpdatedProgress"
#define kBookUpdateCellLabel              @"BookUpdateCellLabel"

@class FileDownloadManager;

@interface BookDownloader : NSObject {
    FileDownloadManager *_downloadManager;
    NSMutableDictionary *_requests;
}

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

+ (id)sharedManager;
- (void)downloadBook:(NSString *)pid orderId:(NSString *)orderId;
- (void)pauseDownloadBook:(NSString *)pid;
- (CGFloat)downloadProgressByBookId:(NSString *)bookId;
- (BOOL)waitForDownload:(NSString*)bookId;
@end
