/******************************************************************************
 * Copyright (c) 2010, Maher Ali <maher.ali@gmail.com>
 * Advanced iOS 4 Programming: Developing Mobile Applications for Apple iPhone, iPad, and iPod touch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

#import "InternetResource.h"
/*zip file*/
#import "Objective_ZipViewController.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

#define FILE_IN_ZIP_MAX_NAME_LENGTH (256)





/*zip file*/

@implementation InternetResource

@synthesize url, title, image, status;
@synthesize hasPackageFiles;
@synthesize packageList;
@synthesize _urlCon;

-(id)initWithTitle:(NSString*)_title andURL:(NSString*)_url{
  if((self = [super init])){
    self.title = _title;
    self.url = _url;
    self.status = NEW;
  }
  return self;
}

-(void)start{
  self.status = FETCHING;
  receivedData = [[NSMutableData data] retain];
  [NSThread detachNewThreadSelector:@selector(fetchURL) toTarget:self withObject:nil];
}

-(void)fetchURL {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
  _urlCon = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
  //[_urlCon initWithRequest:theRequest delegate:self];
  [[NSRunLoop currentRunLoop ] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:120]];
    //[_urlCon release]; 
  [pool release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  int statusCode = ((NSHTTPURLResponse*) response).statusCode;
  if(statusCode != 200){
    @synchronized(self){
      self.status = FAILED;
    }
  }
  [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [connection release];
  if(receivedData){
    [receivedData release];
    receivedData = nil;
  }
  @synchronized(self){
    self.status = FAILED;
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  @synchronized(self){
    if(self.status != FAILED)
    {

        self.status = COMPLETE;
        /*save download data to file*/
        NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents"];
        NSString *downloadfn=@"tempdn.zip";		
        NSString *filePath= [documentsDir stringByAppendingPathComponent:downloadfn];
	
        [receivedData writeToFile:filePath atomically:YES];
        Objective_ZipViewController *_unzipobj = [Objective_ZipViewController alloc];
		
		NSString *_bid = [self title];
        [_unzipobj unzip:filePath file_id:_bid];
        [_unzipobj release];
	 
	    NSFileManager *NSFm= [NSFileManager defaultManager];
        [NSFm removeItemAtPath:filePath error:NULL];
        NSString *_pklistpath = [documentsDir stringByAppendingPathComponent:@"pklist.plist"];
		if([NSFm fileExistsAtPath:_pklistpath])
        {
            hasPackageFiles = YES;
            packageList = [NSMutableArray arrayWithContentsOfFile:_pklistpath];
            eZoeAppDelegate *appDelegate = (eZoeAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableArray *_thebookList = [appDelegate bookList];
            
            for(NSString *_pk in packageList)
            {
                [_thebookList addObject:_pk];
            }
            [NSFm removeItemAtPath:_pklistpath error:NULL];
            

        }
		
        [receivedData release];
        receivedData = nil;
    }
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:FinishedLoading object:self];
  [connection release];  
}          

-(void)dealloc{
  if(receivedData){
    [receivedData release];
  }
    self.packageList = nil;
  self.title = nil;
  self.url = nil;
  self.image = nil;
    //[_urlCon release];
  [super dealloc];
}


@end
