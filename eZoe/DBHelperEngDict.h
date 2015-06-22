//
//  DBHelper.h
//  sqlite
//
//  Created by Lawrence on 20/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>
#define DB_NAME_ENG_DICT @"engDict"
#define DB_EXT_ENG_DICT @".db"

@interface DBHelperEngDict : NSObject {
    sqlite3 *database;
}

@property(readonly, nonatomic) sqlite3 *database;

+ (DBHelperEngDict *) newInstance;
- (void) openDatabase;
- (void) closeDatabase;
- (NSString *) getDatabaseFullPath;
- (void) copyDatabaseIfNeeded;
- (sqlite3_stmt *) executeQuery:(NSString *) query;
- (BOOL) executeStatement:(NSString *) statement;

@end