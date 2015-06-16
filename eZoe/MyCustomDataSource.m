//
//  MyCustomDataSource.m
//  eZoe
//
//  Created by 劉 立山 on 12/5/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyCustomDataSource.h"

@implementation MyCustomDataSource
///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object { 
    if ([object isKindOfClass:[TTTableSubtitleItem class]]) {
        return [TableCustomSubtitleItem class];
    } else {
        return [super tableView:tableView cellClassForObject:object];
    }
}
@end
