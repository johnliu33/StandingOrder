//
//  Objective_ZipViewController.m
//  Objective-Zip
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright Flying Dolphin Studio 2009. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "Objective_ZipViewController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"


@implementation Objective_ZipViewController


- (void) loadView {
	[super loadView];
	
	_textView.font= [UIFont fontWithName:@"Helvetica" size:11.0];
}

- (void) dealloc {
	if (_testThread)
		[_testThread release];
    [super dealloc];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) zipUnzip {
	if (_testThread)
		[_testThread release];
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil];
	[_testThread start];
}

- (void) test {
    NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];

	@try {
		NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
		NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for writing..." waitUntilDone:YES];
		
		ZipFile *zipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Adding first file..." waitUntilDone:YES];
		
		ZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:ZipCompressionLevelBest];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to first file's stream..." waitUntilDone:YES];

		NSString *text= @"abc";
		[stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
		
		[stream1 finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Adding second file..." waitUntilDone:YES];
		
		ZipWriteStream *stream2= [zipFile writeFileInZipWithName:@"x/y/z/xyz.txt" compressionLevel:ZipCompressionLevelNone];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Writing to second file's stream..." waitUntilDone:YES];
		
		NSString *text2= @"XYZ";
		[stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
		
		[stream2 finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
		
		[zipFile close];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening zip file for reading..." waitUntilDone:YES];
		
		ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Reading file infos..." waitUntilDone:YES];
		
		NSArray *infos= [unzipFile listFileInZipInfos];
		for (FileInZipInfo *info in infos) {
			NSString *fileInfo= [NSString stringWithFormat:@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
			[self performSelectorOnMainThread:@selector(log:) withObject:fileInfo waitUntilDone:YES];
		}
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening first file..." waitUntilDone:YES];
		
		[unzipFile goToFirstFileInZip];
		ZipReadStream *read1= [unzipFile readCurrentFileInZip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from first file's stream..." waitUntilDone:YES];
		
		NSMutableData *data1= [[[NSMutableData alloc] initWithLength:256] autorelease];
		int bytesRead1= [read1 readDataWithBuffer:data1];
		
		BOOL ok= NO;
		if (bytesRead1 == 3) {
			NSString *fileText1= [[[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding] autorelease];
			if ([fileText1 isEqualToString:@"abc"])
				ok= YES;
		}
		
		if (ok)
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is OK" waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is WRONG" waitUntilDone:YES];
			
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
		
		[read1 finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Opening second file..." waitUntilDone:YES];

		[unzipFile goToNextFileInZip];
		ZipReadStream *read2= [unzipFile readCurrentFileInZip];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from second file's stream..." waitUntilDone:YES];
		
		NSMutableData *data2= [[[NSMutableData alloc] initWithLength:256] autorelease];
		int bytesRead2= [read2 readDataWithBuffer:data2];
		
		ok= NO;
		if (bytesRead2 == 3) {
			NSString *fileText2= [[[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding] autorelease];
			if ([fileText2 isEqualToString:@"XYZ"])
				ok= YES;
		}
		
		if (ok)
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is OK" waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is WRONG" waitUntilDone:YES];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
		
		[read2 finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
		
		[unzipFile close];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test terminated succesfully" waitUntilDone:YES];
		
	} @catch (ZipException *ze) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a ZipException (see logs), terminating..." waitUntilDone:YES];
		
		//NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);

	} @catch (id e) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), terminating..." waitUntilDone:YES];

		//NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
	}
	
	[pool drain];
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

- (void) unzip:(NSString *)downLoadFN file_id:(NSString *)file_id
{
	NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
	//NSString *zipFilePath= [documentsDir stringByAppendingPathComponent:downLoadFN];
	NSString *zipFilePath=downLoadFN;
    NSLog(@"%@",zipFilePath);
	ZipFile *zipFile = [[ZipFile alloc] initWithFileName:zipFilePath mode:ZipFileModeUnzip];
	[zipFile goToFirstFileInZip];
	
	BOOL continueReading = YES;
	while (continueReading) {
		
		
		/*
		 for (FileInZipInfo *info in infos) {
		 NSString *fileInfo= [NSString stringWithFormat:@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
		 [self performSelectorOnMainThread:@selector(log:) withObject:fileInfo waitUntilDone:YES];
		 }
		 */ 
        FileInZipInfo *info = [zipFile getCurrentFileInZipInfo];
        
		const char *Cbuffer = [file_id cStringUsingEncoding:NSUTF8StringEncoding];
        char   buffer[200]= {0} ;
        
        strcpy(buffer,Cbuffer);
        fill_sum(buffer);
        check_sum(buffer);
        //buffer[sizeof(buffer)] = '\0';
        //NSString *pwd = [NSString stringWithString:@"FSSJ-QB1B-HNFQ-SJLF-NDQ1"];//[
        NSString *pwd = [NSString stringWithUTF8String:(char *)buffer];//[NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
        //NSString *pwd  = [[NSString alloc] initWithBytes:buffer length:sizeof(buffer) encoding:NSASCIIStringEncoding];
        ////[NSString stringWithUTF8String:(char *)buffer];
        pwd = [pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSLog(@"pwd:%@,",pwd);
        ZipReadStream *stream = [zipFile readCurrentFileInZipWithPassword:pwd]; //decode encryupt file
		
        //[pwd release];
		//ZipReadStream *stream = [zipFile readCurrentFileInZip];//for no encrypt files
		NSMutableData *data = [[NSMutableData alloc] initWithLength:info.length];
		[stream readDataWithBuffer:data];
		
		
		NSString *writePath = [documentsDir stringByAppendingPathComponent:info.name];//
        //NSLog(@"%@",writePath);
		NSError *error = nil;
		[data writeToFile:writePath options:NSDataWritingAtomic error:&error];
		if (error) {
			//NSLog(@"Error unzipping file: %@", [error localizedDescription]);
		}
		
        BOOL successFix = [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:writePath]];
        if(successFix)
            NSLog(@"Can mark:%@ as don't save to iCloud",writePath);
        else
            NSLog(@"Can't mark:%@ as don't save to iCloud",writePath);
		
		[stream finishedReading];
		[data release];
		
		
		continueReading = [zipFile goToNextFileInZip];
	}
	
	[zipFile close];
    [zipFile release];
}

- (void) log:(NSString *)text {
	//NSLog(@"%@", text);
	
	_textView.text= [_textView.text stringByAppendingString:text];
	_textView.text= [_textView.text stringByAppendingString:@"\n"];
	
	NSRange range;
	range.location= [_textView.text length] -6;
	range.length= 5;
	[_textView scrollRangeToVisible:range];
}

@end
