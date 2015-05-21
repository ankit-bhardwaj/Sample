//
//  MyMeetingsVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 2/9/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "MyMeetingsVC.h"
#import "Event.h"
#import "EventDocument.h"
#import "GetMoreTableFooter.h"
#import "CustomBadge.h"
#import "UIViewController+MMDrawerController.h"
#import "ScheduleNavigationVC.h"
#import "ScheduleMeetingStepOneVC.h"
#import "Meeting.h"
#import "MyMeetingCell.h"
#import "MyMeetingDetailVC.h"

@interface MyMeetingsVC ()
{
    IBOutlet UITableView* tableView;
    NSMutableArray* _myMetingFeeds;
    GetMoreTableFooter*_getFooterView;
    CustomBadge* badgeView;
    UIImageView* _cruunLogo;
    BOOL tableReloading;

}
@end

@implementation MyMeetingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupLeftMenuButton];
    [self setupRightMenuButton];
    
    UIColor * barColor = [UIColor
                          colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:barColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 1001;
    [tableView addSubview:refreshControl];
    [refreshControl beginRefreshing];
    
    [tableView registerNib:[UINib nibWithNibName:@"MyMeetingCell" bundle:nil]  forCellReuseIdentifier:@"MyMeetingCell"];
    
    _getFooterView = [[GetMoreTableFooter alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 100)];
    [_getFooterView setState:TableFooterNormal];
    [tableView setTableFooterView:_getFooterView];
    
    _myMetingFeeds = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationObserved:) name:@"RemoteNotificationArrived" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMeetingCallBack:) name:@"MyMeetingsNotifier" object:nil];
    [[EventDocument sharedInstance] refreshMyMeetings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)notificationObserved:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(refreshBadge) withObject:nil waitUntilDone:NO];
}

- (void)refreshBadge
{
    int badge = [APPDELEGATE notificationCounter];
    if(badge > 0)
    {
        badgeView.hidden = NO;
        badgeView.badgeText = [NSString stringWithFormat:@"%d",badge];
        [badgeView setNeedsDisplay];
    }
    else
    {
        badgeView.hidden = YES;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _cruunLogo.hidden = NO;
    if([EventDocument sharedInstance].myMeetingUpdateRequire)
        [[EventDocument sharedInstance] refreshMyMeetings];
    else if([EventDocument sharedInstance].myMeetingUpdateRequire)
    {
        [EventDocument sharedInstance].myMeetingUpdateRequire = NO;
        [_myMetingFeeds removeAllObjects];
        [_myMetingFeeds addObjectsFromArray:[EventDocument sharedInstance].myMeetings];
        [tableView reloadData];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _cruunLogo.hidden = YES;
}

- (void)reloadView:(NSArray*)tmp
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIRefreshControl* cnt = (UIRefreshControl*)[tableView viewWithTag:1001];
    [cnt endRefreshing];
    
    [_myMetingFeeds removeAllObjects];
    [_myMetingFeeds addObjectsFromArray:[EventDocument sharedInstance].myMeetings];
    if(tmp && [tmp isKindOfClass:[NSArray class]] && tmp.count > 0)
    {
        if([EventDocument sharedInstance].myMeetingIndex > 1)
        {
            if(!tableReloading)
            {
                tableReloading = YES;
                
                [tableView beginUpdates];
                [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tableView numberOfSections])] withRowAnimation:UITableViewRowAnimationNone];
                [tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([tableView numberOfSections], [tmp count])] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
                tableReloading = NO;
            }
        }
        else
        {
            [tableView reloadData];
        }
    }
    if(!_myMetingFeeds.count || ![tmp isKindOfClass:[NSArray class]])
        [_getFooterView setState:TableFooterNoData];
    else if(!tmp || tmp.count ==0)
        [_getFooterView setState:TableFooterNoMoreData];
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    [APPDELEGATE setNotificationCounter:0];
    [self refreshBadge];
}

- (void)refresh:(UIRefreshControl*)control
{
    [control beginRefreshing];
    [[EventDocument sharedInstance] refreshMyMeetings];
}



- (void)myMeetingCallBack:(NSNotification*)note
{
    do {
        
        [[NSRunLoop currentRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
        
    } while ( tableReloading );
    [self performSelectorOnMainThread:@selector(reloadView:) withObject:[note object] waitUntilDone:NO];
}

-(void)setupLeftMenuButton
{
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menubutton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress:)];
    
    _cruunLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cruun_logo.png"]];
    [_cruunLogo setContentMode:UIViewContentModeScaleAspectFit];
    [_cruunLogo setFrame:CGRectMake(55, 0, 90, 35)];
    
    [self.navigationController.navigationBar addSubview:_cruunLogo];
    
    //UIBarButtonItem * logoButton = [[UIBarButtonItem alloc] initWithCustomView:imgv];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:leftDrawerButton, nil] animated:YES];
}

-(void)setupRightMenuButton
{
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"create_task.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openTaskCreator:)];
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35 , 35)];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"recentActivityNew.png"] forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 35, 35)];
    [v addSubview:btn];
    
    badgeView = [CustomBadge customBadgeWithString:@""];
    badgeView.userInteractionEnabled = NO;
    [badgeView setFrame:CGRectMake(20, -5, 25, 25)];
    [v addSubview:badgeView];
    [btn addTarget:self action:@selector(notificationTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self refreshBadge];
    
    UIBarButtonItem * notificationButton = [[UIBarButtonItem alloc] initWithCustomView:v];
    
    UIBarButtonItem * calendarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendar_btn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openCalendar)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:rightDrawerButton,notificationButton, nil] animated:YES];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)openTaskCreator:(id)sender
{
    ScheduleMeetingStepOneVC* vc = [[ScheduleMeetingStepOneVC alloc] initWithNibName:@"ScheduleMeetingStepOneVC" bundle:nil];
    ScheduleNavigationVC* navVC = [[ScheduleNavigationVC alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    //navVC.navigationBarHidden = YES;
    [self presentViewController:navVC animated:NO completion:^{
        
    }];
}

- (void)notificationTapped:(id)sender
{
    if(!badgeView.hidden)
        [[EventDocument sharedInstance] refreshMyMeetings];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Delegate Method



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_myMetingFeeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyMeetingCell";
    MyMeetingCell *cell = (MyMeetingCell*)[tblView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[MyMeetingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Meeting* task = [_myMetingFeeds objectAtIndex:indexPath.section];
    cell.creatorName.text = task.Title;
    cell.createdDate.text = [[task.CreatedOnTimeString componentsSeparatedByString:@"|"] firstObject];
    [cell.creatorImage loadImageFromURL:task.CreatorDetails.MobileImageUrl];
    return cell;
    
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Meeting* task = [_myMetingFeeds objectAtIndex:indexPath.section];
    MyMeetingDetailVC* vc = [[MyMeetingDetailVC alloc] initWithNibName:@"MyMeetingDetailVC" bundle:nil];
    [vc setMeeting:task];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float height = [UIScreen mainScreen].bounds.size.height;
    if(scrollView.contentOffset.y >= (scrollView.contentSize.height - height))
    {
        if([_getFooterView getState] != TableFooterNoMoreData)
        {
            [_getFooterView setState:TableFooterLoading];
            [[EventDocument sharedInstance] fetchMyMeetings];
        }
    }
}

@end
