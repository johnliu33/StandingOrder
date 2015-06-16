//
//  BookManager.h
//  TAAZEREADER
//
//  Created by gdx on 1/3/14.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "BookManagerDelegate.h"

@interface BookManager : NSObject <ASIHTTPRequestDelegate> {
    NSArray *_books;
    NSArray *_createBooks;
    NSArray *_gospelBooks;
    NSArray *_churchBooks;
    NSArray *_bibleBooks;
    NSArray *_biologyBooks;
    NSArray *_resalesBooks;
    NSArray *_gospelPaperBooks;
}

@property (nonatomic, readonly) NSArray *books;
@property (nonatomic, readonly) NSArray *createBooks;
@property (nonatomic, readonly) NSArray *gospelBooks;
@property (nonatomic, readonly) NSArray *churchBooks;
@property (nonatomic, readonly) NSArray *bibleBooks;
@property (nonatomic, readonly) NSArray *biologyBooks;
@property (nonatomic, readonly) NSArray *resalesBooks;
@property (nonatomic, readonly) NSArray *gospelPaperBooks;
@property (nonatomic, unsafe_unretained) id <BookManagerDelegate> delegate;

+ (id)sharedManager;

- (void)deleteBook:(NSString *)bookId;
- (void)requestBookList;
- (void)refreshBooksByGroup;
- (void)refreshBooksByID;
- (void)refreshBooksByName;
- (void)refreshBooksBySearch:(NSString*)searchText;
- (void)copyFileFromResource:(NSString *)fileName;
@end
