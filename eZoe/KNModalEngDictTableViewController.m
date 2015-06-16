//
//  KNModalTableViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "KNModalEngDictTableViewController.h"
#import "eZoeAppDelegate.h"
#import "math.h"
@interface KNModalEngDictTableViewController ()

@end

@implementation KNModalEngDictTableViewController
@synthesize searchBar;
@synthesize findString;
@synthesize _engDict;

- (void)initBibleDict
{
    _engDict = [NSDictionary dictionaryWithObjectsAndKeys:
                  @"1",@"創世記",
                  @"1",@"創",
                  @"2",@"出埃及記",
                  @"2",@"出埃及",                  
                  @"2",@"出",
                  @"3",@"利未記",                               
                  @"3",@"利",
                  @"4",@"民數記",
                  @"4",@"民",
                  @"5",@"申命記",
                  @"5",@"申",
                  @"6",@"約書亞記",
                  @"6",@"書",
                  @"7",@"士師記",
                  @"7",@"士",
                  @"8",@"路得記",                               
                  @"8",@"得",
                  @"9",@"撒母耳記上",
                  @"9",@"撒上",
                  @"10",@"撒母耳記下",
                  @"10",@"撒下",
                  @"11",@"列王紀上",
                  @"11",@"列王記上",
                  @"11",@"王上",
                  @"12",@"列王紀下",
                  @"12",@"列王記下",
                  @"12",@"王下",   
                  @"13",@"歷代志上",
                  @"13",@"代上",
                  @"14",@"歷代志下",
                  @"14",@"代下",
                  @"15",@"以斯拉記",                               
                  @"15",@"以斯拉",                  
                  @"15",@"拉",
                  @"16",@"尼希米記",
                  @"16",@"尼希米",                  
                  @"16",@"尼",
                  @"17",@"以斯帖記",
                  @"17",@"以斯帖",                  
                  @"17",@"斯",
                  @"18",@"約伯記",
                  @"18",@"伯",
                  @"19",@"詩篇",
                  @"19",@"詩",
                  @"20",@"箴言",                               
                  @"20",@"箴",
                  @"21",@"傳道書",
                  @"21",@"傳",
                  @"22",@"雅歌",
                  @"22",@"歌",                    
                  @"23",@"以賽亞書",                               
                  @"23",@"以賽亞",                                                 
                  @"23",@"賽",
                  @"24",@"耶利米書",
                  @"24",@"耶利米",                  
                  @"24",@"耶",
                  @"25",@"耶利米哀歌",
                  @"25",@"哀歌",                  
                  @"25",@"哀",
                  @"26",@"以西結書",
                  @"26",@"結",
                  @"27",@"但以理書",
                  @"27",@"但以理",                  
                  @"27",@"但",
                  @"28",@"何西阿書",                               
                  @"28",@"何西阿",                                                 
                  @"28",@"何",
                  @"29",@"約珥書",
                  @"29",@"珥",
                  @"30",@"阿摩司書",
                  @"30",@"阿摩司",                  
                  @"30",@"摩", 
                  @"31",@"俄巴底亞書",
                  @"31",@"俄巴底亞",                  
                  @"31",@"俄",
                  @"32",@"約拿書",
                  @"32",@"拿",
                  @"33",@"彌迦書",                               
                  @"33",@"彌",
                  @"34",@"那鴻書",
                  @"34",@"鴻",
                  @"35",@"哈巴谷書",
                  @"35",@"哈巴谷",                  
                  @"35",@"哈",
                  @"36",@"西番雅書",
                  @"36",@"西番雅",                  
                  @"36",@"番",
                  @"37",@"哈該書",
                  @"37",@"該",
                  @"38",@"撒迦利亞書",                               
                  @"38",@"撒迦利亞",                                                 
                  @"38",@"亞",
                  @"39",@"瑪拉基書",
                  @"39",@"瑪拉基",                  
                  @"39",@"瑪",                                
                  @"40",@"馬太福音",
                  @"40",@"馬太",
                  @"40",@"太",
                  @"41",@"馬可福音",
                  @"41",@"馬可",
                  @"41",@"可",                                
                  @"42",@"路加福音",
                  @"42",@"路加",                                
                  @"42",@"路", 
                  @"43",@"約翰福音",
                  @"43",@"約翰",
                  @"43",@"約",                                
                  @"44",@"使徒行傳",
                  @"44",@"行傳",                                
                  @"44",@"徒",  
                  @"45",@"羅馬書",
                  @"45",@"羅馬",                                
                  @"45",@"羅",
                  @"46",@"哥林多前書",
                  @"46",@"林前",
                  @"47",@"哥林多後書",
                  @"47",@"林後",
                  @"48",@"加拉太書",
                  @"48",@"加拉太",
                  @"48",@"加",   
                  @"49",@"以弗所書",
                  @"49",@"以弗所",
                  @"49",@"弗",                                
                  @"50",@"腓立比書",
                  @"50",@"腓立比",                                
                  @"50",@"腓", 
                  @"51",@"歌羅西書",
                  @"51",@"歌羅西",
                  @"51",@"西",                                
                  @"52",@"帖撒羅尼迦前書",                                
                  @"52",@"帖前",  
                  @"53",@"帖撒羅尼迦後書",                                
                  @"53",@"帖後",                                  
                  @"54",@"提摩太前書",
                  @"54",@"提前",
                  @"55",@"提摩太後書",
                  @"55",@"提後",                                                            
                  @"56",@"提多書",
                  @"56",@"多",                                
                  @"57",@"腓利門書",
                  @"57",@"腓利門",                                
                  @"57",@"門",    
                  @"58",@"希伯來書",
                  @"58",@"希伯來",                                
                  @"58",@"來",  
                  @"59",@"雅各書",                                
                  @"59",@"雅",
                  @"60",@"彼得前書",
                  @"60",@"彼前",
                  @"61",@"彼得後書",
                  @"61",@"彼後",
                  @"62",@"約翰壹書",
                  @"62",@"約翰一書",
                  @"62",@"約壹",
                  @"63",@"約翰貳書",
                  @"63",@"約翰二書",
                  @"63",@"約貳",
                  @"64",@"約翰參書",
                  @"64",@"約翰三書",
                  @"64",@"約參",                               
                  @"65",@"猶大書",
                  @"65",@"猶",                                
                  @"66",@"啟示錄",
                  @"66",@"啟",                                
                  nil];  

}

- (void)dealloc {
    [super dealloc];
    //[_bibleDict release];
}

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(!TTIsOrienLandscape()) //直向
            self.view.frame = CGRectMake(0, 0, 768, 380);
        else                //橫向
            self.view.frame = CGRectMake(0, 0, 1024, 470);
        
    }else 
    {
        if(!TTIsOrienLandscape()) //直向
            self.view.frame = CGRectMake(0, 0, 320, 300);
        else                //橫向
            self.view.frame = CGRectMake(0, 0, 480, 250);
    }

  
    
    findString = @"";
  
    self.variableHeightRows = YES;
    
  }
  return self;
}

- (NSString *)verseConvert:(int)book chapter:(int)chapter section:(int)section column:(int)column
{
    NSString *_sbook;   
    switch (book) {
        case 1:
            _sbook = @"創世記";
           break;
        case 2:
            _sbook = @"出埃及";
           break;
        case 3:
            _sbook = @"利未記";
           break;
        case 4:
            _sbook = @"民數記";
           break;
        case 5:
            _sbook = @"申命記";
           break;
        case 6:
            _sbook = @"約書亞";
           break;
        case 7:
            _sbook = @"士師記";
           break;
        case 8:
            _sbook = @"路得記";
           break;
        case 9:
            _sbook = @"撒上";
           break;
        case 10:
            _sbook = @"撒下";
           break;     
        case 11:
            _sbook = @"王上";
           break;
        case 12:
            _sbook = @"王下";
            break;
        case 13:
            _sbook = @"代上";
           break;
        case 14:
            _sbook = @"代下";
           break;
        case 15:
            _sbook = @"以斯拉";
           break;
        case 16:
            _sbook = @"尼希米";
            break;
        case 17:
            _sbook = @"以斯帖";
            break;
        case 18:
            _sbook = @"約伯記";
            break;
        case 19:
            _sbook = @"詩篇";
            break;
        case 20:
            _sbook = @"箴言";
            break;    
        case 21:
            _sbook = @"傳道書";
            break;
        case 22:
            _sbook = @"雅歌";
            break;
        case 23:
            _sbook = @"以賽亞";
            break;
        case 24:
            _sbook = @"耶利米";
            break;
        case 25:
            _sbook = @"哀歌";
            break;
        case 26:
            _sbook = @"以西結";
            break;
        case 27:
            _sbook = @"但以理";
            break;
        case 28:
            _sbook = @"何西阿";
            break;
        case 29:
            _sbook = @"約珥書";
            break;
        case 30:
            _sbook = @"阿摩司";
            break;             
        case 31:
            _sbook = @"俄巴底亞";
            break;
        case 32:
            _sbook = @"約拿書";
            break;
        case 33:
            _sbook = @"彌迦書";
            break;
        case 34:
            _sbook = @"那鴻書";
            break;
        case 35:
            _sbook = @"哈巴谷";
            break;
        case 36:
            _sbook = @"西番雅";
            break;
        case 37:
            _sbook = @"哈該書";
            break;
        case 38:
            _sbook = @"撒迦利亞";
            break;
        case 39:
            _sbook = @"瑪拉基";
            break;
        case 40:
            _sbook = @"馬太";
            break;     
        case 41:
            _sbook = @"馬可";
            break;
        case 42:
            _sbook = @"路加";
            break;
        case 43:
            _sbook = @"約翰";
            break;
        case 44:
            _sbook = @"行傳";
            break;
        case 45:
            _sbook = @"羅馬";
            break;
        case 46:
            _sbook = @"林前";
            break;
        case 47:
            _sbook = @"林後";
            break;
        case 48:
            _sbook = @"加拉太";
            break;
        case 49:
            _sbook = @"以弗所";
            break;
        case 50:
            _sbook = @"腓立比";
            break;    
        case 51:
            _sbook = @"歌羅西";
            break;
        case 52:
            _sbook = @"帖前";
            break;
        case 53:
            _sbook = @"帖後";
            break;
        case 54:
            _sbook = @"提前";
            break;
        case 55:
            _sbook = @"提後";
            break;
        case 56:
            _sbook = @"提多書";
            break;
        case 57:
            _sbook = @"腓利門";
            break;
        case 58:
            _sbook = @"希伯來";
            break;
        case 59:
            _sbook = @"雅各書";
            break;
        case 60:
            _sbook = @"彼前";
            break;            
        case 61:
            _sbook = @"彼後";
            break;
        case 62:
            _sbook = @"約壹";
            break;
        case 63:
            _sbook = @"約貳";
            break;
        case 64:
            _sbook = @"約參";
            break;
        case 65:
            _sbook = @"猶大書";
            break;
        case 66:
            _sbook = @"啟示錄";
            break;
            
        default:
            _sbook = @"其它書卷";
            break;
    }
    
    return [NSString stringWithFormat:@"%@%i章%i節",_sbook,chapter,section];
}

- (NSString *)filterDecimalNumber:(NSString *)strText
{
    NSString *_a = @"～，";
    NSMutableString *_filteredString = [NSMutableString stringWithString:@""];
    for (NSUInteger i = 0; i < [strText length]; i++)
    {
        unichar character = [strText characterAtIndex:i];
        if(character == [_a characterAtIndex:0] || character == [_a characterAtIndex:1])
            break;
        
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:character])
        {
            [_filteredString appendFormat:@"%C",character];
        }
        
    }
    NSLog(@"Filtered Chinese Number:%@",_filteredString);
    return _filteredString;
}

- (NSString *)filterChineseNumber:(NSString *)strText
{
    NSMutableString *_filteredString = [NSMutableString stringWithString:@""];
    NSCharacterSet* charactersOfChinese = [NSCharacterSet characterSetWithCharactersInString:@"十一二三四五六七八九百"];
    for (NSUInteger i = 0; i < [strText length]; i++)
    {
        unichar character = [strText characterAtIndex:i];
        if ([charactersOfChinese characterIsMember:character])
        {
            [_filteredString appendFormat:@"%C",character];
        }
        
    }
    NSLog(@"Filtered Chinese Number:%@",_filteredString);
    return _filteredString;
}

- (int)convertChineseNumber:(NSString *)strNumber
{
    
    NSUInteger len = [strNumber length];
    unichar *buffer = calloc(len, sizeof(unichar));
    //unichar a[10];
    NSString *aString = @"十一二三四五六七八九百";
    //if (!buffer) return;
    
    [strNumber getCharacters:buffer range:NSMakeRange(0, len)];
    //NSMutableString *_newNumber = [NSMutableString stringWithCapacity:1];
   
    //for (int i = 0; i < 10; i++)
    //    a[i] = [aString characterAtIndex:i];
    NSUInteger _iNew = 0;
    NSUInteger _iLastAdd = 0;
    for (NSUInteger i = 0; i < len; i++)
    {
        
        NSLog(@"%C",buffer[i]);
        if(buffer[i] == [aString characterAtIndex:0])
        {
            if(_iNew > 0)
            {
                _iNew -=_iLastAdd;
                _iNew += 10*_iLastAdd;
            }else
                _iNew += 10;
        }
        else if(buffer[i] == [aString characterAtIndex:1])
        {
            _iNew += 1;
            _iLastAdd = 1;
        }
        else if(buffer[i] == [aString characterAtIndex:2])
        {
            _iNew += 2;
            _iLastAdd = 2;
        }
        else if(buffer[i] == [aString characterAtIndex:3])
        {
            _iNew += 3;
            _iLastAdd = 3;
        }
        else if(buffer[i] == [aString characterAtIndex:4])
        {
            _iNew += 4;
            _iLastAdd = 4;
        }
        else if(buffer[i] == [aString characterAtIndex:5])
        {
            _iNew += 5;
            _iLastAdd = 5;
        }
        else if(buffer[i] == [aString characterAtIndex:6])
        {
            _iNew += 6;
            _iLastAdd = 6;
        }
        else if(buffer[i] == [aString characterAtIndex:7])
        {
            _iNew += 7;
            _iLastAdd = 7;
        }
        else if(buffer[i] == [aString characterAtIndex:8])
        {
            _iNew += 8;
            _iLastAdd = 8;
        }
        else if(buffer[i] == [aString characterAtIndex:9])
        {
            _iNew += 9;
            _iLastAdd = 9;
        }else if(buffer[i] ==[aString characterAtIndex:10])
        {
            _iNew -=_iLastAdd;
            _iNew += 100*_iLastAdd;
        }
        
    }
    free(buffer);
    
    return _iNew;
}

- (int)convertChineseNumber1:(NSString *)strNumber
{
    
    NSUInteger len = [strNumber length];
    unichar *buffer = calloc(len, sizeof(unichar));
    //unichar a[10];
    NSString *aString = @"十一二三四五六七八九";
    //if (!buffer) return;
    
    [strNumber getCharacters:buffer range:NSMakeRange(0, len)];
    //NSMutableString *_newNumber = [NSMutableString stringWithCapacity:1];
    
    //for (int i = 0; i < 10; i++)
    //    a[i] = [aString characterAtIndex:i];
    NSUInteger _iNew = 0;
    //NSUInteger _iLastAdd = 0;
    int _powI = 0;
    for (int i = len-1; i >= 0; i--)
    {
        
        NSLog(@"%C",buffer[i]);
        if(buffer[i] == [aString characterAtIndex:0])
        {
            if(_powI != 0 || len == 1)
                _iNew += 10;
        }
        else if(buffer[i] == [aString characterAtIndex:1])
        {
            _iNew += 1*pow(10,_powI);
            //_iLastAdd = 1;
        }
        else if(buffer[i] == [aString characterAtIndex:2])
        {
            _iNew += 2*pow(10,_powI);
            //_iLastAdd = 2;
        }
        else if(buffer[i] == [aString characterAtIndex:3])
        {
            _iNew += 3*pow(10,_powI);
            //_iLastAdd = 3;
        }
        else if(buffer[i] == [aString characterAtIndex:4])
        {
            _iNew += 4*pow(10,_powI);
            //_iLastAdd = 4;
        }
        else if(buffer[i] == [aString characterAtIndex:5])
        {
            _iNew += 5*pow(10,_powI);
            //_iLastAdd = 5;
        }
        else if(buffer[i] == [aString characterAtIndex:6])
        {
            _iNew += 6*pow(10,_powI);
            //_iLastAdd = 6;
        }
        else if(buffer[i] == [aString characterAtIndex:7])
        {
            _iNew += 7*pow(10,_powI);
            //_iLastAdd = 7;
        }
        else if(buffer[i] == [aString characterAtIndex:8])
        {
            _iNew += 8*pow(10,_powI);
            //_iLastAdd = 8;
        }
        else if(buffer[i] == [aString characterAtIndex:9])
        {
            _iNew += 9*pow(10,_powI);
            //_iLastAdd = 9;
        }
        _powI++;
    }
    free(buffer);
    
    return _iNew;
}

//myformatedVerse格式說明 "@@@$$$###"
//@@@書名
//$$$章名
//###節名
- (void)findVerseShort:(NSString *)myformatedVerse
{
    int _iBook = 0;
    int _iC = 0;
    int _iS = 0;
    
    //NSMutableString *_myText = [NSMutableString stringWithString:myformatedVerse];
    _iBook = [[myformatedVerse substringToIndex:3] intValue];
    NSRange _r;
    _r.location = 3;
    _r.length = 3;
    _iC = [[myformatedVerse substringWithRange:_r] intValue];
    _iS = [[myformatedVerse substringFromIndex:6] intValue];
    
    NSLog(@"書:%i,章:%i,節:%i",_iBook,_iC,_iS);
    
    eZoeAppDelegate *app = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate] ;
    
    NSMutableArray *_resultarray = [NSMutableArray arrayWithCapacity:3];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT book,chapter,section,column,verse FROM hant where book = %i and chapter = %i and section between %i and %i",_iBook,_iC,_iS,_iS+5];
    NSLog(@"sql:%@",sql);
    sqlite3_stmt *statement = [app.dbHelper executeQuery:sql];
    
    
    
    while(sqlite3_step(statement) == SQLITE_ROW){
        
        int _book = sqlite3_column_int(statement, 0);
        int _chapter = sqlite3_column_int(statement, 1);
        int _section = sqlite3_column_int(statement, 2);
        int _column = sqlite3_column_int(statement, 3);
        NSString *_verse = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        
        
        TTTableSubtextItem *_item = [TTTableSubtextItem itemWithText:[self verseConvert:_book chapter:_chapter section:_section column:_column] 
                                                             caption:_verse];
        [_resultarray addObject:_item];
    }
    self.dataSource = [TTListDataSource dataSourceWithItems:_resultarray];
}
/*
- (void)findVerse:(NSString *)myfindVerse
{
    NSRange _rBook;
    NSRange _rCh;
    NSRange _rSe;
    //NSRange _rRange;
    NSRange _rHymn;
   
    NSArray *_bibleKeys = [_bibleDict allKeys];
    NSRange _find;
    int _iBook = 0;
    NSMutableString *_fixBookName = [NSMutableString stringWithString:@""];
    
    for(NSString *_bookNames in _bibleKeys)
    {
        _find = [myfindVerse rangeOfString:_bookNames];
        if(_find.location != NSNotFound)
        {
            _iBook =  [[_bibleDict objectForKey:_bookNames] intValue];
            [_fixBookName setString:_bookNames];
            if([_fixBookName isEqualToString:@"拉"] && [myfindVerse rangeOfString:@"加拉太"].location != NSNotFound)
                continue;
            if(([_fixBookName isEqualToString:@"羅"] || [_fixBookName isEqualToString:@"歌"]) && [myfindVerse rangeOfString:@"歌羅西"].location != NSNotFound)
                continue;
            if(([_fixBookName isEqualToString:@"耶"] || [_fixBookName isEqualToString:@"歌"]) && [myfindVerse rangeOfString:@"耶利米哀歌"].location != NSNotFound)
                continue;
            else
                break;
        }
    }                     
    if(_iBook == 0)
    {
        NSLog(@"There is no book information:%@",myfindVerse);
        return;
    }
    NSLog(@"Found in myVerse:%@ BookName:%@",myfindVerse,_fixBookName);

    _rBook = [myfindVerse rangeOfString:_fixBookName];
    
    
    NSString *Book_ = [NSString stringWithString:[myfindVerse substringWithRange:_rBook]];

    NSString *myfindVerse0;
    
    if([Book_ isEqualToString:@"詩"])
        myfindVerse0 = [NSString stringWithString:[myfindVerse substringFromIndex:_rBook.location+_rBook.length+1]];
    else
        myfindVerse0 = [NSString stringWithString:[myfindVerse substringFromIndex:_rBook.location+_rBook.length]];
    
    //找章的數字中文
    _rCh = [myfindVerse0 rangeOfString:@"章"];
    _rHymn = [myfindVerse0 rangeOfString:@"篇"];
    NSString *Ch_;
    NSString *myfindVerse1;

    if(_rCh.location != NSNotFound)
    {
        Ch_ = [NSString stringWithString:[myfindVerse0 substringToIndex:_rCh.location]];
        myfindVerse1 = [NSString stringWithString:[myfindVerse0 substringFromIndex:_rCh.location+1]];
    }
    else if(_rHymn.location != NSNotFound)
    {
        Ch_ = [NSString stringWithString:[myfindVerse0 substringToIndex:_rHymn.location]];
        myfindVerse1 = [NSString stringWithString:[myfindVerse0 substringFromIndex:_rHymn.location+1]];
    }
    else if(_iBook == 31 || _iBook == 57 || _iBook == 63 || _iBook == 64 || _iBook == 65)
    {
        //有五本書只有一章或略過
        Ch_ = @"一";
        myfindVerse1 = myfindVerse0;
    }else {
        return;
    }
    
    NSCharacterSet* charOfDiv = [NSCharacterSet characterSetWithCharactersInString:@"至及和到節"];
    //找節的數字中文
    //_rRange = [myfindVerse1 rangeOfString:@"至"];
    //_rSe = [myfindVerse1 rangeOfString:@"節"];
    _rSe = [myfindVerse1 rangeOfCharacterFromSet:charOfDiv];
    NSString *Se_ ;
    if(_rSe.location != NSNotFound)
        Se_ = [NSString stringWithString:[myfindVerse1 substringToIndex:_rSe.location]];
    else {
        return;
    }
   
    
    int _iC =[self convertChineseNumber:Ch_];
    int _iS = [self convertChineseNumber:Se_];
   
    NSLog(@"章節：%@,%i章，%i節",Book_,_iC,_iS);
    
    eZoeAppDelegate *app = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate] ;
    
    NSMutableArray *_resultarray = [NSMutableArray arrayWithCapacity:3];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT book,chapter,section,column,verse FROM hant where book = %i and chapter = %i and section between %i and %i",_iBook,_iC,_iS,_iS+5];
    NSLog(@"sql:%@",sql);
    sqlite3_stmt *statement = [app.dbHelper executeQuery:sql];
    
    
    
    while(sqlite3_step(statement) == SQLITE_ROW){
        
        int _book = sqlite3_column_int(statement, 0);
        int _chapter = sqlite3_column_int(statement, 1);
        int _section = sqlite3_column_int(statement, 2);
        int _column = sqlite3_column_int(statement, 3);
        NSString *_verse = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        
        
        TTTableSubtextItem *_item = [TTTableSubtextItem itemWithText:[self verseConvert:_book chapter:_chapter section:_section column:_column] 
                                                             caption:_verse];
        [_resultarray addObject:_item];
    }
    self.dataSource = [TTListDataSource dataSourceWithItems:_resultarray];
    
}
*/

-(void)findKeywords:(NSString *)myfindString{
    
    eZoeAppDelegate *app = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate] ;
    
    NSMutableArray *_resultarray = [NSMutableArray arrayWithCapacity:3];
    NSString *sql = [NSString stringWithFormat:@"SELECT chinWord,engWord,type,engExSentence,chinExSentence FROM wordDictionary where chinWord like '%%%@%%'",myfindString];
    NSLog(@"sql:%@",sql);
    sqlite3_stmt *statement = [app.dbHelperEngDict executeQuery:sql];
    
    
    
    while(sqlite3_step(statement) == SQLITE_ROW){
        
        NSString *_chinWord = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
        NSString *_engWord = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
        NSString *_type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
        NSString *_engExSentence = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
        NSString *_chinExSentence = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 4)];
        
        
        TTTableSubtextItem *_item = [TTTableSubtextItem itemWithText:[NSString stringWithFormat:@"%@ %@ %@ ",_chinWord,_type,_engWord]
                                                                      caption:[NSString stringWithFormat:@"%@\n%@",_engExSentence,_chinExSentence]];
        [_resultarray addObject:_item];
    }
    self.dataSource = [TTListDataSource dataSourceWithItems:_resultarray];
    
    
    
}


- (void)hideKeyboard {
    // Hide keyboard if visible
	UIResponder *firstResponder = [[[UIApplication sharedApplication] keyWindow] findFirstResponder]; 
	[firstResponder resignFirstResponder];    
}


- (void)viewDidLoad
{
    UISearchBar *tempSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    self.searchBar = tempSearchBar;
    self.searchBar.delegate = self; 
    [self.searchBar sizeToFit]; 
    
    self.tableView.tableHeaderView = self.searchBar;  

    [self.searchBar release];
   
  
    [super viewDidLoad];
        
    [super viewWillAppear:NO];
    [super viewDidAppear:NO];
    
}
/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ModalCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  cell.textLabel.text = [NSString stringWithFormat:@"Crazy shit %d", indexPath.row];
  return cell;
}*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



//返回值說明 "@@$$$###"
//@@@書名
//$$$章名
//###節名
/*
- (NSString *)isItShortVerseSearch:(NSString *)findText
{
    BOOL hasBook = NO;
    BOOL hasChapter = NO;
    BOOL hasSection = NO;
    NSArray *_bibleKeys = [_bibleDict allKeys];
    NSRange _find;
    int _iBook = 0;
    NSMutableString *_fixBookName = [NSMutableString stringWithString:@""];
    
    for(NSString *_bookNames in _bibleKeys)
    {
        _find = [findText rangeOfString:_bookNames];
        if(_find.location != NSNotFound)
        {
            _iBook =  [[_bibleDict objectForKey:_bookNames] intValue];
            [_fixBookName setString:_bookNames];
            if([_fixBookName isEqualToString:@"拉"] && [findText rangeOfString:@"加拉太"].location != NSNotFound)
            {
                //_find.location = NSNotFound;
                continue;
            } 
            if([_fixBookName isEqualToString:@"羅"] && [findText rangeOfString:@"歌羅西"].location != NSNotFound)
            {
                //_find.location = NSNotFound;
                continue;
            }
            else
                break;
        }
    }        
    if(!_iBook == 0)
        hasBook = YES;
    
    int iChapter_ = 0;
    NSString *_chineseSection = [self filterChineseNumber:findText];

    if(![_chineseSection isEqualToString:@""])
    {
        hasChapter = YES;
        iChapter_ = [self convertChineseNumber1:_chineseSection];
    }
    //有五本書只有一章或略過
    if(_iBook == 31 || _iBook == 57 || _iBook == 63 || _iBook == 64 || _iBook == 65)
    {
        iChapter_ = 1;
        hasChapter = YES;
    }
    
    NSString *_decimalSection = [self filterDecimalNumber:findText];
    int iSection_ = 0;
    if(![_decimalSection isEqualToString:@""])
    {
        hasSection = YES;
        iSection_ = [_decimalSection intValue];
    }
    if(hasBook && hasChapter && hasSection)
        return [NSString stringWithFormat:@"%03d%03d%03d",_iBook,iChapter_,iSection_];
    else {
        return@"";
    }
    
}

- (BOOL)isItVerseSearch:(NSString *)findText
{
    NSRange _rCh = [findText rangeOfString:@"章"];
    NSRange _rHymn = [findText rangeOfString:@"篇"];
    NSCharacterSet* charOfDiv = [NSCharacterSet characterSetWithCharactersInString:@"至及和到節"];
    NSRange _rSe = [findText rangeOfCharacterFromSet:charOfDiv];
   
    if((_rCh.location != NSNotFound || _rHymn.location != NSNotFound) && _rSe.location != NSNotFound)
        return YES;
    else {
        return NO;
    }
}*/

- (void)tableWithSearch
{
    //[self initBibleDict];
    NSString *_text = [[self searchBar] text];
    //NSString *_filterShortSearchResult = [self isItShortVerseSearch:_text];
    /*if(![_filterShortSearchResult isEqualToString:@""])
    {
        NSLog(@"YES,this is short verse search and the converted string is %@",_filterShortSearchResult);
        [self findVerseShort:_filterShortSearchResult];
        
    }else if([self isItVerseSearch:_text])
        [self findVerse:_text];
    else*/
    
    [self findKeywords:_text];
    
    [self refresh];
       
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //NSLog(@"the search bar text is %@",searchBar.text);
    //[self resignFirstResponder];
    [self tableWithSearch];
    [self hideKeyboard];
}

@end
