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

#define FinishedLoading @"FinishedLoading"
#include "eZoeAppDelegate.h"

typedef enum  {
  NEW,
  FETCHING, 
  FAILED,
  COMPLETE
} STATUS;

@interface InternetResource : NSObject {
  NSString  *url, *title;
  UIImage *image;
  STATUS status;
  NSMutableData *receivedData;
  BOOL hasPackageFiles;
    NSMutableArray *packageList;
    
    NSURLConnection *_urlCon;  
  
}
-(void)start;
//-(void)test;
-(id)initWithTitle:(NSString*)_title andURL:(NSString*)_url;
@property(nonatomic, retain) NSString *url;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, assign) STATUS status;
@property(nonatomic, assign) BOOL hasPackageFiles;
@property(nonatomic, assign) NSMutableArray *packageList;
@property(nonatomic, retain) NSURLConnection *_urlCon;

@end
