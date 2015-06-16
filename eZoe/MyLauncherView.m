//
//  MyLauncherView.m
//  eZoe
//
//  Created by John Liu on 2011/5/13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "MyLauncherView.h"


@implementation MyLauncherView

/*- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}*/

- (NSArray *) listFileInDir:(NSString *)subfilename{
	
	NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
    //NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:documentsDir error];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:NULL];
    int num=[dirContents count];
    
    if (num < 1)
		return [[[NSArray alloc] init] autorelease];
	NSMutableArray *files= [[[NSMutableArray alloc] initWithCapacity:num] autorelease];
    
    
    for (NSString *tString in dirContents) {
        if ([tString hasPrefix:subfilename]) {
            
            [files addObject:tString];
            
        }
    }  
    
    return files;
}

- (void)dealloc {
    [super dealloc];
}

- (void)removeItem:(TTLauncherItem*)item animated:(BOOL)animated
{
    [super removeItem:item animated:animated];
    NSLog(@"removeItem");
    
    //eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
    //NSMutableArray *_t = (NSMutableArray*)[appDelegate bookList];
    //NSUInteger _i = [[item count] intValue];
    
    //[_t removeObjectAtIndex:_i];
    //NSString *dataPath = [[NSString stringWithString:@"booklist.plist"] getDocPathWithPList];
    //[_t writeToFile:dataPath atomically:YES];
    
    if(animated == YES)//表示是從launcher刪的，NO則是從下載刪的只要刪圖示
    {
        NSString *_bookid = [item bookid];
        NSArray *_filearray = [self listFileInDir:_bookid];
        

        NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
        NSFileManager *NSFm= [NSFileManager defaultManager];
        
        for(NSString *_f in _filearray)
        {
            NSString *filePath= [documentsDir stringByAppendingPathComponent:_f];
            [NSFm removeItemAtPath:filePath error:NULL];
        }

    }
}
@end
