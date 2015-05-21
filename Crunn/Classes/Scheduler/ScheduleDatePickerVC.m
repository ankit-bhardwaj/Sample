//
//  ScheduleDatePickerVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/31/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "ScheduleDatePickerVC.h"
#import <Kal.h>
#import "ScheduleTimeSlotPickerVC.h"
#import "DropDownControl.h"
#import "DropdownActionSheet.h"
#import "EventDocument.h"
#import "ScheduleNavigationVC.h"

@interface ScheduleDatePickerVC ()
{
    KalViewController* kal;
    NSMutableArray* _selectedDates;
    IBOutlet UITableView* tableView;
    NSMutableArray* _sections;
    NSMutableArray* _timeSlots;
    
    DropdownActionSheet* dropDownActionSheet;
    NSMutableArray* _defaulSlots;
    
    UIView* headerWithCalendar;
    UIView* headerWithOutCalendar;
    
    IBOutlet UIView* timeSelectionAlertView;
    IBOutlet UIView* timeSelectionView;
    IBOutlet UIView* timePickerView;
    
    IBOutlet UITableView* timeSelectionTableView;
    
    IBOutlet UIDatePicker* datePicker;
    NSString* _selectedValue;
}
@property (nonatomic,strong)NSMutableArray* selectedDates;

- (IBAction)setPickerValue:(id)sender;
- (IBAction)setTimeSlot:(id)sender;
- (IBAction)toggleCalendar:(id)sender;
@end

@implementation ScheduleDatePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
    
    _selectedDates = [NSMutableArray new];
    
    headerWithCalendar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 400)];
    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeMultiple CalendarModeType:CalendarModeTypeMeeting];
    kal.delegate = self;
    kal.dataSource = self;
    kal.minAvailableDate = [NSDate date];
    kal.modeType = CalendarModeTypeNone;
    //kal.selectedDate = [NSDate date];
    
    CGRect rect = kal.view.frame;
    rect.origin.y += 0;
    rect.size.height = 360;
    [kal.view setFrame:rect];
    [headerWithCalendar addSubview:kal.view];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, rect.size.height+5, self.view.frame.size.width-5, 30)];
    [lbl setTextColor:[UIColor colorWithRed:24.0/255.0 green:161.0/255.0 blue:226.0/255.0 alpha:1.0]];
    [lbl setFont:[UIFont systemFontOfSize:15.0]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:@"You can propose multiple time slots each day."];
    [headerWithCalendar addSubview:lbl];
    
    
    headerWithOutCalendar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    UILabel* lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.view.frame.size.width-5, 30)];
    [lbl1 setTextColor:[UIColor colorWithRed:24.0/255.0 green:161.0/255.0 blue:226.0/255.0 alpha:1.0]];
    [lbl1 setFont:[UIFont systemFontOfSize:15.0]];
    [lbl1 setBackgroundColor:[UIColor clearColor]];
    [lbl1 setText:@"You can propose multiple time slots each day."];
    [headerWithOutCalendar addSubview:lbl1];
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGPoint center = kal.view.center;
        center.x = 270;
        kal.view.center = center;
    }
    _selectedDates = [NSMutableArray new];
    //[_selectedDates addObject:[NSDate date]];
    
    _sections = [NSMutableArray new];
    _timeSlots = [NSMutableArray new];
    
    _defaulSlots = [NSMutableArray new];
    
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
    double interval = [EventDocument sharedInstance].selectedMeetingInterval*3600;

    while ([[startDate dateByAddingTimeInterval:interval] compare:nextDate] != NSOrderedDescending) {
        
        NSString* str = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:startDate],[df stringFromDate:[startDate dateByAddingTimeInterval:interval]]];
        [_timeSlots addObject:str];
        
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: startDate];
        if(_defaulSlots.count < 2 && [components hour] >= 9 && [lastSelected compare:startDate] == NSOrderedSame)
        {
            if([EventDocument sharedInstance].selectedMeetingInterval == 4)
                lastSelected = [startDate dateByAddingTimeInterval:3600];
            else
                lastSelected = [startDate dateByAddingTimeInterval:interval];
            [_defaulSlots addObject:str];
        }
        startDate = [startDate dateByAddingTimeInterval:1800];
    };
    
    if([_timeSlots count] > 0 && [_defaulSlots count] == 0)
    {
        [_defaulSlots addObject:[_timeSlots objectAtIndex:0]];
    }

    for(NSDate* date in self.selectedDates)
    {
        [_sections addObject:[NSMutableArray arrayWithArray:_defaulSlots]];
    }
    [tableView setTableHeaderView:headerWithCalendar];
    [tableView setTableFooterView:[(ScheduleNavigationVC*)self.navigationController getToolBar]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    //[[EventDocument sharedInstance] fetchEventsFromStartDate:fromDate toEnddate:toDate];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    return [self eventsFrom:fromDate to:toDate];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    
}

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSMutableArray *matches = [NSMutableArray array];
    return matches;
}

- (void)removeAllItems
{
    
}


- (void)tapOnDate:(NSDate *)date
{
    if(![_selectedDates containsObject:date])
    {
        [_sections addObject:[NSMutableArray arrayWithArray:_defaulSlots]];
        [_selectedDates addObject:date];
    }
    else
    {
         [_sections removeObjectAtIndex:[_selectedDates indexOfObject:date]];
        [_selectedDates removeObject:date];
    }
   
    
    [tableView reloadData];
}

- (void)pickTimeSlotsAction:(UIBarButtonItem*)item
{
    if([_selectedDates count] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select atleat one date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        ScheduleTimeSlotPickerVC* vc = [[ScheduleTimeSlotPickerVC alloc] initWithNibName:@"ScheduleTimeSlotPickerVC" bundle:nil];
        vc.selectedDates = [_selectedDates sortedArrayUsingSelector:@selector(compare:)];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)removeDate:(UIButton*)btn
{
    [kal removeSelectionOnDate:[_selectedDates objectAtIndex:btn.tag]];
    [_sections removeObjectAtIndex:btn.tag];
    [_selectedDates removeObjectAtIndex:btn.tag];
    [tableView reloadData];
}

- (void)removeTimeSlots:(UIButton*)btn
{
    NSIndexPath* indexpath = objc_getAssociatedObject(btn, "indexpath");
    NSMutableArray* arr = [_sections objectAtIndex:indexpath.section];
    if(arr.count)
        [arr removeObjectAtIndex:indexpath.row];
    else
    {
        [kal removeSelectionOnDate:[_selectedDates objectAtIndex:indexpath.section]];
        [_sections removeObjectAtIndex:indexpath.section];
        [_selectedDates removeObjectAtIndex:indexpath.section];
    }
    [tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    if(tv == timeSelectionTableView)
        return 1;
    if(tv == tableView)
        return [_selectedDates count];
    return 0;
}// Default is 1 if not implemented

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38.0;
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section
{
    if(tv == timeSelectionTableView)
        return 1.0;
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tv heightForFooterInSection:(NSInteger)section
{
    if(tv == timeSelectionTableView)
        return 1.0;
    return 10.0;
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section
{
    if(tv == timeSelectionTableView)
        return nil;
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [view setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:1.0]];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(tableView.bounds.size.width-70, 0, 80, 30)];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [btn.titleLabel setTextColor:[UIColor blackColor]];
    [btn setTitle:@"Delete" forState:UIControlStateNormal];
    [btn setTag:section];
    [btn addTarget:self action:@selector(removeDate:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 30)];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:18.0]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    NSDateFormatter * df = [NSDateFormatter new];
    [df setDateFormat:@"EEEE, MMM d, yyyy"];
    [lbl setText:[df stringFromDate:[self.selectedDates objectAtIndex:section]]];
    [view addSubview:lbl];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if(tv == timeSelectionTableView)
        return 2;

    NSMutableArray* arr = [_sections objectAtIndex:section];
    return [arr count]+1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tv == timeSelectionTableView)
    {
        static NSString *CellIdentifier = @"Cell1";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.backgroundColor =[UIColor clearColor];
        }
        if(indexPath.row == 0)
        {
            cell.textLabel.text = @"Start Time";
            cell.detailTextLabel.text = [[_selectedValue componentsSeparatedByString:@" - "] firstObject];
        }
        else
        {
            cell.textLabel.text = @"End Time";
            cell.detailTextLabel.text = [[_selectedValue componentsSeparatedByString:@" - "] lastObject];
        }
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor =[UIColor clearColor];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(tableView.bounds.size.width - 40,-5, 30, cell.bounds.size.height)];
        [btn setImage:[UIImage imageNamed:@"deleteStot.png"] forState:UIControlStateNormal];
        [btn setTag:1001];
        [btn addTarget:self action:@selector(removeTimeSlots:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
    }
    
    cell.accessoryView = nil;
    
    UIButton* btn = (UIButton*)[cell.contentView viewWithTag:1001];
    objc_setAssociatedObject(btn, "indexPath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSMutableArray* arr = [_sections objectAtIndex:indexPath.section];
    if(_timeSlots.count > 0)
    {
        btn.hidden = NO;
        
        if(indexPath.row < arr.count)
        {
            NSString* value = [arr objectAtIndex:indexPath.row];
            if([value isEqualToString:@"12:00AM - 12:00AM"])
                [cell.textLabel setText:@"All day"];
            else
                [cell.textLabel setText:value];
            cell.imageView.image = nil;
        }
        else
        {
            btn.hidden = YES;
            [cell.textLabel setText:@"Add time slots"];
            cell.imageView.image = [UIImage imageNamed:@"addSlots.png"];
        }
    }

    
    return cell;
    
}

- (void)tableView:(UITableView *)tv  didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tv == timeSelectionTableView)
    {
        timePickerView.hidden = NO;
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"h:mma"];
        NSString* str = [[_selectedValue componentsSeparatedByString:@" - "] objectAtIndex:indexPath.row];
       [datePicker setDate:[df dateFromString:str]];
        objc_setAssociatedObject(datePicker, "indexpath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else
    {
        NSMutableArray* arr = [_sections objectAtIndex:indexPath.section];
        if(_timeSlots.count > 0)
        {
            if(indexPath.row < arr.count)
            {
                _selectedValue = [arr objectAtIndex:indexPath.row];
            }
            else if(3 < _timeSlots.count)
            {
                _selectedValue = [_timeSlots objectAtIndex:3];
            }
            else
                _selectedValue = [arr objectAtIndex:0];
            timeSelectionAlertView.hidden = NO;
            
            objc_setAssociatedObject(timeSelectionAlertView, "indexpath", indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [timeSelectionTableView reloadData];
            [self.view bringSubviewToFront:timeSelectionAlertView];
        }
        
        
    }
}


- (DropDownControl*)getDropDown
{
    DropDownControl* dropdown = [DropDownControl buttonWithType:UIButtonTypeCustom];
    dropdown.ownerView = self.view;
    dropdown.delegate = self;
    [dropdown.titleLabel setTextColor:[UIColor whiteColor]];
    [dropdown.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [dropdown.titleLabel setFont:[UIFont systemFontOfSize:10.0]];
    [dropdown setBackgroundColor:[UIColor
                                  colorWithRed:0.0/255.0 green:120.0/255.0 blue:255.0/255.0 alpha:1.0f]];
    [dropdown setTag:1001];
    
    return dropdown;
}


- (IBAction)toggleCalendar:(UIButton*)sender
{
    sender.selected = !sender.selected;
    if(sender.selected)
    {
        [tableView setTableHeaderView:headerWithOutCalendar];
    }
    else
    {
        [tableView setTableHeaderView:headerWithCalendar];
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
        
        [tableView reloadData];
        
//        [tableView beginUpdates];
//        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexpath.section] withRowAnimation:UITableViewRowAnimationFade];
//        [tableView endUpdates];
    }
    if (dropDownActionSheet) {
        [dropDownActionSheet slideOut];
    }
}
- (NSString*)validate
{
    if(_selectedDates.count==0)
        return @"Please select atleast one date";
    
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
    
    return nil;
}

- (IBAction)setPickerValue:(id)sender
{
    NSIndexPath* indexPath = objc_getAssociatedObject(datePicker, "indexpath");
    NSString* str = [[_selectedValue componentsSeparatedByString:@" - "] objectAtIndex:indexPath.row];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"h:mma"];
    str = [df stringFromDate:datePicker.date];
    if(indexPath.row == 0)
        _selectedValue = [NSString stringWithFormat:@"%@ - %@",str,[[_selectedValue componentsSeparatedByString:@" - "] lastObject]];
    else
        _selectedValue = [NSString stringWithFormat:@"%@ - %@",[[_selectedValue componentsSeparatedByString:@" - "] firstObject],str];
    timePickerView.hidden = YES;
    [timeSelectionTableView reloadData];
}

- (IBAction)setTimeSlot:(id)sender
{
    NSString* startTime = [[_selectedValue componentsSeparatedByString:@" - "] firstObject];
    NSString* endTime = [[_selectedValue componentsSeparatedByString:@" - "] lastObject];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"h:mma"];
    if([[df dateFromString:startTime] compare:[df dateFromString:endTime]] == NSOrderedDescending)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Start time should be lesser than end time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        timeSelectionAlertView.hidden = YES;
        NSIndexPath* indexPath = objc_getAssociatedObject(timeSelectionAlertView, "indexpath");
        NSMutableArray* arr = [_sections objectAtIndex:indexPath.section];
        if(indexPath.row < arr.count)
        {
            [arr replaceObjectAtIndex:indexPath.row withObject:[NSString stringWithFormat:@"%@ - %@",startTime,endTime]];
        }
        else
        {
            [arr addObject:[NSString stringWithFormat:@"%@ - %@",startTime,endTime]];
        }
        [tableView reloadData];
    }

}


@end
