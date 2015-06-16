//
//  Global.m
//  eZoe
//
//  Created by John Liu on 2011/5/7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Global.h"
#include <sys/xattr.h>
@implementation NSString (getDocPathWithPList)
/*- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}*/


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


-(NSString *) getDocPathWithPList
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    NSFileManager *_fmanager = [NSFileManager defaultManager];
    if(![_fmanager fileExistsAtPath:documentsDirectory])
    {
        [_fmanager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
        //mark the private documents folder to be "do not backup"
        BOOL success = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:documentsDirectory]];
        if(success)
            NSLog(@"Can mark:%@",documentsDirectory);
        else
            NSLog(@"Can't mark:%@",documentsDirectory);
    }
    
    return [documentsDirectory stringByAppendingPathComponent:self];
}

@end

@implementation NSString (getUserDocPathWithPList)
-(NSString *) getUserDocPathWithPList
{
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);	
     NSString *docPath = [paths objectAtIndex:0];
     return [docPath stringByAppendingPathComponent:self];
     
}

@end

@implementation NSString (filterStringBeforeSpeech)
-(NSString *) filterStringBeforeSpeech
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"voice" ofType:@"plist"];
    NSString *path = [@"voice.plist" getDocPathWithPList];
    NSDictionary *rootDict = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
    //NSString *URLString = [[rootDict objectForKey:key] objectForKey:@"URL"]
    NSArray *_keys = [rootDict allKeys];
    NSScanner *theScanner;
    NSString *text = nil;
 
    NSString *html = [NSString stringWithString:self];
    for(NSString *sKey_ in _keys)
    {
        html = [html stringByReplacingOccurrencesOfString:sKey_ withString:[rootDict objectForKey:sKey_]];
    }
    /*
    html = [html stringByReplacingOccurrencesOfString:@"住在那裡" withString:@"住在哪裡"];
    html = [html stringByReplacingOccurrencesOfString:@"兩種果汁" withString:@"涼種果汁"];
    html = [html stringByReplacingOccurrencesOfString:@"那一種果汁" withString:@"哪一種果汁"];
    html = [html stringByReplacingOccurrencesOfString:@"那一部分" withString:@"哪一部分"];
    html = [html stringByReplacingOccurrencesOfString:@"裡面的" withString:@"裡面得"];
    html = [html stringByReplacingOccurrencesOfString:@"在那裡" withString:@"在哪裡"];
    html = [html stringByReplacingOccurrencesOfString:@"到底在那裡" withString:@"到底在哪裡"];
    html = [html stringByReplacingOccurrencesOfString:@"同著" withString:@"同嫬"];
    html = [html stringByReplacingOccurrencesOfString:@"哦" withString:@"偶"];
    html = [html stringByReplacingOccurrencesOfString:@"外面的" withString:@"外面得"];
     */
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"。"];
    html = [html stringByReplacingOccurrencesOfString:@"〔" withString:@"（"];
    html = [html stringByReplacingOccurrencesOfString:@"〕" withString:@"）"];
    theScanner = [NSScanner scannerWithString:html];
    
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"（" intoString:NULL] ; 
        
        // find end of tag
        [theScanner scanUpToString:@"）" intoString:&text] ;
        //如果掃到標題
        if([text isEqualToString:@"（一"] ||[text isEqualToString:@"（二"]  ||[text isEqualToString:@"（三"] ||[text isEqualToString:@"（四"] ||[text isEqualToString:@"（五"] ||[text isEqualToString:@"（六"] ||[text isEqualToString:@"（七"] ||[text isEqualToString:@"（八"] ||[text isEqualToString:@"（九"] ||[text isEqualToString:@"（十"]||[text isEqualToString:@"（十一"]||[text isEqualToString:@"（十二"]||[text isEqualToString:@"（十三"]||[text isEqualToString:@"（十四"]||[text isEqualToString:@"（十五"]||[text isEqualToString:@"（十六"]||[text isEqualToString:@"（十七"]||[text isEqualToString:@"（十八"]||[text isEqualToString:@"（十九"]||[text isEqualToString:@"（十"])
            continue;
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [ NSString stringWithFormat:@"%@）", text]
                                               withString:@" "];
        
    } // while //
    
    //html = [html stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"HTML String:%@",html);

    return html;
    
}
@end



/*@implementation NSString(compare)

-(NSComparisonResult)keyCompare:(NSString*)other
{
    
    float myValue = [self floatValue];
    float otherValue= [other floatValue];
    if(myValue == otherValue) return NSOrderedSame;
    return (myValue < otherValue ? NSOrderedAscending : NSOrderedDescending);
}

@end*/