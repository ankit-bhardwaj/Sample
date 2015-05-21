//
//  CenterViewController.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "MyTaskVC.h"
#import "UIViewController+MMDrawerController.h"
#import "TaskFeedCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "CreateTaskVC.h"
#import "TaskDocument.h"
#import "Task.h"
#import "Comment.h"
#import "WYPopoverController.h"
#import "TaskSortCategoryVC.h"
#import "GetMoreTableFooter.h"
#import "CommentVC.h"
#import "TaskDetailVC.h"
#import "ShowAttachmentVC.h"
#import "ImageMapVC.h"

#import "CommentCell.h"
#import "StatusListVC.h"
#import "ManageTaskUserVC.h"
#import "CustomBadge.h"
#import "TaskFeedFooterView.h"
#import "FilterTaskOnOFFVC.h"
#import "ComposeCommentCell.h"
#import "SpeechToTextModule.h"
#import "MapVC.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MyTaskVC (){

    IBOutlet UIButton* sortCategoryBtn;
    IBOutlet UIButton* expandCollaspeBtn;
    IBOutlet UIButton* filterTaskDoneBtn;
    IBOutlet UILabel* titleLabel;
    UIImageView* _cruunLogo;
    NSMutableArray* feedsArray;
    WYPopoverController* sortCategoryPopover;
     WYPopoverController* filterTaskPopover;
    GetMoreTableFooter* _getFooterView;
    NSIndexPath* _selectedIndexPath;
    TaskStatus _changeTaskStatus;
    UIPopoverController* statusPopOver;
    CustomBadge* badgeView;
    NSMutableArray* _myAgendaTaskFeeds;
    NSMutableArray* _taskFeeds;
    BOOL tableReloading;
    
    NSInteger _lastSelectedTaskIndex;
    int currentConsiderTaskIndex;
    
    IBOutlet UITextField* taskName;
    IBOutlet UIButton* taskNameMic;
    NSIndexPath* _sourceReorderIndexPath;
    
    IBOutlet UIActivityIndicatorView* taskNameActivity;
}
@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;

@property (nonatomic, retain) NSMutableArray *columns;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) UIImageView *dragView;

- (void) configureTable:(UITableView *)theCol;

- (IBAction)showSortCategory:(id)sender;
- (IBAction)toggleCollaspeExpandAction:(id)sender;
- (IBAction)filterTaskDoneAction:(id)sender;
- (IBAction)taskSpeackAction:(id)sender;
- (IBAction)createTaskAction:(id)sender;

@end

@interface UIView (Adiciones)
- (UIImage *) screenshot;
@end

@implementation MyTaskVC


- (id)init
{
    self = [super init];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setRestorationIdentifier:@"MMExampleCenterControllerRestorationKey"];
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechToTextObj setDelegate:self];

    
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
    [tblView addSubview:refreshControl];
    [refreshControl beginRefreshing];
    
    [tblView registerNib:[UINib nibWithNibName:@"TaskFeedCell" bundle:nil]  forCellReuseIdentifier:@"TaskFeedCell"];
    
    taskName.background = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    [v setBackgroundColor:[UIColor clearColor]];
    taskName.leftView = v;
    taskName.leftViewMode = UITextFieldViewModeAlways;
    
    
    _getFooterView = [[GetMoreTableFooter alloc] initWithFrame:CGRectMake(0, 0, tblView.bounds.size.width, 40)];
    [_getFooterView setState:TableFooterNormal];
    [tblView setTableFooterView:_getFooterView];
    [[TaskDocument sharedInstance] setIsMyTasksCollaspe:YES];
    
    _taskFeeds = [[NSMutableArray alloc] init];
    _myAgendaTaskFeeds = [[NSMutableArray alloc] init];
    
    [_myAgendaTaskFeeds removeAllObjects];
    [_myAgendaTaskFeeds addObjectsFromArray:[TaskDocument sharedInstance].myAgendaFeed];
    [_taskFeeds removeAllObjects];
    [_taskFeeds addObjectsFromArray:[TaskDocument sharedInstance].myTaskFeed];
    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyTaskFeedCallBackCallBack:) name:@"MyTaskFeedNotifier" object:nil];
    [[TaskDocument sharedInstance] refreshMyTasks];
    [[TaskDocument sharedInstance] getTaskSortingCategories:@"MyTask"];
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationObserved:) name:@"RemoteNotificationArrived" object:nil];
    
    Portfolio* portfolio = [TaskDocument sharedInstance].selectedPortfolio;
    Project* project = [TaskDocument sharedInstance].selectedProject;
    NSString* title = @"";
    if(portfolio || project)
    {
        filterTaskDoneBtn.hidden = NO;
        title = [title stringByAppendingString:portfolio.PortfolioName];
        if(project)
            title = [title stringByAppendingFormat:@" > %@",project.ProjectName];
    }
    else
    {
        filterTaskDoneBtn.hidden = YES;
        title = @"My Tasks";
    }
    
    titleLabel.text = title;
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
    if([TaskDocument sharedInstance].myTaskFeedUpdateRequire)
        [[TaskDocument sharedInstance] refreshMyTasks];
    else if([TaskDocument sharedInstance].homeFeedTaskUpdateRequire)
    {
        [TaskDocument sharedInstance].homeFeedTaskUpdateRequire = NO;
        [tblView reloadData];
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
    UIRefreshControl* cnt = (UIRefreshControl*)[tblView viewWithTag:1001];
    [cnt endRefreshing];
    
    [TaskDocument sharedInstance].myTaskFeedUpdateRequire = NO;
    
    [_myAgendaTaskFeeds removeAllObjects];
    [_myAgendaTaskFeeds addObjectsFromArray:[TaskDocument sharedInstance].myAgendaFeed];
    [_taskFeeds removeAllObjects];
    [_taskFeeds addObjectsFromArray:[TaskDocument sharedInstance].myTaskFeed];
    
    if(tmp && [tmp isKindOfClass:[NSArray class]])
    {
        if(tmp.count > 0 && [TaskDocument sharedInstance].myTaskFeedIndex > 1)
        {
            if(!tableReloading)
            {
                tableReloading = YES;
                
                [tblView beginUpdates];
                [tblView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tblView numberOfSections])] withRowAnimation:UITableViewRowAnimationNone];
                [tblView endUpdates];
                tableReloading = NO;
            }
        }
        else
        {
            [tblView reloadData];
        }
    }
    if(![tmp isKindOfClass:[NSArray class]] || (_myAgendaTaskFeeds.count+_taskFeeds.count) == 0)
        [_getFooterView setState:TableFooterNoData];
    else if(!tmp || tmp.count ==0 || (_myAgendaTaskFeeds.count+_taskFeeds.count)<10)
        [_getFooterView setState:TableFooterNoMoreData];
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    [APPDELEGATE setNotificationCounter:0];
    [self refreshBadge];
}

- (void)refresh:(UIRefreshControl*)control
{
    [control beginRefreshing];
    [[TaskDocument sharedInstance] refreshMyTasks];
}



- (void)getMyTaskFeedCallBackCallBack:(NSNotification*)note
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
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:rightDrawerButton,notificationButton, nil] animated:YES];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)openTaskCreator:(id)sender
{
    CreateTaskVC* vc = [[CreateTaskVC alloc] initWithNibName:@"CreateTaskVC" bundle:nil];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)notificationTapped:(id)sender
{
    if(!badgeView.hidden)
        [[TaskDocument sharedInstance] refreshMyTasks];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}


- (IBAction)showSortCategory:(UIButton*)sender
{
    TaskSortCategoryVC* vc = [[TaskSortCategoryVC alloc] initWithNibName:@"TaskSortCategoryVC" bundle:nil];
    vc.target = self;vc.action = @selector(categorySelected:);
    CGRect rect = sender.frame;
    if([[[UIDevice currentDevice]systemVersion] floatValue]>= 7.0)
        rect.origin.y += 55;
    if(DEVICE_IS_TABLET)
    {
        sortCategoryPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [sortCategoryPopover setPopoverContentSize:CGSizeMake(280, 220)];
        sortCategoryPopover.delegate = self;
        [sortCategoryPopover presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        
        sortCategoryPopover = [[WYPopoverController alloc] initWithContentViewController:vc];
        [sortCategoryPopover setPopoverContentSize:CGSizeMake(280, 220)];
        [sortCategoryPopover setDelegate:self];
        [sortCategoryPopover presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    }
}

-(void)categorySelected:(TaskSortCategory*)category
{
    [[TaskDocument sharedInstance] setSortCategory:category];
    [[TaskDocument sharedInstance] refreshMyTasks];
    [sortCategoryPopover dismissPopoverAnimated:YES];
    sortCategoryPopover = nil;
    //[sortCategoryBtn setTitle:[NSString stringWithFormat:@"Show: %@", category.SortByDescription] forState:UIControlStateNormal];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)popoverController
{
    statusPopOver = nil;
    sortCategoryPopover = nil;
    filterTaskPopover = nil;
    return YES;
}

- (IBAction)toggleCollaspeExpandAction:(UIButton*)sender
{
    if(!tableReloading)
    {
        sender.selected = !sender.selected;
        NSArray* MyTaskFeeds = _taskFeeds;
        for (Task* task in MyTaskFeeds) {
            task.isCollapsed = sender.selected;
        }
        for (Task* task in _myAgendaTaskFeeds) {
            task.isCollapsed = sender.selected;
        }
        [[TaskDocument sharedInstance] setIsMyTasksCollaspe:sender.selected];
        
        tableReloading = YES;
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tblView numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
        [tblView endUpdates];
        tableReloading = NO;
        if(!sender.selected)
        {
            [self.view makeToast:@"Expanding all tasks"];
            
        }
        else
        {
            [self.view makeToast:@"Collapsing all tasks"];
            
        }
    }
}

- (IBAction)filterTaskDoneAction:(UIButton*)sender
{
    FilterTaskOnOFFVC* vc = [[FilterTaskOnOFFVC alloc] initWithNibName:@"FilterTaskOnOFFVC" bundle:nil];
    vc.target = self;
    vc.action = @selector(filterOnOFF:);
    vc.filterOn = sender.selected;
    CGRect rect = sender.frame;
    if([[[UIDevice currentDevice]systemVersion] floatValue]>= 7.0)
        rect.origin.y += 55;
    if(DEVICE_IS_TABLET)
    {
        filterTaskPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [filterTaskPopover setPopoverContentSize:CGSizeMake(280, 150)];
        filterTaskPopover.delegate = self;
        [filterTaskPopover presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        filterTaskPopover = [[WYPopoverController alloc] initWithContentViewController:vc];
        [filterTaskPopover setPopoverContentSize:CGSizeMake(280, 150)];
        [filterTaskPopover setDelegate:self];
        [filterTaskPopover presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:WYPopoverArrowDirectionUp animated:NO];
    }
}

-(void)filterOnOFF:(UISwitch*)filter{

    if (filter != nil) {
        filterTaskDoneBtn.selected = filter.on;
        [[TaskDocument sharedInstance] setClosedTask:filterTaskDoneBtn.selected];
        [[TaskDocument sharedInstance] refreshMyTasks];
    }
    
    [filterTaskPopover dismissPopoverAnimated:YES];
    filterTaskPopover = nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIRefreshControl* cnt = (UIRefreshControl*)[tblView viewWithTag:1001];
    if(cnt.refreshing)
        [cnt endRefreshing];
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float height = [UIScreen mainScreen].bounds.size.height;
    if(scrollView.contentOffset.y >= (scrollView.contentSize.height - height))
    {
        if([_getFooterView getState] != TableFooterNoMoreData)
        {
            [_getFooterView setState:TableFooterLoading];
            [[TaskDocument sharedInstance] getMyTaskFeed];
        }
    }
}


#pragma mark - UITableView Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32.0)];
    [v setBackgroundColor:[UIColor whiteColor]];
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 1,tableView.bounds.size.width-10, 30.0)];
    [lbl setTextColor:[UIColor colorWithRed:47.0/255.0 green:182.0/255.0 blue:232.0/255.0 alpha:1.0]];
    [lbl setFont:[UIFont boldSystemFontOfSize:15.0]];
    [lbl setBackgroundColor:[UIColor whiteColor]];
    if(section == 0)
        [lbl setText:@"TODAY'S AGENDA"];
    else
        [lbl setText:@"TASKS TO CONSIDER"];
    [v addSubview:lbl];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return [_myAgendaTaskFeeds count];
    else
        return [_taskFeeds count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_myAgendaTaskFeeds count] || [_taskFeeds count])
        return 2;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *item = nil;
    if(indexPath.section == 0)
    {
        item = [_myAgendaTaskFeeds objectAtIndex:indexPath.row];
    }
    else
    {
        item = [_taskFeeds objectAtIndex:indexPath.row];
    }
    if([item isKindOfClass:[Task class]])
    {
        if(item.isCollapsed)
            return 40.0;
        else
            return 84.0;
    }
    else
    {
        return 40.0;
    }
    return 40.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *item = nil;
    if(indexPath.section == 0)
    {
        item = [_myAgendaTaskFeeds objectAtIndex:indexPath.row];
    }
    else
    {
        item = [_taskFeeds objectAtIndex:indexPath.row];
    }
    if([item isKindOfClass:[Task class]])
    {
        static NSString *CellIdentifier = @"TaskFeedCell";
        TaskFeedCell *cell = (TaskFeedCell*)[tblView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if(cell == nil)
        {
            cell = [[TaskFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell.collapseExpandButton addTarget:self action:@selector(collapseExpandAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.collapseExpandButton.tag = indexPath.section;
        objc_setAssociatedObject(cell.collapseExpandButton, "TaskFeedCell", cell, OBJC_ASSOCIATION_ASSIGN);
        
        [cell.detailDisclosure addTarget:self action:@selector(showTaskDetail:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(cell.detailDisclosure, "TaskFeedItem",item, OBJC_ASSOCIATION_ASSIGN);
        
        [cell.taskStatus addTarget:self action:@selector(changeTaskStatus:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(cell.taskStatus, "TaskFeedCell", indexPath, OBJC_ASSOCIATION_ASSIGN);
        [cell fillDataWithTask:item];
        
        UISwipeGestureRecognizer * pan = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
        [pan setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:pan];
        
        [cell.taskStatus setImage:[item getTaskStatusImage] forState:UIControlStateNormal];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        
        [cell.locationBtn addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
        cell.locationBtn.tag = indexPath.section;
        
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
        [v setBackgroundColor:[UIColor
                               colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f]];
        [cell setSelectedBackgroundView:v];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        return cell;
    }
    else if ([item isKindOfClass:[NSString class]])
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MyTaskCell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyTaskCell"];
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.font = [UIFont systemFontOfSize:14.0];
            cell.imageView.image = nil;
            cell.textLabel.textColor = [UIColor blackColor];
        }
        cell.textLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

{
    return proposedDestinationIndexPath;
}

-(void)showTaskDetail:(UIButton*)sender
{
    Task* task = objc_getAssociatedObject(sender, "TaskFeedItem");
    TaskDetailVC* taskDetailvc = [[TaskDetailVC alloc] initWithNibName:@"TaskDetailVC" bundle:nil];
    taskDetailvc.task = task;
    taskDetailvc.target = self;
    [self.navigationController pushViewController:taskDetailvc animated:YES];
}
-(void)showMap:(UIButton*)sender
{
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:sender.tag];
    MapVC* vc = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
    vc.location = task.location;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)collapseExpandAction:(UIButton*)sender
{
    if(!tableReloading)
    {
        TaskFeedCell * cell = objc_getAssociatedObject(sender, "TaskFeedCell");
        [cell setSelected:YES animated:YES];
        Task* task = cell.task;
        task.isCollapsed = !task.isCollapsed;
        
        
        tableReloading = YES;
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
        [tblView endUpdates];
        tableReloading = NO;
    }
}

-(void)changeTaskStatus:(UIButton*)sender
{
    _selectedIndexPath = objc_getAssociatedObject(sender, "TaskFeedCell");
    Task* task = nil;
    if(_selectedIndexPath.section == 0)
        task = [_myAgendaTaskFeeds objectAtIndex:_selectedIndexPath.row];
    else
        task = [_taskFeeds objectAtIndex:_selectedIndexPath.row];
    [self changeTaskStatusForTask:task withSender:sender];
}

- (void)changeTaskStatusCompleteForTask:(Task*)task withSender:(UIView*)sender
{
    if(task.CanEditAssignee || task.CanEdit)
    {
        if(task.taskStatus == TaskStatusCompleted)
        {
            NSString* completeByName = ([task.CompletedById intValue]==[User currentUser].UserId)?@"me":task.CompletedByName;
            [self.view makeToast:[NSString stringWithFormat:@"Completed by %@ on %@.",completeByName,task.CompletedOnString]];
            
            return;
        }
        else
        {
            _changeTaskStatus = TaskStatusCompleted;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusGotItCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
            
            [[TaskDocument sharedInstance] setTaskStatusComplete:task.taskId];
            return;
        }
    }
    [self.view makeToast:@"You can't change status of this task."];
    
}

- (void)changeTaskStatusForTask:(Task*)task withSender:(UIView*)sender
{
    User* user= [User currentUser];
    if(task.CanEditAssignee || task.CanEdit)
    {
        if(task.taskStatus == TaskStatusCompleted)
        {
            NSString* completeByName = ([task.CompletedById intValue]==[User currentUser].UserId)?@"me":task.CompletedByName;
            [self.view makeToast:[NSString stringWithFormat:@"Completed by %@ on %@.",completeByName,task.CompletedOnString]];
            
            return;
        }
        else if(task.CanEditAssignee && task.taskStatus == TaskStatusNew && (task.assignee.UserId == user.UserId))
        {
            _changeTaskStatus = TaskStatusAccept;
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusGotItCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
            
            [[TaskDocument sharedInstance] setTaskStatusAccepted:task.taskId];
            return;
        }
        else
        {
            StatusListVC* vc = [[StatusListVC alloc] initWithNibName:@"StatusListVC" bundle:nil];
            vc.target = self;
            vc.action = @selector(statusSelected:);
            vc.task = task;
            vc.selectedStatus = task.StatusTypeDescription;
            UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            if(DEVICE_IS_TABLET)
            {
                statusPopOver = [[UIPopoverController alloc] initWithContentViewController:navVC];
                vc.popOver = statusPopOver;
                [statusPopOver setPopoverContentSize:CGSizeMake(320, 320)];
                statusPopOver.delegate = self;
                [statusPopOver presentPopoverFromRect:sender.superview.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            else
            {
                statusPopOver = [[WYPopoverController alloc] initWithContentViewController:navVC];
                vc.popOver = statusPopOver;
                [statusPopOver setPopoverContentSize:CGSizeMake(280, 320)];
                [statusPopOver setDelegate:self];
                [statusPopOver presentPopoverFromRect:sender.superview.frame inView:sender.superview permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
            }
            
            return;
        }
    }
    
    [self.view makeToast:@"You can't change status of this task."];
    
}


- (void)statusSelected:(StatusListVC*)vc
{
    _changeTaskStatus =  [Task getTaskStatus:vc.selectedStatus];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusGotItCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
    
    [[TaskDocument sharedInstance] setStatus:vc.selectedStatus taskID:vc.task.taskId];
}

- (void)taskStatusGotItCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(taskStatusChange:) withObject:[note object] waitUntilDone:NO];
}

-(void)panGestureCallback:(UIPanGestureRecognizer*)ges
{
    TaskFeedCell* cell = (TaskFeedCell*)[ges view];
    [cell removeGestureRecognizer:ges];
    [UIView animateWithDuration:1.0 animations:^{
            CGRect rect = cell.contentView.frame;
            rect.origin.x += rect.size.width;
            [cell.contentView setFrame:rect];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(cellAnimationComplete:) withObject:cell afterDelay:0.3];
        
    }];
}

- (void)cellAnimationComplete:(TaskFeedCell*)cell
{
    [UIView animateWithDuration:1.0 animations:^{
            CGRect rect = cell.contentView.frame;
            rect.origin.x = 0;
            [cell.contentView setFrame:rect];
    } completion:^(BOOL finished)
     {
         _selectedIndexPath = [tblView indexPathForCell:cell];
         cell.taskStatus.selected = YES;
         if(_selectedIndexPath.section == 0)
         {
             Task* task = [_myAgendaTaskFeeds objectAtIndex:_selectedIndexPath.row];
             [self changeTaskStatusCompleteForTask:task withSender:cell];
         }
         else
         {
             Task* task = [_taskFeeds objectAtIndex:_selectedIndexPath.row];
             [self changeTaskStatusCompleteForTask:task withSender:cell];
         }
     }];
}

- (void)taskStatusChangeCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(taskStatusChange:) withObject:[note object] waitUntilDone:NO];
}

- (void)taskStatusChange:(NSNumber*)num
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    if(num && [num isKindOfClass:[NSNumber class]])
    {
        Task* task = nil;
        if(_selectedIndexPath.section == 0)
        {
            task = [_myAgendaTaskFeeds objectAtIndex:_selectedIndexPath.row];
        }
        else
        {
            task = [_taskFeeds objectAtIndex:_selectedIndexPath.row];
        }
        task.taskStatus = _changeTaskStatus;
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndex:_selectedIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [tblView endUpdates];
        
        if(_changeTaskStatus == TaskStatusAccept)
        {
            [self.view makeToast:@"Changed the status to 'Accepted'"];
            
        }
        else
        {
            [self.view makeToast:@"Status changed"];
            
        }
        //[[TaskDocument sharedInstance] refreshMyTasks];
    }
    else
    {
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndex:_selectedIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [tblView endUpdates];
        [self.view makeToast:@"Error in status change"];
        
        
    }
    
}

// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath
{
    _sourceReorderIndexPath = indexPath;
    id object = nil;
    if(indexPath.section == 0)
    {
        object = [_myAgendaTaskFeeds objectAtIndex:indexPath.row];
        [_myAgendaTaskFeeds replaceObjectAtIndex:indexPath.row withObject:@"DUMMY"];
    }
    else
    {
        object = [_taskFeeds objectAtIndex:indexPath.row];
        [_taskFeeds replaceObjectAtIndex:indexPath.row withObject:@"DUMMY"];
    }
    
    return object;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    id object = nil;
    if(fromIndexPath.section == 0)
    {
        object = [_myAgendaTaskFeeds objectAtIndex:fromIndexPath.row];
        [_myAgendaTaskFeeds removeObjectAtIndex:fromIndexPath.row];
    }
    else
    {
        object = [_taskFeeds objectAtIndex:fromIndexPath.row];
        [_taskFeeds removeObjectAtIndex:fromIndexPath.row];
    }
    
    if(toIndexPath.section == 0)
    {
        [_myAgendaTaskFeeds insertObject:object atIndex:toIndexPath.row];
    }
    else
    {
        [_taskFeeds insertObject:object atIndex:toIndexPath.row];
    }
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    
    
    if(indexPath.section == 0)
    {
        [_myAgendaTaskFeeds replaceObjectAtIndex:indexPath.row withObject:object];
    }
    else
    {
        [_taskFeeds replaceObjectAtIndex:indexPath.row withObject:object];
    }
    Task* item = (Task*)object;
    if(_sourceReorderIndexPath.section != indexPath.section)
    {
        if(indexPath.section == 0)
        {
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMyAgendaTaskNotifier:) name:@"MyAgendaTaskNotifier" object:nil];
            NSMutableArray* tmp = [NSMutableArray array];
            for(int i =0;i<[_myAgendaTaskFeeds count];i++)
            {
                Task* t = [_myAgendaTaskFeeds objectAtIndex:i];
                [tmp addObject:[[t taskId] stringValue]];
            }
            [[TaskDocument sharedInstance] setMyAgenda:NO forTask:item.taskId withOrder:[tmp componentsJoinedByString:@";"]];
        }
        else
        {
            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMyAgendaTaskNotifier:) name:@"MyAgendaTaskNotifier" object:nil];
            [[TaskDocument sharedInstance] setMyAgenda:YES forTask:item.taskId withOrder:@""];
        }
        //[tableView reloadData];
    }
    else
    {
        if([_sourceReorderIndexPath isEqual:indexPath])
            return;
        if(_sourceReorderIndexPath.section == 0 && indexPath.section == 0)
        {

            //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMyAgendaTaskNotifier:) name:@"MyAgendaTaskNotifier" object:nil];
            NSMutableArray* tmp = [NSMutableArray array];
            for(int i =0;i<[_myAgendaTaskFeeds count];i++)
            {
                Task* t = [_myAgendaTaskFeeds objectAtIndex:i];
                [tmp addObject:[[t taskId] stringValue]];
            }
            [[TaskDocument sharedInstance] setMyAgenda:NO forTask:item.taskId withOrder:[tmp componentsJoinedByString:@";"]];
        }
    }
    // do any additional cleanup here
}



- (IBAction)taskSpeackAction:(id)sender
{
    if(taskNameMic.selected)
    {
        [self createTaskAction:nil];
    }
    else
    {
        taskNameMic.enabled = NO;
        objc_setAssociatedObject(self.speechToTextObj, "textField", taskName, OBJC_ASSOCIATION_RETAIN);
        [self.speechToTextObj beginRecording];
    }
}


#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    taskNameMic.hidden = NO;
    taskNameMic.selected = NO;
    [taskNameActivity stopAnimating];
    [taskName resignFirstResponder];
    [taskName setInputView:nil];
    [taskName becomeFirstResponder];
    
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* str = [[response componentsSeparatedByString:@"\n"] lastObject];    
    
    if(NSSTRING_HAS_DATA(str))
    {
        NSData* streamData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:streamData options:NSJSONReadingMutableContainers error:NULL];
        
        NSArray* result = [dict objectForKey:@"result"];
        if(result && result.count)
        {
            NSDictionary* d = [result firstObject];
            NSArray* alternatives = [d objectForKey:@"alternative"];
            if(alternatives && alternatives.count)
            {
                NSDictionary* alternative = [alternatives firstObject];
                NSString* text = [alternative objectForKey:@"transcript"];
                if(NSSTRING_HAS_DATA(text))
                {
                    taskName.text = [taskName.text stringByAppendingString:text];
                    
                }
            }
        }
    }

    objc_removeAssociatedObjects(self.speechToTextObj);
    return YES;
}
- (void)showSineWaveView:(SineWaveViewController *)view
{
    [taskName resignFirstResponder];
    [taskName setInputView:view.view];
    [taskName becomeFirstResponder];
}

- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    [taskName resignFirstResponder];
    [taskName setInputView:nil];
    taskNameMic.hidden = NO;
    taskNameMic.selected = NO;
}


- (void)showLoadingView
{
    taskNameMic.selected = NO;
    taskNameMic.hidden = YES;
    taskNameActivity.hidden = NO;
    [taskNameActivity startAnimating];
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}


- (IBAction)createTaskAction:(id)sender
{
    [taskName resignFirstResponder];
    
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(name))
    {
        msg = @"Please give your task a title.";
    }
    
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self createTask];
    }
}

- (void)createTask
{
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    User* user = [User currentUser];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:@"taskDescription"];
    [dict setObject:@"" forKey:@"taskDetails"];
    [dict setObject:user.Email forKey:@"assignedToEmail"];
    [dict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"logInUserId"];
    [dict setObject:[TaskDocument sharedInstance].myProjectId forKey:@"projectId"];
    [dict setObject:@"" forKey:@"dueDate"];
    [dict setObject:@"Normal" forKey:@"priority"];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"])
    {
        if(![LocationService isValidLocation])
        {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enable location services in iphone location settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else
        {
            [dict setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.longitude] forKey:@"longitude"];
            [dict setObject:[LocationService addressString] forKey:@"locationAddress"];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createTaskCallBack:) name:@"CreateTaskNotifier" object:nil];
    [[TaskDocument sharedInstance] createTask:dict];
}

- (void)createTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(createTaskSuccess:) withObject:[note object] waitUntilDone:NO];
    
}



-(void)createTaskSuccess:(id)sender
{
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[Task class]])
    {
        taskName.text = nil;
        taskNameMic.selected = NO;
        [[TaskDocument sharedInstance] refreshMyTasks];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setMyAgendaTaskNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(setMyAgendaCallBack:) withObject:[note object] waitUntilDone:NO];
}

- (void)setMyAgendaCallBack:(id)item
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


- (NSString *)stringFromDate:(NSDate *)DateLocal{
    
    NSDateFormatter *prefixDateFormatter = [[NSDateFormatter alloc] init];
    [prefixDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [prefixDateFormatter setDateFormat:@"EEE d. MMM @ hh:mm"];//June 13th, 2013
    NSString * prefixDateString = [prefixDateFormatter stringFromDate:DateLocal];
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    int date_day = [[monthDayFormatter stringFromDate:DateLocal] intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix = [suffixes objectAtIndex:date_day];
    
    prefixDateString = [prefixDateString stringByReplacingOccurrencesOfString:@"." withString:suffix];
    NSString *dateString =prefixDateString;
    //  NSLog(@"%@", dateString);
    return dateString;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (filterTaskPopover != nil) {
        [filterTaskPopover dismissPopoverAnimated:NO];
    }
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    if(filterTaskPopover != nil){
        filterTaskPopover = nil;
        [self filterTaskDoneAction:filterTaskDoneBtn];
    
    }
    
    if(!tableReloading && [tblView numberOfSections])
    {
        tableReloading = YES;
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, ([tblView numberOfSections]-1))] withRowAnimation:UITableViewRowAnimationNone];
        [tblView endUpdates];
        tableReloading = NO;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openTaskMenu:(UILongPressGestureRecognizer*)ges
{
    if(ges.state == UIGestureRecognizerStateBegan)
    {
        TaskFeedCell* cell = objc_getAssociatedObject(ges, "TaskFeedCell");
        _selectedIndexPath = [tblView indexPathForCell:cell];
        UIActionSheet* actionSheet= nil;
        if(cell.task.HasNudge)
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Nudge assignee",@"Delete this task",[cell.task.FollowTaskFlag boolValue]?@"Un-follow this task":@"Follow this task",@"Share this task",@"Edit this task",nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete this task",[cell.task.FollowTaskFlag boolValue]?@"Un-follow this task":@"Follow this task",@"Share this task",@"Edit this task",nil];
        }
        
    
        if(DEVICE_IS_TABLET)
        {
            CGRect rect = cell.collapseExpandButton.frame;
            [actionSheet showFromRect:rect inView:cell.collapseExpandButton animated:YES];
        }
        else
            [actionSheet showInView:self.view];
        
        objc_setAssociatedObject(actionSheet, "TaskFeedCellAction", cell, OBJC_ASSOCIATION_RETAIN);
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
    TaskFeedCell* cell = objc_getAssociatedObject(actionSheet, "TaskFeedCellAction");
    objc_removeAssociatedObjects(actionSheet);
    
    if(buttonIndex < 0)
        return;
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if([btnTitle isEqualToString:@"Nudge assignee"])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommentCallBack:) name:@"PostCommentNotifier" object:nil];
        [[TaskDocument sharedInstance] saveCommentNudgeForTaskId:cell.task.taskId];
    }
    else if([btnTitle isEqualToString:@"Delete this task"])
    {
        if(cell.task.CanEdit)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTaskCallBack:) name:@"DeleteTaskNotifier" object:nil];
            [[TaskDocument sharedInstance] deleteTask:cell.task.taskId];
        }
        else
        {
            [self.view makeToast:@"You can't delete this task."];
            
        }
    }
    else if([btnTitle isEqualToString:@"Un-follow this task"])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeFollowTaskCallBack:) name:@"ChangeFollowTaskNotifier" object:nil];
        [[TaskDocument sharedInstance] ChangeFollowTask:cell.task.taskId follow:[NSString stringWithFormat:@"%d",![cell.task.FollowTaskFlag boolValue]]];
    }
    else if([btnTitle isEqualToString:@"Follow this task"])
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeFollowTaskCallBack:) name:@"ChangeFollowTaskNotifier" object:nil];
        [[TaskDocument sharedInstance] ChangeFollowTask:cell.task.taskId follow:[NSString stringWithFormat:@"%d",![cell.task.FollowTaskFlag boolValue]]];
    }
    else if([btnTitle isEqualToString:@"Share this task"])
    {
        ManageTaskUserVC* vc = [[ManageTaskUserVC alloc] initWithNibName:@"ManageTaskUserVC" bundle:nil];
        vc.task = cell.task;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        navVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navVC animated:YES completion:^{
            navVC.navigationItem.title = @"Manage Task Users";
        }];
    }
    else if([btnTitle isEqualToString:@"Edit this task"])
    {
        Task* task = cell.task;
        TaskDetailVC* taskDetailvc = [[TaskDetailVC alloc] initWithNibName:@"TaskDetailVC" bundle:nil];
        taskDetailvc.task = task;
        taskDetailvc.target = self;
        [self.navigationController pushViewController:taskDetailvc animated:YES];
    }
    
}

- (void)postCommentCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(postComment:) withObject:[note object] waitUntilDone:NO];
}

- (void)postComment:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if([sender isKindOfClass:[Comment class]])
        [[TaskDocument sharedInstance] refreshMyTasks];
}


-(void)ChangeFollowTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(changeFollowTaskSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)changeFollowTaskSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]])
    {
        Task* task = nil;
        if(_selectedIndexPath.section == 0)
            task = [_myAgendaTaskFeeds objectAtIndex:[_selectedIndexPath row]];
        else
            task = [_taskFeeds objectAtIndex:[_selectedIndexPath row]];
        task.FollowTaskFlag = [NSNumber numberWithBool:![task.FollowTaskFlag boolValue]];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
}
- (void)deleteTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(deleteTaskSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)deleteTaskSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]])
    {
        [_taskFeeds removeObjectAtIndex:[_selectedIndexPath section]];
        [tblView beginUpdates];
        [tblView deleteSections:[NSIndexSet indexSetWithIndex:[_selectedIndexPath section]] withRowAnimation:UITableViewRowAnimationRight];
        [tblView endUpdates];
    }
    else
    {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    taskNameMic.enabled = YES;
    taskNameMic.selected = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    taskNameMic.selected = NO;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger namelen = [string length] > 0?([textField.text length]+[string length]):([textField.text length]-1);
    if([string length] > 0 && namelen > 100)
    {
        textField.text = [textField.text stringByAppendingString:[string substringToIndex:(100-[textField.text length])]];
        return NO;
    }
    return YES;
}

@end

@implementation UIView (Adiciones)

- (UIImage *) screenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = self.bounds.size;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self.layer renderInContext:context];
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    return image;
}

@end
