//
//  BookManagerDelegate.h
//  TAAZEREADER
//
//  Created by gdx on 1/3/14.
//
//

#import <Foundation/Foundation.h>

@class BookManager;

@protocol BookManagerDelegate <NSObject>

- (void)bookListDidDownload:(BookManager *)manager;
- (void)bookListDidDownloadFail:(BookManager *)manager error:(NSError *)error;

@end
