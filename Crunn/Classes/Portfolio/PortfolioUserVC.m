//
//  PortfolioUserVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "PortfolioUserVC.h"
#import "TaskDocument.h"
#import "ValidationHelper.h"
#import "TaskUserCell.h"
#import "ProjectUserCell.h"


#define FILTER_SECTION 0
#define ADD_TASK_USERS_SECTION 1
#define TASK_USERS_SECTION 2

@interface PortfolioUserVC ()
{
    NSArray* assignees;
    IBOutlet UISearchBar* searchBar;
    NSMutableArray* _sections;
    NSIndexPath* _selectedIndexPath;
    IBOutlet UIButton* followCheckmark;
    IBOutlet UIButton* canAddOtherCheckmark;
    IBOutlet UILabel* placeholderText;
    NSMutableArray* _taskUserList;
    NSIndexPath* _deletedIndexPath;
}
@property(nonatomic,retain)IBOutlet UITableView* tableView;

- (IBAction)followAction:(UIButton*)item;
- (IBAction)canAddAction:(UIButton*)item;
@end

@implementation PortfolioUserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    UIBarButtonItem* addBtn = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addAction:)];
    addBtn.enabled = NO;
    [addBtn setWidth:40.0];
    //self.navigationItem.rightBarButtonItem = addBtn;
    if(self.portfolioUserType == PortfolioUserTypePortfolio)
    {
        self.navigationItem.title = @"Portfolio Members";
    }
    else
    {
        self.navigationItem.title = @"Project Members";
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TaskUserCell" bundle:nil] forCellReuseIdentifier:@"TaskUserCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProjectUserCell" bundle:nil] forCellReuseIdentifier:@"ProjectUserCell"];
    
    _sections = [[NSMutableArray alloc] init];
    _taskUserList = [[NSMutableArray alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assigneeListCallBack:) name:@"AssigneeListNotifier" object:nil];
    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
    
    if(self.portfolioUserType == PortfolioUserTypePortfolio)
    {
        [_taskUserList addObjectsFromArray:self.portfolio.UserList];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector   (getPortfolioUserListCallBack:) name:@"GetPortfolioNotifier" object:nil];
        //[[TaskDocument sharedInstance] getPortfolio:self.portfolio];
    }
    else
    {
        [_taskUserList addObjectsFromArray:self.project.UserList];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector   (getProjectUserListCallBack:) name:@"GetProjectNotifier" object:nil];
        //[[TaskDocument sharedInstance] getProject:self.project];
    }
    [self reloadView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.editing = NO;
}

- (void)getPortfolioUserListCallBack:(NSNotification*)note
{
    Portfolio* portfolio = [note object];
    if(portfolio && [portfolio isKindOfClass:[Portfolio class]])
    {
        self.portfolio = portfolio;
        if(!portfolio.CurrentUserCanAddOtherUsers)
        {
            //self.navigationItem.rightBarButtonItem = nil;
        }
        [_taskUserList removeAllObjects];
        [_taskUserList addObjectsFromArray: portfolio.UserList];
    }
    [self performSelectorOnMainThread:@selector(gotoUserList:) withObject:[note object] waitUntilDone:NO];
}

- (void)getProjectUserListCallBack:(NSNotification*)note
{
    Project* project = [note object];
    if(project && [project isKindOfClass:[Project class]])
    {
        self.project = project;
        if(!project.CurrentUserCanAddOtherUsers)
        {
            //self.navigationItem.rightBarButtonItem = nil;
        }
        [_taskUserList removeAllObjects];
        [_taskUserList addObjectsFromArray: project.UserList];
    }
    [self performSelectorOnMainThread:@selector(gotoUserList:) withObject:[note object] waitUntilDone:NO];
}

- (void)gotoUserList:(NSArray*)arr
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self reloadView];
}

- (IBAction)followAction:(UIButton*)item
{
    item.selected = !item.selected;
}

- (IBAction)canAddAction:(UIButton*)item
{
    item.selected = !item.selected;
}

- (void)assigneeListCallBack:(NSNotification*)note
{
    //assignees = [[TaskDocument sharedInstance] assignees];
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadView
{
    [_sections removeAllObjects];
    if(NSSTRING_HAS_DATA(searchBar.text))
        [_sections addObject:[NSNumber numberWithInteger:ADD_TASK_USERS_SECTION]];
    
    if(_taskUserList.count)
        [_sections addObject:[NSNumber numberWithInteger:TASK_USERS_SECTION]];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sec
{
    int section = [[_sections objectAtIndex:sec] integerValue];

    if(section == ADD_TASK_USERS_SECTION)
    {
        if(NSSTRING_HAS_DATA( searchBar.text))
            return MAX(1,[assignees count]);
        else
            return [assignees count];
    }
    else
    {
        return [_taskUserList count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sec
{
    int section = [[_sections objectAtIndex:sec] integerValue];
    if(section == ADD_TASK_USERS_SECTION)
    {
        return 0.0;
    }
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sec
{
    int section = [[_sections objectAtIndex:sec] integerValue];
    if(section == ADD_TASK_USERS_SECTION)
    {
        return nil;
    }
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [v setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* prefixLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 20)];
    [prefixLbl setTextColor:[UIColor lightGrayColor]];
    if(self.portfolioUserType == PortfolioUserTypePortfolio)
    {
        [prefixLbl setText:@"Portfolio:"];
    }
    else
    {
        [prefixLbl setText:@"Project:"];
    }
    
    [prefixLbl setFont:[UIFont systemFontOfSize:14.0]];
    [prefixLbl setBackgroundColor:[UIColor clearColor]];
    [v addSubview:prefixLbl];
    
    UILabel* pName = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, tableView.bounds.size.width - 80, 20)];
    [pName setTextColor:[UIColor
                         colorWithRed:6/255.0 green:108/255.0 blue:173/255.0 alpha:1.0f]];
    if(self.portfolioUserType == PortfolioUserTypePortfolio)
    {
        [pName setText:self.portfolio.PortfolioName];
    }
    else
    {
        [pName setText:self.project.ProjectName];
    }
    [pName setFont:[UIFont systemFontOfSize:12.0]];
    [pName setBackgroundColor:[UIColor clearColor]];
    [v addSubview:pName];
    
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 100, 20)];
    [lbl setTextColor:[UIColor lightGrayColor]];
    if(self.portfolioUserType == PortfolioUserTypePortfolio)
    {
        [lbl setText:@"Portfolio Users:"];
    }
    else
    {
        [lbl setText:@"Project Users:"];
    }
    
    [lbl setFont:[UIFont systemFontOfSize:14.0]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [v addSubview:lbl];
    
    UILabel* cntLbl = [[UILabel alloc] initWithFrame:CGRectMake(115, 20, 60, 20)];
    [cntLbl setTextColor:[UIColor
                          colorWithRed:6/255.0 green:108/255.0 blue:173/255.0 alpha:1.0f]];
    [cntLbl setText:[NSString stringWithFormat:@"%d users",_taskUserList.count]];
    [cntLbl setFont:[UIFont systemFontOfSize:12.0]];
    [cntLbl setBackgroundColor:[UIColor clearColor]];
    [v addSubview:cntLbl];
    
    
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    int section = [[_sections objectAtIndex:indexPath.section] integerValue];
  
    if(section == ADD_TASK_USERS_SECTION)
    {
        TaskUserCell *cell = nil;
        static NSString *taskUserCell = @"TaskUserCell";
        
        cell = (TaskUserCell*)[tableView dequeueReusableCellWithIdentifier:taskUserCell];
        
        if(cell == nil)
        {
            cell = [[TaskUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taskUserCell];
        }
        
        if(assignees.count)
        {
            User* user = [assignees objectAtIndex:indexPath.row];
            if(NSSTRING_HAS_DATA(user.FormattedName))
                cell.name.text = user.FormattedName;
            else
                cell.name.text = user.Email;
            cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
            [cell.image loadImageFromURL:user.MobileImageUrl];
        }
        else if([searchBar isFirstResponder])
        {
            cell.name.text = searchBar.text;
            cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
        }
        
        if([_selectedIndexPath isEqual:indexPath])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else
    {
        ProjectUserCell* cell = nil;
        static NSString *userCell = @"ProjectUserCell";
        
        cell = (ProjectUserCell*)[tableView dequeueReusableCellWithIdentifier:userCell];
        
        if(cell == nil)
        {
            cell = [[ProjectUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userCell];
        }
        
        ProjectUser* user = [_taskUserList objectAtIndex:indexPath.row];
        [(ProjectUserCell*)cell fillDataForProjectUser:user];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        //cell.editing = YES;
        if(user.CanAddOtherUser && user.UserPermission == 1)
        {
            
        }
        
        return cell;
    }
   
}



 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     return NO;
     int section = [[_sections objectAtIndex:indexPath.section] integerValue];
     
     if(section == ADD_TASK_USERS_SECTION)
     {
         // Return NO if you do not want the specified item to be editable.
         return NO;
     }
     else
     {
         ProjectUser* user = [_taskUserList objectAtIndex:indexPath.row];
         if(user.CanAddOtherUser && user.UserPermission == 1)
             return NO;
         return YES;
     }
 }


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
         ProjectUser* user = [_taskUserList objectAtIndex:indexPath.row];
         
         _deletedIndexPath = indexPath;
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         if(self.portfolioUserType == PortfolioUserTypePortfolio)
         {
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteProjectCallBack:) name:@"DeletePortfolioUserNotifier" object:nil];
             [[TaskDocument sharedInstance] deleteUser:user forPortfolio:self.portfolio];
         }
         else
         {
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteProjectCallBack:) name:@"DeleteProjectUserNotifier" object:nil];
             [[TaskDocument sharedInstance] deleteUser:user forProject:self.project];
         }
         
     }
 }





#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int section = [[_sections objectAtIndex:indexPath.section] integerValue];
    if(section == ADD_TASK_USERS_SECTION)
    {
        if(_selectedIndexPath)
        {
            UITableViewCell* preCell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
            preCell.accessoryType = UITableViewCellAccessoryNone;
        }
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
        //self.navigationItem.rightBarButtonItem.enabled = YES;
        if(assignees.count)
        {
            User* user = [assignees objectAtIndex:indexPath.row];
            searchBar.text = user.Email;
        }
    }
}


- (void)openTaskMenu:(UILongPressGestureRecognizer*)ges
{
    if(ges.state == UIGestureRecognizerStateBegan)
    {
        ProjectUserCell* cell = objc_getAssociatedObject(ges, "ProjectUserCell");
        _selectedIndexPath = [_tableView indexPathForCell:cell];
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:self.portfolioUserType == PortfolioUserTypePortfolio?@"Remove this portfolio member": @"Remove this project member",nil];
        
        
        if(DEVICE_IS_TABLET)
        {
            CGRect rect = cell.frame;
            [actionSheet showFromRect:rect inView:_tableView animated:YES];
        }
        else
            [actionSheet showInView:self.view];
        
        objc_setAssociatedObject(actionSheet, "ProjectUserCellAction", cell, OBJC_ASSOCIATION_RETAIN);
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIColor *customTitleColor = [UIColor
                                 colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [button setTitleColor:customTitleColor forState:UIControlStateNormal];
            [button setTitleColor:customTitleColor forState:UIControlStateSelected];
        }
    }
}

#pragma mark - UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ProjectUserCell* cell = objc_getAssociatedObject(actionSheet, "ProjectUserCellAction");
    objc_removeAssociatedObjects(actionSheet);
    
    if(buttonIndex < 0)
        return;
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([btnTitle isEqualToString:@"Remove this project member"])
    {
        ProjectUser* user = [_taskUserList objectAtIndex:_selectedIndexPath.row];
        
        _deletedIndexPath = _selectedIndexPath;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if(self.portfolioUserType == PortfolioUserTypePortfolio)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteProjectCallBack:) name:@"DeletePortfolioUserNotifier" object:nil];
            [[TaskDocument sharedInstance] deleteUser:user forPortfolio:self.portfolio];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteProjectCallBack:) name:@"DeleteProjectUserNotifier" object:nil];
            [[TaskDocument sharedInstance] deleteUser:user forProject:self.project];
        }
    }
    _selectedIndexPath = nil;
}

-(void)deleteProjectCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(deleteProjectSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)deleteProjectSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]])
    {
        [_taskUserList removeObjectAtIndex:_deletedIndexPath.row];
        [self.tableView beginUpdates];
        // Delete the row from the data source
        [self.tableView deleteRowsAtIndexPaths:@[_deletedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
    }
    else
    {
        [self reloadView];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    _selectedIndexPath = nil;
}

- (void)addUserAction:(UIButton*)btn
{
    if(assignees.count)
    {
        [self assigneeSelected:[assignees objectAtIndex:btn.tag]];
    }
    else
    {
        if(![ValidationHelper validateEmail:searchBar.text])
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        
        User* user = [User new];
        user.Email = searchBar.text;
        [self assigneeSelected:user];
    }
}

- (void)addAction:(UIBarButtonItem*)btn
{
    if(assignees.count)
    {
        [self assigneeSelected:[assignees objectAtIndex:_selectedIndexPath.row]];
    }
    else
    {
        if(![ValidationHelper validateEmail:searchBar.text])
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        
        User* user = [User new];
        user.Email = searchBar.text;
        [self assigneeSelected:user];
    }
}

- (void)assigneeSelected:(User*)assignee
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"UserProfile.Email CONTAINS[c] %@",assignee.Email];
    NSArray* tmp = [_taskUserList filteredArrayUsingPredicate:predicate];
    if(!tmp || tmp.count == 0)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if(self.portfolioUserType == PortfolioUserTypePortfolio)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addProjectCallBack:) name:@"AddPortfolioUserNotifier" object:nil];
            [[TaskDocument sharedInstance] addUser:assignee forPortfolio:self.portfolio andFollow:!followCheckmark.selected andCanAddUser:!canAddOtherCheckmark.selected];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addProjectCallBack:) name:@"AddProjectUserNotifier" object:nil];
            [[TaskDocument sharedInstance] addUser:assignee forProject:self.project andFollow:!followCheckmark.selected andCanAddUser:!canAddOtherCheckmark.selected];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is already added." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(void)addProjectCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(addProjectSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)addProjectSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([sender isKindOfClass:[ProjectUser class]])
    {
        searchBar.text = @"";
        [searchBar resignFirstResponder];
        [searchBar setShowsCancelButton:NO];
        //iToast *toast = [iToast makeText:@"Project added Successfully"];
        //[toast show:iToastTypeInfo];
        [_taskUserList addObject:sender];
        [self reloadView];
    }
    else
    {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)sb
{
    [sb setShowsCancelButton:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText != nil && [searchText isKindOfClass:[NSString class]])
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"FormattedName CONTAINS[c] %@ || Email CONTAINS[c] %@",searchText,searchText];
        NSArray* arr = [[TaskDocument sharedInstance] assignees];
        assignees = [arr filteredArrayUsingPredicate:predicate];
        [self reloadView];
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *) sb
{
    sb.text = @"";
    [self reloadView];
    [sb setShowsCancelButton:NO];
    [self.view endEditing:YES];
}




@end
