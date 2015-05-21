//
//  ProjectListVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/8/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ProjectListVC.h"
#import "TaskDocument.h"
#import "Portfolio.h"
#import "UIImage+Additions.h"
@interface ProjectListVC ()
{
}
@end

@implementation ProjectListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    
    self.navigationItem.title = @"Project List" ;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               
                                               [UIFont systemFontOfSize:16.0],NSFontAttributeName,
                                               shadow, NSShadowAttributeName, nil];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
        UIColor * barColor = [UIColor
                              colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectListCallBack:) name:@"ProjectListNotifier" object:nil];
    [[TaskDocument sharedInstance] getProjectList];
    
}

- (void)statusListCallBack:(NSNotification*)note
{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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
    if([[TaskDocument sharedInstance] selectedProject] || [[TaskDocument sharedInstance] selectedPortfolio])
        return 1;
    
    return [[[TaskDocument sharedInstance] portfolios] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30.0)];
    [lbl setBackgroundColor:[UIColor lightGrayColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0]];
    Portfolio* portfolio;
    if([[TaskDocument sharedInstance] selectedPortfolio])
        portfolio = [[TaskDocument sharedInstance] selectedPortfolio];
    else
        portfolio = [[[TaskDocument sharedInstance] portfolios] objectAtIndex:section];
    lbl.text = [NSString stringWithFormat:@" %@",portfolio.PortfolioName];
    return lbl;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([[TaskDocument sharedInstance] selectedProject])
        return 1;

    Portfolio* portfolio;
    if([[TaskDocument sharedInstance] selectedPortfolio])
        portfolio = [[TaskDocument sharedInstance] selectedPortfolio];
    else
        portfolio = [[[TaskDocument sharedInstance] portfolios] objectAtIndex:section];
    NSArray* projects = portfolio.Projects;
    // Return the number of rows in the section.
    return [projects count];
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
    
    Project* project;
    if([[TaskDocument sharedInstance] selectedProject])
        project = [[TaskDocument sharedInstance] selectedProject];
    else
    {
        
        Portfolio* portfolio;
        if([[TaskDocument sharedInstance] selectedPortfolio])
            portfolio = [[TaskDocument sharedInstance] selectedPortfolio];
        else
            portfolio = [[[TaskDocument sharedInstance] portfolios] objectAtIndex:indexPath.section];
        
        NSArray* projects = portfolio.Projects;
        
        project = [projects objectAtIndex:indexPath.row];
    }
    if(NSSTRING_HAS_DATA(project.ProjectName))
    {
        cell.textLabel.text = project.ProjectName;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    else
    {
        cell.textLabel.text = @"No Project";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    if([self.selectedProject.ProjectName isEqualToString: project.ProjectName])
        cell.accessoryType= UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType= UITableViewCellAccessoryNone;
    
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
        
        Project* project;
        if([[TaskDocument sharedInstance] selectedProject])
            project = [[TaskDocument sharedInstance] selectedProject];
        else
        {
            
            Portfolio* portfolio;
            if([[TaskDocument sharedInstance] selectedPortfolio])
                portfolio = [[TaskDocument sharedInstance] selectedPortfolio];
            else
                portfolio = [[[TaskDocument sharedInstance] portfolios] objectAtIndex:indexPath.section];
            
            NSArray* projects = portfolio.Projects;
            
            project = [projects objectAtIndex:indexPath.row];
        }
        if(NSSTRING_HAS_DATA(project.ProjectName))
        {
            [self.target performSelector:self.action withObject:project];
            if(self.popOver)
                [self.popOver dismissPopoverAnimated:YES];
            else
                [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}


@end
