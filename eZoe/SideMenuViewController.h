//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>

#define kBookDidJumpIndex   @"BookDidJumpIndex"

@interface SideMenuViewController : UITableViewController {

    NSString *pdfBookId;
    NSString *bookName;
    
    NSArray *arrayIndex;
}

-(void)setBookId:(NSString *)bookId;

@end