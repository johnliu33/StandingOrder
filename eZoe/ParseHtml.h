//
//  ParseHtml.h
//  PDFViewerHD
//
//  Created by John Liu on 2010/12/22.
//  Copyright 2010 Samountech.com. All rights reserved.
//
#define kCacLine (NSInteger)((float)iSize/(float)iCharEachLine)+1;

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Global.h"

@interface ParseHtml : NSObject {

	NSString *bookNumber;
	NSString *bookName;
	NSString *databaseName;
	NSString *sql;
	NSString *htmlName;
	NSString *htmlPath;
	NSInteger lineCharactersNumber;
    NSInteger _lineCharacterBias;
    NSInteger lineCharactersNumber_L;
	NSInteger indexNextStart; //前一頁最後一個db index test
	BOOL	bLastPicture;
	NSInteger lastPicturePx;
	
	NSString *databasePath;
	
    NSMutableString *cssString;
	NSString *aHtml;
    NSMutableString *iHtml; //for cover page
    NSMutableString *iCHtml;//for innver cover page
    NSMutableString *preHtml;//for preFace pages
	NSString *sRemainText;
    NSString *sRemainPureText;
	
    //book content
	NSMutableArray *array_type;
	NSMutableArray *array_text;
	NSMutableArray *array_chap;
    NSMutableArray *array_rowid;
    
    NSMutableDictionary *array_row_page_index; //for search
	
    //book preface
    NSMutableArray *array_pre_type;
    NSMutableArray *array_pre_text;
    NSMutableArray *array_pre_chap;
    NSMutableArray *array_pre_rowid;
    NSMutableArray *array_pre_html;
    
    //book index
    NSMutableArray *array_index_type;
    NSMutableArray *array_index_text;
    NSMutableArray *array_index_chap;
    NSMutableArray *array_index_pagenum;
    NSMutableArray *array_index_html;

    //Mark the text info
    BOOL bHasMarkData;
    BOOL bCheckMark;
    NSMutableDictionary *dic_mark_text;
    NSInteger id_next_start_from;
    NSString  *_lastSetRowId;
    
	NSString *pageNumber;
	BOOL bFinalPage;
    
	
	//Page layout
	NSInteger pixelHeight;
	NSInteger pixelWidth;
    NSInteger pixelHeight_L;
	NSInteger pixelWidth_L;
    
    NSInteger pixelWidthReading;
    NSInteger pixelWidthReading_L;
    
    NSInteger pixelWidthHymn;
    NSInteger pixelWidthHymn_L;
    
    NSInteger iFontSize;//字型大小
    NSString *sFontType;//字體
    NSString *sFontType1;//字體1
    NSString *sFontColor;//字顏色
    NSString *sHighLightColor;//標記顏色
    NSString *sNoteLightColor;//筆記顏色
    NSString *sNoteDash;
	
	//Style layout
	NSInteger icharEachLineVerses;
    NSInteger icharEachLineVerses_L;
	
	//control chapter
	BOOL breakMark;
	BOOL bRemainMark;
	BOOL bFinalMark;
    NSUInteger hasChapMark; //控制計算目錄中的頁數
    BOOL hasBookZMark; //控制多本和一的書本title
    BOOL hasZMark;      //調整計算z在index page array的影響
    
    //memory last status
    NSInteger iLastOrientation; //0:portrait 1:landscape
    NSInteger iLastPage;
    NSInteger iLastPercent;
    
    NSMutableArray *htmlPages;
    NSMutableArray *htmlPrefacePages;
    
    NSInteger iCoverPageCount;
    NSInteger iIndexPageCount;
    NSInteger iPrefacePageCount;
    
	
}
@property(nonatomic,retain) NSMutableArray *htmlPages;
@property(nonatomic,retain) NSMutableArray *htmlPrefacePages;
@property(nonatomic, copy) NSMutableString *cssString;
@property(nonatomic, retain) NSString *aHtml;
@property(nonatomic, retain) NSMutableString *iHtml;
@property(nonatomic, retain) NSMutableString *iCHtml;
@property(nonatomic, copy) NSMutableString *preHtml;
@property(nonatomic, copy) NSString *bookNumber;
@property(nonatomic, copy) NSString *bookName;
@property(nonatomic, copy) NSString *databaseName;
@property(nonatomic, copy) NSString *databasePath;
@property(nonatomic, copy) NSString *htmlName;
@property(nonatomic, copy) NSString *htmlPath;
@property(nonatomic, copy) NSString *sql;
@property(nonatomic, copy) NSString *pageNumber;
@property(nonatomic, assign) NSInteger lineCharactersNumber;
@property(nonatomic, assign) NSInteger lineCharactersNumber_L;
@property(nonatomic, assign) BOOL bLastPicture;
@property(nonatomic, assign) NSInteger lastPicturePx;
@property(nonatomic, assign) NSInteger indexNextStart;
@property(nonatomic, assign) BOOL bFinalPage;
@property(nonatomic, assign) BOOL bFinalMark;
@property(nonatomic, assign) NSInteger iCoverPageCount;
@property(nonatomic, assign) NSInteger iIndexPageCount;
@property(nonatomic, assign) NSInteger iPrefacePageCount;

@property(nonatomic, assign) NSInteger pixelHeight;
@property(nonatomic, assign) NSInteger pixelWidth;
@property(nonatomic, assign) NSInteger pixelHeight_L;
@property(nonatomic, assign) NSInteger pixelWidth_L;
@property(nonatomic, assign) NSInteger pixelWidthReading;
@property(nonatomic, assign) NSInteger pixelWidthReading_L;
@property(nonatomic, assign) NSInteger pixelWidthHymn;
@property(nonatomic, assign) NSInteger pixelWidthHymn_L;


@property(nonatomic, assign) NSInteger iFontSize;
@property(nonatomic, copy)   NSString *sFontType;
@property(nonatomic, copy)   NSString *sFontType1;
@property(nonatomic, copy)   NSString *sFontColor;
@property(nonatomic, copy)   NSString *sHighLightColor;
@property(nonatomic, copy)   NSString *sNoteLightColor;
@property(nonatomic, copy)   NSString *sNoteDash;

@property(nonatomic, assign) NSInteger icharEachLineVerses;
@property(nonatomic, assign) NSInteger icharEachLineVerses_L;

@property(nonatomic, assign)NSInteger iLastOrientation;
@property(nonatomic, assign)NSInteger iLastPage;
@property(nonatomic, assign)NSInteger iLastPercent;

@property(nonatomic, retain)NSMutableDictionary *dic_mark_text;
@property(nonatomic, copy)  NSString  *_lastSetRowId;

//index pages
@property(nonatomic, retain) NSMutableArray *array_index_html;
@property(nonatomic, retain) NSMutableArray *array_index_text;
@property(nonatomic, retain) NSMutableArray *array_index_pagenum;
//preface pages
@property(nonatomic, retain) NSMutableArray *array_pre_html;

//for search
@property(nonatomic, retain) NSMutableDictionary *array_row_page_index;

+ (ParseHtml *)withBookNumber:(NSString *)bookNumber fontSize:(NSInteger)iFontSize BGType:(NSInteger)iBGType fontType:(NSInteger)iFontType inPutsql:(NSString *)inPutsql orientation:(NSInteger)orientation;

- (void)createDocumentPages:(NSInteger)orientation;

- (id)initWithBookNumber:(NSString *)_bookNumber fontSize:(NSInteger)_iFontSize BGType:(NSInteger)_iBGType fontType:(NSInteger)_iFontType;
- (void)readFromPlistData;
- (void)checkAndCreateDatabase;
- (void)copyFileFromResource:(NSString *)fileName;
- (void)loadFromDb;

- (void)loadPrefaceFromDb;
- (void)loadBookIndex_CoverPage;
//直向CSS
- (NSMutableString *)loadCSS;
- (NSMutableString *)loadCSS_iPhone;
//橫向CSS
- (NSMutableString *)loadCSS_L;
//- (NSMutableString *)loadCSS_L_iPhone:(NSMutableString *)cssHtml;
//排版
- (NSInteger)TagHeight:(NSInteger)_iSize fontSize:(float)_fontSize lineHeight:(float)_lineHeight padding:(float)_padding pageWidth:(NSInteger)_pageWidth lineBias:(NSInteger)_lineBias; //計整tag高度
- (BOOL)convertToHtml:(NSInteger)iArrayCount isPreFace:(BOOL)bPreface isLandscape:(BOOL)bLandscape;
- (BOOL)convertToHtml_iphone:(NSInteger)iArrayCount isPreFace:(BOOL)bPreface isLandscape:(BOOL)bLandscape;
- (void)createIndexPage_:(BOOL)bLandscape;
- (void)createCoverPage_:(BOOL)bLandscape;
- (void)createInnerCoverPage_:(BOOL)bLandscape;

- (void)checkFile;
- (void)saveToFile:(NSMutableString *)sHtml;
- (NSMutableString *)convertHalfNumberToFull:(NSString *)text;
- (int)occurrencesOfString:(NSString *)myString findString:(NSString *)findString;
- (NSInteger)countHalfNumber:(NSString *)text;

- (NSInteger)checkFontSizeAvalible:(NSInteger)orignFontSize;

//read mark text data
- (BOOL)readMarkDataFromPlist;
- (NSMutableString *)makeMarkHighLight:(NSString*)arowid aText:(NSMutableString *)aText iDataStartFrom:(NSInteger)iDataStartFrom;


@end
