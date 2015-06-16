//
//  NSString+Path.m
//  TAAZEREADER
//
//  Created by gdx on 13/10/3.
//
//

#import "NSString+Path.h"

@implementation NSString (Path)

+ (NSString *)cachePath {
    NSArray *cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [cachePathArray lastObject];
}

+ (NSString *)privateDocumentPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
}

@end
