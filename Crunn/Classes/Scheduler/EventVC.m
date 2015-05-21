//
//  EventVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/16/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "EventVC.h"
#import <Kal.h>
#import "CreateEventVC.h"
#import "Event.h"
#import "EventDocument.h"

@interface EventVC ()
{
    KalViewController* kal;
    NSMutableArray* currentMonthEvents;
    id<KalDataSourceCallbacks> kalDelegate;
}
@end

static BOOL IsDateBetweenInclusive(NSDate *date, NSDate *begin, NSDate *end)
{
    return [date compare:begin] != NSOrderedAscending && [date compare:end] != NSOrderedDescending;
}

@implementation EventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    currentMonthEvents = [[NSMutableArray alloc] init];
    
    UIColor * barColor = [UIColor
                          colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:barColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               
                                               [UIFont systemFontOfSize:16.0],NSFontAttributeName,
                                               shadow, NSShadowAttributeName, nil];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
    self.navigationItem.title = @"My Calendar";
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddEventOnDate:)];
    [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeEventsNotifier:) name:@"HomeEventNotifier" object:nil];
    [[EventDocument sharedInstance] getHomeEvents];
    
    self.calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 1.;
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
//    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeSingle];
//    kal.delegate = self;
//    kal.dataSource = self;
//    kal.minAvailableDate = [NSDate date];
//    kal.modeType = CalendarModeTypeNone;
//    [self.view addSubview:kal.view];
//    
//    CGRect rect = kal.view.frame;
//    rect.origin.y += 64;
//    [kal.view setFrame:rect];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadView];
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [self.calendar setCurrentDate:[NSDate date]];
}

- (IBAction)didChangeModeTouch
{
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    for (Event *event in [[EventDocument sharedInstance] homeEvents])
    {
        if (IsDateBetweenInclusive(date, event.startDate, event.endDate))
        {
            [currentMonthEvents addObject:event];
            return YES;
        }
    }
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSLog(@"Date: %@", date);
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 300;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75.;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
                         //self.calendarContentViewHeight.constant = newHeight;
                         CGRect rect = self.calendarContentView.frame;
                         rect.size.height = newHeight;
                         [self.calendarContentView setFrame:rect];
                         
                         CGRect rect1 = self.tableView.frame;
                         rect1.origin.y = rect.origin.y+ newHeight;
                         rect1.size.height = self.view.bounds.size.height - rect.origin.y;
                         [self.tableView setFrame:rect1];
                         
                         [self.view layoutIfNeeded];
                     }];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         if(!self.calendar.calendarAppearance.isWeekMode)
                         {
                             CGRect rect = self.calendarContentView.frame;
                             rect.size.height = newHeight;
                             [self.calendarContentView setFrame:rect];
                             
                             CGRect rect1 = self.tableView.frame;
                             rect1.origin.y = rect.origin.y+ newHeight;
                             rect1.size.height = self.view.bounds.size.height - rect.origin.y;
                             [self.tableView setFrame:rect1];
                         }
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getHomeEventsNotifier:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
}

- (void)reloadView
{
    [currentMonthEvents removeAllObjects];
    
    [self.calendar reloadData];
    [self.tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)cancelAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)createEventAction
{
    CreateEventVC* vc = [[CreateEventVC alloc] initWithNibName:@"CreateEventVC" bundle:nil];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)presentingDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate delegate:(id<KalDataSourceCallbacks>)delegate
{
    //[[EventDocument sharedInstance] fetchEventsFromStartDate:fromDate toEnddate:toDate];
    kalDelegate = delegate;
    [delegate loadedDataSource:self];
}

- (NSArray *)markedDatesFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    return [self eventsFrom:fromDate to:toDate];
}

- (void)loadItemsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    
}

- (void)removeAllItems
{
    [currentMonthEvents removeAllObjects];
}

- (NSArray *)eventsFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
    NSMutableArray *matches = [NSMutableArray array];
    for (Event *event in [[EventDocument sharedInstance] homeEvents])
        if (IsDateBetweenInclusive(event.startDate, fromDate, toDate))
            [matches addObject:event];
    
    [currentMonthEvents removeAllObjects];
    [currentMonthEvents addObjectsFromArray:matches];
    [kal.tableView reloadData];
    return matches;
}


- (void)tapOnDate:(NSDate *)date
{

}

- (void)tapToAddOnDate:(NSDate *)date
{
    [self openAddEventOnDate:date];
}

- (void)openAddEventOnDate:(UIBarButtonItem*)item
{
    CreateEventVC* vc = [[CreateEventVC alloc] initWithNibName:@"CreateEventVC" bundle:nil];
    //[vc setStartDate:date];
    //[vc setEndDate:[date dateByAddingTimeInterval:60*60]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark-

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger cnt = [currentMonthEvents count];
    return cnt;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
//    Event *item = [currentMonthEvents objectAtIndex:indexPath.row];
//    size = [item.name sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0] constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return MAX(44,size.height+10);
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Event *item = [currentMonthEvents objectAtIndex:indexPath.row];
    cell.textLabel.text = [item name];
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.detailTextLabel.text = [fmt stringFromDate:item.startDate];
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Event *item = [currentMonthEvents objectAtIndex:indexPath.row];
//    EventsDetailVC* vc = [[EventsDetailVC alloc] initWithNibName:@"EventsDetailView" bundle:nil];
//    [vc setEvent:item];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.calendar reloadData];
    }
}
@end
