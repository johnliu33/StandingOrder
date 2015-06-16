//
//  DataDetailViewController.h
//  eZoe
//
//  Created by John Liu on 2011/6/22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

@protocol DataDetailViewControllerDelegate

- (void) didSelectDataItem:(NSInteger)type selectedItem:(NSInteger)selectedItem;
- (void) didSelectMarkDataItem:(NSString *)searchText pagePercent:(NSNumber *)pagePercent rowId:(NSString *)rowId;

@end


@interface DataDetailViewController : UITableViewController {
    NSInteger   iSettingType; //0:字型大小 1:背景 2:字體
    NSArray     *data;
    NSArray     *note;
    NSArray     *dataPrecent;
    NSArray     *dataRowId;
    id<DataDetailViewControllerDelegate>      caller1;
}
@property (nonatomic, assign) NSInteger iSettingType;
@property (nonatomic, retain)  NSArray                             *data;
@property (nonatomic, retain)  NSArray                             *note;
@property (nonatomic, retain)  NSArray                             *dataPercent;
@property (nonatomic, retain)  NSArray                             *dataRowId;
@property (nonatomic, assign) id <DataDetailViewControllerDelegate>     caller1;


@end
