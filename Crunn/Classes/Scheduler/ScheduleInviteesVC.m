//
//  ScheduleInviteesVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ScheduleInviteesVC.h"
#import "TaskDocument.h"
#import "ValidationHelper.h"

#import "TaskUserCell.h"
#include <AddressBookUI/AddressBookUI.h>
#import "EventDocument.h"
#import "BrowserVC.h"
#import "ScheduleNavigationVC.h"

#define FILTER_SECTION 0
#define ADD_INVITEE_USERS_SECTION 1
#define INVITEE_USERS_SECTION 2

@interface ScheduleInviteesVC ()
{
    NSMutableArray* assignees;
    IBOutlet UISearchBar* searchTextBar;
    UISegmentedControl* segment;
    NSMutableArray* phoneContacts;
    NSMutableArray* actualPhoneContacts;
    NSMutableArray* _sections;
    IBOutlet UIButton* doneBtn;

}
@property(nonatomic,strong)IBOutlet UITableView* tableView;

- (IBAction)addAction:(id)sender;
- (IBAction)doneAction:(id)sender;
@end

@implementation ScheduleInviteesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[UIView new]];
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    searchTextBar.delegate = self;
    
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send Invitation" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    
    //self.navigationController.toolbarHidden = NO;
    
    segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Grapple Contacts",@"Phone Contacts", nil]];
    //segment.tintColor = [UIColor whiteColor];
    segment.selectedSegmentIndex = 0;
    //[self.navigationItem setTitleView:segment];
    [segment addTarget:self action:@selector(toggleContacts:) forControlEvents:UIControlEventValueChanged];
    

    _sections = [[NSMutableArray alloc] init];
    _selectedAssignees = [[NSMutableArray alloc] init];
    assignees = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assigneeListCallBack:) name:@"AssigneeListNotifier" object:nil];
    [[TaskDocument sharedInstance] getAssigneeListForSearch:nil];
    
    [[TaskDocument sharedInstance] requestForABAccess];
    [[TaskDocument sharedInstance] getAllABContacts];
}

-(void)reloadView
{
    [_sections removeAllObjects];
    if(NSSTRING_HAS_DATA(searchTextBar.text))
        [_sections addObject:[NSNumber numberWithInteger:ADD_INVITEE_USERS_SECTION]];
    
    [_sections addObject:[NSNumber numberWithInteger:INVITEE_USERS_SECTION]];
    
    [self.tableView reloadData];
}


- (void)toggleContacts:(UISegmentedControl*)seg
{
    if(phoneContacts.count == 0)
        [phoneContacts addObjectsFromArray:[[TaskDocument sharedInstance] allABContacts]];
    [self.tableView reloadData];
}

- (NSString*)validate
{
    if(_selectedAssignees.count==0)
        return @"Please select atleast one invitee";
    
    NSMutableArray* participationList = [NSMutableArray array];
    for(User* user in _selectedAssignees)
    {
        NSString* firstname = user.FirstName;
        NSString* lastname = user.LastName;
        if(!firstname)firstname = @"";
        if(!lastname)lastname = @"";
        [participationList addObject:user.Email];
    }
    [[EventDocument sharedInstance].currentMeetingInfo setObject:[participationList componentsJoinedByString:@","] forKey:@"RecipientEmailList"];
    [EventDocument sharedInstance].currentMeetingRecipientList = participationList;
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createMeetingNotifier:) name:@"CreateMeetingNotifier" object:nil];
    [[EventDocument sharedInstance] createMeeting];
    return @"";
}

- (void)createMeetingNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(createMeetingSuccess:) withObject:note.object waitUntilDone:NO];
}

- (void)createMeetingSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if(sender && [sender isKindOfClass:[NSDictionary class]])
    {
        NSNumber* meetingId = [sender objectForKey:@"MeetingId"];
        NSString* meetingLink = [sender objectForKey:@"MeetingLink"];
        if([meetingId integerValue] > 0)
        {
            [(ScheduleNavigationVC*)self.navigationController showFinalLink:meetingLink];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"There is some issue in sending fields. Please check and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
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
    if(NSSTRING_HAS_DATA(searchTextBar.text))
    {
        [self doSearch:searchTextBar.text];

        [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
    }
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
    return [_sections count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sec
{
    int section = [[_sections objectAtIndex:sec] intValue];
    
    if(section == ADD_INVITEE_USERS_SECTION)
    {
        return 0.0;
    }
    return 30.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" Invitees";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sec
{
    int section = [[_sections objectAtIndex:sec] intValue];
    
    if(section == ADD_INVITEE_USERS_SECTION)
    {
        if(NSSTRING_HAS_DATA( searchTextBar.text))
            return MAX(1,[assignees count]);
        else
            return [assignees count];
    }
    else
    {
        return [_selectedAssignees count];
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
    int section = [[_sections objectAtIndex:indexPath.section] intValue];
    
    if(section == ADD_INVITEE_USERS_SECTION)
    {
        array = assignees;
    }
    else
    {
        array = _selectedAssignees;
    }
    if(array.count)
    {
        User* user = [array objectAtIndex:indexPath.row];
        cell.name.text = user.FormattedName?user.FormattedName:user.Email;
        if(user.photoData)
            cell.image.image = [UIImage imageWithData:user.photoData];
        else
        {
            cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
            [cell.image loadImageFromURL:user.MobileImageUrl];
        }

        if(section == ADD_INVITEE_USERS_SECTION)
        {
//            if([_selectedAssignees containsObject:user])
//                cell.accessoryType= UITableViewCellAccessoryCheckmark;
//            else
//                cell.accessoryType= UITableViewCellAccessoryNone;
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else
        {
            cell.accessoryType= UITableViewCellAccessoryNone;
            cell.deleteBtn.hidden = NO;
            objc_setAssociatedObject(cell.deleteBtn, "indexpath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.deleteBtn addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else
    {
        cell.name.text = searchTextBar.text;
        cell.image.image = [UIImage imageNamed:@"avatar_small.png"];
    }
   
    
    return cell;
}

- (void)deleteUser:(UIButton*)btn
{
    NSIndexPath* indexpath = objc_getAssociatedObject(btn, "indexpath");
    [_selectedAssignees removeObjectAtIndex:indexpath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
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
    [searchTextBar resignFirstResponder];
    if(indexPath.section == 1)
        return;
    
    NSArray* array = nil;
    int section = [[_sections objectAtIndex:indexPath.section] intValue];
    
    if(section == ADD_INVITEE_USERS_SECTION)
    {
        array = assignees;
    }
    else
    {
        array = _selectedAssignees;
    }
    if(array.count)
    {
        User* user = [array objectAtIndex:indexPath.row];
        
//        if(![_selectedAssignees containsObject:[array objectAtIndex:indexPath.row]])
//            [_selectedAssignees addObject:[array objectAtIndex:indexPath.row]];
        [assignees removeAllObjects];
        [tableView reloadData];
        searchTextBar.text = user.Email;
    }

}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    doneBtn.hidden = NO;
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(searchText != nil && [searchText isKindOfClass:[NSString class]])
    {
        [self doSearch:searchText];
        
        [self reloadView];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *) sb
{
    [sb resignFirstResponder];
    [sb setShowsCancelButton:NO animated:YES];
    sb.text = @"";
    [self reloadView];
}

- (void)doSearch:(NSString*)term
{
    if(term != nil && [term isKindOfClass:[NSString class]])
    {
        [assignees removeAllObjects];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"FormattedName CONTAINS[c] %@ OR Email CONTAINS[c] %@",term,term];
        NSMutableArray* arr = [NSMutableArray arrayWithArray:[[TaskDocument sharedInstance] assignees]];
        [arr addObjectsFromArray:[[TaskDocument sharedInstance] allABContacts]];
        [assignees addObjectsFromArray:[arr filteredArrayUsingPredicate:predicate]];
    }
}

- (void)openAddressBook
{
    if(ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
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

- (IBAction)doneAction:(id)sender
{
    if(NSSTRING_HAS_DATA(searchTextBar.text) && ![ValidationHelper validateEmail:searchTextBar.text])
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Email Id is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    User* user = [User new];
    user.Email = searchTextBar.text;
    if(![_selectedAssignees containsObject:user])
        [_selectedAssignees addObject:user];
    
    searchTextBar.text = @"";
    [searchTextBar resignFirstResponder];
    //doneBtn.hidden = YES;
    //[searchTextBar setShowsCancelButton:NO animated:YES];
    [self.tableView reloadData];
}

@end
