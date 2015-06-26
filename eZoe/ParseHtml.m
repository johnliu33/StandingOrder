//
//  ParseHtml.m
//  PDFViewerHD
//
//  Created by John Liu on 2010/12/22.
//  Copyright 2010 Samountech.com. All rights reserved.
//

//#import "Three20Style/UIImageAdditions.h"
#import "ParseHtml.h"
#import "Three20UINavigator/TTGlobalNavigatorMetrics.h"
#import "eZoeAppDelegate.h"

@implementation ParseHtml
@synthesize cssString;
@synthesize htmlPages = _htmlPages;
@synthesize htmlPrefacePages = _htmlPrefacePages;
@synthesize aHtml,iHtml,iCHtml,preHtml;
@synthesize bookNumber;
@synthesize bookName;
@synthesize databaseName,databasePath,htmlName,htmlPath,sql;
@synthesize lineCharactersNumber;
@synthesize lineCharactersNumber_L;
@synthesize indexNextStart;
@synthesize pageNumber;
@synthesize bLastPicture;
@synthesize lastPicturePx;
@synthesize bFinalPage;
@synthesize bFinalMark;

@synthesize pixelHeight;
@synthesize pixelWidth;
@synthesize pixelHeight_L;
@synthesize pixelWidth_L;
@synthesize pixelWidthReading;
@synthesize pixelWidthReading_L;
@synthesize pixelWidthHymn;
@synthesize pixelWidthHymn_L;

@synthesize iFontSize;
@synthesize sFontType;
@synthesize sFontType1;
@synthesize sFontColor;
@synthesize sHighLightColor;
@synthesize sNoteLightColor;
@synthesize sNoteDash;
//index
@synthesize array_index_html;
@synthesize array_index_text;
@synthesize array_index_pagenum;
@synthesize array_pre_html;

@synthesize icharEachLineVerses;
@synthesize icharEachLineVerses_L;

@synthesize iLastOrientation;
@synthesize iLastPage;
@synthesize iLastPercent;
//for search
@synthesize array_row_page_index;
//for mark
@synthesize dic_mark_text;
@synthesize _lastSetRowId;

@synthesize iCoverPageCount = _iCoverPageCount;
@synthesize iIndexPageCount = _iIndexPageCount;
@synthesize iPrefacePageCount = _iPrefacePageCount;

+ (ParseHtml *)withBookNumber:(NSString *)bookNumber fontSize:(NSInteger)iFontSize BGType:(NSInteger)iBGType fontType:(NSInteger)iFontType inPutsql:(NSString *)inPutsql  orientation:(NSInteger)orientation
{
    
  	ParseHtml *document = nil;
    
	if (document == nil)
	{
		document = [[[ParseHtml alloc] initWithBookNumber:bookNumber fontSize:iFontSize BGType:iBGType fontType:iFontType] autorelease];
        [document readFromPlistData];
        document.sql = inPutsql;
        
        [document checkAndCreateDatabase];
        //load序言資料
        [document  loadPrefaceFromDb];
        [document loadFromDb];
        [document createDocumentPages:orientation];
	}
    
	return document;
  
}

- (void)createDocumentPages:(NSInteger)orientation
{
    NSInteger _array_count = 0;
    bFinalPage = NO;
    _htmlPages = [NSMutableArray arrayWithCapacity:10];
    _htmlPrefacePages = [NSMutableArray arrayWithCapacity:10];
    
    //排版程式
	do
	{
     
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [self convertToHtml:_array_count isPreFace:NO isLandscape:NO];
            else                //橫向
                bFinalPage= [self convertToHtml:_array_count isPreFace:NO isLandscape:YES];
        }else
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [self convertToHtml_iphone:_array_count isPreFace:NO isLandscape:NO];
            else                //橫向
                bFinalPage = [self convertToHtml_iphone:_array_count isPreFace:NO isLandscape:YES];
            
        }
        
        NSString *passString = [NSString stringWithString:aHtml];
        [_htmlPages addObject:passString];
    
        _array_count++;
        
	}while (!bFinalPage);
    
    [_htmlPages removeLastObject];
    
    //_iContentPageCount = _array_count;
    bFinalPage = NO;
    
    //產生search page index dictionary
    eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.searchPageDictionary = array_row_page_index;
    
    //產生preface頁面
    _array_count = 0;
    bFinalMark = NO;
    //mem
    do {
        //排序言的內容
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [self convertToHtml:_array_count isPreFace:YES isLandscape:NO];
            else
                bFinalPage = [self convertToHtml:_array_count isPreFace:YES isLandscape:YES];
        }else
        {
            if(!TTIsOrienLandscape()) //直向
                bFinalPage = [self convertToHtml_iphone:_array_count isPreFace:YES isLandscape:NO];
            else
                bFinalPage = [self convertToHtml_iphone:_array_count isPreFace:YES isLandscape:YES];
            
        }
        if(!bFinalPage)
        {
            
            NSString *passString = [NSString stringWithString:aHtml];
            [_htmlPrefacePages addObject:passString];
            
            _array_count++;
        }
    } while (!bFinalPage);
    
    //計數序言頁數
    _iPrefacePageCount = _array_count;
    //產生目錄
	[self loadBookIndex_CoverPage];
    if(orientation == 0)//直向
        [self createIndexPage_:NO];
    else
        [self createIndexPage_:YES];
    //
    
    appDelegate.arrayIndexText =array_index_text;
    appDelegate.arrayIndexPagenum = array_index_pagenum;
    //NSLog(@"test:%@",[appDelegate.arrayIndexPagenum objectAtIndex:0]);
    //計數目錄頁數
    _iIndexPageCount = [self.array_index_html count];
    
    //產生內外封
    if(!TTIsOrienLandscape())//直向
    {
        [self createCoverPage_:NO];
        [self createInnerCoverPage_:NO];
        //計數封面頁數
        _iCoverPageCount = 2;
        
    }
    else
    {
        [self createCoverPage_:YES];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            _iCoverPageCount = 1;
        }else
        {
            [self createInnerCoverPage_:YES];
            _iCoverPageCount = 2;
        }
    }
    
    
    //insert index page in front of main page array
    int _iCount = [self.array_index_html count];
    for (int i = _iCount-1; i >= 0; i--)
    {
        NSMutableString *_s = [self.array_index_html objectAtIndex:i];
        [_htmlPages insertObject:_s atIndex:0];
    }
    //insert preface pages in front of the index page
    _iCount = [_htmlPrefacePages count];
    for(int i = _iCount-1; i >=0; i--)
    {
        NSMutableString *_s = [_htmlPrefacePages objectAtIndex:i];
        [_htmlPages insertObject:_s atIndex:0];
    }
    if(!TTIsOrienLandscape() || UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        //inner cover page內封
        NSMutableString *_ic = [NSMutableString stringWithString:iCHtml];
        [_htmlPages insertObject:_ic atIndex:0];//mem
    }
    //cover page
    NSMutableString *_c = [NSMutableString stringWithString:iHtml];
    [_htmlPages insertObject:_c atIndex:0];//mem
    
    
}

- (id)initWithBookNumber:(NSString *)_bookNumber fontSize:(NSInteger)_iFontSize BGType:(NSInteger)_iBGType fontType:(NSInteger)_iFontType;
{

    id object = nil;
    
	if((self = [super init]))
	{
		self.bookNumber = _bookNumber;
		sRemainText = @"";
		pageNumber = @"1";
		
		indexNextStart = (NSInteger)0;	
		
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            lineCharactersNumber = (NSInteger)23;
            lineCharactersNumber_L = (NSInteger)16;
            pixelHeight = (NSInteger)842;
            pixelWidth = (NSInteger)600;
            
            pixelHeight_L = (NSInteger)1120;
            pixelWidth_L = (NSInteger)455;
            
            pixelWidthReading = (NSInteger)510;
            pixelWidthReading_L = (NSInteger)365;
            
            pixelWidthHymn = (NSInteger)(pixelWidth-36*2);
            pixelWidthHymn_L = (NSInteger)(pixelWidth_L-36*2);
            
            icharEachLineVerses = 22;
            icharEachLineVerses_L = 17;
        }else
        {
            lineCharactersNumber = (NSInteger)17;
            lineCharactersNumber_L = (NSInteger)27;
            
            int iVersionAdjust = 0;
                       
            if(_iFontSize == 14)
                pixelHeight = (NSInteger)395;
            else
            {
                if(IS_IPHONE_5)
                    pixelHeight = (NSInteger)508- iVersionAdjust;
                else
                    pixelHeight = (NSInteger)420-iVersionAdjust;
                //pixelHeight = (NSInteger)420-iVersionAdjust;
            }
            pixelWidth = (NSInteger)280;
            
            
            if(_iFontSize == 14)
                pixelHeight_L = (NSInteger)250;
            else
                pixelHeight_L = (NSInteger)260;
            pixelWidth_L = (NSInteger)440;
            
            pixelWidthReading = (NSInteger)260;
            pixelWidthReading_L = (NSInteger)420;
            
            pixelWidthHymn = (NSInteger)(pixelWidth-5*2);
            pixelWidthHymn_L = (NSInteger)(pixelWidth_L-5*2);
            
            icharEachLineVerses = 14;
            icharEachLineVerses_L = 17;

        }
        
        iFontSize = _iFontSize;//26
        
        if(_iBGType < 3)
        {
            sFontColor = @"rgb(96,76,63)";
            sHighLightColor = @"rgb(255,255,0)";
            sNoteLightColor = @"rgb(245,197,181)";
            sNoteDash = @"#FF0000";
        }
        else
        {
            sFontColor = @"rgb(219,219,219)";
            sHighLightColor = @"rgb(102,102,102)";
            sNoteLightColor = @"rgb(36,95,42)";
            sNoteDash = @"#C4A8FF";
        }
        
        if(_iFontType == 0)
        {
            sFontType = @"STKaiti";//
            sFontType1 = @"Microsoft JhengHei";
        }
        else
        {
            sFontType = @"Microsoft JhengHei";
            sFontType1 = @"STKaiti";
        }
        
        
        _lineCharacterBias = 0;
		
		
		
		array_type = [NSMutableArray arrayWithCapacity:10];
		array_text = [NSMutableArray arrayWithCapacity:10];
        array_chap = [NSMutableArray arrayWithCapacity:10];
        array_rowid = [NSMutableArray arrayWithCapacity:10];
        
        array_row_page_index = [NSMutableDictionary dictionaryWithCapacity:10];
        
        array_pre_type = [NSMutableArray arrayWithCapacity:10];
		array_pre_text = [NSMutableArray arrayWithCapacity:10];
        array_pre_chap = [NSMutableArray arrayWithCapacity:10];
        array_pre_rowid = [NSMutableArray arrayWithCapacity:10];
        array_pre_html = [NSMutableArray arrayWithCapacity:10];
        
        //index page of book
        array_index_chap = [NSMutableArray arrayWithCapacity:10];
        array_index_type = [NSMutableArray arrayWithCapacity:10];
        array_index_text = [NSMutableArray arrayWithCapacity:10];
        array_index_pagenum = [NSMutableArray arrayWithCapacity:10];
        array_index_html = [NSMutableArray arrayWithCapacity:10];
        
		databaseName = [NSString stringWithFormat:@"%@_1.db",self.bookNumber];
		
        object = self;
	}
	
	return object;
}

- (void)readFromPlistData
{
		
	NSString *plistName = [NSString stringWithFormat:@"%@.plist",self.bookNumber];
	
	//NSString *myPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:plistName];
	NSString *myPath = [plistName getDocPathWithPList];
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if(![fileManager fileExistsAtPath:myPath])
	{	
	
		NSString *myPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:plistName];
		
		[fileManager copyItemAtPath:myPathFromApp toPath:myPath error:nil];
		
		
	}
	//[fileManager release];
    
	NSMutableDictionary *bookSetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
	self.bookName = [bookSetting objectForKey:@"bookName"];
    self.iLastOrientation = [[bookSetting objectForKey:@"lastOrientation"] integerValue];
    self.iLastPage = [[bookSetting objectForKey:@"lastPageNum"] integerValue];
    self.iLastPercent = [[bookSetting objectForKey:@"lastPagePercent"] integerValue];
	//int i = [[mysetting objectForKey:@"playMode"]
}

- (void)checkAndCreateDatabase
{
	BOOL success;


	//databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:databaseName];
    databasePath = [databaseName getDocPathWithPList];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:databasePath];
	
	if(success)
    {
        //[fileManager release];
        return;
    }
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	//[fileManager release];
}

- (void)copyFileFromResource:(NSString *)fileName
{
	BOOL success;
	
	
	//NSString *desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSString *desPath = [fileName getDocPathWithPList];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:desPath];
	
	if(success) return;
	
	NSString *souPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
	
	[fileManager copyItemAtPath:souPath toPath:desPath error:nil];
	
	//[fileManager release];
	
}
- (void)loadPrefaceFromDb
{
	sqlite3 *database;
	NSString *sqlIndex = @"select  type,text,rowid from Preface;";
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		
		const char *sqlStatement = [sqlIndex UTF8String]; 
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *atype = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *atext = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                NSString *arowid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                NSString *achap_ = [[NSString alloc] initWithString:@"000"];
                
				[array_pre_type addObject:atype];
				[array_pre_text addObject:atext];
                NSString *_preRowID = [NSString stringWithFormat:@"%d",990000 + [arowid integerValue]];
                [array_pre_rowid addObject:_preRowID];
                [array_pre_chap addObject:achap_];
                [achap_ release];

			}
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
    sqlite3_close(database);
}
- (void)loadBookIndex_CoverPage
{
	sqlite3 *database;
	NSString *sqlIndex = @"select  * from Content where type = \"0\" or type = \"z\";";
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		
		const char *sqlStatement = [sqlIndex UTF8String]; 
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *achap= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *atype = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *atext = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                
				
				[array_index_chap addObject:achap];
				[array_index_type addObject:atype];
				[array_index_text addObject:atext];
				
			}
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
    sqlite3_close(database);
    
}

- (void)loadFromDb
{
	sqlite3 *database;
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) 
	{
		
		const char *sqlStatement = [sql UTF8String]; 
		
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *atype= [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *atext = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *achap = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                NSString *arowid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];

				
				[array_type addObject:atype];
				[array_text addObject:atext];
				[array_chap addObject:achap];
                [array_rowid addObject:arowid];
				
                
			}
		}
		
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	//if([[array_type objectAtIndex:0] isEqualToString:@"b"])
	//	self.bookName = [array_text objectAtIndex:0];
	sqlite3_close(database);
    
}

- (int)occurrencesOfString:(NSString *)myString findString:(NSString *)findString
{
    return [[myString componentsSeparatedByString:findString] count]-1;
}

- (NSInteger)countHalfNumber:(NSString *)text
{
	NSInteger iCount=0;
	NSArray *arrayOfChar;
	arrayOfChar = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"8",@"9"
											,@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v"
											,@"w",@"x",@"y",@"z",nil];
	for(NSString *sF in arrayOfChar)
	{
		iCount += [self occurrencesOfString:text findString:sF];
		
	}
	return iCount;
}

- (NSMutableString *)convertHalfNumberToFull:(NSString *)text
{
	NSMutableString *tmp = [NSMutableString stringWithString:text];
	/*tmp = [[tmp stringByReplacingOccurrencesOfString:@"1" withString:@"１"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"2" withString:@"２"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"3" withString:@"３"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"4" withString:@"４"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"5" withString:@"５"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"6" withString:@"６"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"7" withString:@"７"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"8" withString:@"８"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"9" withString:@"９"] mutableCopy];
	tmp = [[tmp stringByReplacingOccurrencesOfString:@"0" withString:@"０"] mutableCopy];
	*/ 
	return tmp;
}
- (void)createCoverPage_:(BOOL)bLandscape
{
    //[iHtml release];
    //iHtml = [[NSMutableString alloc] initWithString:@""];
    NSMutableString  *coverHtml = [NSMutableString stringWithString:@""];
    NSString *aEnd;
    NSString *aTop;
    NSInteger _pixelWidth;
    NSInteger _pixelHeight;
    NSInteger _imgHeight;
    NSInteger _imgResolution;
    if(bLandscape)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            coverHtml = [self loadCSS_L];
            aTop = [[NSString alloc] initWithFormat:@"<div class=\"headerL\"><p class=\"top\">%@</p></div>\n<div class=\"headerR\"><p class=\"top\">%@</p></div>\n<div class=\"main\">\n",self.bookName,self.bookName];
            
            aEnd = @"</div>\n</body>\n</html>\n";
            
        }
        else
        {
            /*iHtml = [self loadCSS_L_iPhone:iHtml];
            aTop = [[NSString alloc] initWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];
            aEnd = @"</div>\n</div>\n</body>\n</html>\n";*/
            NSLog(@"iPhone is not support landscape mode! must something wrong!");
        }
        
        _pixelWidth = pixelWidth_L;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            _imgResolution = 350;
        else
        {
            _imgResolution = 440;
            _imgHeight = 240;
        }
        
    }else
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            coverHtml = [self loadCSS];
        else
            coverHtml = [self loadCSS_iPhone];
        aTop = [[NSString alloc] initWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];
        aEnd = @"</div>\n</div>\n</body>\n</html>\n";//
        _pixelWidth = pixelWidth;
        _pixelHeight = pixelHeight;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            _imgResolution = 550;
        else
        {
            _imgResolution = 280;
            _imgHeight = 400;
        }
    }
    
    NSString *sCoverImgName;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        sCoverImgName = [NSString stringWithFormat:@"%@.jpg",bookNumber];
    else
    {
        NSString *_scName = [NSString stringWithFormat:@"%@.jpg",bookNumber];
        sCoverImgName = [NSString stringWithFormat:@"%@_scover.png",bookNumber];
        //NSString *desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:sCoverImgName];
        NSString *desPath = [sCoverImgName getDocPathWithPList];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:desPath])
        {
            UIImage *image;
            if([bookNumber isEqualToString:@"8887"])
                image = [UIImage imageNamed:_scName];
            else
                image = [UIImage imageWithContentsOfFile:[_scName getDocPathWithPList]];//[UIImage i_scName];
            CGSize newSize = CGSizeMake(320, 480);
            UIGraphicsBeginImageContext(newSize);
            [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(result)];
            [imageData writeToFile:[sCoverImgName getDocPathWithPList] atomically:YES];
        }
    }
   


    [coverHtml appendString:aTop];
    
    [aTop release];
    
    NSString *sFormat = [[NSString alloc] initWithString:@"<p class=\"Image\"><img src=\"file://"];
    [self copyFileFromResource:sCoverImgName];
    //NSString *_aImgPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:sCoverImgName];
    NSString *_aImgPath = [sCoverImgName getDocPathWithPList];
    UIImage *_aImg = [UIImage imageWithContentsOfFile:_aImgPath];
    NSString *aTmp;
    CGSize _aS = _aImg.size;
    //在改成下載購買時需更動
    //NSString *desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:sCoverImgName];
    NSString *desPath = [sCoverImgName getDocPathWithPList];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)//iphone
    {
        if(_aS.width > _pixelWidth)
            aTmp = [[NSString alloc] initWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
        else
            aTmp = [[NSString alloc] initWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
    }else
    {
            aTmp = [[NSString alloc] initWithFormat:@"%@%@\" height=\"%d\" />%@",sFormat,desPath,_imgHeight,@"</p>\n"];
            
    }
    [coverHtml appendString:aTmp];
    if(bLandscape)//橫向時順便將內頁一起產生
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            NSString *sFormat = [NSString stringWithFormat:@"<p class=\"InnerCover\">%@</p>\n",self.bookName];    
            [coverHtml appendString:sFormat];
        }
    }
    [coverHtml appendString:aEnd];
    iHtml = [coverHtml copy];
    [aTmp release];
    [sFormat release];
    
}
- (void)createInnerCoverPage_:(BOOL)bLandscape
{
    //[iCHtml release];
    //iCHtml = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *innerCoverHtml = [NSMutableString stringWithString:@""];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        innerCoverHtml = [self loadCSS];
    else
    {
        innerCoverHtml = [self loadCSS_iPhone];
    }
    
    NSString *aEnd = @"</div>\n</div>\n</body>\n</html>\n";//</div>\n</body>\n</html>\n

    NSString *aTop = [NSString stringWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];

    [innerCoverHtml appendString:aTop];
    NSString *sFormat = [NSString stringWithFormat:@"<p class=\"InnerCover\">%@</p>\n",self.bookName];
    [innerCoverHtml appendString:sFormat];
    [innerCoverHtml appendString:aEnd];
    
    iCHtml = [innerCoverHtml copy];
  

}

- (void)createIndexPage_:(BOOL)bLandscape
{
    
    
    NSMutableString *frontHtml = [NSMutableString stringWithString:@""];
    NSMutableString *changedHtml = [NSMutableString stringWithString:@""];
    
    NSString *aEnd;
    NSString *aTop;
    //int iCharEachLine;
    NSInteger _pixelHeight;
    NSInteger _pixelWidth;

    
    if(bLandscape)
    {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {    
            frontHtml = [self loadCSS_L];
            aTop = [NSString stringWithFormat:@"<div class=\"headerL\"><p class=\"top\">%@</p></div>\n<div class=\"headerR\"><p class=\"top\">%@</p></div>\n<div class=\"main\">\n",self.bookName,self.bookName];
            aEnd = @"</div>\n</body>\n</html>\n";
        }
        else
        {
            /*frontHtml = [self loadCSS_L_iPhone:frontHtml];
            aTop = [NSString stringWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];
            
            aEnd = @"</div>\n</div>\n</body>\n</html>\n";
             */
            NSLog(@"iPhone doesn't support landscape mode. Must something wrong!");
        }
        
        
        
        
        
        //iCharEachLine = (NSInteger)((float)(pixelWidth_L)/(float)iFontSize)-_lineCharacterBias;//(int)lineCharactersNumber_L;
        
        _pixelHeight = pixelHeight_L;
        _pixelWidth = pixelWidth_L;

    }
    else
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            frontHtml = [self loadCSS];
        else
            frontHtml = [self loadCSS_iPhone];
        
        aTop = [NSString stringWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];
        
        aEnd = @"</div>\n</div>\n</body>\n</html>\n";//</div>\n</body>\n</html>\n
        
        //iCharEachLine = (NSInteger)((float)(pixelWidth)/(float)iFontSize)-_lineCharacterBias;//(int)lineCharactersNumber;
        
        _pixelHeight = pixelHeight;
        _pixelWidth = pixelWidth;

    }
    
    
    // NSInteger iLine = 0;
    NSInteger iPxTotal = 0;
    NSInteger iSize = 0;
    
    

    NSString *aIndexTitle = [NSString stringWithFormat:@"<p class = \"indexTitle\">%@</p>\n",@"目錄"];
	[frontHtml appendString:aTop];
    [frontHtml appendString:aIndexTitle];
    int iIndexCount = [array_index_text count];
    //NSLog(@"array_index_pagenum count:%d",[array_index_pagenum count]);
    
    for(int i = 0; i < iIndexCount; i++)
    {
        
        NSString *_text = [array_index_text objectAtIndex:i];
        NSString *_type = [array_index_type objectAtIndex:i];
        iSize = [_text length];
        
        NSString *_pagenum = [array_index_pagenum objectAtIndex:i]; //test the format of index
        NSString *sFormat;
        //NSLog(@"_text:%@ _type:%@ _pagenum:%@",_text,_type,_pagenum);
        if([_type isEqualToString:@"z"])
        {
            int iPxSingle = [self TagHeight:iSize fontSize:1.2 lineHeight:1.4 padding:1.0 pageWidth:_pixelWidth lineBias:0];
            iPxTotal += iPxSingle;
            sFormat = [NSString stringWithFormat:@"<p class=\"indexBook\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];

        }else
        {
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.4 padding:1.0 pageWidth:_pixelWidth lineBias:0];
            iPxTotal += iPxSingle;
            sFormat = [NSString stringWithFormat:@"<p class=\"index\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
        }
        
        //NSString *sFormat = [NSString stringWithString:@"<p class=\"index\">"];
        //iLine +=  kCacLine;
        //int iL =  kCacLine;
        //int iPxSingle = iL*26*1.4+25;
        //iPxTotal += iPxSingle;
        //NSLog(@"[index]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
        
        NSString *sUrlFormat = @"<a style=\"text-decoration : underline;\"";//href=\"page=
        NSString *sUrlEnd1 = @" onclick = \"processPage(";//\"
        NSString *sUrlEnd2 = @")\"/>";
        NSString *aTmp;
        
        if([_type isEqualToString:@"z"])
        {
            //aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_text,@"</p>\n"];
            aTmp = [NSString stringWithFormat:@"%@%@%@%i%@%@%@",sFormat,sUrlFormat,sUrlEnd1,[_pagenum intValue],sUrlEnd2,_text,@"</a></p>\n"];
        }
        else
            aTmp = [NSString stringWithFormat:@"%@%@%@%i%@%@%@",sFormat,sUrlFormat,sUrlEnd1,[_pagenum intValue],sUrlEnd2,_text,@"</a></p>\n"];

        //NSLog(@"aTmp:%@",aTmp);
        [changedHtml appendString:aTmp];
        
        int _iGap;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            _iGap = 25+53;
        }else
        {
            _iGap = 15+43;
        }
        
        if(iPxTotal+_iGap > _pixelHeight) //53是標題的高度
        {
            [changedHtml appendString:aEnd];
            
            NSMutableString *myHtml = [NSMutableString stringWithString:@""];
            [myHtml appendString:frontHtml];
            [myHtml appendString:changedHtml];
            
            [array_index_html addObject:myHtml];
            //[myHtml release];
            
            iPxTotal = 0;
            //iSize = 0;
            [changedHtml setString:@""];
            //return;
            
        }
    }
    if([changedHtml length] > 0)
    {
        [changedHtml appendString:aEnd];
        NSMutableString *Html = [NSMutableString stringWithString:frontHtml];
        
        [Html appendString:changedHtml];
        
        [array_index_html addObject:Html];
        //[Html release];
    }
    //[frontHtml release];    
    //[changedHtml release];
}

- (NSInteger)checkFontSizeAvalible:(NSInteger)orignFontSize
{
    NSArray *_a = [NSArray arrayWithObjects:[NSNumber numberWithInt:30],[NSNumber numberWithInt:31],[NSNumber numberWithInt:36],[NSNumber numberWithInt:38],[NSNumber numberWithInt:40],[NSNumber numberWithInt:42],[NSNumber numberWithInt:44],[NSNumber numberWithInt:46],[NSNumber numberWithInt:47],[NSNumber numberWithInt:49],nil];
    NSNumber *f = [NSNumber numberWithInt:orignFontSize];
    while ([_a containsObject:f]) {
        orignFontSize+=1;
        f = [NSNumber numberWithInt:orignFontSize];
    }
    return orignFontSize;
}

- (NSMutableString *)loadCSS_L
{
    
    NSMutableString *_cssHtml = [NSMutableString stringWithString:@"<!DOCTYPE html><html lang=\"en\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"stylesheet\" type=\"text/css\">\n<title></title>\n<script src=\"./TGJSBridge.js\"></script><script src=\"./jquery.js\"></script>"];
    
	NSString *aStyleBegin = [NSString stringWithFormat:@"<style>\n.wrap {\nfont-family:%@;\ncolor:%@;\nposition:absolute;\nleft: 0px;\ntop: 0px;\nwidth:1024px;\nheight:768px;\nmargin:0 auto;\nbackground:transparent;\n}\n.top {\nfont-size: 16px;\ntext-align: center;\nmargin-bottom: 50px;\n}\n",sFontType,sFontColor];
    
    NSString *aStyleHeader = @".headerL {\nwidth:462px;\nfloat:left;\nheight:57px;\nmargin-left:10px;\npadding:0px 20px;\nbackground:transparent;\ntext-align:center;\n}\n.headerR {\nwidth:462px;\nfloat:right;\nheight:57px;\nmargin-right:10px;\npadding:0px 20px;\nbackground:transparent;\ntext-align:center;\n}\n";
    
    NSString *aStyleFooter = @".footerL {\nwidth:462px;\nheight:47px;\nfloat:left;\nmargin-left:10px;\npadding:0px 20px;\ntext-align:center;\nbackground:transparent;\n}\n.footerR {\nwidth:462px;\nheight:47px;\nfloat:right;\nmargin-left:10px;\npadding:0px 20px;\ntext-align:center;\nbackground:transparent;\n}\n";
    
    NSString *aStyleMain;
    
    if(iFontSize == 18 || iFontSize == 22  || iFontSize == 30)
    {
        aStyleMain = @".main {\nletter-spacing:-1px;\nfloat:left;\nwidth:950px;\nheight:590px;\npadding-left:37px;\npadding-right:37px;\npadding-top:37px;\npadding-bottom:0px;\nmargin-bottom:37px;\nbackground:transparent;\ntext-align: justify;\n-webkit-column-count: 2;\n-webkit-column-gap: 40px;\n}\n";
    }else
    {
      aStyleMain = @".main {\nfloat:left;\nwidth:950px;\nheight:590px;\npadding-left:37px;\npadding-right:37px;\npadding-top:37px;\npadding-bottom:0px;\nmargin-bottom:37px;\nbackground:transparent;\ntext-align: justify;\n-webkit-column-count: 2;\n-webkit-column-gap: 40px;\n}\n";
    }
        
	//NSString *aStyleP = [NSString stringWithString:@"p{\npadding: 0;\nmargin-top: 25px;\nmargin-bottom: 25px;\n}\n"];
    NSString *aStyleHL = [NSString stringWithFormat:@"\n.hl	{\nbackground:%@ ;\ncolor:%@;\n}\n",sHighLightColor,sFontColor];//#ffff00
    NSString *aStyleHLNote = [NSString stringWithFormat:@"\n.hlnote	{\nbackground:%@ ;\ncolor:%@;\ntext-decoration: none;\nborder-bottom: 2px dashed %@}\n",sNoteLightColor,sFontColor,sNoteDash];//#ffff00
	NSString *aStyleBookTitle = [NSString stringWithFormat:@".BookTitle {\nfont-size: %dpx;\ntext-align: center;\nfont-weight: normal;\nmargin: 0px;\nline-height: 1.2em;\npadding-top:0px;\npadding-bottom:0.7em;\n}\n",(NSInteger)((float)iFontSize*1.4)];
	NSString *aStyleChapterTitle = [NSString stringWithFormat:@".ChapterTitle {\nfont-size: %dpx;\nline-height: 1.1em;\ntext-align: center;\npadding-top:0px;\npadding-bottom:0.7em;\nmargin:0px;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.2)]];
    
	NSString *aStyleHeading1 = [NSString stringWithFormat:@".Heading1 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.2)]];
	NSString *aStyleHeading2 =  [NSString stringWithFormat:@".Heading2 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.16)]];
	NSString *aStyleHeading3 = [NSString stringWithFormat:@".Heading3,.Heading4,.Heading5,.Heading6,.Heading7,.Heading8,.Heading9 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.12)]];
    
	NSString *aStyleOutline1 = [NSString stringWithFormat:@".Outline1 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline2 = [NSString stringWithFormat:@".Outline2 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline3 = [NSString stringWithFormat:@".Outline3 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline4 = [NSString stringWithFormat:@".Outline4 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];		
	NSString *aStyleOutline5 = [NSString stringWithFormat:@".Outline5,.Outline6,.Outline7,.Outline8,.Outline9 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 3em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	

	NSString *aStyleContent1 = [NSString stringWithFormat:@".content\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align:justify;\nword-break:break-all;\nword-warp: break-word;\n}\n",iFontSize];
	NSString *aStyleContent2 = [NSString stringWithFormat:@".content2\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;\n}\n",iFontSize];
    
	NSString *aStyleVerse1 = [NSString stringWithFormat:@".Verses1 {\nfont-size:%dpx;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left: 55px;\npadding-right: 35px;\nline-height: 1.4;\ntext-indent: 1em;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleReading =  [NSString stringWithFormat:@".Reading {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left:55px;\npadding-right:35px;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
    
	NSString *aStyleHymns1_2= [NSString stringWithFormat:@".Hymns1,.Hymns2 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 36px;\npadding-right: 36px;\npadding-bottom: 0px;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleHymns3= [NSString stringWithFormat:@".Hymns3 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 36px;\npadding-right: 36px;\npadding-bottom: 1em;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];		
	NSString *aStyleNote = [NSString stringWithFormat:@".Note {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: right;\n}\n",(NSInteger)((float)iFontSize*0.85)];
    NSString *aStyleHeadNote = [NSString stringWithFormat:@".HeadNote {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: left;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];
    NSString *aStyleHeadNote2 = [NSString stringWithFormat:@".HeadNote2 {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: center;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleImage = @".Image {\npadding: 0;\nmargin-top: 25px;\nmargin-bottom: 25px;\ntext-align: center;\n}\n";
    //cover page picture
    NSString *aStyleCoverImage = @".CoverImage {\npadding: 0;\nmargin-top: 25x;\nmargin-bottom: 25px;\ntext-align: center;\n}\n";
    //inner page title
    NSString *aStyleIC = [NSString stringWithFormat:@".InnerCover{\nfont-size: %dpx;\nfont-weight: normal;\nline-height:1.0;\ntext-align: center;\nmargin-top:260px;\n}\n",(NSInteger)((float)iFontSize*1.4)];
    //Index page title
    NSString *aStyleIndexTitle = [NSString stringWithFormat:@".indexTitle {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\ntext-align: center;\n}",(NSInteger)((float)iFontSize*1.08)];
    //index page words
    NSString *aStyleIndex = [NSString stringWithFormat:@".index {\nfont-size: %dpx;\nline-height: 1.4;\ntext-align: left;\n}",(NSInteger)((float)iFontSize*1.0)];    
    NSString *aStyleIndexBook = [NSString stringWithFormat:@".indexBook {\nfont-size: %dpx;\nfont-weight:normal;\nline-height: 1.4;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.2)];
	NSString *aStylePageNumber = @".PageNumber {\nfont-size: 16px;\ntext-align: center;\nmargin: 0px;\npadding: 0px;\nborder: 0px;\n}\n";
    //for link color
    NSString *aStyleLink = [NSString stringWithFormat:@"<!--a:link {\ncolor:%@;\n; text-decoration: underline;}\na:active {color: %@; text-decoration: underline; }\na:visited {color: %@; text-decoration: underline; }\na:hover{color: %@; text-decoration: underline; }\n-->\n",sFontColor,sFontColor,sFontColor,sFontColor];
	NSString *aStyleEnd = @"</style>\n<script src=\"./selfjs.js\"></script>\n</head>\n<body>\n<div class=\"wrap\">\n";
	
    [_cssHtml appendString:aStyleBegin];
	//[_cssHtml appendString:aStyleP];
    [_cssHtml appendString:aStyleHL];
    [_cssHtml appendString:aStyleHLNote];    
	[_cssHtml appendString:aStyleBookTitle];
	[_cssHtml appendString:aStyleChapterTitle];
	[_cssHtml appendString:aStyleHeading1];
	[_cssHtml appendString:aStyleHeading2];
	[_cssHtml appendString:aStyleHeading3];
	[_cssHtml appendString:aStyleOutline1];
	[_cssHtml appendString:aStyleOutline2];
	[_cssHtml appendString:aStyleOutline3];
	[_cssHtml appendString:aStyleOutline4];
	[_cssHtml appendString:aStyleOutline5];	
    
	[_cssHtml appendString:aStyleContent1];
	[_cssHtml appendString:aStyleContent2];
	[_cssHtml appendString:aStyleVerse1];
	[_cssHtml appendString:aStyleReading];	
	[_cssHtml appendString:aStyleHymns1_2];
	[_cssHtml appendString:aStyleHymns3];	
	[_cssHtml appendString:aStyleNote];
    [_cssHtml appendString:aStyleHeadNote];
    [_cssHtml appendString:aStyleHeadNote2];
	[_cssHtml appendString:aStyleImage];
    [_cssHtml appendString:aStyleCoverImage];
    [_cssHtml appendString:aStyleIC];
    [_cssHtml appendString:aStyleIndexTitle];
	[_cssHtml appendString:aStyleIndex];
    [_cssHtml appendString:aStyleIndexBook];
    [_cssHtml appendString:aStyleLink];
	[_cssHtml appendString:aStylePageNumber];
    [_cssHtml appendString:aStyleMain];
    [_cssHtml appendString:aStyleHeader];
    [_cssHtml appendString:aStyleFooter];
	[_cssHtml appendString:aStyleEnd];

    
    return _cssHtml;
}
/*
- (NSMutableString *)loadCSS_L_iPhone:(NSMutableString *)cssHtml
{
	NSMutableString *_cssHtml = [NSMutableString stringWithString:@"<!DOCTYPE html><html lang=\"en\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"stylesheet\" type=\"text/css\">\n<title></title>\n<script src=\"./TGJSBridge.js\"></script><script src=\"./jquery.js\"></script>"];
	NSString *aStyleBegin = @"<style>\n.top,.PageNumber\n{\nfont-size: 12px;\ntext-align: center;\nmargin:0px;\npadding:0px;\nborder: 0px;\n}\n";//iphone font-size
    
	NSString *aStyleBookTitle = [NSString stringWithFormat:@".BookTitle {\nfont-size: %dpx;\ntext-align: center;\nfont-weight: normal;\nmargin: 0px;\nline-height: 1.2em;\npadding-top:0px;\npadding-bottom:0.7em;\n}\n",(NSInteger)((float)iFontSize*1.4)];
	NSString *aStyleChapterTitle = [NSString stringWithFormat:@".ChapterTitle {\nfont-size: %dpx;\nline-height: 1.1em;\ntext-align: center;\npadding-top:0px;\npadding-bottom:0.7em;\nmargin:0px;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.25)]];
	NSString *aStyleHeading1 = [NSString stringWithFormat:@".Heading1 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.2)]];
	NSString *aStyleHeading2 = [NSString stringWithFormat:@".Heading2 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.16)]];
	NSString *aStyleHeading3 = [NSString stringWithFormat:@".Heading3,.Heading4,.Heading5,.Heading6,.Heading7,.Heading8,.Heading9 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.12)]];
	NSString *aStyleOutline1 = [NSString stringWithFormat:@".Outline1 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline2 = [NSString stringWithFormat:@".Outline2 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline3 = [NSString stringWithFormat:@".Outline3 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline4 = [NSString stringWithFormat:@".Outline4 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleOutline5 = [NSString stringWithFormat:@".Outline5,.Outline6,.Outline7,.Outline8,.Outline9 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 3em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleContent1 = [NSString stringWithFormat:@".content\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;}\n",iFontSize];
	NSString *aStyleContent2 = [NSString stringWithFormat:@".content2\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;}\n",iFontSize];
	NSString *aStyleVerse1 = [NSString stringWithFormat:@".Verses1 {\nfont-size:%dpx;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left: 55px;\npadding-right: 35px;\nline-height: 1.4;\ntext-indent: 1em;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleReading = [NSString stringWithFormat:@".Reading {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left:10px;\npadding-right:10px;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleHymns1_2= [NSString stringWithFormat:@".Hymns1,.Hymns2 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 5px;\npadding-right: 5px;\npadding-bottom: 0px;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleHymns3= [NSString stringWithFormat:@".Hymns3 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 5px;\npadding-right: 5px;\npadding-bottom: 1em;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleNote = [NSString stringWithFormat:@".Note {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: right;\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleImage = @".Image {\nmargin: 0;\npadding-top: 10px;\npadding-bottom: 10px;\ntext-align: center;\n}\n";
    //cover page picture
    NSString *aStyleCoverImage = @".CoverImage {\npadding: 0;\nmargin-top: 25x;\nmargin-bottom: 25px;\ntext-align: center;\n}\n";
    //inner page title
    NSString *aStyleIC = [NSString stringWithFormat:@".InnerCover{\nfont-size: %dpx;\nfont-weight: normal;\nline-height:1.0;\ntext-align: center;\nposition: absolute;\ntop: 120px;\nwidth: 440px;\n}\n",(NSInteger)((float)iFontSize*1.4)];//iphone
    //Index page title
    NSString *aStyleIndexTitle = [NSString stringWithFormat:@".indexTitle {\nfont-size: %dpx;\nline-height:1.0;\nwidth: 440px;\ntext-align: center;\n}\n",(NSInteger)((float)iFontSize*1.08)];//iphone
    //index page words
    NSString *aStyleIndex = [NSString stringWithFormat:@".index {\nfont-size: %dpx;\nline-height: 1.4;\nwidth: 440px;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.0)];//iphone
    NSString *aStyleIndexBook = [NSString stringWithFormat:@".indexBook {\nfont-size: %dpx;\nfont-weight:normal;\nline-height: 1.4;\nwidth: 440px;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.2)];//iphone
	NSString *aStyleLayout = [NSString stringWithFormat:@".apDiv1 {\nfont-family:%@;\ncolor:%@;\nposition:absolute;\nleft: 0px;\ntop: 0px;\nwidth:480px;\nheight:320px;\nz-index:1;\nbackground-color:transparent;\n}\n",sFontType,sFontColor];//#EBEBEB//transparent#f00;//iphone
    NSString *aStyleMain;
    int iAdjustVersion = 0;
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5.0)
    {
        if(iFontSize == 20)
            iAdjustVersion = 8;
        else if(iFontSize == 22)
            iAdjustVersion = 12;
        else
            iAdjustVersion = 10;
        
    }

    if(iFontSize == 14)
    {
        aStyleMain = @".main {\nwidth:440px;\nheight:280px;\npadding:0px 0px;\nmargin-left:20px;\nbackground:transparent;}\n"; 
    }else if(iFontSize == 16)//iphone
    {
        aStyleMain = @".main {\nwidth:440px;\nheight:280px;\npadding:0px 0px;\nmargin-left:20px;\nbackground:transparent;}\n";//iphone
    }else if(iFontSize == 18)
    {
        aStyleMain = [NSString stringWithFormat:@".main {\nletter-spacing:-1px;\nwidth:440px;\nheight:280px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",35-iAdjustVersion];
    }else if(iFontSize == 20)
    {
         aStyleMain = [NSString stringWithFormat:@".main {\nletter-spacing:-1px;\nwidth:440px;\nheight:280px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",30-iAdjustVersion];
       
    }else
    {
        aStyleMain = [NSString stringWithFormat:@".main {\nletter-spacing:-1px;\nwidth:440px;\nheight:280px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",30-iAdjustVersion];
    }
    NSString *aStyleHeader = @".header {\nmargin-top:5px;\nmargin-bottom:15px;\nmargin-left:0px;\nmargin-right:0px;\npadding:0px;\nbackground:transparent;\ntext-align:center;\n}\n";//iphone
    NSString *aStyleFooter = @".footer {\nposition:absolute;\nwidth:480px;\nbottom:5px;\npadding-top:5px;\npadding-bottom:0px;\nmargin:0px;\nbackground:transparent;\ntext-align:center;\n}\n";//iphone
    //for link color
    NSString *aStyleLink = [NSString stringWithFormat:@"<!--a:link {\ncolor:%@;\n; text-decoration: underline;}\na:active {color: %@; text-decoration: underline; }\na:visited {color: %@; text-decoration: underline; }\na:hover{color: %@; text-decoration: underline; }\n-->\n",sFontColor,sFontColor,sFontColor,sFontColor];
    NSString *aStyleHL = [NSString stringWithFormat:@"\n.hl	{\nbackground-color:%@ ;\ncolor:%@;padding:0px;\nmargin-left:0px;text-align:left;left:0px;z-index:0;}",sHighLightColor,sFontColor];//#ffff00
    NSString *aStyleHLNote = [NSString stringWithFormat:@"\n.hlnote	{\nbackground:%@ ;\ncolor:%@;\ntext-decoration: none;\nborder-bottom: 2px dashed %@}\n",sNoteLightColor,sFontColor,sNoteDash];
	NSString *aStyleEnd = @"</style>\n<script src=\"./selfjs.js\"></script></head>\n<body>\n<div class=\"apDiv1\">\n";
	//<script type=\"text/javascript\" src=\"https://getfirebug.com/firebug-lite.js\"></script>
	[_cssHtml appendString:aStyleBegin];
    [_cssHtml appendString:aStyleHL];
    [_cssHtml appendString:aStyleHLNote];
	[_cssHtml appendString:aStyleBookTitle];
	[_cssHtml appendString:aStyleChapterTitle];
	[_cssHtml appendString:aStyleHeading1];
	[_cssHtml appendString:aStyleHeading2];
	[_cssHtml appendString:aStyleHeading3];
	[_cssHtml appendString:aStyleOutline1];
	[_cssHtml appendString:aStyleOutline2];
	[_cssHtml appendString:aStyleOutline3];
	[_cssHtml appendString:aStyleOutline4];
	[_cssHtml appendString:aStyleOutline5];	
    
	[_cssHtml appendString:aStyleContent1];
	[_cssHtml appendString:aStyleContent2];
	[_cssHtml appendString:aStyleVerse1];
	[_cssHtml appendString:aStyleReading];	
	[_cssHtml appendString:aStyleHymns1_2];
	[_cssHtml appendString:aStyleHymns3];	
	[_cssHtml appendString:aStyleNote];
	[_cssHtml appendString:aStyleImage];
    [_cssHtml appendString:aStyleCoverImage];
    [_cssHtml appendString:aStyleIC];
    [_cssHtml appendString:aStyleIndexTitle];
	[_cssHtml appendString:aStyleIndex];
    [_cssHtml appendString:aStyleIndexBook];
    [_cssHtml appendString:aStyleLink];
	[_cssHtml appendString:aStyleLayout];
    [_cssHtml appendString:aStyleMain];
    [_cssHtml appendString:aStyleHeader];
    [_cssHtml appendString:aStyleFooter];
	[_cssHtml appendString:aStyleEnd];
    
    [cssHtml appendString:_cssHtml];
    
    return cssHtml;

}*/


- (NSMutableString *)loadCSS_iPhone
{
	NSMutableString *_cssHtml = [NSMutableString stringWithString:@"<!DOCTYPE html><html lang=\"en\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"stylesheet\" type=\"text/css\">\n<title></title>\n<script src=\"./TGJSBridge.js\"></script><script src=\"./jquery.js\"></script>"];
	NSString *aStyleBegin = @"<style>\n.top,.PageNumber\n{\nfont-size: 12px;\ntext-align: center;\nmargin:0px;\npadding:0px;\nborder: 0px;\n}\n";//iphone font-size
    
	NSString *aStyleBookTitle = [NSString stringWithFormat:@".BookTitle {\nfont-size: %dpx;\ntext-align: center;\nfont-weight: normal;\nmargin: 0px;\nline-height: 1.2em;\npadding-top:0px;\npadding-bottom:0.7em;\n}\n",(NSInteger)((float)iFontSize*1.4)];
	NSString *aStyleChapterTitle = [NSString stringWithFormat:@".ChapterTitle {\nfont-size: %dpx;\nline-height: 1.1em;\ntext-align: center;\npadding-top:0px;\npadding-bottom:0.7em;\nmargin:0px;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.25)]];
	NSString *aStyleHeading1 = [NSString stringWithFormat:@".Heading1 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.2)]];
	NSString *aStyleHeading2 = [NSString stringWithFormat:@".Heading2 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.16)]];
	NSString *aStyleHeading3 = [NSString stringWithFormat:@".Heading3,.Heading4,.Heading5,.Heading6,.Heading7,.Heading8,.Heading9 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.12)]];
	NSString *aStyleOutline1 = [NSString stringWithFormat:@".Outline1 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline2 = [NSString stringWithFormat:@".Outline2 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline3 = [NSString stringWithFormat:@".Outline3 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline4 = [NSString stringWithFormat:@".Outline4 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleOutline5 = [NSString stringWithFormat:@".Outline5,.Outline6,.Outline7,.Outline8,.Outline9 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 3em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleContent1 = [NSString stringWithFormat:@".content\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;}\n",iFontSize];
	NSString *aStyleContent2 = [NSString stringWithFormat:@".content2\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;}\n",iFontSize];
	NSString *aStyleVerse1 = [NSString stringWithFormat:@".Verses1 {\nfont-size:%dpx;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left: 55px;\npadding-right: 35px;\nline-height: 1.4;\ntext-indent: 1em;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleReading = [NSString stringWithFormat:@".Reading {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left:10px;\npadding-right:10px;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleHymns1_2= [NSString stringWithFormat:@".Hymns1,.Hymns2 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 5px;\npadding-right: 5px;\npadding-bottom: 0px;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleHymns3= [NSString stringWithFormat:@".Hymns3 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 5px;\npadding-right: 5px;\npadding-bottom: 1em;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];
    NSString *aStyleNote = [NSString stringWithFormat:@".Note {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: left;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];
	//NSString *aStyleNote = [NSString stringWithFormat:@".Note {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: right;\n}\n",(NSInteger)((float)iFontSize*0.85)];
    NSString *aStyleHeadNote = [NSString stringWithFormat:@".HeadNote {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: left;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];
    NSString *aStyleHeadNote2 = [NSString stringWithFormat:@".HeadNote2 {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: center;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleImage = @".Image {\nmargin: 0;\npadding-top: 10px;\npadding-bottom: 10px;\ntext-align: center;\n}\n";
    //cover page picture
    NSString *aStyleCoverImage = @".CoverImage {\npadding: 0;\nmargin-top: 25x;\nmargin-bottom: 25px;\ntext-align: center;\n}\n";
    //inner page title
    NSString *aStyleIC = [NSString stringWithFormat:@".InnerCover{\nfont-size: %dpx;\nfont-weight: normal;\nline-height:1.0;\ntext-align: center;\nposition: absolute;\ntop: 150px;\nwidth: 280px;\n}\n",(NSInteger)((float)iFontSize*1.4)];//iphone
    //Index page title
    NSString *aStyleIndexTitle = [NSString stringWithFormat:@".indexTitle {\nfont-size: %dpx;\nline-height:1.0;\nwidth: 280px;\ntext-align: center;\n}\n",(NSInteger)((float)iFontSize*1.08)];//iphone
    //index page words
    NSString *aStyleIndex = [NSString stringWithFormat:@".index {\nfont-size: %dpx;\nline-height: 1.4;\nwidth: 280px;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.0)];//iphone
    NSString *aStyleIndexBook = [NSString stringWithFormat:@".indexBook {\nfont-size: %dpx;\nfont-weight:normal;\nline-height: 1.4;\nwidth: 280px;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.2)];//iphone
    NSString *aStyleLayout;
    if(IS_IPHONE_5)
        aStyleLayout= [NSString stringWithFormat:@"\n.apDiv1 {\nfont-family:%@;\ncolor:%@;\nposition:absolute;\nleft: 0px;\ntop: 0px;\nwidth:320px;\nheight:568px;\nz-index:1;\nbackground-color:transparent;\n}\n",sFontType,sFontColor];
    else
        aStyleLayout= [NSString stringWithFormat:@"\n.apDiv1 {\nfont-family:%@;\ncolor:%@;\nposition:absolute;\nleft: 0px;\ntop: 0px;\nwidth:320px;\nheight:480px;\nz-index:1;\nbackground-color:transparent;\n}\n",sFontType,sFontColor];
	//NSString *aStyleLayout = [NSString stringWithFormat:@".apDiv1 {\nfont-family:%@;\ncolor:%@;\nposition:absolute;\nleft: 0px;\ntop: 0px;\nwidth:320px;\nheight:480px;\nz-index:1;\nbackground-color:transparent;\n}\n",sFontType,sFontColor];//#EBEBEB//transparent#f00;//iphone
    NSString *aStyleMain;
    
    int iAdjustVersion = 0;
    
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 5.0)
    {
        if(iFontSize == 20)
            iAdjustVersion = 8;
        else if(iFontSize == 26)
            iAdjustVersion = 12;
        else
            iAdjustVersion = 10;
            
    }
    
    if(iFontSize == 14)
    {
        aStyleMain = @".main {\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:20px;\nbackground:transparent;}\n"; 
    }else if(iFontSize == 16)
    {
        aStyleMain = @".main {\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:20px;\nbackground:transparent;}\n";
    }else if(iFontSize == 18)
    {
        if([[[UIDevice currentDevice] systemVersion] intValue] >= 5.0)
        {
            aStyleMain = [NSString stringWithFormat:@".main {\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",30-iAdjustVersion];//\nletter-spacing:-1px;
        }else
        {
            aStyleMain = [NSString stringWithFormat:@".main {\nletter-spacing:-1px;\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",30-iAdjustVersion];//\nletter-spacing:-1px;
        }
    }else if(iFontSize == 20)
    {
        aStyleMain = [NSString stringWithFormat:@".main {\nletter-spacing:-1px;\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",25-iAdjustVersion];
    }else
    {
        aStyleMain = [NSString stringWithFormat:@".main {\nletter-spacing:-1px;\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:%dpx;\nbackground:transparent;}\n",33-iAdjustVersion];

    }
    
    /*if(iFontSize == 16)//iphone
    {
        aStyleMain = [NSString stringWithString:@".main {\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:20px;\nbackground:transparent;}\n"];
    }else if(iFontSize == 18)
    {
        aStyleMain = [NSString stringWithString:@".main {\nletter-spacing:-1px;\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:30px;\nbackground:transparent;}\n"];
    }else if(iFontSize == 22)
    {
        aStyleMain = [NSString stringWithString:@".main {\nletter-spacing:-1px;\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:33px;\nbackground:transparent;}\n"];
    }
    else if(iFontSize == 14)
    {
        aStyleMain = [NSString stringWithString:@".main {\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:20px;\nbackground:transparent;}\n"];    
    }
    else
    {
        aStyleMain = [NSString stringWithString:@".main {\nletter-spacing:-1px;\nwidth:280px;\nheight:440px;\npadding:0px 0px;\nmargin-left:25px;\nbackground:transparent;}\n"];
    }*/
    
    NSString *aStyleHeader = @".header {\nmargin-top:5px;\nmargin-bottom:15px;\nmargin-left:0px;\nmargin-right:0px;\npadding:0px;\nbackground:transparent;\ntext-align:center;\n}\n";//iphone
    NSString *aStyleFooter = @".footer {\nposition:absolute;\nwidth:320px;\nbottom:5px;\npadding-top:5px;\npadding-bottom:0px;\nmargin:0px;\nbackground:transparent;\ntext-align:center;\n}\n";//iphone
    //for link color
    NSString *aStyleLink = [NSString stringWithFormat:@"<!--a:link {\ncolor:%@;\n; text-decoration: underline;}\na:active {color: %@; text-decoration: underline; }\na:visited {color: %@; text-decoration: underline; }\na:hover{color: %@; text-decoration: underline; }\n-->\n",sFontColor,sFontColor,sFontColor,sFontColor];
    NSString *aStyleHL = [NSString stringWithFormat:@"\n.hl	{\nbackground-color:%@ ;\ncolor:%@;padding:0px;\nmargin-left:0px;text-align:left;left:0px;z-index:0;}",sHighLightColor,sFontColor];//#ffff00
    NSString *aStyleHLNote = [NSString stringWithFormat:@"\n.hlnote	{\nbackground:%@ ;\ncolor:%@;\ntext-decoration: none;\nborder-bottom: 2px dashed %@}\n",sNoteLightColor,sFontColor,sNoteDash];
	NSString *aStyleEnd = @"</style>\n<script src=\"./selfjs.js\"></script></head>\n<body>\n<div class=\"apDiv1\">\n";
	//<script type=\"text/javascript\" src=\"https://getfirebug.com/firebug-lite.js\"></script>
	[_cssHtml appendString:aStyleBegin];
    [_cssHtml appendString:aStyleHL];
    [_cssHtml appendString:aStyleHLNote];
	[_cssHtml appendString:aStyleBookTitle];
	[_cssHtml appendString:aStyleChapterTitle];
	[_cssHtml appendString:aStyleHeading1];
	[_cssHtml appendString:aStyleHeading2];
	[_cssHtml appendString:aStyleHeading3];
	[_cssHtml appendString:aStyleOutline1];
	[_cssHtml appendString:aStyleOutline2];
	[_cssHtml appendString:aStyleOutline3];
	[_cssHtml appendString:aStyleOutline4];
	[_cssHtml appendString:aStyleOutline5];	
    
	[_cssHtml appendString:aStyleContent1];
	[_cssHtml appendString:aStyleContent2];
	[_cssHtml appendString:aStyleVerse1];
	[_cssHtml appendString:aStyleReading];	
	[_cssHtml appendString:aStyleHymns1_2];
	[_cssHtml appendString:aStyleHymns3];	
	[_cssHtml appendString:aStyleNote];
    [_cssHtml appendString:aStyleHeadNote];
    [_cssHtml appendString:aStyleHeadNote2];
	[_cssHtml appendString:aStyleImage];
    [_cssHtml appendString:aStyleCoverImage];
    [_cssHtml appendString:aStyleIC];
    [_cssHtml appendString:aStyleIndexTitle];
	[_cssHtml appendString:aStyleIndex];
    [_cssHtml appendString:aStyleIndexBook];
    [_cssHtml appendString:aStyleLink];
	[_cssHtml appendString:aStyleLayout];
    [_cssHtml appendString:aStyleMain];
    [_cssHtml appendString:aStyleHeader];
    [_cssHtml appendString:aStyleFooter];
	[_cssHtml appendString:aStyleEnd];
    
    return _cssHtml;

}

- (NSMutableString *)loadCSS
{
	NSMutableString *_cssHtml = [NSMutableString stringWithString:@"<!DOCTYPE html><html lang=\"en\">\n<head>\n<meta charset=\"utf-8\"/>\n<link rel=\"stylesheet\" type=\"text/css\">\n<title></title>\n<script src=\"./TGJSBridge.js\"></script><script src=\"./jquery.js\"></script>"];
	NSString *aStyleBegin = @"<style>\n.top,.PageNumber\n{\nfont-size: 16px;\ntext-align: center;\nmargin:0px;\npadding:0px;\nborder: 0px;\n}\n";
   
	NSString *aStyleBookTitle = [NSString stringWithFormat:@".BookTitle {\nfont-size: %dpx;\ntext-align: center;\nfont-weight: normal;\nmargin: 0px;\nline-height: 1.2em;\npadding-top:0px;\npadding-bottom:0.7em;\n}\n",(NSInteger)((float)iFontSize*1.4)];
	NSString *aStyleChapterTitle = [NSString stringWithFormat:@".ChapterTitle {\nfont-size: %dpx;\nline-height: 1.1em;\ntext-align: center;\npadding-top:0px;\npadding-bottom:0.7em;\nmargin:0px;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.25)]];
	NSString *aStyleHeading1 = [NSString stringWithFormat:@".Heading1 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.2)]];
	NSString *aStyleHeading2 = [NSString stringWithFormat:@".Heading2 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.16)]];
	NSString *aStyleHeading3 = [NSString stringWithFormat:@".Heading3,.Heading4,.Heading5,.Heading6,.Heading7,.Heading8,.Heading9 {\nfont-size: %dpx;\nline-height:1.0;\ntext-align: center;\nmargin:0px;\npadding-top: 0px;\npadding-bottom:0.8em;\n}\n",[self checkFontSizeAvalible:(NSInteger)((float)iFontSize*1.12)]];
	NSString *aStyleOutline1 = [NSString stringWithFormat:@".Outline1 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline2 = [NSString stringWithFormat:@".Outline2 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 1.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline3 = [NSString stringWithFormat:@".Outline3 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleOutline4 = [NSString stringWithFormat:@".Outline4 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 2.5em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleOutline5 = [NSString stringWithFormat:@".Outline5,.Outline6,.Outline7,.Outline8,.Outline9 {\nfont-size: %dpx;\nmargin:0px;\npadding: 0px;\nline-height: 1.45;\ntext-indent: 3em;\ntext-align: justify;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleContent1 = [NSString stringWithFormat:@".content\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-indent: 1em;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;}\n",iFontSize];
	NSString *aStyleContent2 = [NSString stringWithFormat:@".content2\n{\nfont-size: %dpx;\npadding-top:0px;\npadding-bottom:1em;\nmargin:0px;\nline-height: 1.45;\ntext-align:justify;\nword-break:break-all\n;word-warp: break-word;}\n",iFontSize];
	NSString *aStyleVerse1 = [NSString stringWithFormat:@".Verses1 {\nfont-size:%dpx;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left: 55px;\npadding-right: 35px;\nline-height: 1.4;\ntext-indent: 1em;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleReading = [NSString stringWithFormat:@".Reading {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top: 0px;\npadding-bottom: 1.1em;\npadding-left:55px;\npadding-right:35px;\nword-break:break-all\n}\n",(NSInteger)((float)iFontSize*0.85)];
	NSString *aStyleHymns1_2= [NSString stringWithFormat:@".Hymns1,.Hymns2 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 36px;\npadding-right: 36px;\npadding-bottom: 0px;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];
	NSString *aStyleHymns3= [NSString stringWithFormat:@".Hymns3 {\nfont-size: %dpx;\npadding-top: 0px;\npadding-left: 36px;\npadding-right: 36px;\npadding-bottom: 1em;\nmargin:0px;\nline-height: 1.5;\n}\n",(NSInteger)((float)iFontSize*1.0)];	
	NSString *aStyleNote = [NSString stringWithFormat:@".Note {\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: right;\n}\n",(NSInteger)((float)iFontSize*0.85)];
    NSString *aStyleHeadNote = [NSString stringWithFormat:@".HeadNote {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: left;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];
    NSString *aStyleHeadNote2 = [NSString stringWithFormat:@".HeadNote2 {\nfont-family:%@;\nfont-size: %dpx;\nline-height:1.0;\nmargin:0px;\npadding-top:0px;\npadding-bottom: 1.1em;\ntext-align: center;\n}\n",sFontType1,(NSInteger)((float)iFontSize*0.85)];

	NSString *aStyleImage = @".Image {\nmargin: 0;\npadding-top: 25px;\npadding-bottom: 25px;\ntext-align: center;\n}\n";
    //cover page picture
    NSString *aStyleCoverImage = @".CoverImage {\npadding: 0;\nmargin-top: 25x;\nmargin-bottom: 25px;\ntext-align: center;\n}\n";
    //inner page title
    NSString *aStyleIC = [NSString stringWithFormat:@".InnerCover{\nfont-size: %dpx;\nfont-weight: normal;\nline-height:1.0;\ntext-align: center;\nposition: absolute;\ntop: 350px;\nwidth: 600px;\n}\n",(NSInteger)((float)iFontSize*1.4)];
    //Index page title
    NSString *aStyleIndexTitle = [NSString stringWithFormat:@".indexTitle {\nfont-size: %dpx;\nline-height:1.0;\nwidth: 600px;\ntext-align: center;\n}\n",(NSInteger)((float)iFontSize*1.08)];//\nmargin-left: 84px;\nmargin-right: 84px;
    //index page words
    NSString *aStyleIndex = [NSString stringWithFormat:@".index {\nfont-size: %dpx;\nline-height: 1.4;\nwidth: 600px;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.0)];
    NSString *aStyleIndexBook = [NSString stringWithFormat:@".indexBook {\nfont-size: %dpx;\nfont-weight:normal;\nline-height: 1.4;\nwidth: 600px;\ntext-align:left;\n}\n",(NSInteger)((float)iFontSize*1.2)];
	NSString *aStyleLayout = [NSString stringWithFormat:@".apDiv1 {\nfont-family:%@;\ncolor:%@;\nposition:absolute;\nleft: 0px;\ntop: 0px;\nwidth:768px;\nheight:1024px;\nz-index:1;\nbackground-color:transparent;\n}\n",sFontType,sFontColor];//#EBEBEB//transparent#f00;
    NSString *aStyleMain;
    if(iFontSize == 26)
    {
        aStyleMain = @".main {\nwidth:600px;\nheight:869px;\npadding:0px 0px;\nmargin-left:84px;\nbackground:transparent;}\n";
    }else if(iFontSize == 18)
    {
        aStyleMain = @".main {\nletter-spacing:-1px;\nwidth:600px;\nheight:869px;\npadding:0px 0px;\nmargin-left:94px;\nbackground:transparent;}\n";
    }else if(iFontSize == 22)
    {
        aStyleMain = @".main {\nletter-spacing:-1px;\nwidth:600px;\nheight:869px;\npadding:0px 0px;\nmargin-left:89px;\nbackground:transparent;}\n";
    }else
    {
        aStyleMain = @".main {\nletter-spacing:-1px;\nwidth:600px;\nheight:869px;\npadding:0px 0px;\nmargin-left:84px;\nbackground:transparent;}\n";
    }
    NSString *aStyleHeader = @".header {\nmargin-top:25px;\nmargin-bottom:50px;\nmargin-left:0px;\nmargin-right:0px;\npadding:0px;\nbackground:transparent;\ntext-align:center;\n}\n";
    NSString *aStyleFooter = @".footer {\nposition:absolute;\nwidth:768px;\nbottom:20px;\npadding-top:25px;\npadding-bottom:0px;\nmargin:0px;\nbackground:transparent;\ntext-align:center;\n}\n";
    //for link color
    NSString *aStyleLink = [NSString stringWithFormat:@"<!--a:link {\ncolor:%@;\n; text-decoration: underline;}\na:active {color: %@; text-decoration: underline; }\na:visited {color: %@; text-decoration: underline; }\na:hover{color: %@; text-decoration: underline; }\n-->\n",sFontColor,sFontColor,sFontColor,sFontColor];
    NSString *aStyleHL = [NSString stringWithFormat:@"\n.hl	{\nbackground-color:%@ ;\ncolor:%@;padding:0px;\nmargin-left:0px;text-align:left;left:0px;z-index:0;}",sHighLightColor,sFontColor];//#ffff00
    NSString *aStyleHLNote = [NSString stringWithFormat:@"\n.hlnote	{\nbackground:%@ ;\ncolor:%@;\ntext-decoration: none;\nborder-bottom: 2px dashed %@}\n",sNoteLightColor,sFontColor,sNoteDash];
	NSString *aStyleEnd = @"</style>\n<script src=\"./selfjs.js\"></script></head>\n<body>\n<div class=\"apDiv1\">\n";
	//<script type=\"text/javascript\" src=\"https://getfirebug.com/firebug-lite.js\"></script>
	[_cssHtml appendString:aStyleBegin];
    [_cssHtml appendString:aStyleHL];
    [_cssHtml appendString:aStyleHLNote];    
	[_cssHtml appendString:aStyleBookTitle];
	[_cssHtml appendString:aStyleChapterTitle];
	[_cssHtml appendString:aStyleHeading1];
	[_cssHtml appendString:aStyleHeading2];
	[_cssHtml appendString:aStyleHeading3];
	[_cssHtml appendString:aStyleOutline1];
	[_cssHtml appendString:aStyleOutline2];
	[_cssHtml appendString:aStyleOutline3];
	[_cssHtml appendString:aStyleOutline4];
	[_cssHtml appendString:aStyleOutline5];	
    
	[_cssHtml appendString:aStyleContent1];
	[_cssHtml appendString:aStyleContent2];
	[_cssHtml appendString:aStyleVerse1];
	[_cssHtml appendString:aStyleReading];
	[_cssHtml appendString:aStyleHymns1_2];
	[_cssHtml appendString:aStyleHymns3];	
	[_cssHtml appendString:aStyleNote];
    [_cssHtml appendString:aStyleHeadNote];
    [_cssHtml appendString:aStyleHeadNote2];
	[_cssHtml appendString:aStyleImage];
    [_cssHtml appendString:aStyleCoverImage];
    [_cssHtml appendString:aStyleIC];
    [_cssHtml appendString:aStyleIndexTitle];
	[_cssHtml appendString:aStyleIndex];
    [_cssHtml appendString:aStyleIndexBook];
    [_cssHtml appendString:aStyleLink];
	[_cssHtml appendString:aStyleLayout];
    [_cssHtml appendString:aStyleMain];
    [_cssHtml appendString:aStyleHeader];
    [_cssHtml appendString:aStyleFooter];
	[_cssHtml appendString:aStyleEnd];
    
    return _cssHtml;
}

- (NSInteger)TagHeight:(NSInteger)_iSize fontSize:(float)_fontSize lineHeight:(float)_lineHeight padding:(float)_padding pageWidth:(NSInteger)_pageWidth lineBias:(NSInteger)_lineBias
{
    NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*_fontSize);
    NSInteger _iLineHeight = (NSInteger)(float)(iBaseFontSize)*_lineHeight;
    NSInteger _iChar = (NSInteger)((float)(_pageWidth)/(float)iBaseFontSize)-_lineBias; //lineBias 因safara特性而調整
    NSInteger iL = (NSInteger)((float)_iSize/(float)_iChar)+1;
    NSInteger iAreaHeight = (NSInteger)((float)_iLineHeight*(float)iL);
    NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*_padding);
    int iPxSingle = iAreaHeight + iPadding;
    return iPxSingle;
}


- (BOOL)readMarkDataFromPlist
{
    NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",self.bookNumber] getDocPathWithPList];
    if ([[NSFileManager defaultManager] fileExistsAtPath:myPath])
    {
        [dic_mark_text release];
        dic_mark_text = [[NSMutableDictionary alloc] initWithContentsOfFile:myPath]; //mem@@
        return YES;
    }else
    {
        return NO;
    }
    

}

- (BOOL)convertToHtml_iphone:(NSInteger)iArrayCount isPreFace:(BOOL)bPreface isLandscape:(BOOL)bLandscape
{
    if(iArrayCount==46-1)//2-1 == 369
        NSLog(@"Stop Here");
    
    
    
    if(!bCheckMark)
    {
        bHasMarkData = [self readMarkDataFromPlist];
        bCheckMark = YES;
    }
    
    NSMutableString *convertedString = [NSMutableString stringWithString:@""];
    //portrait and landscape shared parameter
    NSString *aEnd;
    NSString *aTop;
    int iCharEachLine; 
    NSInteger _pixelHeight;
    NSInteger _pixelWidth;
    NSInteger _pixelWidthReading;
    NSInteger _pixelWidthHymn;
    NSInteger _imgResolution;
    NSInteger _icharEachLineVerses;
    
    NSInteger iCurrentPage = [pageNumber integerValue];
    //NSInteger iCurrentPage_L;
    NSString *pageInfo;
    
    //parameters
    NSInteger iSize = 0;
	NSInteger iLine = 0;
	NSInteger iPxTotal = 0;
	NSInteger iLastPxTotal = 0;
	NSInteger iCountHalfChar;
    
    NSInteger iLastAddIndex = 0;
	
	
    if(!bLandscape)
    {
        
        
        convertedString = [self loadCSS_iPhone];
        
        //[cssString release];
    
        //cssString = [[NSMutableString alloc] initWithString:[self loadCSS_iPhone:aHtml]];
        
        //NSLog(@"%@",cssString);
        //[aHtml appendString:cssString];//[NSMutableString stringWithString:cssString];
        _imgResolution = 280;
            
           
        
        
        aTop = [NSString stringWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];
        
        aEnd = @"</div>\n</body>\n</html>\n";
        
        
        _pixelHeight = pixelHeight;//maybe change when smallest font 14 pixelheight = 400
        _pixelWidth = pixelWidth;
        iCharEachLine = (NSInteger)((float)(pixelWidth)/(float)iFontSize)-_lineCharacterBias;//(int)lineCharactersNumber;
        
        _pixelWidthReading = pixelWidthReading;  
        _pixelWidthHymn = pixelWidthHymn; 
        _imgResolution = pixelWidth;
        
        // _icharEachLineVerses = icharEachLineVerses;
        
        pageInfo = [NSString stringWithFormat:@"</div>\n<div class=\"footer\"><p class=\"PageNumber\">%d</p></div>\n",iCurrentPage];
    }
    
    
	[convertedString appendString:aTop];
	
	
	
    int iCount;// = [array_type count];
    if(bPreface)
        iCount = [array_pre_type count];
    else
        iCount = [array_type count];
	
	int iNextStart = (int)indexNextStart;
	
	if(![sRemainText isEqualToString:@""])
	{	
		bRemainMark = YES;
		[convertedString appendString:sRemainText];
        //NSLog(@"%@",sRemainText);
		int iL = (int)([sRemainPureText length]/iCharEachLine)+1;
		iLine += iL;
		sRemainText = @"";
		
		//iL = (iSize/iCharEachLine+1);
		int iPxSingle = iL*14*1.45+0.8*14;  //iphone
		if(bLastPicture)
			iPxSingle = lastPicturePx;
		iPxTotal += iPxSingle;
        iLastPxTotal = iPxTotal;
		//NSLog(@"[Content2]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
	}else 
	{
		
		if(bFinalMark && !bRemainMark)
		{
			self.indexNextStart = (NSInteger)0;
			return YES;
		}
        
		if(iNextStart >= iCount-1)
        {
            if(!bPreface)
                bFinalMark = YES;
            else if(!bRemainMark)
                bFinalMark = YES;
            
            if(!bPreface)
            {
                if(bFinalMark && !bRemainMark)
                {
                    self.indexNextStart = (NSInteger)0;
                    return YES;
                }
            }
            
            
            if(bPreface && bFinalMark) //bPreface && &&!bRemainMark
            {
                return YES;
            }
            bFinalMark = YES;
            
        }
		else 
			bFinalMark = NO;
        bRemainMark = NO;
		
	}
    
	
	for(int i = iNextStart ; i < iCount; i++)
	{
        //id_next_start_from = 0;
   		
		NSString *sFormat;
		NSString *aImgPath;
		UIImage *aImg;
        
		NSString *aType;
        NSMutableString *aText;
        NSString *_aChap;
        NSString *_rowid;
        if(bPreface)
        {
            aType = [array_pre_type objectAtIndex:i];
            aText = [array_pre_text objectAtIndex:i];
            _aChap = [array_pre_chap objectAtIndex:i];
            _rowid = [array_pre_rowid objectAtIndex:i];
            //NSLog(@"preface:%@",aText);
            if(![_lastSetRowId isEqualToString:_rowid]) 
                id_next_start_from = 0;
        }
        else
        {
            aType = [array_type objectAtIndex:i];
            aText = [array_text objectAtIndex:i];
            _aChap = [array_chap objectAtIndex:i];
            _rowid = [array_rowid objectAtIndex:i];
            
            //for search index
            
            [array_row_page_index setObject:[NSString stringWithFormat:@"%d",iArrayCount] forKey:_rowid];
            //NSLog(@"set array_row key %@ at page %d",_rowid,iArrayCount);
            //NSLog(@"page:%d,text:%@",iArrayCount-1,aText);
            if(![_lastSetRowId isEqualToString:_rowid]) 
                id_next_start_from = 0;
        }
		
		//iCountHalfChar = 0;
        NSString *desPath;
		
		
        if(i == 0 && !bPreface)
        {
			iSize = [self.bookName length];
            /*NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.4);
             float _iLineHeight = (float)(iBaseFontSize)*1.2;
             NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
             NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
             NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
             NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*0.7);
             int iPxSingle = iAreaHeight + iPadding;*/
            
            int iPxSingle = [self TagHeight:iSize fontSize:1.4 lineHeight:1.2 padding:0.7 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
            //NSString *aBookTitle = [NSString stringWithFormat:@"<p class=\"BookTitle\" id=\"singleHeight:%d totalHeight:%d\">%@</p>\n",iPxSingle,iPxTotal,self.bookName];
            // id=\"%04d_%@\">
            //NSString *aBookTitle = [NSString stringWithFormat:@"<p class=\"BookTitle\" id=\"%05d\">%@</p>\n",_rowid,self.bookName];
            NSString *aBookTitle = [NSString stringWithFormat:@"<p class=\"BookTitle\">%@</p>\n",self.bookName];
            [convertedString appendString:aBookTitle];
            
        }
        
        iSize = [aText length];
        
        if([aType isEqualToString:@"m"])
            aType = @"3";
        
		if([aType isEqualToString:@"0"])
		{
            iSize = [aText length];
            /*NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.2);
             float _iLineHeight = (float)(iBaseFontSize)*1.1;
             NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
             NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
             NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
             NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*0.7);
             int iPxSingle = iAreaHeight + iPadding;*/
            int iPxSingle = [self TagHeight:iSize fontSize:1.2 lineHeight:1.1 padding:0.7 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"ChapterTitle\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"ChapterTitle\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
            
            hasChapMark += 1;
            //NSLog(@"The hasChapMark mark is added 1 in count;%d,_array_count:%d",i,iArrayCount);
            if(hasBookZMark && i > 2)
            {
                breakMark = YES;
                hasBookZMark = NO;
            }
            
        }
		else if([aType isEqualToString:@"b"])
		{
			sFormat = @"<p class=\"BookTitle\">";
			iLine += 2;
			
			int iL = kCacLine;
			int iPxSingle = iL*60/4; //iphone
			iPxTotal += iPxSingle;
			//NSLog(@"[BookTitle]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);		
		}
        else if([aType isEqualToString:@"z"])
        {
            int iPxSingle = [self TagHeight:iSize fontSize:1.4 lineHeight:1.2 padding:0.7 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"BookTitle\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];//InnerCover
            sFormat = [NSString stringWithFormat:@"<p class=\"BookTitle\">"];
            
            hasZMark = YES;
            //NSLog(@"The hasZMark mark is added in count;%d,_array_count:%d",i,iArrayCount);
            if(i > 2)
                hasBookZMark = YES;
        }
		else if([aType isEqualToString:@"1"])
		{
            /*
             NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.2);
             float _iLineHeight = (float)(iBaseFontSize)*1.2;
             NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
             NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
             NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
             NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*0.7);
             int iPxSingle = iAreaHeight + iPadding;*/
            int iPxSingle = [self TagHeight:iSize fontSize:1.2 lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Heading1\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"Heading1\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"2"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.16 lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Heading2\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"Heading2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"3"] || [aType isEqualToString:@"4"] || [aType isEqualToString:@"5"] || [aType isEqualToString:@"6"] || 
                [aType isEqualToString:@"7"] || [aType isEqualToString:@"8"] || [aType isEqualToString:@"9"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.12 lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Heading%@\" id=\"singleHeight:%d totalHeight:%d\">",aType,iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"Heading%@\"  id=\"%06d%05d\">",aType,[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"o1"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline1\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];   
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline1\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"o2"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline2\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"o3"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline3\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline3\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"o4"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline4\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline4\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
        }
		else if([aType isEqualToString:@"o5"] || [aType isEqualToString:@"o6"] || [aType isEqualToString:@"o7"] || [aType isEqualToString:@"o8"] || [aType isEqualToString:@"o9"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            NSString *_oN = [aType substringFromIndex:1];
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline%@\" id=\"singleHeight:%d totalHeight:%d\">",_oN,iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline%@\"  id=\"%06d%05d\">",_oN,[_rowid integerValue],id_next_start_from];
        }
		else if([aType isEqualToString:@"s"] || [aType isEqualToString:@"t"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidthReading lineBias:1];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Reading\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
        }
        else if([aType isEqualToString:@"h1"] || [aType isEqualToString:@"h2"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.5 padding:0.0 pageWidth:_pixelWidthHymn lineBias:0];
			iPxTotal += iPxSingle;
            NSString *_hN = [aType substringFromIndex:1];
			//sFormat = [NSString stringWithFormat:@"<p class=\"Hymns%@\" id=\"singleHeight:%d totalHeight:%d\">",_hN,iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Hymns%@\"  id=\"%06d%05d\">",_hN,[_rowid integerValue],id_next_start_from]; 
			
		}
        else if([aType isEqualToString:@"h3"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.5 padding:1.0 pageWidth:_pixelWidthHymn lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Hymns3\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Hymns3\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
            
		}
		else if([aType isEqualToString:@"n"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Note\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Note\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"hn"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Note\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"HeadNote\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"hn2"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Note\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"HeadNote2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"p"])
		{
            
            [self copyFileFromResource:aText];
            //NSLog(@"%@",aText);
			//aImgPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aText];
            aImgPath = [aText getDocPathWithPList];
            aImg = [UIImage imageWithContentsOfFile:aImgPath];
					
            CGSize aS = [aImg size];
            
            int iPxSingle;
			//if(aS.width > _imgResolution)//pixWidth
            if(aS.height > _pixelHeight || aS.width > _imgResolution)
			{
                if(aS.height > aS.width*1.1)
                    iPxSingle = aS.height*(_pixelHeight/aS.height);
                else
                    iPxSingle = aS.height*(_imgResolution/aS.width);
			}else {
				iPxSingle = aS.height*(_pixelHeight/aS.height);
			}
            iPxSingle += 14*2;  //iphone
			iPxTotal += iPxSingle;
            if(bLandscape)
            {
                if (iPxTotal > 260 && iPxTotal < (260+iPxSingle)) 
                {
                    iPxTotal = 260 + iPxSingle;
                }
            }
            sFormat = [NSString stringWithFormat:@"<p class=\"Image\" id=\"singleHeight:%d totalHeight:%d\"><img src=\"file://",iPxSingle,iPxTotal];
            
			//NSLog(@"[Image]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
		}
		else if([aType isEqualToString:@"c"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            //sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"content\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
        }
		else if([aType isEqualToString:@"re"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            //sFormat = [NSString stringWithFormat:@"<p class=\"content2\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"content2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
            
        }
		else 
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            //sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"content\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
            
		}
		
		//NSLog(@"iLine = %d",iLine);
		NSString *aTmp;
		//若斷落大於頁面大小時
		if(iPxTotal+ iFontSize*1.4 > _pixelHeight)//iphone
		{
			//若為圖片時
			if([aType isEqualToString:@"p"])
			{
                //在改成下載購買時需更動
                //desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aText];
                desPath = [aText getDocPathWithPList];
				CGSize aS = aImg.size;
                CGFloat _iRectFactor;
                
                if(bLandscape)
                    _iRectFactor = 0.9;
                else
                    _iRectFactor = 1.1;
                
                if(aS.height > aS.width*_iRectFactor)
                {
                    if(iPxTotal > _pixelHeight)
                    {
                        
                        sRemainText = [NSString stringWithFormat:@"%@%@\" height=\"%d\" />%@",sFormat,desPath,_pixelHeight-30,@"</p>\n"];
                        aTmp = @"";
                        bLastPicture = YES;
                        lastPicturePx = _pixelHeight;//aS.height+50
                    }else
                    {
                        
                        aTmp = [NSString stringWithFormat:@"%@%@\" height=\"%d\" />%@",sFormat,desPath,_pixelHeight-30,@"</p>\n"];
                        sRemainText = @"";//changed in 20110420
                        
                        bLastPicture = NO;
                    }
                }
                else
                {
                    if(iPxTotal > _pixelWidth || bLandscape)
                    {
                        
                        if(aS.width > _pixelWidth)
                            sRemainText = [NSString stringWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
                        else
                            sRemainText = [NSString stringWithFormat:@"%@%@\" />%@",sFormat,desPath,@"</p>\n"];
                        aTmp = @"";
                        
                        //NSLog(@"%@",aTmp);
                        bLastPicture = YES;
                        if (bLandscape) {
                            lastPicturePx = _pixelHeight + 50;
                        }else                            
                            lastPicturePx = _pixelHeight;
                        
                        
                    }else
                    {
                        
                        if(aS.width > _pixelWidth)
                            aTmp = [NSString stringWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
                        else
                            aTmp = [NSString stringWithFormat:@"%@%@\" />%@",sFormat,desPath,@"</p>\n"];
                        
                        sRemainText = @"";//changed in 20110420
                        
                        bLastPicture = NO;
                    }
                }
                //[aImg release];
			}//若type為s或t時(引經類)
			else if([aType isEqualToString:@"s"] || [aType isEqualToString:@"t"])
			{
                NSInteger _iBaseFontSize = iFontSize*0.85;
				int iGap = (NSInteger)((_pixelHeight-iLastPxTotal)/(float)_iBaseFontSize);
				if(iGap <= 0)
					iGap = 1;
                _icharEachLineVerses = (NSInteger)((float)(_pixelWidthReading)/(float)_iBaseFontSize);//-1;
                
				int iSubstringIndex = _icharEachLineVerses*iGap-1-1;
				int iLength = [aText length];
                
				if(iLength < iSubstringIndex)
				{
                    //NSLog(@"page:%d",iArrayCount);
					int iPxSingle = [self TagHeight:iLength fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidthReading lineBias:1];
                    iPxTotal += iPxSingle;
                    
                    //sFormat = [NSString stringWithFormat:@"<p class=\"Reading\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
                    sFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                    
                    NSMutableString *_aText = [NSMutableString stringWithString:aText];
                    if(bHasMarkData)
                        _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                    
					aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
					sRemainText = @""; 
					
				}
				else
				{
                    
					NSString *_aText  = [aText substringToIndex:iSubstringIndex];
					iCountHalfChar = [self countHalfNumber:_aText];
					
					NSInteger aLength = aText.length;
					if((iSubstringIndex + (int)iCountHalfChar/2) < aLength)
					{
						iSubstringIndex += (int)iCountHalfChar/2;
                        
                        NSMutableString *_aText = [NSMutableString stringWithString:[aText substringToIndex:iSubstringIndex]];
                        NSMutableString *_aText1 = [NSMutableString stringWithString:[aText substringFromIndex:iSubstringIndex]];
                        if(bHasMarkData)
                        {
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                            _aText1 = [self makeMarkHighLight:_rowid aText:_aText1 iDataStartFrom:iSubstringIndex];
                        }
                        
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
                        //sFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                        NSString *_sRemainFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],iSubstringIndex];
                        
                        
                        
						sRemainText = [NSString stringWithFormat:@"%@%@%@",_sRemainFormat,_aText1,@"</p>\n"]; //[aText substringFromIndex:iSubstringIndex]//_aText1
                        sRemainPureText = [aText substringFromIndex:iSubstringIndex];
                        
					}else {
                        
                        NSMutableString *_aText = [NSMutableString stringWithString:aText];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
						sRemainText = @"";
					}
                    
					int _iL = [[aText substringToIndex:iSubstringIndex] length];//([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					int iPxSingle = [self TagHeight:_iL fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidthReading lineBias:1];//iL*22*1.4+25;
					iPxTotal += iPxSingle;
					//NSLog(@"[SubStringMulti]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
				
				bLastPicture = NO;
			}            
            else if([aType isEqualToString:@"1"] || [aType isEqualToString:@"2"] || [aType isEqualToString:@"3"] || [aType isEqualToString:@"4"] ||
                    [aType isEqualToString:@"5"] || [aType isEqualToString:@"6"] || [aType isEqualToString:@"7"] || [aType isEqualToString:@"8"] ||
                    [aType isEqualToString:@"9"])
            {
                NSInteger _iBaseFontSize;
                NSInteger _aType = [aType integerValue];
                CGFloat _fFontPara;
                switch (_aType) {
                    case 1:
                        _iBaseFontSize = iFontSize*1.2;
                        _fFontPara = 1.2;
                        break;
                    case 2:
                        _iBaseFontSize = iFontSize*1.16;
                        _fFontPara = 1.16;
                        break;
                        
                    default:
                        _iBaseFontSize = iFontSize*1.12;
                        _fFontPara = 1.12;
                        break;
                }
                NSString *_strHeading = [NSString stringWithFormat:@"Heading%d",_aType];
                
				int iGap = (NSInteger)((_pixelHeight-iLastPxTotal)/(float)_iBaseFontSize);
				if(iGap <= 0)
					iGap = 1;
                _icharEachLineVerses = (NSInteger)((float)(_pixelWidth)/(float)_iBaseFontSize)-1;
                
				int iSubstringIndex = _icharEachLineVerses*iGap-1;
				int iLength = [aText length];
                
				if(iLength < iSubstringIndex)
				{
                    //NSLog(@"page:%d",iArrayCount);
					int iPxSingle = [self TagHeight:iLength fontSize:_fFontPara lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
                    iPxTotal += iPxSingle;
                    
                    //sFormat = [NSString stringWithFormat:@"<p class=\"%@\" id=\"singleHeight:%d totalHeight:%d\">",_strHeading,iPxSingle,iPxTotal]; 
                    sFormat = [NSString stringWithFormat:@"<p class=\"%@\"  id=\"%06d%05d\">",_strHeading,[_rowid integerValue],id_next_start_from];
					aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,aText,@"</p>\n"];
					sRemainText = @""; 
					
				}
				else
				{
                    
					NSString *_aText = [aText substringToIndex:iSubstringIndex];
					iCountHalfChar = [self countHalfNumber:_aText];
					
					NSInteger aLength = aText.length;
					if((iSubstringIndex + (int)iCountHalfChar/2) < aLength)
					{
						iSubstringIndex += (int)iCountHalfChar/2;
                        // iSize = [[aText substringToIndex:iSubstringIndex] length];
						//aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,[aText substringToIndex:iSubstringIndex],@"</p>\n"];
                        //NSString *_sformat = [NSString stringWithFormat:@"<p class=\"%@\">",_strHeading];
						//sRemainText = [NSString stringWithFormat:@"%@%@%@",_sformat,[aText substringFromIndex:iSubstringIndex],@"</p>\n"];
                        
                        //////////////////////////////////////////////////////////////////////
                        //int iPxSingle = [self TagHeight:iSize fontSize:_fFontPara lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
                        //iPxTotal += iPxSingle;
                        sFormat = [NSString stringWithFormat:@"<p class=\"%@\" id=\"%06d%05d\">",_strHeading,[_rowid integerValue],id_next_start_from];//[NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
                        //////////////////////////////////////////////////////////////////////
                        NSMutableString *_aText = [NSMutableString stringWithString:[aText substringToIndex:iSubstringIndex]];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                        
                        aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];//[NSString stringWithFormat:@"%@%@%@",sFormat,[aText substringToIndex:iSubstringIndex],@"</p>\n"];
						
                        id_next_start_from += iSubstringIndex;
                        [_lastSetRowId release];
                        _lastSetRowId = [_rowid retain];
						//將剩下的文件放到array的下一個待處理
						
                        [array_type insertObject:aType atIndex:i+1];
                        [array_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                        [array_chap insertObject:_aChap atIndex:i+1];
                        [array_rowid insertObject:_rowid atIndex:i+1];
                        
                        
						
						sRemainText = @"";
						bRemainMark = YES;
                        
					}else {
                        NSMutableString *_aText = [NSMutableString stringWithString:aText];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                        
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
						sRemainText = @"";
					}
                    
					//int _iL = [[aText substringToIndex:iSubstringIndex] length];//([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					//int iPxSingle = [self TagHeight:_iL fontSize:_fFontPara lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];//iL*22*1.4+25;
					//iPxTotal += iPxSingle;
                    
                    iPxTotal = 0;
					//NSLog(@"[SubStringMulti]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
                
            }//其它狀況(主要是內文type=c類)
			else
			{
				NSInteger iGap = (NSInteger)((float)((_pixelHeight-iLastPxTotal))/((float)iFontSize*1.45));
				if(iGap <= 0)
					iGap = 1;
                int iSubstringIndex = iCharEachLine*iGap-1;
				int iLength = [aText length];
                
				if(iLength < iSubstringIndex && !(bLandscape && bLastPicture))
				{
					//NSLog(@"page:%d",iArrayCount);
                    //NSLog(@"aText:%@",aText);
                    NSMutableString *_aText = [NSMutableString stringWithString:aText];
                    if(bHasMarkData)
                        _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                    
                    
					aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
					sRemainText = @"";
					
					int iL = 1;//([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					int iPxSingle = iL*iFontSize*1.45;
					iPxTotal += iPxSingle;
					//NSLog(@"[SubString1Line]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
				else
				{
                    if(bLastPicture)
                        iSubstringIndex = 0;
					NSString *_aText = [aText substringToIndex:iSubstringIndex];
					int _a = [self countHalfNumber:_aText];
					iCountHalfChar = _a > 2? _a-1 : _a;
					//NSLog(@"countHalfNumber: %d",iCountHalfChar);
					NSInteger aLength = aText.length;
					if((iSubstringIndex + (int)iCountHalfChar/2) < aLength+1)
					{
						NSRange r = [aType rangeOfString:@"o"];
						if( r.location != NSNotFound)
							iSubstringIndex += (int)iCountHalfChar/2-1;
						else
							iSubstringIndex += (int)iCountHalfChar/2;
						
                        iSize = [[aText substringToIndex:iSubstringIndex] length];
                        
                        //////////////////////////////////////////////////////////////////////
                        int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
                        iPxTotal += iPxSingle;
                        //sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
                        if([aType isEqualToString:@"re"])
                            sFormat = [NSString stringWithFormat:@"<p class=\"content2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                        else
                            sFormat = [NSString stringWithFormat:@"<p class=\"content\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                        
                        ///////////////////////////////////////////////////////////////////
                        /*NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.0);
                         float _iLineHeight = (float)(iBaseFontSize)*1.45;
                         NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
                         NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
                         NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
                         NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*1.0);
                         int iPxSingle = iAreaHeight + iPadding;
                         iPxTotal += iPxSingle;
                         sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"iAreaHeight:%d iPadding:%d totalHeight:%d\">",iAreaHeight,iPadding,iPxTotal];*/
                        //////////////////////////////////////////////////////////////////////
                        
                        NSMutableString *_aText = [NSMutableString stringWithString:[aText substringToIndex:iSubstringIndex]];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                        
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
                        
						id_next_start_from += iSubstringIndex;
                        [_lastSetRowId release];
                        _lastSetRowId = [_rowid retain];
						//將剩下的文件放到array的下一個待處理
						//[array_chap insertObject:aChap atIndex:i+1];
						if([aType isEqualToString:@"c"])
						{	
                            if(bPreface)
                            {
                                [array_pre_type insertObject:@"re" atIndex:i+1];
                                [array_pre_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_pre_chap insertObject:_aChap atIndex:i+1];
                                [array_pre_rowid insertObject:_rowid atIndex:i+1];
                            }else
                            {
                                [array_type insertObject:@"re" atIndex:i+1];
                                [array_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_chap insertObject:_aChap atIndex:i+1];
                                [array_rowid insertObject:_rowid atIndex:i+1];
                            }
						}else if(![aType isEqualToString:@"0"] && ![aType isEqualToString:@"1"] && ![aType isEqualToString:@"2"] && 
                                 ![aType isEqualToString:@"3"] && ![aType isEqualToString:@"4"] && ![aType isEqualToString:@"5"] && 
                                 ![aType isEqualToString:@"6"] && ![aType isEqualToString:@"7"] && ![aType isEqualToString:@"8"] &&
                                 ![aType isEqualToString:@"9"] && ![aType isEqualToString:@"z"])
						{
							if(bPreface)
                            {
                                [array_pre_type insertObject:aType atIndex:i+1];
                                [array_pre_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_pre_chap insertObject:_aChap atIndex:i+1];
                                [array_pre_rowid insertObject:_rowid atIndex:i+1];
                                
                            }else
                            {
                                [array_type insertObject:aType atIndex:i+1];
                                [array_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_chap insertObject:_aChap atIndex:i+1];
                                [array_rowid insertObject:_rowid atIndex:i+1];
                            }
						}
						//else
						//	[array_type insertObject:aType atIndex:i+1];
						
						sRemainText = @"";
						bRemainMark = YES;
						
					}else {
                        //NSLog(@"page:%d",iArrayCount);
                        NSMutableString *_aText = [NSMutableString stringWithString:aText];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
						sRemainText = @"";
					}
                    
                    
					//for remain text?
					//int iL = ([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					//int iPxSingle = iL*iFontSize*1.45+25;
					//iPxTotal += iPxSingle;
					//NSLog(@"[SubStringMulti]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
				
				bLastPicture = NO;
			}
		}	
		else
		{
			if([aType isEqualToString:@"p"])
			{
				//desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aText];
                desPath = [aText getDocPathWithPList];
				CGSize aS = aImg.size;
				if(aS.width > _pixelWidth)
					aTmp = [NSString stringWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
				else
					aTmp = [NSString stringWithFormat:@"%@%@\" />%@",sFormat,desPath,@"</p>\n"];
				
                //NSLog(@"%@",aTmp);
				//[aImg release];
			}else
			{
				//NSMutableString *_aText = [self convertHalfNumberToFull:aText];
				//iCountHalfChar = [self countHalfNumber:aText];
				//NSLog(@"countHalfNumber: %d",iCountHalfChar);
                
                if(bHasMarkData)
                    aText = [self makeMarkHighLight:_rowid aText:aText iDataStartFrom:id_next_start_from];
                
				aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,aText,@"</p>\n"];
			}
		}
		
		
		//判斷分章節的時候的動作 
		if((((i > 2  && [aType isEqualToString:@"0"]) || [aType isEqualToString:@"z"]) && breakMark == NO && !(i == iNextStart && bRemainMark == NO)) || 
		   (([aType isEqualToString:@"1"] || [aType isEqualToString:@"2"] || [aType isEqualToString:@"3"] || 
			 [aType isEqualToString:@"4"] || [aType isEqualToString:@"5"] || [aType isEqualToString:@"6"] ||
			 [aType isEqualToString:@"7"] || [aType isEqualToString:@"8"]  || [aType isEqualToString:@"9"]) && iPxTotal+50 > _pixelHeight))
		{
			iNextStart = i;
			breakMark = YES;
            if([aType isEqualToString:@"0"])
            {    
                hasChapMark -= 1;
                //NSLog(@"The hasChapTer mark is minused 1 in count;%d,_array_count:%d",i,iArrayCount);
                //add iArrayCount > 2 to prevent the caculate error in some book index first page jonliu33 20110801
                if(iArrayCount > 2 && iArrayCount - iLastAddIndex == 1) 
                {
                    hasChapMark += 1;
                    //NSLog(@"The hasChapTer mark is raised to YES bcs 1pge in count;%d,iLastAdd:%d,_array_count:%d",i,iLastAddIndex,iArrayCount);
                }
                
            }
            if([aType isEqualToString:@"z"])
            {    
                hasZMark = NO;
                //NSLog(@"The hasChapTer mark is canceled in count;%d,_array_count:%d",i,iArrayCount);
                /*if(iArrayCount - iLastAddIndex == 1)
                 {
                 hasZMark = YES;
                 //NSLog(@"The hasChapTer mark is raised to YES bcs 1pge in count;%d,iLastAdd:%d,_array_count:%d",i,iLastAddIndex,iArrayCount);
                 }*/
                
            }
            
            break;
            
		}else
		{
			[convertedString appendString:aTmp];
			breakMark = NO;
		}
		
		//[aTmp release];
		
		//iLastLine = iLine;
		iLastPxTotal = iPxTotal;
		if(iPxTotal > _pixelHeight || iPxTotal == 0)//if(iLine >24)
		{
			//iLine = [[aText substringFromIndex:iCharEachLine] length]/iCharEachLine+1;
			iNextStart = i+1;
			break;
		}else {
			iNextStart = i;
		}
        
	}
	
    
    if(!bPreface)
        [convertedString appendString:pageInfo];
    
	[convertedString appendString:aEnd];
     aHtml = [convertedString copy];
    
    //add the pagenum to index_array
    if(([[array_type objectAtIndex:0] isEqualToString:@"z"] && iArrayCount == 0) || hasZMark)
    {    
        [array_index_pagenum addObject:[NSString stringWithFormat:@"%d",iArrayCount]];
        hasZMark = NO;
        //NSLog(@"The book page has bee added to array in page:%d",iArrayCount);
    }
    
    if(hasChapMark > 0 || iArrayCount == 0)
    {
        [array_index_pagenum addObject:[NSString stringWithFormat:@"%d",iArrayCount]];
        hasChapMark = 0;
        //NSLog(@"The index page has bee added to array in page:%d",iArrayCount);
    }
	iCurrentPage++;
	NSString *sP = [NSString stringWithFormat:@"%d",iCurrentPage];
	self.pageNumber = sP;
	//[sP release];
	
	
	
	
	//indexNextStart = nil; 
	//NString *st = [NSString stringWithFormat:@"%d",iNextStart];
	//indexNextStart  = [NSString stringWithFormat:@"%d",iNextStart];
	//[st release];
	self.indexNextStart = (NSInteger)iNextStart;
	return NO;

}


- (BOOL)convertToHtml:(NSInteger)iArrayCount isPreFace:(BOOL)bPreface isLandscape:(BOOL)bLandscape
{
    if(iArrayCount==182)//2-1 == 369
        NSLog(@"Stop Here");
    
    
    
    if(!bCheckMark)
    {
       bHasMarkData = [self readMarkDataFromPlist];
        bCheckMark = YES;
    }
    

    NSMutableString *convertedString = [NSMutableString stringWithString:@""];
    //portrait and landscape shared parameter
    NSString *aEnd;
    NSString *aTop;
    int iCharEachLine; 
    NSInteger _pixelHeight;
    NSInteger _pixelWidth;
    NSInteger _pixelWidthReading;
    NSInteger _pixelWidthHymn;
    NSInteger _imgResolution;
    NSInteger _icharEachLineVerses;
    
    NSInteger iCurrentPage = [pageNumber integerValue];
    NSInteger iCurrentPage_L;
    NSString *pageInfo;
    
    //parameters
    NSInteger iSize = 0;
	NSInteger iLine = 0;
	NSInteger iPxTotal = 0;
	NSInteger iLastPxTotal = 0;
	NSInteger iCountHalfChar;
    
    NSInteger iLastAddIndex = 0;
	
	
    if(bLandscape)
    {
        convertedString = [self loadCSS_L];
        
        aTop = [NSString stringWithFormat:@"<div class=\"headerL\"><p class=\"top\">%@</p></div>\n<div class=\"headerR\"><p class=\"top\">%@</p></div>\n<div class=\"main\">\n",self.bookName,self.bookName];
        
        aEnd = @"</div>\n</body>\n</html>\n";
        
                
        _pixelHeight = pixelHeight_L;
        _pixelWidth = pixelWidth_L;
        
        iCharEachLine = (NSInteger)((float)(pixelWidth_L)/(float)iFontSize)-_lineCharacterBias;//(int)lineCharactersNumber_L;

        _pixelWidthReading = pixelWidthReading_L;  
        _pixelWidthHymn = pixelWidthHymn_L;
        
        _imgResolution = 400;
        
        //_icharEachLineVerses = icharEachLineVerses_L;
        
        
        iCurrentPage_L = iCurrentPage;
        if(iCurrentPage_L > 1)
            iCurrentPage_L = iCurrentPage*2-1;
        pageInfo = [NSString stringWithFormat:@"</div>\n<div class=\"footerL\"><p class=\"PageNumber\">%d</p></div>\n<div class=\"footerR\"><p class=\"PageNumber\">%d</p></div>",iCurrentPage_L,iCurrentPage_L+1];
    }
    else
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            convertedString = [self loadCSS];
        else
        {
            convertedString = [self loadCSS_iPhone];
            _imgResolution = 280;
        }
        
        aTop = [NSString stringWithFormat:@"<div class=\"header\">\n<p class=\"top\">%@</p>\n</div>\n<div class=\"main\">\n",self.bookName];

        aEnd = @"</div>\n</body>\n</html>\n";
        
        
        _pixelHeight = pixelHeight;
        _pixelWidth = pixelWidth;
        iCharEachLine = (NSInteger)((float)(pixelWidth)/(float)iFontSize)-_lineCharacterBias;//(int)lineCharactersNumber;
        
        _pixelWidthReading = pixelWidthReading;  
        _pixelWidthHymn = pixelWidthHymn; 
        _imgResolution = pixelWidth;
        
       // _icharEachLineVerses = icharEachLineVerses;
        
        pageInfo = [NSString stringWithFormat:@"</div>\n<div class=\"footer\"><p class=\"PageNumber\">%d</p></div>\n",iCurrentPage];
    }
    
     
	[convertedString appendString:aTop];
	
	
	
    int iCount;// = [array_type count];
    if(bPreface)
        iCount = [array_pre_type count];
    else
        iCount = [array_type count];
	
	int iNextStart = (int)indexNextStart;
	
	if(![sRemainText isEqualToString:@""])
	{	
		bRemainMark = YES;
		[convertedString appendString:sRemainText];
        NSLog(@"%@",sRemainText);
		int iL = (int)([sRemainPureText length]/iCharEachLine)+1;
		iLine += iL;
		sRemainText = @"";
		
		//iL = (iSize/iCharEachLine+1);
		int iPxSingle = iL*26*1.45+25;
		if(bLastPicture)
			iPxSingle = lastPicturePx;
		iPxTotal += iPxSingle;
		iLastPxTotal = iPxTotal;
		//NSLog(@"[Content2]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
	}else 
	{
		
		if(bFinalMark && !bRemainMark)
		{
			self.indexNextStart = (NSInteger)0;
			return YES;
		}
		
		if(iNextStart >= iCount-1)
        {
			bFinalMark = YES;
            
            if(!bPreface)
             {
                 if(bFinalMark && !bRemainMark)
                 {
                     self.indexNextStart = (NSInteger)0;
                     return YES;
                 }
             }
             
            
            if(bPreface && bFinalMark) //bPreface && &&!bRemainMark
            {
                return YES;
            }
            
        }
		else 
			bFinalMark = NO;
        bRemainMark = NO;
		
	}

	
	for(int i = iNextStart ; i < iCount; i++)
	{
        //id_next_start_from = 0;
   		
		NSString *sFormat;
		NSString *aImgPath;
		UIImage *aImg;
        
		NSString *aType;
        NSMutableString *aText;
        NSString *_aChap;
        NSString *_rowid;
        if(bPreface)
        {
            aType = [array_pre_type objectAtIndex:i];
            aText = [array_pre_text objectAtIndex:i];
            _aChap = [array_pre_chap objectAtIndex:i];
            _rowid = [array_pre_rowid objectAtIndex:i];
            
            if(![_lastSetRowId isEqualToString:_rowid]) 
                id_next_start_from = 0;
        }
        else
        {
            aType = [array_type objectAtIndex:i];
            aText = [array_text objectAtIndex:i];
            _aChap = [array_chap objectAtIndex:i];
            _rowid = [array_rowid objectAtIndex:i];
            
            //for search index
            
            [array_row_page_index setObject:[NSString stringWithFormat:@"%d",iArrayCount] forKey:_rowid];
            //NSLog(@"set array_row key %@ at page %d",_rowid,iArrayCount);
            if(![_lastSetRowId isEqualToString:_rowid]) 
                id_next_start_from = 0;
        }
		
		//iCountHalfChar = 0;
        NSString *desPath;
		
		
        if(i == 0 && !bPreface)
        {
			iSize = [self.bookName length];
            /*NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.4);
            float _iLineHeight = (float)(iBaseFontSize)*1.2;
            NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
            NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
            NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
            NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*0.7);
			int iPxSingle = iAreaHeight + iPadding;*/
            
            int iPxSingle = [self TagHeight:iSize fontSize:1.4 lineHeight:1.2 padding:0.7 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
            //NSString *aBookTitle = [NSString stringWithFormat:@"<p class=\"BookTitle\" id=\"singleHeight:%d totalHeight:%d\">%@</p>\n",iPxSingle,iPxTotal,self.bookName];
            // id=\"%04d_%@\">
            //NSString *aBookTitle = [NSString stringWithFormat:@"<p class=\"BookTitle\" id=\"%05d\">%@</p>\n",_rowid,self.bookName];
            NSString *aBookTitle = [NSString stringWithFormat:@"<p class=\"BookTitle\">%@</p>\n",self.bookName];
            [convertedString appendString:aBookTitle];
            
        }
        
        iSize = [aText length];
        
        if([aType isEqualToString:@"m"])
            aType = @"3";
        
		if([aType isEqualToString:@"0"])
		{
            iSize = [aText length];
            /*NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.2);
            float _iLineHeight = (float)(iBaseFontSize)*1.1;
            NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
            NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
            NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
            NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*0.7);
			int iPxSingle = iAreaHeight + iPadding;*/
            int iPxSingle = [self TagHeight:iSize fontSize:1.2 lineHeight:1.1 padding:0.7 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"ChapterTitle\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"ChapterTitle\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
            
            hasChapMark += 1;
            //NSLog(@"The hasChapMark mark is added 1 in count;%d,_array_count:%d",i,iArrayCount);
            if(hasBookZMark && i > 2)
            {
                breakMark = YES;
                hasBookZMark = NO;
            }

        }
		else if([aType isEqualToString:@"b"])
		{
			sFormat = @"<p class=\"BookTitle\">";
			iLine += 2;
			
			int iL = kCacLine;
			int iPxSingle = iL*60;
			iPxTotal += iPxSingle;
			//NSLog(@"[BookTitle]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);		
		}
        else if([aType isEqualToString:@"z"])
        {
            int iPxSingle = [self TagHeight:iSize fontSize:1.4 lineHeight:1.2 padding:0.7 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"BookTitle\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];//InnerCover
            sFormat = [NSString stringWithFormat:@"<p class=\"BookTitle\">"];
            
            hasZMark = YES;
             //NSLog(@"The hasZMark mark is added in count;%d,_array_count:%d",i,iArrayCount);
            if(i > 2)
             hasBookZMark = YES;
        }
		else if([aType isEqualToString:@"1"])
		{
            /*
            NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.2);
            float _iLineHeight = (float)(iBaseFontSize)*1.2;
            NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
            NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
            NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
            NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*0.7);
			int iPxSingle = iAreaHeight + iPadding;*/
            int iPxSingle = [self TagHeight:iSize fontSize:1.2 lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
             
			//sFormat = [NSString stringWithFormat:@"<p class=\"Heading1\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"Heading1\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"2"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.16 lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Heading2\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"Heading2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"3"] || [aType isEqualToString:@"4"] || [aType isEqualToString:@"5"] || [aType isEqualToString:@"6"] || 
            [aType isEqualToString:@"7"] || [aType isEqualToString:@"8"] || [aType isEqualToString:@"9"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.12 lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Heading%@\" id=\"singleHeight:%d totalHeight:%d\">",aType,iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"Heading%@\"  id=\"%06d%05d\">",aType,[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"o1"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline1\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];   
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline1\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"o2"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline2\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"o3"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline3\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline3\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"o4"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline4\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline4\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
        }
		else if([aType isEqualToString:@"o5"] || [aType isEqualToString:@"o6"] || [aType isEqualToString:@"o7"] || [aType isEqualToString:@"o8"] || [aType isEqualToString:@"o9"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:0.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            NSString *_oN = [aType substringFromIndex:1];
			//sFormat = [NSString stringWithFormat:@"<p class=\"Outline%@\" id=\"singleHeight:%d totalHeight:%d\">",_oN,iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Outline%@\"  id=\"%06d%05d\">",_oN,[_rowid integerValue],id_next_start_from];
        }
		else if([aType isEqualToString:@"s"] || [aType isEqualToString:@"t"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidthReading lineBias:1];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Reading\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
        }
        else if([aType isEqualToString:@"h1"] || [aType isEqualToString:@"h2"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.5 padding:0.0 pageWidth:_pixelWidthHymn lineBias:0];
			iPxTotal += iPxSingle;
            NSString *_hN = [aType substringFromIndex:1];
			//sFormat = [NSString stringWithFormat:@"<p class=\"Hymns%@\" id=\"singleHeight:%d totalHeight:%d\">",_hN,iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Hymns%@\"  id=\"%06d%05d\">",_hN,[_rowid integerValue],id_next_start_from]; 
			
		}
        else if([aType isEqualToString:@"h3"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.5 padding:1.0 pageWidth:_pixelWidthHymn lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Hymns3\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Hymns3\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
            
		}
		else if([aType isEqualToString:@"n"])
		{	
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Note\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
            sFormat = [NSString stringWithFormat:@"<p class=\"Note\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"hn"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Note\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"HeadNote\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
        else if([aType isEqualToString:@"hn2"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            
			//sFormat = [NSString stringWithFormat:@"<p class=\"Note\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"HeadNote2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
		}
		else if([aType isEqualToString:@"p"])
		{
            
            [self copyFileFromResource:aText];
            //NSLog(@"%@",aText);
			//aImgPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aText];
            aImgPath = [aText getDocPathWithPList];
            aImg = [UIImage imageWithContentsOfFile:aImgPath];
            //iLine += (iSize/iCharEachLine+5);
            /*if(bLandscape && aImg.size.height > 590)
            {
                aImg = [aImg transformWidth:(aImg.size.width/aImg.size.height)*340.0 height:340.0 rotate:NO];
                _imgResolution = aImg.size.width;
            }*/
			CGSize aS = [aImg size];
            
            int iPxSingle;
			if(aS.width > _imgResolution)//pixWidth
			{
				iPxSingle = aS.height*(_imgResolution/aS.width);
			}else {
				iPxSingle = aS.height;
			}
            iPxSingle += 25*2;
			iPxTotal += iPxSingle;
            if(bLandscape)
            {
                if (iPxTotal > 590 && iPxTotal < (590+iPxSingle)) 
                {
                    iPxTotal = 590 + iPxSingle;
                }
            }
            sFormat = [NSString stringWithFormat:@"<p class=\"Image\" id=\"singleHeight:%d totalHeight:%d\"><img src=\"file://",iPxSingle,iPxTotal];

			//NSLog(@"[Image]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
		}
		else if([aType isEqualToString:@"c"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            //sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"content\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
        }
		else if([aType isEqualToString:@"re"])
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            //sFormat = [NSString stringWithFormat:@"<p class=\"content2\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"content2\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];

        }
		else 
		{
            int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
			iPxTotal += iPxSingle;
            //sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
            sFormat = [NSString stringWithFormat:@"<p class=\"content\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];

		}
		
		//NSLog(@"iLine = %d",iLine);
		NSString *aTmp;
		//若斷落大於頁面大小時
		if(iPxTotal+ iFontSize*1.2 > _pixelHeight)//if(iLine > 24)
		{
			//若為圖片時
			if([aType isEqualToString:@"p"])
			{
                //在改成下載購買時需更動
                //desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aText];
                desPath = [aText getDocPathWithPList];
				CGSize aS = aImg.size;
               
				if(iPxTotal > _pixelWidth)
				{
					
					if(aS.width > _pixelWidth)
						sRemainText = [NSString stringWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
					else
						sRemainText = [NSString stringWithFormat:@"%@%@\" />%@",sFormat,desPath,@"</p>\n"];
					aTmp = @"";
					
					//NSLog(@"%@",aTmp);
					bLastPicture = YES;
					lastPicturePx = aS.height+50;
					

				}else
				{
					
					if(aS.width > _pixelWidth)
						aTmp = [NSString stringWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
					else
						aTmp = [NSString stringWithFormat:@"%@%@\" />%@",sFormat,desPath,@"</p>\n"];
					
					sRemainText = @"";//changed in 20110420
					
					bLastPicture = NO;
				}
                //[aImg release];
			}//若type為s或t時(引經類)
			else if([aType isEqualToString:@"s"] || [aType isEqualToString:@"t"])
			{
                NSInteger _iBaseFontSize = iFontSize*0.85;
				int iGap = (NSInteger)((_pixelHeight-iLastPxTotal)/(float)_iBaseFontSize);
				if(iGap <= 0)
					iGap = 1;
                _icharEachLineVerses = (NSInteger)((float)(_pixelWidthReading)/(float)_iBaseFontSize);//-1;
                
				int iSubstringIndex = _icharEachLineVerses*iGap-1-1;
				int iLength = [aText length];
                
				if(iLength < iSubstringIndex)
				{
                    //NSLog(@"page:%d",iArrayCount);
					int iPxSingle = [self TagHeight:iLength fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidthReading lineBias:1];
                    iPxTotal += iPxSingle;
                    
                    //sFormat = [NSString stringWithFormat:@"<p class=\"Reading\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal]; 
                    sFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                    
                    NSMutableString *_aText = [NSMutableString stringWithString:aText];
                    if(bHasMarkData)
                        _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                    
					aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
					sRemainText = @""; 
					
				}
				else
				{
                   
					NSString *_aText = [aText substringToIndex:iSubstringIndex];
					iCountHalfChar = [self countHalfNumber:_aText];
					
					NSInteger aLength = aText.length;
					if((iSubstringIndex + (int)iCountHalfChar/2) < aLength)
					{
						iSubstringIndex += (int)iCountHalfChar/2;
                        
                        NSMutableString *_aText = [NSMutableString stringWithString:[aText substringToIndex:iSubstringIndex]];
                        NSMutableString *_aText1 = [NSMutableString stringWithString:[aText substringFromIndex:iSubstringIndex]];
                        if(bHasMarkData)
                        {
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                            _aText1 = [self makeMarkHighLight:_rowid aText:_aText1 iDataStartFrom:iSubstringIndex];
                        }
                        
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
                        //sFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                        NSString *_sRemainFormat = [NSString stringWithFormat:@"<p class=\"Reading\"  id=\"%06d%05d\">",[_rowid integerValue],iSubstringIndex];
                        
                        
                        
						sRemainText = [NSString stringWithFormat:@"%@%@%@",_sRemainFormat,_aText1,@"</p>\n"]; //[aText substringFromIndex:iSubstringIndex]//_aText1
                        sRemainPureText = [aText substringFromIndex:iSubstringIndex];
                       
					}else {
                        
                        NSMutableString *_aText = [NSMutableString stringWithString:aText];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
						sRemainText = @"";
					}
										
					int _iL = [[aText substringToIndex:iSubstringIndex] length];//([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					int iPxSingle = [self TagHeight:_iL fontSize:0.85 lineHeight:1.0 padding:1.1 pageWidth:_pixelWidthReading lineBias:1];//iL*22*1.4+25;
					iPxTotal += iPxSingle;
					//NSLog(@"[SubStringMulti]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
				
				bLastPicture = NO;
			}            
            else if([aType isEqualToString:@"1"] || [aType isEqualToString:@"2"] || [aType isEqualToString:@"3"] || [aType isEqualToString:@"4"] ||
                    [aType isEqualToString:@"5"] || [aType isEqualToString:@"6"] || [aType isEqualToString:@"7"] || [aType isEqualToString:@"8"] ||
                    [aType isEqualToString:@"9"])
            {
                NSInteger _iBaseFontSize;
                NSInteger _aType = [aType integerValue];
                CGFloat _fFontPara;
                switch (_aType) {
                    case 1:
                        _iBaseFontSize = iFontSize*1.2;
                        _fFontPara = 1.2;
                        break;
                    case 2:
                        _iBaseFontSize = iFontSize*1.16;
                        _fFontPara = 1.16;
                        break;
                        
                    default:
                        _iBaseFontSize = iFontSize*1.12;
                        _fFontPara = 1.12;
                        break;
                }
                NSString *_strHeading = [NSString stringWithFormat:@"Heading%d",_aType];
                
				int iGap = (NSInteger)((_pixelHeight-iLastPxTotal)/(float)_iBaseFontSize);
				if(iGap <= 0)
					iGap = 1;
                _icharEachLineVerses = (NSInteger)((float)(_pixelWidth)/(float)_iBaseFontSize)-1;
                
				int iSubstringIndex = _icharEachLineVerses*iGap-1;
				int iLength = [aText length];
                
				if(iLength < iSubstringIndex)
				{
                    //NSLog(@"page:%d",iArrayCount);
					int iPxSingle = [self TagHeight:iLength fontSize:_fFontPara lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
                    iPxTotal += iPxSingle;
                    
                    //sFormat = [NSString stringWithFormat:@"<p class=\"%@\" id=\"singleHeight:%d totalHeight:%d\">",_strHeading,iPxSingle,iPxTotal]; 
                    sFormat = [NSString stringWithFormat:@"<p class=\"%@\"  id=\"%06d%05d\">",_strHeading,[_rowid integerValue],id_next_start_from];
					aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,aText,@"</p>\n"];
					sRemainText = @""; 
					
				}
				else
				{
                   
					NSString *_aText = [aText substringToIndex:iSubstringIndex];
					iCountHalfChar = [self countHalfNumber:_aText];
					
					NSInteger aLength = aText.length;
					if((iSubstringIndex + (int)iCountHalfChar/2) < aLength)
					{
						iSubstringIndex += (int)iCountHalfChar/2;
                        // iSize = [[aText substringToIndex:iSubstringIndex] length];
						//aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,[aText substringToIndex:iSubstringIndex],@"</p>\n"];
                        //NSString *_sformat = [NSString stringWithFormat:@"<p class=\"%@\">",_strHeading];
						//sRemainText = [NSString stringWithFormat:@"%@%@%@",_sformat,[aText substringFromIndex:iSubstringIndex],@"</p>\n"];
                        
                         //////////////////////////////////////////////////////////////////////
                         //int iPxSingle = [self TagHeight:iSize fontSize:_fFontPara lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];
                         //iPxTotal += iPxSingle;
                         sFormat = [NSString stringWithFormat:@"<p class=\"%@\" id=\"%06d%05d\">",_strHeading,[_rowid integerValue],id_next_start_from];//[NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
                         //////////////////////////////////////////////////////////////////////
                        NSMutableString *_aText = [NSMutableString stringWithString:[aText substringToIndex:iSubstringIndex]];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                        
						 aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];//[NSString stringWithFormat:@"%@%@%@",sFormat,[aText substringToIndex:iSubstringIndex],@"</p>\n"];
						
                        id_next_start_from += iSubstringIndex;
                        [_lastSetRowId release];
                        _lastSetRowId = [_rowid retain];
						//將剩下的文件放到array的下一個待處理
						
                        [array_type insertObject:aType atIndex:i+1];
                        [array_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                        [array_chap insertObject:_aChap atIndex:i+1];
                        [array_rowid insertObject:_rowid atIndex:i+1];
                            

						
						sRemainText = @"";
						bRemainMark = YES;
 
					}else {
                        NSMutableString *_aText = [NSMutableString stringWithString:aText];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                        
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
						sRemainText = @"";
					}
                                       
					//int _iL = [[aText substringToIndex:iSubstringIndex] length];//([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					//int iPxSingle = [self TagHeight:_iL fontSize:_fFontPara lineHeight:1.0 padding:0.8 pageWidth:_pixelWidth lineBias:0];//iL*22*1.4+25;
					//iPxTotal += iPxSingle;
                    
                    iPxTotal = 0;
					//NSLog(@"[SubStringMulti]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}

            }//其它狀況(主要是內文type=c類)
			else
			{
				NSInteger iGap = (NSInteger)((float)((_pixelHeight-iLastPxTotal))/((float)iFontSize*1.45));
				if(iGap <= 0)
					iGap = 1;
                int iSubstringIndex = iCharEachLine*iGap-1;
				int iLength = [aText length];
               
				if(iLength < iSubstringIndex)
				{
					//NSLog(@"page:%d",iArrayCount);
                    //NSLog(@"aText:%@",aText);
                    NSMutableString *_aText = [NSMutableString stringWithString:aText];
                    if(bHasMarkData)
                        _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                    

					aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
					sRemainText = @"";
					
					int iL = 1;//([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					int iPxSingle = iL*iFontSize*1.45;
					iPxTotal += iPxSingle;
					//NSLog(@"[SubString1Line]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
				else
				{
					NSString *_aText = [aText substringToIndex:iSubstringIndex];
					int _a = [self countHalfNumber:_aText];
					iCountHalfChar = _a > 2? _a-1 : _a;
					//NSLog(@"countHalfNumber: %d",iCountHalfChar);
					NSInteger aLength = aText.length;
					if((iSubstringIndex + (int)iCountHalfChar/2) < aLength)
					{
						NSRange r = [aType rangeOfString:@"o"];
						if( r.location != NSNotFound)
							iSubstringIndex += (int)iCountHalfChar/2-1;
						else
							iSubstringIndex += (int)iCountHalfChar/2;
						
                        iSize = [[aText substringToIndex:iSubstringIndex] length];
                        
                        //////////////////////////////////////////////////////////////////////
                        int iPxSingle = [self TagHeight:iSize fontSize:1.0 lineHeight:1.45 padding:1.0 pageWidth:_pixelWidth lineBias:0];
                        iPxTotal += iPxSingle;
                        //sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"singleHeight:%d totalHeight:%d\">",iPxSingle,iPxTotal];
                        sFormat = [NSString stringWithFormat:@"<p class=\"content\"  id=\"%06d%05d\">",[_rowid integerValue],id_next_start_from];
                        
                        ///////////////////////////////////////////////////////////////////
                        /*NSInteger iBaseFontSize = (NSInteger)((float)iFontSize*1.0);
                        float _iLineHeight = (float)(iBaseFontSize)*1.45;
                        NSInteger _iChar = (NSInteger)((float)(600)/(float)iBaseFontSize);
                        NSInteger iL = (NSInteger)((float)iSize/(float)_iChar)+1;
                        NSInteger iAreaHeight = (NSInteger)(_iLineHeight*(float)iL)+1;
                        NSInteger iPadding = (NSInteger)((float)(iBaseFontSize)*1.0);
                        int iPxSingle = iAreaHeight + iPadding;
                        iPxTotal += iPxSingle;
                        sFormat = [NSString stringWithFormat:@"<p class=\"content\" id=\"iAreaHeight:%d iPadding:%d totalHeight:%d\">",iAreaHeight,iPadding,iPxTotal];*/
                        //////////////////////////////////////////////////////////////////////
                        
                        NSMutableString *_aText = [NSMutableString stringWithString:[aText substringToIndex:iSubstringIndex]];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
                        
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
                        
						id_next_start_from += iSubstringIndex;
                        [_lastSetRowId release];
                        _lastSetRowId = [_rowid retain];
						//將剩下的文件放到array的下一個待處理
						//[array_chap insertObject:aChap atIndex:i+1];
						if([aType isEqualToString:@"c"])
						{	
                            if(bPreface)
                            {
                                [array_pre_type insertObject:@"re" atIndex:i+1];
                                [array_pre_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_pre_chap insertObject:_aChap atIndex:i+1];
                                [array_pre_rowid insertObject:_rowid atIndex:i+1];
                            }else
                            {
                                [array_type insertObject:@"re" atIndex:i+1];
                                [array_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_chap insertObject:_aChap atIndex:i+1];
                                [array_rowid insertObject:_rowid atIndex:i+1];
                            }
						}else if(![aType isEqualToString:@"0"] && ![aType isEqualToString:@"1"] && ![aType isEqualToString:@"2"] && 
                                 ![aType isEqualToString:@"3"] && ![aType isEqualToString:@"4"] && ![aType isEqualToString:@"5"] && 
                                 ![aType isEqualToString:@"6"] && ![aType isEqualToString:@"7"] && ![aType isEqualToString:@"8"] &&
                                 ![aType isEqualToString:@"9"] && ![aType isEqualToString:@"z"])
						{
							if(bPreface)
                            {
                                [array_pre_type insertObject:aType atIndex:i+1];
                                [array_pre_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_pre_chap insertObject:_aChap atIndex:i+1];
                                [array_pre_rowid insertObject:_rowid atIndex:i+1];
                                
                            }else
                            {
                                [array_type insertObject:aType atIndex:i+1];
                                [array_text insertObject:[aText substringFromIndex:iSubstringIndex] atIndex:i+1];
                                [array_chap insertObject:_aChap atIndex:i+1];
                                [array_rowid insertObject:_rowid atIndex:i+1];
                            }
						}
						//else
						//	[array_type insertObject:aType atIndex:i+1];
						
						sRemainText = @"";
						bRemainMark = YES;
						
					}else {
                        //NSLog(@"page:%d",iArrayCount);
                        NSMutableString *_aText = [NSMutableString stringWithString:aText];
                        if(bHasMarkData)
                            _aText = [self makeMarkHighLight:_rowid aText:_aText iDataStartFrom:id_next_start_from];
						aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,_aText,@"</p>\n"];
						sRemainText = @"";
					}


					//for remain text?
					//int iL = ([[aText substringToIndex:iSubstringIndex] length]/iCharEachLine+1);
					//int iPxSingle = iL*iFontSize*1.45+25;
					//iPxTotal += iPxSingle;
					//NSLog(@"[SubStringMulti]iPxTotal:%d,iPxSingle:%d",iPxTotal,iPxSingle);
				}
				
				bLastPicture = NO;
			}
		}	
		else
		{
			if([aType isEqualToString:@"p"])
			{
				//desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:aText];
                desPath = [aText getDocPathWithPList];
				CGSize aS = aImg.size;
				if(aS.width > _pixelWidth)
					aTmp = [NSString stringWithFormat:@"%@%@\" width=\"%d\" />%@",sFormat,desPath,_imgResolution,@"</p>\n"];
				else
					aTmp = [NSString stringWithFormat:@"%@%@\" />%@",sFormat,desPath,@"</p>\n"];
				
                //NSLog(@"%@",aTmp);
				//[aImg release];
			}else
			{
				//NSMutableString *_aText = [self convertHalfNumberToFull:aText];
				//iCountHalfChar = [self countHalfNumber:aText];
				//NSLog(@"countHalfNumber: %d",iCountHalfChar);
                
                if(bHasMarkData)
                    aText = [self makeMarkHighLight:_rowid aText:aText iDataStartFrom:id_next_start_from];
                
				aTmp = [NSString stringWithFormat:@"%@%@%@",sFormat,aText,@"</p>\n"];
			}
		}
		
		
		//判斷分章節的時候的動作 
		if((((i > 2  && [aType isEqualToString:@"0"]) || [aType isEqualToString:@"z"]) && breakMark == NO && !(i == iNextStart && bRemainMark == NO)) || 
		   (([aType isEqualToString:@"1"] || [aType isEqualToString:@"2"] || [aType isEqualToString:@"3"] || 
			 [aType isEqualToString:@"4"] || [aType isEqualToString:@"5"] || [aType isEqualToString:@"6"] ||
			 [aType isEqualToString:@"7"] || [aType isEqualToString:@"8"]  || [aType isEqualToString:@"9"]) && iPxTotal+50 > _pixelHeight))
		{
			iNextStart = i;
			breakMark = YES;
            if([aType isEqualToString:@"0"])
            {    
                hasChapMark -= 1;
                //NSLog(@"The hasChapTer mark is minused 1 in count;%d,_array_count:%d",i,iArrayCount);
                //add iArrayCount > 2 to prevent the caculate error in some book index first page jonliu33 20110801
                if(iArrayCount > 2 && iArrayCount - iLastAddIndex == 1) 
                {
                    hasChapMark += 1;
                    //NSLog(@"The hasChapTer mark is raised to YES bcs 1pge in count;%d,iLastAdd:%d,_array_count:%d",i,iLastAddIndex,iArrayCount);
                }
                
            }
            if([aType isEqualToString:@"z"])
            {    
                hasZMark = NO;
                //NSLog(@"The hasChapTer mark is canceled in count;%d,_array_count:%d",i,iArrayCount);
                /*if(iArrayCount - iLastAddIndex == 1)
                {
                    hasZMark = YES;
                    //NSLog(@"The hasChapTer mark is raised to YES bcs 1pge in count;%d,iLastAdd:%d,_array_count:%d",i,iLastAddIndex,iArrayCount);
                }*/
                
            }

            break;
            
		}else
		{
			[convertedString appendString:aTmp];
			breakMark = NO;
		}
		
		//[aTmp release];
		
		//iLastLine = iLine;
		iLastPxTotal = iPxTotal;
		if(iPxTotal > _pixelHeight || iPxTotal == 0)//if(iLine >24)
		{
			//iLine = [[aText substringFromIndex:iCharEachLine] length]/iCharEachLine+1;
			iNextStart = i+1;
			break;
		}else {
			iNextStart = i;
		}

	}
	

    if(!bPreface)
        [convertedString appendString:pageInfo];
    
	[convertedString appendString:aEnd];
    aHtml = [convertedString copy];
    
    //NSLog(@"%@",aHtml);
    //add the pagenum to index_array
    if(([[array_type objectAtIndex:0] isEqualToString:@"z"] && iArrayCount == 0) || hasZMark)
    {    
        [array_index_pagenum addObject:[NSString stringWithFormat:@"%d",iArrayCount]];
        hasZMark = NO;
        //NSLog(@"The book page has bee added to array in page:%d",iArrayCount);
    }

    if(hasChapMark > 0 || iArrayCount == 0)
    {
        [array_index_pagenum addObject:[NSString stringWithFormat:@"%d",iArrayCount]];
        hasChapMark = 0;
        //NSLog(@"The index page has bee added to array in page:%d",iArrayCount);
    }
	iCurrentPage++;
	NSString *sP = [NSString stringWithFormat:@"%d",iCurrentPage];
	self.pageNumber = sP;
	//[sP release];
	
	
	
	
	//indexNextStart = nil; 
	//NString *st = [NSString stringWithFormat:@"%d",iNextStart];
	//indexNextStart  = [NSString stringWithFormat:@"%d",iNextStart];
	//[st release];
	self.indexNextStart = (NSInteger)iNextStart;
	return NO;
}

/*NSInteger intSort1(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}*/


- (NSMutableString *)makeMarkHighLight:(NSString*)arowid aText:(NSMutableString *)aText iDataStartFrom:(NSInteger)iDataStartFrom
{
    NSInteger iLimitLength = iDataStartFrom + [aText length];
    
    NSMutableArray *_rarray = [dic_mark_text valueForKey:arowid];
    NSMutableArray *_marray = [[NSMutableArray alloc] init];
    
    if(_rarray != nil)
    {
        for(int i = 0; i < [_rarray count];i++)
        {
            NSMutableDictionary *_darray = [_rarray objectAtIndex:i];
            NSInteger _markstart = [[_darray objectForKey:@"astart"] integerValue];
            NSInteger _markend = [[_darray objectForKey:@"aend"] integerValue];
            NSString *theText = [_darray objectForKey:@"text"];
            NSNumber *iPercent = [_darray objectForKey:@"pagepercent"];
            NSString *_rowID = [_darray objectForKey:@"rowID"];
            NSString *_sopt1 = [_darray objectForKey:@"opt1"];// mark:0 or note:1
            NSString *_sopt2 = [_darray objectForKey:@"opt2"];// noteText number key in the _$booknote.plist
            //NSLog(@"start:%d,end:%d",_markstart,_markend);
            
            if(_markstart >= iDataStartFrom && _markend <= iLimitLength)
            {
                [_marray addObject:[NSNumber numberWithInt:(_markstart-iDataStartFrom)]];
                [_marray addObject:[NSNumber numberWithInt:(_markend-iDataStartFrom)]];
                [_marray addObject:_sopt1];
                [_marray addObject:_sopt2];
            }
            else if(iLimitLength > _markstart && iLimitLength < _markend)
            {
                
                [_marray addObject:[NSNumber numberWithInt:(_markstart-iDataStartFrom)]];
                [_marray addObject:[NSNumber numberWithInt:(iLimitLength-iDataStartFrom)]];
                [_marray addObject:_sopt1];
                [_marray addObject:_sopt2];
                
                NSMutableDictionary *_updateDictionary = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *_updateDictionary1 = [[NSMutableDictionary alloc] init];
                
                [_updateDictionary setObject:[NSNumber numberWithInteger:_markstart] forKey:@"astart"];
                [_updateDictionary setObject:[NSNumber numberWithInteger:iLimitLength] forKey:@"aend"];
                //add some more information
                NSInteger iCutIndex = iLimitLength-_markstart;
                NSString *theText1 = [theText substringToIndex:iCutIndex];
                //NSLog(@"iPercent:%d",[iPercent integerValue]);
                //NSLog(@"theText1:%@",theText1);
                
                [_updateDictionary setObject:theText1 forKey:@"text"];
                [_updateDictionary setObject:iPercent forKey:@"pagepercent"];
                [_updateDictionary setObject:_rowID forKey:@"rowID"];
                [_updateDictionary setObject:@"0" forKey:@"markColor"];
                [_updateDictionary setObject:_sopt1 forKey:@"opt1"];
                [_updateDictionary setObject:@"0" forKey:@"opt2"];
                [_updateDictionary setObject:@"0" forKey:@"opt3"];
                [_updateDictionary setObject:@"0" forKey:@"opt4"];
                [_updateDictionary setObject:@"0" forKey:@"opt5"];
                [_updateDictionary setObject:@"0" forKey:@"opt6"];
                [_updateDictionary setObject:@"0" forKey:@"opt7"];
                [_updateDictionary setObject:@"0" forKey:@"opt8"];
                [_updateDictionary setObject:@"0" forKey:@"opt9"];
                
                [_updateDictionary1 setObject:[NSNumber numberWithInteger:iLimitLength] forKey:@"astart"];
                [_updateDictionary1 setObject:[NSNumber numberWithInteger:_markend] forKey:@"aend"];
                 //add some more information
                NSString *theText2 = [theText substringFromIndex:iCutIndex];
                 //NSLog(@"theText2:%@",theText2);
                [_updateDictionary1 setObject:theText2 forKey:@"text"];
                [_updateDictionary1 setObject:iPercent forKey:@"pagepercent"];
                [_updateDictionary1 setObject:_rowID forKey:@"rowID"];
                [_updateDictionary1 setObject:@"0" forKey:@"markColor"];
                [_updateDictionary1 setObject:_sopt1 forKey:@"opt1"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt2"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt3"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt4"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt5"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt6"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt7"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt8"];
                [_updateDictionary1 setObject:@"0" forKey:@"opt9"];
                
                [_rarray removeObjectAtIndex:i];
                [_rarray addObject:_updateDictionary];
                [_rarray addObject:_updateDictionary1];
                
                NSSortDescriptor * descriptor = [[[NSSortDescriptor alloc] initWithKey:@"astart" 
                                                                             ascending:YES] autorelease]; // 1
                [_rarray sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];

                
                /*[_rarray removeObjectAtIndex:i];
                [_rarray removeObjectAtIndex:i];
                
                [_rarray addObject:[NSString stringWithFormat:@"%d",_markstart]];
                [_rarray addObject:[NSString stringWithFormat:@"%d",iLimitLength]];
                [_rarray addObject:[NSString stringWithFormat:@"%d",iLimitLength]];
                [_rarray addObject:[NSString stringWithFormat:@"%d",_markend]];
                
                [_rarray sortUsingFunction:intSort1 context:NULL];*/
                
                [dic_mark_text setObject:_rarray forKey:arowid];
                
                NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",bookNumber] getDocPathWithPList];
                [dic_mark_text writeToFile:myPath atomically:YES];
                
                
                 [_updateDictionary release];
                [_updateDictionary1 release];
            }

            
        }
        

        /*for(int i = 0; i < [_rarray count]; i+=2)
        {
            NSString *_rs = [_rarray objectAtIndex:0+i];
            NSString *_rs1 = [_rarray objectAtIndex:1+i];
            NSLog(@"start:%@,end:%@",_rs,_rs1);
            NSInteger _markstart = [_rs integerValue];
            NSInteger _markend =  [_rs1 integerValue];
            
            if(_markstart >= iDataStartFrom && _markend <= iLimitLength)
            {
                [_marray addObject:[NSNumber numberWithInt:(_markstart-iDataStartFrom)]];
                [_marray addObject:[NSNumber numberWithInt:(_markend-iDataStartFrom)]];
            }else if(iLimitLength > _markstart && iLimitLength < _markend)
            {
                
                [_marray addObject:[NSNumber numberWithInt:(_markstart-iDataStartFrom)]];
                [_marray addObject:[NSNumber numberWithInt:(iLimitLength-iDataStartFrom)]];
                
                [_rarray removeObjectAtIndex:i];
                [_rarray removeObjectAtIndex:i];
                
                [_rarray addObject:[NSString stringWithFormat:@"%d",_markstart]];
                [_rarray addObject:[NSString stringWithFormat:@"%d",iLimitLength]];
                [_rarray addObject:[NSString stringWithFormat:@"%d",iLimitLength]];
                [_rarray addObject:[NSString stringWithFormat:@"%d",_markend]];
                
                [_rarray sortUsingFunction:intSort1 context:NULL];
                
                [dic_mark_text setObject:_rarray forKey:arowid];
                
                NSString *myPath = [[NSString stringWithFormat:@"_%@marktext.plist",bookNumber] getDocPathWithPList];
                [dic_mark_text writeToFile:myPath atomically:YES];

            }
            
        }*/
        
        NSString *opt1_;
        NSString *opt2_;
        int _iAdjust = 0;
        int _lastAdd = 0;
        for(int i = 0; i < [_marray count]; i+=4)
        {
            NSInteger _markstart = [[_marray objectAtIndex:0+i] intValue];
            NSInteger _markend =  [[_marray objectAtIndex:1+i] intValue];
            opt1_ = [_marray objectAtIndex:2+i];
            opt2_ = [_marray objectAtIndex:3+i];
            
            if(i >= 4)
            {
                _iAdjust+=_lastAdd;
                // NSLog(@"_iadjust:%i,_lastAdd:%i",_iAdjust,_lastAdd);
                _markstart+=_iAdjust;
                _markend+=_iAdjust;
               
            }
            
            NSRange _range = NSMakeRange(_markstart, _markend - _markstart);
            NSString *_text = [aText substringWithRange:_range];
            //NSLog(@"sopt1:%@,%@",opt1_,_text);
            NSString *_rtext;
            if([opt1_ isEqualToString:@"1"]) //has note
                _rtext = [NSString stringWithFormat:@"%@%@%@%@%@",@"<font class=\"hlnote\" onclick=\"processNote(",opt2_,@")\">",_text,@"</font>"];
            else 
                _rtext = [NSString stringWithFormat:@"%@%@%@",@"<font class=\"hl\">",_text,@"</font>"];
            aText = [NSMutableString stringWithString:[aText stringByReplacingOccurrencesOfString:_text withString:_rtext options:0 range:_range]];
            
           
            //24因為<font class="hl"></font>長度是24,28因為<font class="hlnote" onclick="processNote(20120623031054)"></font>長度是66
            _lastAdd = [opt1_ isEqualToString:@"0"]?24:66;
        }
    }
    [_marray release];
    return  aText;
}

- (void)checkFile
{
	//htmlPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:htmlName];
	htmlPath = [htmlName getDocPathWithPList];
	//For temp move back backup
	BOOL success;
	
	
	//NSString *backPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:databaseName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	success = [fileManager fileExistsAtPath:htmlPath];
	
	if(success)
	{
		
		//NSString *tempPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"back.html"];
        NSString *backName = @"back.html";
        
		NSString *tempPath = [backName getDocPathWithPList];
        
		if([fileManager fileExistsAtPath:tempPath])
			[fileManager removeItemAtPath:tempPath error:nil];
		[fileManager copyItemAtPath:htmlPath toPath:tempPath error:nil];
		
	}
	//[fileManager release];
}

- (void)saveToFile:(NSMutableString *)sHtml
{
	NSError *error = nil;
	[sHtml writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];	
	//NSLog(@"error: %@", error.localizedFailureReason);
	
}

- (void)dealloc	
{
    
    [cssString release];
    [_lastSetRowId release];
    dic_mark_text = nil;
    [sFontType release];
    [sFontType1 release];
    [sFontColor release];
    [sHighLightColor release];
	[aHtml release];
    [iHtml release];
    [iCHtml release];
    [preHtml release];
    
	/*[array_chap release];
	[array_type release];
	[array_text release];
    [array_rowid release];
    
    [array_pre_type release];
    [array_pre_text release];
    [array_pre_chap release];
    [array_pre_rowid release];
    [array_pre_html release];
    
    [array_index_chap release];
    [array_index_type release];
    [array_index_pagenum release];
    [array_index_html release];
    [array_index_text release];
     
    
    [array_row_page_index release];
    */
	[super dealloc];
}
@end
