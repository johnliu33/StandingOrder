//
//  BookListItem.m
//  TAAZEREADER
//
//  Created by gdx on 12/26/13.
//
//

#import "BookListItem.h"
#import "BookListCell.h"
#import "BookHelper.h"
#import "BookDownloader.h"
#import "Global.h"

@implementation BookListItem

#pragma mark - Lifecycle

- (id)initWithBookInfo:(NSDictionary *)bookInfo {
    if (self = [super init]) {
        self.bookInfo = bookInfo;
    }
    return self;
}

#pragma mark - TETableViewItem

- (UITableViewCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *cellIdentifier = @"BookListCell";
    BookListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier
                                              owner:nil
                                            options:nil] objectAtIndex:0];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:cell];
    }

    NSString *bookId = [self.bookInfo objectForKey:@"bookId"];
    if(cell.bookImageView.image == nil)
    {
        cell.bookImageView.image = [UIImage imageNamed:@"preload.png"];
    }
   
    NSString *orderId = [self.bookInfo objectForKey:@"orderId"];
    cell.bookId = bookId;
    cell.orderId = orderId;
    NSString *imagePath = [[NSString stringWithFormat:@"%@l.png", bookId] getDocPathWithPList];
    //cell.bookImageView.imagePath = imageUrl;
    cell.bookImageView.imagePath = imagePath;
    cell.bookTitleLabel.text = [self.bookInfo objectForKey:@"title"];
    cell.bookDescLabel.text = [self.bookInfo objectForKey:@"bookId"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        cell.bookTitleLabel.font = [UIFont systemFontOfSize:16];
        cell.bookDescLabel.font = [UIFont systemFontOfSize:16];
    }
    
    
    if ([[BookDownloader sharedManager] downloadProgressByBookId:bookId] != -1) {
        cell.type = BookListCellTypePaused;
        cell.downloadProgressLabel.text = @"下載暫停";
        cell.progress = [[BookDownloader sharedManager] downloadProgressByBookId:bookId];
    } else if ([[BookDownloader sharedManager] waitForDownload:bookId]) {
        cell.type = BookListCellTypeWaitForDownload;
        cell.downloadProgressLabel.text = @"等待下載";
    } else if([BookHelper isDownloaded:self.bookInfo]) {
        cell.type = BookListCellTypeDownloaded;
    } else {
        cell.type = BookListCellTypeNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(bookDownloadDidStarted:)
                                                 name:kBookDownloadDidStarted
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(bookDownloadDidFinished:)
                                                 name:kBookDownloadDidFinished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(bookDownloadDidFailed:)
                                                 name:kBookDownloadDidFailed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(bookDownloadDidUpdatedProgress:)
                                                 name:kBookDownloadDidUpdatedProgress
                                               object:nil];
    
    //johnliu
    [[NSNotificationCenter defaultCenter] addObserver:cell
                                             selector:@selector(bookUpdateCellLabel:)
                                                 name:kBookUpdateCellLabel
                                               object:nil];
    
    
    return cell;
}

- (CGFloat)cellHeightWithTableView:(UITableView *)tableView {
    return 90.0f;
}



@end
