//
//  StatusListVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/8/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "StatusListVC.h"
#import "TaskDocument.h"
#import "Portfolio.h"
#import "UIImage+Additions.h"
@interface StatusListVC ()
{
    NSMutableArray* _statusList;
}
@end

@implementation StatusListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setTableFooterView:[UIView new]];
    
    self.navigationItem.title = @"Task Status";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],NSForegroundColorAttributeName,
                                               
                                               [UIFont systemFontOfSize:16.0],NSFontAttributeName,
                                               shadow, NSShadowAttributeName, nil];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
        UIColor * barColor = [UIColor
                              colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  
    
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    _statusList = [[NSMutableArray alloc] init];
    
    [self reloadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusListCallBack:) name:@"GetTaskStatusListNotifier" object:nil];
    [[TaskDocument sharedInstance] getTaskStatusList];
}

- (void)statusListCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
}

- (void)reloadView
{
    [_statusList removeAllObjects];
    [_statusList addObjectsFromArray:[[TaskDocument sharedInstance] taskStatusList]];
    if(_statusList.count > 2 && self.task)
    {
        if(self.task.CanEditAssignee && (self.task.assignee.UserId != [User currentUser].UserId))
        {
            [_statusList removeObjectsInRange:NSMakeRange(1, 2)];
        }
    }
    [self.tableView reloadData];
}

- (void)projectListCallBack:(NSNotification*)note
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return  nil;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int cnt = [_statusList count];
    return cnt;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    }

    NSString* status = [_statusList objectAtIndex:indexPath.row];
    cell.textLabel.text = status;
    cell.imageView.image = [UIImage imageForStatus:status];
    if([status isEqualToString:self.selectedStatus]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.target && [self.target respondsToSelector:self.action])
    {
        NSString* status = [_statusList objectAtIndex:indexPath.row];
        self.selectedStatus = status;
        [self.target performSelector:self.action withObject:self];
    }
    if(self.popOver)
        [self.popOver dismissPopoverAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}


@end
