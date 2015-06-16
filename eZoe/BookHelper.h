//
//  BookHelper.h
//  TAAZEREADER
//
//  Created by gdx on 1/3/14.
//
//

#import <Foundation/Foundation.h>

@interface BookHelper : NSObject
+ (NSString *)getDocPathWithPList:(NSString*)fileName;//johnliu
+ (NSString *)dBookId:(NSString *)pid;
+ (NSString *)generateSN;
+ (NSString *)getSNString;
+ (NSInteger)MakeStringSum:(NSString *)numString;
+ (NSString *)getnerateSHA:(NSString *)sn functionName:(NSString *)functionName;
+ (double)MakeStringAsciiSum:(NSString *)myString;
+ (NSString *)CUID;
+ (BOOL)isDownloaded:(NSDictionary *)bookInfo;

@end
