//
//  BookListCell.m
//  TAAZEREADER
//
//  Created by gdx on 12/26/13.
//
//

#import "BookListCell.h"
#import "BookDownloader.h"
#import "BookHelper.h"



@implementation BookListCell

#pragma mark - Properties

- (void)setType:(BookListCellType)type {
    _type = type;
    switch (type) {
        case BookListCellTypeNone:
            self.progressView.hidden = YES;
            self.downloadProgressLabel.hidden = YES;
            self.playButton.hidden = NO;
            self.stopButton.hidden = YES;
            break;
        case BookListCellTypeDownloaded:
            self.progressView.hidden = YES;
            self.downloadProgressLabel.hidden = YES;
            self.playButton.hidden = NO;
            self.stopButton.hidden = YES;
            break;
        case BookListCellTypeDownloading:
            self.progressView.hidden = NO;
            self.downloadProgressLabel.hidden = NO;
            self.playButton.hidden = YES;
            self.stopButton.hidden = NO;
            break;
        case BookListCellTypePaused:
            self.progressView.hidden = NO;
            self.downloadProgressLabel.hidden = NO;
            self.playButton.hidden = NO;
            self.stopButton.hidden = YES;
            break;
        case BookListCellTypeWaitForDownload:
            self.progressView.hidden = YES;
            self.downloadProgressLabel.hidden = NO;
            self.playButton.hidden = NO;
            self.stopButton.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)setProgress:(CGFloat)progress {
    if (progress != _progress) {
        _progress = progress;
        self.progressView.progress = progress;
        if(progress >= 1.0)
            self.downloadProgressLabel.text = @"解壓中";
        else
            self.downloadProgressLabel.text = [NSString stringWithFormat:@"%.1f%%", progress * 100];
    }
}


#pragma mark - Events

- (IBAction)playButtonClicked:(id)sender {
    //johnliu
    /*if(self.type == BookListCellTypeDownloaded)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"書籍已下載" message:@"是否要重新下載"
                               
                                                        delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定",nil] autorelease];
        [alert show];
        
    }else
    {
        [self addDownloadBook];
        
    }*/
    [self openReader:self.bookId];
}

- (void)openReader:(NSString *)bookId
{
    NSDictionary* bookInfo = [NSDictionary dictionaryWithObjectsAndKeys:bookId,@"bookId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"show modal"
                                                        object:self
                                                      userInfo:bookInfo];
}

- (void)addDownloadBook
{
    [[BookDownloader sharedManager] downloadBook:self.bookId
                                         orderId:self.orderId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBookUpdateCellLabel
                                                        object:self.bookId
                                                      userInfo:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
        [self addDownloadBook];
}

- (IBAction)stopButtonClicked:(id)sender {
    [[BookDownloader sharedManager] pauseDownloadBook:self.bookId];
}

#pragma mark - Notifications

- (void)bookDownloadDidStarted:(NSNotification *)notification {
    NSString *bookId = notification.object;
    if ([bookId isEqualToString:self.bookId]) {
        self.type = BookListCellTypeDownloading;
        CGFloat progress = [[BookDownloader sharedManager] downloadProgressByBookId:bookId];
        if (progress < 0) {
            progress = 0;
        }
        self.progress = progress;
    }
}

- (void)bookUpdateCellLabel:(NSNotification *)notification {
    NSString *bookId = notification.object;
    if ([bookId isEqualToString:self.bookId]) {
        self.type = BookListCellTypeWaitForDownload;
        self.progress = 0;
        self.downloadProgressLabel.text = @"等待下載";
    }
}

- (void)bookDownloadDidFailed:(NSNotification *)notification {
    NSString *bookId = notification.object;
    if ([bookId isEqualToString:self.bookId]) {
        self.type = BookListCellTypePaused;
        self.progressView.hidden = YES;
        self.downloadProgressLabel.text = @"下載暫停";
    }
}

- (void)bookDownloadDidFinished:(NSNotification *)notification {
    NSString *bookId = notification.object;
    if ([bookId isEqualToString:self.bookId]) {
        self.type = BookListCellTypeNone;
    }
}

- (void)bookDownloadDidUpdatedProgress:(NSNotification *)notification {
    NSString *bookId = notification.object;
    if ([bookId isEqualToString:self.bookId]) {
        self.type = BookListCellTypeDownloading;
        CGFloat progress = [[BookDownloader sharedManager] downloadProgressByBookId:bookId];
        if (progress < 0) {
            progress = 0;
        }
        self.progress = progress;
    }
}

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected && self.playButton.hidden == NO)
        [self playButtonClicked:self];
    else if(selected && self.stopButton.hidden == NO)
        [self stopButtonClicked:self];
    // Configure the view for the selected state
}

- (void)dealloc {
    [_bookTitleLabel release];
    [_bookDescLabel release];
    [_downloadProgressLabel release];
    [_progressView release];
    [_bookImageView release];
    [_playButton release];
    [_stopButton release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_bookId release];
    [_orderId release];
    
    [super dealloc];
}

@end
