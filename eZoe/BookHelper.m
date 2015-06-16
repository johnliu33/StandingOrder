//
//  BookHelper.m
//  TAAZEREADER
//
//  Created by gdx on 1/3/14.
//
//

#import "BookHelper.h"
#import "NSString+Sha1.h"
#import "NSString+Path.h"
#include <sys/xattr.h>//johnliu
@implementation BookHelper

//johnliu
#pragma mark - Helper methods
/*+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)path
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}*/
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
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

+ (NSString *) getDocPathWithPList:(NSString*)fileName
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
    
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
//johnliu

#pragma mark - Generic methods

+ (NSString *)dBookId:(NSString *)pid {
    NSInteger iModPid = [BookHelper MakeStringSum:pid] % 10;
    return [NSString stringWithFormat:@"%i%@", iModPid, pid];
}

+ (NSString *)generateSN {
    NSMutableString *sn = [NSMutableString stringWithString:[BookHelper getSNString]];
    NSInteger iMod = [BookHelper MakeStringSum:sn] % 10;
    [sn insertString:[NSString stringWithFormat:@"%i", iMod]
             atIndex:6];
    return sn;
}

+ (NSString *)getSNString {
    NSDateFormatter *dateFormat = [[NSDateFormatter new] autorelease];
    [dateFormat setDateFormat:@"ssMMyyyyHHddmm"];
    return [dateFormat stringFromDate:[NSDate date]];
}

+ (NSInteger)MakeStringSum:(NSString *)numString {
    NSString *str = numString;
    NSInteger iSum = 0;
    for (int i = 0; i < [str length]; i++) {
        NSString *ch = [str substringWithRange:NSMakeRange(i, 1)];
        iSum += [ch integerValue];
    }
    return iSum;
}

+ (NSString *)getnerateSHA:(NSString *)sn functionName:(NSString *)functionName {
    double apiASCIIsum = [BookHelper MakeStringAsciiSum:functionName];
    double beforeSHA = [sn doubleValue] + apiASCIIsum;
    NSString *s = [NSString stringWithFormat:@"%@%.0f%.0f", functionName, apiASCIIsum, beforeSHA];
    NSString *afterSHA = [s sha1];
    
    return afterSHA;
}

+ (double)MakeStringAsciiSum:(NSString *)myString {
    NSString *str = myString;
    double dSum = 0;
    for (int i = 0; i < [str length]; i++) {
        NSString *ch = [str substringWithRange:NSMakeRange(i, 1)];
        int asciiCode = [ch characterAtIndex:0];
        dSum += asciiCode;
    }
    return  dSum;
}

+ (NSString *)CUID {
    NSString *myPath = [self getDocPathWithPList:@"setting.plist"];
    NSMutableDictionary *mysetting = [NSMutableDictionary dictionaryWithContentsOfFile:myPath];
    NSString *lastCuid = [mysetting objectForKey:@"lastCuid"];
    return lastCuid;
}

+ (BOOL)isDownloaded:(NSDictionary *)bookInfo {
    
    
    
    NSString *coverName = [NSString stringWithFormat:@"%@l.png", [bookInfo objectForKey:@"bookId"]];
    NSString *dataPath = [self getDocPathWithPList:coverName];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:dataPath];
}

@end
