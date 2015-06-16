//
//  BookListCell.h
//  TAAZEREADER
//
//  Created by gdx on 12/26/13.
//
//

#import "TUKit.h"

typedef enum {
    BookListCellTypeNone,
    BookListCellTypeDownloading,
    BookListCellTypePaused,
    BookListCellTypeDownloaded,
    BookListCellTypeWaitForDownload
} BookListCellType;


@interface BookListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet TELoadingImageView *bookImageView;
@property (retain, nonatomic) IBOutlet UILabel *bookTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *bookDescLabel;
@property (retain, nonatomic) IBOutlet UILabel *downloadProgressLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UIButton *stopButton;

@property (retain, nonatomic) NSString *bookId;
@property (retain, nonatomic) NSString *orderId;
@property (assign, nonatomic) BookListCellType type;
@property (assign, nonatomic) CGFloat progress;

- (IBAction)playButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;

@end
