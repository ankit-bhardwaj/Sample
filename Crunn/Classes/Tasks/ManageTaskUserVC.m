//
//  ManageTaskUserVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ManageTaskUserVC.h"
#import "TaskDocument.h"
#import "ValidationHelper.h"
#import "TaskUserCell.h"

#include <AddressBookUI/AddressBookUI.h>

#define FILTER_SECTION 0
#define ADD_TASK_USERS_SECTION 1
#define TASK_USERS_SECTION 2

@interface ManageTaskUserVC ()
{
    NSMutableArray* assignees;
    IBOutlet UISearchBar* searchBar;
    NSMutableArray* _sections;
    NSIndexPath* _selectedIndexPath;
    IBOutlet UIButton* followCheckmark;
    NSMutableArray* _taskUserList;
}
@property(nonatomic,retain)IBOutlet UITableView* tableView;

- (IBAction)followAction:(UIButton*)item;
@end

@implementation ManageTaskUserVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = @"Manage Task Users";
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
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    UIBarButtonItem* addBtn = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addAction:)];
    addBtn.enabled = NO;
    [addBtn setWidth:40.0];
    
    self.navigationItem.rightBarButtonItem = addBtn;
    
    self.navigationController.toolbarHidden = NO;
    
    _sections = [[NSMutableArray alloc] init];
    _taskUserList = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assigneeListCallBack:) name:@"AssigneeListNotifier" object:nil];
    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
    //assignees = [[TaskDocument sharedInstance] assignees];
    [self reloadView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTaskUserListCallBack:) name:@"GetTaskUserListNotifier" object:nil];
    [[TaskDocument sharedInstance] getTaskUserListForId:self.task.taskId];
    
    [[TaskDocument sharedInstance] requestForABAccess];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"Share From Address book" style:UIBarButtonItemStylePlain target:self action:@selector(openAddressBook)];
    
    UIBarButtonItem* flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.navigationController.toolbar setItems:[NSArray arrayWithObjects:flexible,item,flexible,nil]];
}


- (void)getTaskUserListCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(gotoUserList:) withObject:[note object] waitUntilDone:NO];
}

- (void)gotoUserList:(NSArray*)arr
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(arr && [arr isKindOfClass:[NSArray class]] && arr.count > 0)
    {
        [_taskUserList removeAllObjects];
        [_taskUserList addObjectsFromArray: arr];
        [self reloadView];
    }
}

- (IBAction)followAction:(UIButton*)item
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
    return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sec
{
    int section = [[_sections objectAtIndex:sec] integerValue];
    if(section == ADD_TASK_USERS_SECTION)
    {
        return nil;
    }
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
    [v setBackgroundColor:[UIColor whiteColor]];
    

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 32)];
        [lbl setTextColor:[UIColor
                           colorWithRed:6/255.0 green:108/255.0 blue:173/255.0 alpha:1.0f]];
        [lbl setText:@"Task Users:"];
        [lbl setFont:[UIFont systemFontOfSize:14.0]];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [v addSubview:lbl];
        
        UILabel* cntLbl = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 60, 32)];
        [cntLbl setTextColor:[UIColor lightGrayColor]];
        [cntLbl setText:[NSString stringWithFormat:@"%d users",_taskUserList.count]];
        [cntLbl setFont:[UIFont systemFontOfSize:12.0]];
        [cntLbl setBackgroundColor:[UIColor clearColor]];
        [v addSubview:cntLbl];
        
        
        UILabel* followLbl = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width-50, 0, 40, 32)];
        [followLbl setTextColor:[UIColor lightGrayColor]];
        [followLbl setText:[NSString stringWithFormat:@"Follow"]];
        [followLbl setFont:[UIFont systemFontOfSize:12.0]];
        [followLbl setBackgroundColor:[UIColor clearColor]];
        [v addSubview:followLbl];
    
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskUserCell *cell = nil;
    
    int section = [[_sections objectAtIndex:indexPath.section] integerValue];
  
    if(section == ADD_TASK_USERS_SECTION)
    {
        static NSString *taskUserCell = @"TaskUserCell";
        
        cell = (TaskUserCell*)[tableView dequeueReusableCellWithIdentifier:taskUserCell];
        
        if (cell == nil) {
            NSString* nibName = @"TaskUserCell";
            NSArray* arrAllObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
            if (arrAllObjects) {
                for (id object in arrAllObjects)
                {
                    if ([object isKindOfClass:[TaskUserCell class]]) {
                        cell = (TaskUserCell*)object;
                        break;
                    }
                }
            }
        }
        if(assignees.count)
        {
            User* user = [assignees objectAtIndex:indexPath.row];
            if(NSSTRING_HAS_DATA(user.FormattedName))
                cell.name.text = user.FormattedName;
            else
                cell.name.text = user.Email;
            if(user.photoData)
                cell.image.image = [UIImage imageWithData:user.photoData];
            else
            {
                cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
                [cell.image loadImageFromURL:user.MobileImageUrl];
            }
        }
        else
        {
            _selectedIndexPath = indexPath;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            cell.name.text = searchBar.text;
            cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
        }
        
        if([_selectedIndexPath isEqual:indexPath])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        static NSString *taskUserCell = @"TaskSubTitleUserCell";
        
        cell = (TaskUserCell*)[tableView dequeueReusableCellWithIdentifier:taskUserCell];
        
        if (cell == nil) {
            NSString* nibName = @"TaskSubTitleUserCell";
            NSArray* arrAllObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
            if (arrAllObjects) {
                for (id object in arrAllObjects)
                {
                    if ([object isKindOfClass:[TaskUserCell class]]) {
                        cell = (TaskUserCell*)object;
                        break;
                    }
                }
            }
        }
        TaskUser* user = [_taskUserList objectAtIndex:indexPath.row];
        [(TaskUserCell*)cell fillDataForUser:user];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    
    
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
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if(assignees.count)
        {
            User* user = [assignees objectAtIndex:indexPath.row];
            searchBar.text = user.Email;
        }
    }
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareTaskCallBack:) name:@"ShareTaskNotifier" object:nil];
        [[TaskDocument sharedInstance] shareTask:self.task withUser:assignee andFollow:!followCheckmark.selected];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is already added." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(void)shareTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(shareTaskSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)shareTaskSuccess:(id)sender
{
    if ([sender isKindOfClass:[NSNumber class]])
    {
        searchBar.text = @"";
        [searchBar resignFirstResponder];
        [searchBar setShowsCancelButton:NO];
        [self.view makeToast:@"User Added Successfully"];
        [[TaskDocument sharedInstance] getTaskUserListForId:self.task.taskId];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)sb
{
    [sb setShowsCancelButton:NO];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText != nil && [searchText isKindOfClass:[NSString class]])
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"FormattedName CONTAINS[c] %@ || Email CONTAINS[c] %@",searchText,searchText];
        NSMutableArray* arr = [[TaskDocument sharedInstance] assignees];
        assignees = [NSMutableArray arrayWithArray:[arr filteredArrayUsingPredicate:predicate]];
        [assignees addObjectsFromArray:[[TaskDocument sharedInstance] contactsContainingEmail:searchText]];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([searchBar isFirstResponder])
    {
        [searchBar resignFirstResponder];
    }
}

- (void)openAddressBook
{
    if([AuthorizationStatus isAddressbookAllowedWithMessage:YES])
    {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
        [picker setPeoplePickerDelegate:self];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
            picker.predicateForSelectionOfPerson = [NSPredicate predicateWithFormat:@"%K.@count <= 1", ABPersonEmailAddressesProperty];
        }
        
        //    if ([picker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        //        [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setBarTintColor:[[SkinDocument sharedInstance] getSkinColorForIdentifier:kSkinNavBarTintColor]];
        //
        //        [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:[[SkinDocument sharedInstance] getSkinColorForIdentifier:kSkinNavTintColor]];
        //    }
        //    else
        //        [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:[[SkinDocument sharedInstance] getSkinColorForIdentifier:kSkinNavTintColor]];
        
        [[UINavigationBar appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
}

#pragma mark -
#pragma mark - AddressbookUI delegate methods
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person];
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    NSMutableArray *contactEmails = nil;
    
    for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++)
    {
        if (!contactEmails)
            contactEmails = [[NSMutableArray alloc]init];
        CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
        [contactEmails addObject:(__bridge NSString *)contactEmailRef];
        CFRelease(contactEmailRef);
    }
    CFRelease(multiEmails);
    ABMultiValueRef Name = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    if(!contactEmails || contactEmails.count==0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"No email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        CFRelease(Name);
        return NO;
    }
    
    
    if (contactEmails && contactEmails.count>0)
    {
        if (contactEmails.count>1)
        {
            return YES;
        }
        else
        {
            NSString *contactEmail = [contactEmails objectAtIndex:0];
            if(![ValidationHelper validateEmail:contactEmail])
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                return NO;
            }
            [peoplePicker dismissViewControllerAnimated:YES completion:^{
                [self closeAddressBookWithEmail:contactEmail];
            }];
            
        }
        
        
        return NO;
    }
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if(property == kABPersonEmailProperty)
    {
        ABMultiValueRef multiEmails = ABRecordCopyValue(person, property);
        
        CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, identifier);
        NSString *contactEmail = (__bridge NSString *)contactEmailRef;
        if(![ValidationHelper validateEmail:contactEmail])
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return YES;
        }
        [peoplePicker dismissViewControllerAnimated:YES completion:^{
            [self closeAddressBookWithEmail:contactEmail];
        }];
        
        return NO;
    }
    return YES;
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


- (void)closeAddressBookWithEmail:(NSString*)email
{
    searchBar.text = email;
    [self reloadView];
}


@end
