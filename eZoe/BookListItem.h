//
//  BookListItem.h
//  TAAZEREADER
//
//  Created by gdx on 12/26/13.
//
//

#import "TUKit.h"

@interface BookListItem : NSObject <TETableViewItem>

@property (nonatomic, retain) NSDictionary *bookInfo;

- (id)initWithBookInfo:(NSDictionary *)bookInfo;

@end
