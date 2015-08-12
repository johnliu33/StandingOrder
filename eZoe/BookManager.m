//
//  BookManager.m
//  TAAZEREADER
//
//  Created by gdx on 1/3/14.
//
//

#import "BookManager.h"
#import "BookHelper.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "Global.h"

@implementation BookManager

#pragma mark - Static method

+ (id)sharedManager {
    static dispatch_once_t onceToken;
    static BookManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [BookManager new];
    });
    return manager;
}

#pragma mark - Public methods

- (void)requestBookList {
    /*
    NSString *sn = [BookHelper generateSN];
    NSString *afterSHA = [BookHelper getnerateSHA:sn
                                     functionName:@"GetEbookList"];
    NSString *cuid = [BookHelper CUID];
    NSString *url = [NSString stringWithFormat:@"http://ebook.taaze.tw/api/ebook/GetEbookList.ashx?cuid=%@&sn=%@&token=%@", cuid, sn, afterSHA];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.delegate = self;
    [request startAsynchronous];
     */
    
    /*[self copyFileFromResource:@"2148l.png"];
    [self copyFileFromResource:@"1044l.png"];
    [self copyFileFromResource:@"2019l.png"];
    
    NSDictionary *bookDict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"2148",@"pid",@"神的經營",@"title", nil];
    NSDictionary *bookDict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"1044",@"pid",@"人生的奧秘",@"title", nil];
    NSDictionary *bookDict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"2019",@"pid",@"正常的基督徒生活",@"title", nil];
    */
    
    NSString *newfileName = [@"bookListInfo.plist" getDocPathWithPList];
    NSArray *bookList = [NSArray arrayWithContentsOfFile:newfileName];
    
    
    //sort
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"bookId"  ascending:YES];
    bookList=[bookList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    NSArray *recent = [bookList copy];
    
    [self setBooks:recent];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)copyFileFromResource:(NSString *)fileName
{
	BOOL success;
	
	NSString *desPath = [fileName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:desPath];
	
	if(success) return;
	
	NSString *souPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	
	[fileManager copyItemAtPath:souPath toPath:desPath error:nil];
    
    BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:desPath]];
    if(successFix)
        NSLog(@"Can mark:%@ as don't save to iCloud",desPath);
    else
        NSLog(@"Can't mark:%@ as don't save to iCloud",desPath);
	
	//[fileManager release];
	
}

- (void)refreshBooksBySearch:(NSString*)searchText {
    NSArray *searchTemp = [self.books copy];

    NSPredicate *predicateByTitle = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
    NSPredicate *predicateByBookId = [NSPredicate predicateWithFormat:@"bookId contains[cd] %@", searchText];
    
    NSPredicate *predicate_union = [NSCompoundPredicate orPredicateWithSubpredicates:
                              @[predicateByTitle, predicateByBookId]];
    NSArray *results = [searchTemp filteredArrayUsingPredicate:predicate_union];
    
    _gospelBooks = [results copy];
    _createBooks = nil;
}

- (void)refreshBooksByName {
    [_gospelBooks release];
    NSMutableDictionary *pairDictTemp = [NSMutableDictionary dictionary];
    for(NSDictionary *bookInfo in self.books)   {
        NSString *titleValue = [bookInfo objectForKey:@"title"];
        [pairDictTemp setValue:bookInfo forKey:titleValue];
    }
    
    NSArray *sortedKeys = [[pairDictTemp allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    
    NSMutableArray *_array = [NSMutableArray array];
    for (NSString *key in sortedKeys)
    {
        [_array addObject:[pairDictTemp objectForKey:key]];
    }
    _gospelBooks = [_array copy];
    _createBooks = nil;
    
}

- (void)refreshBooksByID {
    
    [_gospelBooks release];
    NSMutableDictionary *pairDictTemp = [NSMutableDictionary dictionary];
    for(NSDictionary *bookInfo in self.books)   {
        NSString *bookId = [bookInfo objectForKey:@"bookId"];
        [pairDictTemp setValue:bookInfo forKey:bookId];
    }
    
    //NSArray *sortedKeys = [[pairDictTemp allKeys] sortedArrayUsingSelector: @selector(localizedCompare:)];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    NSArray* sortedKeys = [[pairDictTemp allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableArray *_array = [NSMutableArray array];
    for (NSString *key in sortedKeys)
    {
        [_array addObject:[pairDictTemp objectForKey:key]];
    }
    _gospelBooks = [_array copy];
    _createBooks = nil;
    
    
    /*
    [_gospelBooks release];
    NSMutableArray *gospelBooks = [NSMutableArray array];
    
    
     for (NSDictionary *bookInfo in self.books) {
         [gospelBooks addObject:bookInfo];
     }
     _gospelBooks = [gospelBooks retain];
    _createBooks = nil;
    */
}

- (void)refreshBooksByGroup {
    [_createBooks release];
    [_gospelBooks release];
    [_churchBooks release];
    [_bibleBooks release];
    [_lifestudyBooks release];
    [_recoveryBooks release];
    [_biologyBooks release];
    [_hymnBooks release];
    [_resalesBooks release];
    [_gospelPaperBooks release];
    [_morningBooks release];
    [_etcBooks release];
    NSMutableArray *createBooks = [NSMutableArray array];
    NSMutableArray *gospelBooks = [NSMutableArray array];
    NSMutableArray *churchBooks = [NSMutableArray array];
    NSMutableArray *bibleBooks = [NSMutableArray array];
    NSMutableArray *lifestudyBooks = [NSMutableArray array];
    NSMutableArray *recoveryBooks = [NSMutableArray array];
    NSMutableArray *biologyBooks = [NSMutableArray array];
    NSMutableArray *hymnBooks = [NSMutableArray array];
    NSMutableArray *resalesBooks = [NSMutableArray array];
    NSMutableArray *gospelPaperBooks = [NSMutableArray array];
    NSMutableArray *morningBooks = [NSMutableArray array];
    NSMutableArray *etcBooks = [NSMutableArray array];
    for (NSDictionary *bookInfo in self.books) {
        if ([[bookInfo objectForKey:@"section"] isEqualToString:@"1"]) {
            [gospelBooks addObject:bookInfo];
        } else if([[bookInfo objectForKey:@"section"] isEqualToString:@"2"]) {
            [createBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"3"]) {
            [churchBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"4"]) {
            [bibleBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"5"]) {
            [lifestudyBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"6"]) {
            [recoveryBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"7"]) {
            [biologyBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"8"]) {
            [hymnBooks addObject:bookInfo];
        } else  if([[bookInfo objectForKey:@"section"] isEqualToString:@"9"]) {
            [resalesBooks addObject:bookInfo];
        } else if([[bookInfo objectForKey:@"section"] isEqualToString:@"10"]) {
            [gospelPaperBooks addObject:bookInfo];
        } else if([[bookInfo objectForKey:@"section"] isEqualToString:@"11"]) {
            [morningBooks addObject:bookInfo];
        }  else {
            [resalesBooks addObject:bookInfo];
        }
    }
    _createBooks = [createBooks retain];
    _gospelBooks = [gospelBooks retain];
    _churchBooks = [churchBooks retain];
    _bibleBooks = [bibleBooks retain];
    _lifestudyBooks = [lifestudyBooks retain];
    _recoveryBooks = [recoveryBooks retain];
    _biologyBooks = [biologyBooks retain];
    _hymnBooks = [hymnBooks retain];
    _resalesBooks = [resalesBooks retain];
    _gospelPaperBooks = [gospelPaperBooks retain];
    _morningBooks = [morningBooks retain];
    _etcBooks = [etcBooks retain];

}

- (void)deleteBook:(NSString *)bookId {
    NSMutableArray *newBooks = [NSMutableArray arrayWithArray:self.books];
    for (NSDictionary *bookInfo in self.books) {
        if ([[bookInfo objectForKey:@"bookId"] isEqualToString:bookId]) {
            
            [newBooks removeObject:bookInfo];
            
        }
    }
    
    [self removeFiles:bookId];
    [self setBooks:newBooks];;
    NSString *newfileName = [@"bookListInfo.plist" getDocPathWithPList];
    [_books writeToFile:newfileName atomically:NO];
}


- (void)removeFiles:(NSString *)bookId {

    NSFileManager  *manager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    // grab all the files in the documents dir
    NSArray *allFiles = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    // filter the array for only begin with bookId files
    
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@",bookId];
    NSArray *deletingFiles = [allFiles filteredArrayUsingPredicate:fltr];
    
    // use fast enumeration to iterate the array and delete the files
    for (NSString *deleteFile in deletingFiles)
    {
        NSError *error = nil;
        [manager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:deleteFile] error:&error];
        NSAssert(!error, @"Assertion: book file deletion shall never throw an error.");
    }
    
}

#pragma mark - Private methods

- (void)setBooks:(NSArray *)books {
    @synchronized (self) {
        [_books release];
        _books = [books retain];
        //[self refreshBooksByGroup];
    }
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (200 == request.responseStatusCode) {
        NSDictionary *results = [request.responseString JSONValue];
        if (results) {
            NSArray *bookList = [results objectForKey:@"ebookList"];
            if (bookList) {
                [self setBooks:bookList];
                if ([self.delegate respondsToSelector:@selector(bookListDidDownload:)]) {
                    [self.delegate bookListDidDownload:self];
                    return;
                }
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(bookListDidDownloadFail:error:)]) {
        [self.delegate bookListDidDownloadFail:self
                                         error:[NSError errorWithDomain:@"UnknownErrorDomain"
                                                                   code:-999
                                                               userInfo:nil]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if ([self.delegate respondsToSelector:@selector(bookListDidDownloadFail:error:)]) {
        [self.delegate bookListDidDownloadFail:self
                                         error:request.error];
    }
}

#pragma mark - Lifecycle

- (void)dealloc {
    [_books release];
    [_createBooks release];
    [_gospelBooks release];
    [_churchBooks release];
    [_bibleBooks release];
    [_lifestudyBooks release];
    [_recoveryBooks release];
    [_biologyBooks release];
    [_hymnBooks release];
    [_resalesBooks release];
    [_gospelPaperBooks release];
    [_morningBooks release];
    [_etcBooks release];
    
    [super dealloc];
}

@end
