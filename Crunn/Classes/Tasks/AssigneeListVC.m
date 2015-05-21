//
//  AssigneeListVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "AssigneeListVC.h"
#import "TaskDocument.h"
#import "ValidationHelper.h"

#import "TaskUserCell.h"
#include <AddressBookUI/AddressBookUI.h>

@interface AssigneeListVC ()
{
    NSMutableArray* assignees;
    IBOutlet UISearchBar* searchBar;
    UISegmentedControl* segment;
    NSMutableArray* phoneContacts;
    NSMutableArray* actualPhoneContacts;
}
@end

@implementation AssigneeListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    
    //self.navigationItem.title = @"Assignee List";
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
    
    if(self.isMultiSelect)
    {
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    }
    
    //self.navigationController.toolbarHidden = NO;
    
    segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Grapple Contacts",@"Phone Contacts", nil]];
    //segment.tintColor = [UIColor whiteColor];
    segment.selectedSegmentIndex = 0;
    [self.navigationItem setTitleView:segment];
    [segment addTarget:self action:@selector(toggleContacts:) forControlEvents:UIControlEventValueChanged];
    
    _selectedAssignees = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assigneeListCallBack:) name:@"AssigneeListNotifier" object:nil];
    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
    assignees = [[TaskDocument sharedInstance] assignees];
    
    phoneContacts = [[NSMutableArray alloc] init];
    [[TaskDocument sharedInstance] requestForABAccess];
     [[TaskDocument sharedInstance] getAllABContacts];
}

- (void)toggleContacts:(UISegmentedControl*)seg
{
    if(segment.selectedSegmentIndex == 1)
        [AuthorizationStatus isAddressbookAllowedWithMessage:YES];
    if(phoneContacts.count == 0)
        [phoneContacts addObjectsFromArray:[[TaskDocument sharedInstance] allABContacts]];
    [self.tableView reloadData];
}

- (void)doneAction:(id)sender
{
    [self.target performSelector:self.action withObject:_selectedAssignees];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"Assign From Address book" style:UIBarButtonItemStylePlain target:self action:@selector(openAddressBook)];
//    
//    UIBarButtonItem* flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    [self.navigationController.toolbar setItems:[NSArray arrayWithObjects:flexible,item,flexible,nil]];
}

- (void)assigneeListCallBack:(NSNotification*)note
{
    assignees = [[TaskDocument sharedInstance] assignees];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(segment.selectedSegmentIndex == 0)
    {
        if([searchBar isFirstResponder])
            // Return the number of rows in the section.
            return MAX(1,[assignees count]);
        else
            return [assignees count];
    }
    else
    {
        if([searchBar isFirstResponder])
            // Return the number of rows in the section.
            return MAX(1,[phoneContacts count]);
        else
            return [phoneContacts count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *taskUserCell = @"TaskUserCell";
    
    TaskUserCell* cell = (TaskUserCell*)[tableView dequeueReusableCellWithIdentifier:taskUserCell];
    
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
    cell.accessoryType= UITableViewCellAccessoryNone;
    NSArray* array = nil;
    if(segment.selectedSegmentIndex == 0)
    {
        array = assignees;
    }
    else
    {
        array = phoneContacts;
    }
    if(array.count)
    {
        User* user = [array objectAtIndex:indexPath.row];
        cell.name.text = user.FormattedName;
        if(user.photoData)
            cell.image.image = [UIImage imageWithData:user.photoData];
        else
        {
            cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
            [cell.image loadImageFromURL:user.MobileImageUrl];
        }
        if(self.isMultiSelect)
        {
            if([_selectedAssignees containsObject:user])
                cell.accessoryType= UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType= UITableViewCellAccessoryNone;
        }
        else if([self.selectedAssignee.Email isEqualToString: user.Email])
            cell.accessoryType= UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.name.text = searchBar.text;
        cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
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
    if(self.target && [self.target respondsToSelector:self.action])
    {
        NSArray* array = nil;
        if(segment.selectedSegmentIndex == 0)
        {
            array = assignees;
        }
        else
        {
            array = phoneContacts;
        }
        if(array.count)
        {
            if(self.isMultiSelect)
            {
                if(![_selectedAssignees containsObject:[array objectAtIndex:indexPath.row]])
                    [_selectedAssignees addObject:[array objectAtIndex:indexPath.row]];
                else
                    [_selectedAssignees removeObject:[array objectAtIndex:indexPath.row]];
                [tableView reloadData];
                return;
            }
            else
                [self.target performSelector:self.action withObject:[array objectAtIndex:indexPath.row]];
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
            if(self.isMultiSelect)
            {
                UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType= UITableViewCellAccessoryCheckmark;
                [_selectedAssignees addObject:user];
                return;
            }
            else
                [self.target performSelector:self.action withObject:user];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText != nil && [searchText isKindOfClass:[NSString class]])
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"FormattedName CONTAINS[c] %@",searchText];
        if(segment.selectedSegmentIndex == 0)
        {
            NSMutableArray* arr = [[TaskDocument sharedInstance] assignees];
            assignees = [NSMutableArray arrayWithArray:[arr filteredArrayUsingPredicate:predicate]];
        }
        else
        {
            NSMutableArray* arr = [[TaskDocument sharedInstance] allABContacts];
            phoneContacts = [NSMutableArray arrayWithArray:[arr filteredArrayUsingPredicate:predicate]];
        }
        [self.tableView reloadData];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *) sb
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    if(segment.selectedSegmentIndex == 0)
    {
        assignees = [[TaskDocument sharedInstance] assignees];
    }
    else
    {
        phoneContacts = [[TaskDocument sharedInstance] allABContacts];
    }
    
    [self.tableView reloadData];
}

- (void)openAddressBook
{
    if(![AuthorizationStatus isAddressbookAllowedWithMessage:YES])
        return;
    
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
    if(self.target && [self.target respondsToSelector:self.action])
    {
        if(![ValidationHelper validateEmail:email])
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        
        User* user = [User new];
        user.Email = email;
        [self.target performSelector:self.action withObject:user];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
