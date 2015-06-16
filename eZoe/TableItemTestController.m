#import "TableItemTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSString* kLoremIpsum = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do\
 eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud\
  exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";
static NSString* versetest1 = @"起初神創造諸天與地";
static NSString* versetest2 = @"基甸說，我主，請容我說，耶和華若與我們同在，我們何至遭遇這一切事呢？我們的列祖向我們敘述的，耶和華一切奇妙的作為在那裏呢？他們說，耶和華豈不是領我們從埃及上來麼？現在祂卻丟棄我們，將我們交在米甸人的手中。";

//Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla\
 pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt\
 mollit anim id est laborum.

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TableItemTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Table Items";
    self.variableHeightRows = YES;

    // Uncomment this to see how the table looks with the grouped style
    //self.tableViewStyle = UITableViewStyleGrouped;

    // Uncomment this to see how the table cells look against a custom background color
    //self.tableView.backgroundColor = [UIColor yellowColor];

    NSString* localImage = @"bundle://tableIcon.png";
    NSString* remoteImage = @"http://profile.ak.fbcdn.net/v223/35/117/q223792_6978.jpg";
    UIImage* defaultPerson = TTIMAGE(@"bundle://defaultPerson.png");

    // This demonstrates how to create a table with standard table "fields".  Many of these
    // fields with URLs that will be visited when the row is selected
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
      @"Links and Buttons",
      [TTTableTextItem itemWithText:@"TTTableTextItem" URL:@"tt://tableItemTest"
                       accessoryURL:@"http://www.google.com"],
      [TTTableLink itemWithText:@"TTTableLink" URL:@"tt://tableItemTest"],
      [TTTableButton itemWithText:@"TTTableButton"],
      [TTTableCaptionItem itemWithText:@"TTTableCaptionItem" caption:@"caption"
                             URL:@"tt://myWebViewController?book=2148"],
      [TTTableSubtitleItem itemWithText:@"TTTableSubtitleItem" subtitle:kLoremIpsum
                            URL:@"tt://tableItemTest"],
      [TTTableMessageItem itemWithTitle:@"Bob Jones" caption:@"TTTableMessageItem"
                          text:kLoremIpsum timestamp:[NSDate date] URL:@"tt://tableItemTest"],
      [TTTableMoreButton itemWithText:@"TTTableMoreButton"],

      @"Images",
      [TTTableImageItem itemWithText:@"TTTableImageItem" imageURL:localImage
                        URL:@"tt://tableItemTest"],
      [TTTableRightImageItem itemWithText:@"TTTableRightImageItem" imageURL:localImage
                        defaultImage:nil imageStyle:TTSTYLE(rounded)
                        URL:@"tt://tableItemTest"],
      [TTTableSubtitleItem itemWithText:@"TTTableSubtitleItem" subtitle:kLoremIpsum
                            imageURL:remoteImage defaultImage:defaultPerson
                            URL:@"tt://tableItemTest" accessoryURL:nil],
      [TTTableMessageItem itemWithTitle:@"Bob Jones" caption:@"TTTableMessageItem"
                          text:kLoremIpsum timestamp:[NSDate date]
                          imageURL:remoteImage URL:@"tt://tableItemTest"],

      @"Static Text",
      [TTTableTextItem itemWithText:@"TTTableTextItem"],
      [TTTableCaptionItem itemWithText:@"TTTableCaptionItem which wraps to several lines"
                            caption:@"Text"],
      [TTTableSubtextItem itemWithText:@"創世紀一章1節"
                                 caption:versetest1],
      [TTTableSubtextItem itemWithText:@"創世紀一章2節"
                                caption:versetest2],
      [TTTableLongTextItem itemWithText:[@"TTTableLongTextItem "
                                         stringByAppendingString:kLoremIpsum]],
      [TTTableGrayTextItem itemWithText:[@"TTTableGrayTextItem "
                                         stringByAppendingString:kLoremIpsum]],
      [TTTableSummaryItem itemWithText:@"TTTableSummaryItem"],

      @"",
      [TTTableActivityItem itemWithText:@"TTTableActivityItem"],

      nil];
  }
  return self;
}
/*- (id)init {
    if ((self = [super init])) {
        self.title = @"Table";
    }
    return self;
}

- (void)loadView
{
    self.title = @"Table Items";
    self.variableHeightRows = YES;
    
    // Uncomment this to see how the table looks with the grouped style
    //self.tableViewStyle = UITableViewStyleGrouped;
    
    // Uncomment this to see how the table cells look against a custom background color
    //self.tableView.backgroundColor = [UIColor yellowColor];
    
    //NSString* localImage = @"bundle://tableIcon.png";
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                       @"Links and Buttons",
                       [TTTableCaptionItem itemWithText:@"TTTableCaptionItem" caption:@"caption"
                                                    URL:@"tt://myWebViewController?book=2148"],
                       nil];
}*/

- (void)dealloc {
  [super dealloc];
}

@end
