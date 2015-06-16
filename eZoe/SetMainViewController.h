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

#import "SetDetailViewController.h"
#import "eZoeAppDelegate.h"
#import "DataDetailViewController.h"
#import "Global.h"

@interface SetMainViewController : UITableViewController <SetDetailViewControllerDelegate,DataDetailViewControllerDelegate> {
      id<SetDetailViewControllerDelegate>       caller;
      id<DataDetailViewControllerDelegate>      caller1;
}

@property (nonatomic, assign) id <SetDetailViewControllerDelegate>     caller;
@property (nonatomic, assign) id <DataDetailViewControllerDelegate>     caller1;

//utility
-(CGFloat)convertPagePercent:(NSInteger)page pageCount:(NSInteger)count;
-(NSInteger)revertPagePercent:(CGFloat)percent pageCount:(NSInteger)count;
@end
