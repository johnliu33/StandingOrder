//
//  DBHelper.m
//  sqlite
//
//  Created by Lawrence on 20/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DBHelperEngDict.h"
#import "Global.h"

@implementation DBHelperEngDict

static DBHelperEngDict *instance = nil;

@synthesize database;

+ (DBHelperEngDict *) newInstance{
    @synchronized(self) {
        if (instance == nil){
            instance = [[DBHelperEngDict alloc]init];
            [instance openDatabase];
        }
    }
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (void) openDatabase{
    if (!database){
        [self copyDatabaseIfNeeded];
        int result = sqlite3_open([[self getDatabaseFullPath] UTF8String], &database);
        if (result != SQLITE_OK){
            NSAssert(0, @"Failed to open database");
        }
    }
}

- (void) closeDatabase{
    if (database){
        sqlite3_close(database);
    }
}

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

- (void) copyDatabaseIfNeeded{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDatabaseFullPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", DB_NAME_ENG_DICT, DB_EXT_ENG_DICT]];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        NSLog(@"Database file copied from bundle to %@", dbPath);
        
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
        
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dbPath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",dbPath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",dbPath);
        
    } else {
        
        NSLog(@"Database file found at path %@", dbPath);
        
    }
}

- (NSString *) getDatabaseFullPath{
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [[NSString stringWithFormat:@"%@%@", DB_NAME_ENG_DICT, DB_EXT_ENG_DICT] getDocPathWithPList];
    return path;
}

- (sqlite3_stmt *) executeQuery:(NSString *) query{
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    return statement;
}

- (BOOL) executeStatement:(NSString *) statement
{
    char * errorMsg;
    if (sqlite3_exec (database, [statement UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        NSAssert1(0, @"Error updating tables: %s", errorMsg);
        return NO;
    }
    else
        return YES;
}


@end
