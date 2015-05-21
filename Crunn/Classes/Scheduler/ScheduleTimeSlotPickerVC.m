//
//  ScheduleTimeSlotPickerVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/31/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "ScheduleTimeSlotPickerVC.h"
#import "EventDocument.h"
#import "DropdownActionSheet.h"
#import "DropDownControl.h"
#import "ScheduleInviteesVC.h"

@interface ScheduleTimeSlotPickerVC ()
{
    IBOutlet UITableView* tableView;
    IBOutlet UILabel* meetingtitleLbl;
    NSMutableArray* _sections;
    NSMutableArray* _timeSlots;
    
    DropdownActionSheet* dropDownActionSheet;
}
@end

@implementation ScheduleTimeSlotPickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Pick time slots";
    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    meetingtitleLbl.text = [EventDocument sharedInstance].currentMeetingInfo[@"Title"];
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Invite team" style:UIBarButtonItemStylePlain target:self action:@selector(invite:)];
    [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    _sections = [NSMutableArray new];
    _timeSlots = [NSMutableArray new];
    
    NSMutableArray* defaulSlots = [NSMutableArray new];
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: today];
    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *startDate = [gregorian dateFromComponents: components];
    NSDate *nextDate = [startDate dateByAddingTimeInterval:3600*24];
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"h:mma"];
    NSDate* lastSelected = nil;
    
    while ([[startDate dateByAddingTimeInterval:[EventDocument sharedInstance].selectedMeetingInterval*3600] compare:nextDate] != NSOrderedDescending) {
        
        NSString* str = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:startDate],[df stringFromDate:[startDate dateByAddingTimeInterval:[EventDocument sharedInstance].selectedMeetingInterval*3600]]];
        [_timeSlots addObject:str];
        
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: startDate];
        if(defaulSlots.count < 3 && [components hour] >= 9 && [lastSelected compare:startDate] == NSOrderedSame)
        {
            lastSelected = [startDate dateByAddingTimeInterval:[EventDocument sharedInstance].selectedMeetingInterval*3600];
            [defaulSlots addObject:str];
        }
        startDate = [startDate dateByAddingTimeInterval:1800];
    };

    for(NSDate* date in self.selectedDates)
    {
        [_sections addObject:[NSMutableArray arrayWithArray:defaulSlots]];
    }
    tableView.tableHeaderView = [UIView new];
    [tableView setEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)invite:(id)sender
{
    NSMutableArray* datesArr = [NSMutableArray array];
    NSMutableArray* slotsArr = [NSMutableArray array];
    int i = 0;
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"MM/d/yyyy"];
    
    for(NSMutableArray* slots in _sections)
    {
        if(slots.count)
        {
            NSDate* date = [self.selectedDates objectAtIndex:i];
            [slotsArr addObject:[slots componentsJoinedByString:@"|"]];
            [datesArr addObject:[df stringFromDate:date]];
        }
        i++;
    }
    [EventDocument sharedInstance].currentMeetingDates = datesArr;
    [EventDocument sharedInstance].currentMeetingSlots = slotsArr;

    
//    for(NSMutableArray* slots in _sections)
//    {
//        if(slots.count)
//        {
//            NSDate* date = [self.selectedDates objectAtIndex:i];
//            NSMutableArray* proposedSlots = [NSMutableArray array];
//            for(NSString* s in slots)
//            {
//                NSArray* comps = [s componentsSeparatedByString:@" - "];
//                [proposedSlots addObject:[NSDictionary dictionaryWithObjectsAndKeys:[comps firstObject],@"MeetingStartTime",[comps lastObject],@"MeetingEndTime", nil]];
//            }
//            [dates addObject:[NSDictionary dictionaryWithObjectsAndKeys:[df stringFromDate:date],@"ProposedDate",proposedSlots,@"MeetingSlotsList",[NSNumber numberWithInt:0],@"MeetingId", nil]];
//        }
//        i++;
//    }
    //[[EventDocument sharedInstance].currentMeetingInfo setObject:dates forKey:@"MeetingProposalsList"];
    
    ScheduleInviteesVC* vc = [[ScheduleInviteesVC alloc] initWithNibName:@"ScheduleInviteesVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.selectedDates count];
}// Default is 1 if not implemented


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [view setBackgroundColor:[UIColor clearColor]];
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [lbl setTextColor:[UIColor
                       colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f]];
    [lbl setFont:[UIFont systemFontOfSize:16.0]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    NSDateFormatter * df = [NSDateFormatter new];
    [df setDateFormat:@"   'Date:-' MM/d/yyyy"];
    [lbl setText:[df stringFromDate:[self.selectedDates objectAtIndex:section]]];
    [view addSubview:lbl];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* arr = [_sections objectAtIndex:section];
    return MIN([arr count] + 1, [_timeSlots count]);
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(UIView* v in cell.contentView.subviews)
        [v removeFromSuperview];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryView = nil;
    
    DropDownControl* dropdown = [DropDownControl buttonWithType:UIButtonTypeCustom];
    dropdown.ownerView = self.view;
    dropdown.delegate = self;
    [dropdown setFrame:CGRectMake(0, 1, tableView.bounds.size.width-70, cell.bounds.size.height-2)];
    [dropdown.titleLabel setTextColor:[UIColor whiteColor]];
    //[dropdown.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [dropdown.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [dropdown setBackgroundColor:[UIColor
                                  colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0f]];
    [dropdown setTag:1001];
    [cell.contentView addSubview:dropdown];
    
    NSMutableArray* arr = [_sections objectAtIndex:indexPath.section];
    if(arr.count > indexPath.row)
    {
        [dropdown setSelectedValue:[arr objectAtIndex:indexPath.row]];
        [dropdown setTitle:[arr objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        cell.editing = YES;
        NSMutableArray* array = [NSMutableArray arrayWithArray:_timeSlots];
        for(int i =0;i<[arr count];i++)
        {
            NSString* v = [arr objectAtIndex:i];
            if(![v isEqualToString:[arr objectAtIndex:indexPath.row]] && [array containsObject:v] )
                [array removeObject:v];            
        }
        dropdown.values = array;
        cell.textLabel.text = @"";
        
        UIImageView* rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"leftArrow_timeSlot.png"]];
        [rightArrow setFrame:CGRectMake(dropdown.center.x - 90, dropdown.center.y - 5, 9  , 10)];
        [cell.contentView addSubview:rightArrow];
        
        UIImageView* leftArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow_timeSlot.png"]];
        [leftArrow setFrame:CGRectMake(dropdown.center.x + 80, dropdown.center.y - 5, 9, 10)];
        [cell.contentView addSubview:leftArrow];
    }
    else
    {
        [dropdown setBackgroundColor:[UIColor whiteColor]];
        NSMutableArray* array = [NSMutableArray arrayWithArray:_timeSlots];
        for(int i =0;i<[arr count];i++)
        {
            NSString* v = [arr objectAtIndex:i];
            if([array containsObject:v] )
                [array removeObject:v];
        }
        dropdown.values = array;
        objc_setAssociatedObject(dropdown, "indexPath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        cell.editing = YES;
        cell.textLabel.text = @"Add";
        cell.textLabel.textColor = [UIColor greenColor];
    }
    [dropdown setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentCenter)];
    
    
    
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray* arr = [_sections objectAtIndex:indexPath.section];
        if(arr.count > indexPath.row)
            [arr removeObjectAtIndex:indexPath.row];
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    else
    {
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray* arr = [_sections objectAtIndex:indexPath.section];
    if(arr.count > indexPath.row)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleInsert;
    }
}

- (void)dropdownControlDidCancel:(DropDownControl *)dtControl
{
    if (dropDownActionSheet) {
        [dropDownActionSheet slideOut];
    }
}

-(void)showDropDownOptions:(DropDownControl *)dropdown values:(NSArray *)values
{
    dropDownActionSheet = [[DropdownActionSheet alloc]initWithNibName:@"DropdownActionSheet" bundle:nil];
    CGRect rect = self.navigationController.view.bounds;
    rect.origin = CGPointMake(0, 0);
    UIView *view = dropDownActionSheet.view;
    view.frame = rect;
    [self.navigationController.view addSubview:view];
    dropDownActionSheet.dropdownControl = dropdown;
    dropDownActionSheet.values = values;
    [dropDownActionSheet setupView];
    [dropDownActionSheet viewWillAppear:NO];
}

- (void)dropdown:(DropDownControl *)dropdown didSelectValue:(NSString *)value
{
    [dropdown setTitle:value forState:UIControlStateNormal];
 
    NSIndexPath* indexpath = objc_getAssociatedObject(dropdown, "indexPath");
    if(indexpath)
    {
        NSMutableArray* arr = [_sections objectAtIndex:indexpath.section];
        [arr addObject:value];
        
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    if (dropDownActionSheet) {
        [dropDownActionSheet slideOut];
    }
}

@end
