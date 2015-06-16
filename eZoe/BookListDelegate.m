//
//  BookListDelegate.m
//  TAAZEREADER
//
//  Created by gdx on 1/14/14.
//
//

#import "BookListDelegate.h"
#import "BookListDataSource.h"
#import "BookListTitleView.h"

@implementation BookListDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BookListDataSource *dataSource = (BookListDataSource *)tableView.dataSource;
    TETableViewSection *sectionItem = (TETableViewSection *)[dataSource.items objectAtIndex:section];
    BookListTitleView *titleView = (BookListTitleView *)[[[NSBundle mainBundle] loadNibNamed:@"BookListTitleView"
                                                                                       owner:nil
                                                                                     options:nil] objectAtIndex:0];
    titleView.titleLabel.text = sectionItem.title;
    return titleView;
}


/* (void)withTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 //add code here for when you hit delete
 NSLog(@"Delete!");
 //[tableView removeObjectAtIndex:indexPath.row];
 //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 }
 }*/




@end
