//
//  CenterViewController.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "HomeVC.h"
#import "UIViewController+MMDrawerController.h"
#import "HomeFeedCell.h"
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
#import "PostCommentVC.h"
#import "CreateEventVC.h"
#import "EventVC.h"
#import "EditTaskVC.h"
#import "LocationService.h"
#import "MapVC.h"
#import "CreatePortfolioVC.h"
#import "ManagePortfolioUserVC.h"
#import "PortfolioUserVC.h"
#import "TaskFilterVC.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HomeVC (){

    IBOutlet UIButton* sortCategoryBtn;
    IBOutlet UIButton* expandCollaspeBtn;
    IBOutlet UIButton* filterTaskDoneBtn;
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* sortTypeLbl;
    
    IBOutlet UIView* portfolioOptionsView;
    IBOutlet UIView* projectOptionsView;
    IBOutlet UIView* portfolioOptionsContentView;
    IBOutlet UIView* projectOptionsContentView;
    IBOutlet UIButton* createProjectBtn;
    IBOutlet UIButton* managePortfolioUserBtn;
    IBOutlet UIButton* createTaskBtn;
    IBOutlet UIButton* manageProjectUserBtn;
    
    IBOutlet UIButton* floatingView;
    
    UIImageView* _cruunLogo;
    NSMutableArray* feedsArray;
    WYPopoverController* sortCategoryPopover;
     WYPopoverController* filterTaskPopover;
    GetMoreTableFooter* _getFooterView;
    NSIndexPath* _selectedIndexPath;
    TaskStatus _changeTaskStatus;
    UIPopoverController* statusPopOver;
    CustomBadge* badgeView;
    NSMutableArray* _taskFeeds;
    BOOL tableReloading;
    
    NSInteger _lastSelectedTaskIndex;
    NSIndexPath* _currentCommentEditingIndex;
    NSString* _currentCommentEditingText;
    
    ComposeCommentCell* _currentComposeCommentCell;
    IBOutlet UITextView* hiddenTextView;
    
    UIActionSheet* projectMenuSheet;
    
    CGPoint startLocation;
    
    WYPopoverController* taskFilterPopover;

}
@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)showSortCategory:(id)sender;
- (IBAction)toggleCollaspeExpandAction:(id)sender;
- (IBAction)filterTaskDoneAction:(id)sender;
- (IBAction)createProjectAction:(id)sender;
- (IBAction)managePortfolioUserAction:(id)sender;
- (IBAction)createTaskAction:(id)sender;
- (IBAction)manageProjectUserAction:(id)sender;
@end

@implementation HomeVC


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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HomeFeedNotifier" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemoteNotificationArrived" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetProjectNotifier" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetPortfolioNotifier" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:portfolioOptionsView];
    [self.view addSubview:projectOptionsView];
    projectOptionsView.hidden = YES;
    portfolioOptionsView.hidden = YES;
    
    portfolioOptionsContentView.layer.cornerRadius = 5.0;
    portfolioOptionsContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    portfolioOptionsContentView.layer.borderWidth = 1.0;
    
    projectOptionsContentView.layer.cornerRadius = 5.0;
    projectOptionsContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    projectOptionsContentView.layer.borderWidth = 1.0;
    
    if(IS_IPAD)[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    if(!self.speechToTextObj)
    {
        self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
        [self.speechToTextObj setDelegate:self];
    }
    
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
    
    
    [tblView registerNib:[UINib nibWithNibName:@"HomeFeedCell" bundle:nil]  forCellReuseIdentifier:@"HomeFeedCell"];
    
    [tblView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil]  forCellReuseIdentifier:@"CommentCell"];
    
    
    [tblView registerNib:[UINib nibWithNibName:@"ComposeCommentCell" bundle:nil]  forCellReuseIdentifier:@"ComposeCommentCell"];
    
    
    [tblView registerClass:[TaskFeedFooterView class] forHeaderFooterViewReuseIdentifier:@"TaskFeedFooterView"];
    
    
    
    _getFooterView = [[GetMoreTableFooter alloc] initWithFrame:CGRectMake(0, 0, tblView.bounds.size.width, 100)];
    [_getFooterView setState:TableFooterNormal];
    [tblView setTableFooterView:_getFooterView];
    [[TaskDocument sharedInstance] setIsHomeFeedCollaspe:YES];
    
    _taskFeeds = [[NSMutableArray alloc] init];
    //[_taskFeeds addObjectsFromArray:[TaskDocument sharedInstance].homeFeeds];
    [TaskDocument sharedInstance].editingComment = 0;
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeFeedCallBackCallBack:) name:@"HomeFeedNotifier" object:nil];
    if(![TaskDocument sharedInstance].hasJustCreatedPortfolio)
    {
        [[TaskDocument sharedInstance] refreshHomeFeed];
        [refreshControl beginRefreshing];
    }
    else
    {
        [[TaskDocument sharedInstance] setHasJustCreatedPortfolio:NO];
        [_getFooterView setState:TableFooterNoData];
    }
    [[TaskDocument sharedInstance] getTaskSortingCategories:@"Home"];
       
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationObserved:) name:@"RemoteNotificationArrived" object:nil];
    
    Portfolio* portfolio = [TaskDocument sharedInstance].selectedPortfolio;
    Project* project = [TaskDocument sharedInstance].selectedProject;
    NSString* title = @"";
    if(portfolio || project)
    {
        filterTaskDoneBtn.hidden = NO;
        if(portfolio.PortfolioName)
            title = [title stringByAppendingString:portfolio.PortfolioName];
        if(project.ProjectName)
            title = [title stringByAppendingFormat:@" > %@",project.ProjectName];
    }
    else
    {
        filterTaskDoneBtn.hidden = YES;
        title = @"Home";
    }
    
    titleLabel.text = title;
    
    sortTypeLbl.text = [NSString stringWithFormat:@"Tasklist by %@",[TaskDocument sharedInstance].sortCategory.SortByDescription];
    
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
    _currentCommentEditingIndex = nil;
    _currentCommentEditingText = nil;
    
    _cruunLogo.hidden = NO;
    if([TaskDocument sharedInstance].homeFeedUpdateRequire)
    {
        projectOptionsView.hidden = YES;
        portfolioOptionsView.hidden = YES;
        [[TaskDocument sharedInstance] refreshHomeFeed];
    }
    else if([TaskDocument sharedInstance].homeFeedTaskUpdateRequire)
    {
        [TaskDocument sharedInstance].homeFeedTaskUpdateRequire = NO;
        [_taskFeeds removeAllObjects];
        [_taskFeeds addObjectsFromArray:[TaskDocument sharedInstance].homeFeeds];
        [tblView reloadData];
        if([TaskDocument sharedInstance].homeFeeds.count)
        {
            [tblView setTableFooterView:_getFooterView];
            [_getFooterView setState:TableFooterNormal];
            projectOptionsView.hidden = YES;
            portfolioOptionsView.hidden = YES;
        }
        else
        {
            //projectOptionsView.hidden = NO;
            //portfolioOptionsView.hidden = NO;
        }
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
    if([TaskDocument sharedInstance].editingComment > 0)
        return;
    
    projectOptionsView.hidden = YES;
    portfolioOptionsView.hidden = YES;
    
    [_taskFeeds removeAllObjects];
    [_taskFeeds addObjectsFromArray:[TaskDocument sharedInstance].homeFeeds];
    if(tmp && [tmp isKindOfClass:[NSArray class]] && tmp.count > 0)
    {
        if([TaskDocument sharedInstance].homeFeedIndex > 1)
        {
            if(!tableReloading)
            {
                tableReloading = YES;
                
                [tblView beginUpdates];
                [tblView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tblView numberOfSections])] withRowAnimation:UITableViewRowAnimationNone];
                [tblView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([tblView numberOfSections], [tmp count])] withRowAnimation:UITableViewRowAnimationNone];
                [tblView endUpdates];
                tableReloading = NO;
            }
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:CREATE_HOME_COMMENT_ATTACHMENTS error:nil];
            [tblView reloadData];
        }
    }
    if(!_taskFeeds.count || ![tmp isKindOfClass:[NSArray class]])
    {
        [_getFooterView setState:TableFooterNoData];

        if([TaskDocument sharedInstance].selectedProject)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProjectCallBack:) name:@"GetProjectNotifier" object:nil];
            [[TaskDocument sharedInstance] getProject:[TaskDocument sharedInstance].selectedProject];
        }
        else if([TaskDocument sharedInstance].selectedPortfolio && ![[TaskDocument sharedInstance].selectedPortfolio hasProject])
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPortfolioCallBack:) name:@"GetPortfolioNotifier" object:nil];
            [[TaskDocument sharedInstance] getPortfolio:[TaskDocument sharedInstance].selectedPortfolio];
        }
    }
    else if(!tmp || tmp.count ==0)
        [_getFooterView setState:TableFooterNoMoreData];
    
    //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    [APPDELEGATE setNotificationCounter:0];
    [self refreshBadge];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches]anyObject];
    if([touch view] == floatingView)
    {
        CGPoint pt = [[touches anyObject] locationInView:floatingView];
        startLocation = pt;
    }
}
- (void) touchesMoved:(NSSet *)touches withEvent: (UIEvent *)event
{
    UITouch *touch = [[event allTouches]anyObject];
    if([touch view] == floatingView)
    {
        
        CGPoint pt = [[touches anyObject] previousLocationInView:floatingView];
        CGFloat dx = pt.x - startLocation.x;
        CGFloat dy = pt.y - startLocation.y;
        CGPoint newCenter = CGPointMake(floatingView.center.x + dx, floatingView.center.y + dy);
        float hight;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
            hight= (self.view.frame.size.height-75);
        else
            hight=(self.view.frame.size.height-55);
        
        if (newCenter.x<=25 || newCenter.y<=25 || newCenter.x>=(self.view.frame.size.width-30) || newCenter.y>=hight) {
            return;
        }
        
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation])) {
            [[NSUserDefaults standardUserDefaults] setObject:NSStringFromCGPoint(newCenter) forKey:@"pointPositionLandscape"];
        }
        else if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice]orientation])){
            [[NSUserDefaults standardUserDefaults] setObject:NSStringFromCGPoint(newCenter) forKey:@"pointPositionPortrait"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        floatingView.center = newCenter;
    }
}

- (void)getPortfolioCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openPortfolioMenu:) withObject:[note object] waitUntilDone:NO];
}

- (void)openPortfolioMenu:(id)note
{
    Portfolio* portfolio = note;
    if(portfolio && [portfolio isKindOfClass:[Portfolio class]])
    {
        [TaskDocument sharedInstance].selectedPortfolio = portfolio;
        
        if([TaskDocument sharedInstance].selectedPortfolio.PortfolioId == -1 || [TaskDocument sharedInstance].selectedPortfolio.CurrentUserCanAddProject || [TaskDocument sharedInstance].selectedPortfolio.CurrentUserCanAddOtherUsers)
        {
            createProjectBtn.hidden = YES;
            managePortfolioUserBtn.hidden = YES;
            [tblView setTableFooterView:nil];
            portfolioOptionsView.hidden = NO;
            if([TaskDocument sharedInstance].selectedPortfolio.CurrentUserCanAddProject)
            {
                createProjectBtn.hidden = NO;
            }
            if([TaskDocument sharedInstance].selectedPortfolio.CurrentUserCanAddOtherUsers)
            {
                managePortfolioUserBtn.hidden = NO;
            }
        }
    }
}

- (void)getProjectCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openProjectMenu:) withObject:[note object] waitUntilDone:NO];
}

- (void)openProjectMenu:(id)note
{
    Project* project = note;
    if(project && [project isKindOfClass:[Project class]])
    {
        [TaskDocument sharedInstance].selectedProject = project;
        manageProjectUserBtn.hidden = YES;
        [_getFooterView setState:TableFooterNormal];
        projectOptionsView.hidden = NO;
        if([TaskDocument sharedInstance].selectedProject.CurrentUserCanAddOtherUsers)
        {
            manageProjectUserBtn.hidden = NO;
        }
    }
}

- (void)refresh:(UIRefreshControl*)control
{
    [TaskDocument sharedInstance].editingComment = 0;
    [control beginRefreshing];
    [[TaskDocument sharedInstance] refreshHomeFeed];
}



- (void)getHomeFeedCallBackCallBack:(NSNotification*)note
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
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(openSearch:)];
    
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

- (void)openSearch:(UIBarButtonItem*)item
{
    TaskFilterVC* vc = [[TaskFilterVC alloc] initWithNibName:@"TaskFilterVC" bundle:nil];
    //vc.target = self;vc.action = @selector(categorySelected:);
    if(DEVICE_IS_TABLET)
    {
        taskFilterPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [taskFilterPopover setPopoverContentSize:CGSizeMake(400, 100)];
        taskFilterPopover.delegate = self;
        [taskFilterPopover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        
        taskFilterPopover = [[WYPopoverController alloc] initWithContentViewController:vc];
        [taskFilterPopover setPopoverContentSize:CGSizeMake(self.view.bounds.size.width-20, 100)];
        [taskFilterPopover setDelegate:self];
        [taskFilterPopover presentPopoverFromRect:CGRectZero inView:self.navigationController.view permittedArrowDirections:WYPopoverArrowDirectionNone animated:YES];
    }
    vc.popOver = taskFilterPopover;
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
        [[TaskDocument sharedInstance] refreshHomeFeed];
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
    [[TaskDocument sharedInstance] refreshHomeFeed];
    [sortCategoryPopover dismissPopoverAnimated:YES];
    sortCategoryPopover = nil;
    sortTypeLbl.text = [NSString stringWithFormat:@"Tasklist by %@",[TaskDocument sharedInstance].sortCategory.SortByDescription];
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
        NSArray* homeFeeds = _taskFeeds;
        for (Task* task in homeFeeds) {
            task.isCollapsed = sender.selected;
        }
        [[TaskDocument sharedInstance] setIsHomeFeedCollaspe:sender.selected];
        
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
        [[TaskDocument sharedInstance] refreshHomeFeed];
    }
    
    [filterTaskPopover dismissPopoverAnimated:YES];
    filterTaskPopover = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float height = [UIScreen mainScreen].bounds.size.height;
    if(scrollView.contentOffset.y >= (scrollView.contentSize.height - height))
    {
        if([_getFooterView getState] != TableFooterNoMoreData && [TaskDocument sharedInstance].editingComment == 0)
        {
            [_getFooterView setState:TableFooterLoading];
            [[TaskDocument sharedInstance] getHomeFeed];
        }
    }
}

-(void)showFullComment:(CommentCell*)cell
{
    NSIndexPath* indexpath = objc_getAssociatedObject(cell, "IndexPath");
    if(!tableReloading && indexpath)
    {
        tableReloading = YES;
        [tblView beginUpdates];
        [tblView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
        [tblView endUpdates];
        tableReloading = NO;
    }
    
}

#pragma mark - UITableView Delegate Method





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([[[UIDevice currentDevice] systemName] localizedCaseInsensitiveCompare:@"ipad"] ==NSOrderedSame)
        return 20.0;
    else
        return 15.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    Task* task = [_taskFeeds objectAtIndex:section];
    if(!task.isCollapsed)
    {
        return 40.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    Task* task = [_taskFeeds objectAtIndex:section];
    if(!task.isCollapsed)
    {
        static NSString *HeaderIdentifier = @"TaskFeedFooterView";
        TaskFeedFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
        if(header == nil)
        {
            header = [[TaskFeedFooterView alloc] initWithReuseIdentifier:HeaderIdentifier];
        }
        header.dateLbl.text = [NSString stringWithFormat:@"Created: %@",task.CreatedOnTimeString];
        
        
        [header.commentBtn addTarget:self action:@selector(openComments:) forControlEvents:UIControlEventTouchUpInside];
        header.commentBtn.selected = ![task.totalComments integerValue];
        header.commentBtn.tag = section;
        

        [header.commentCount setText:[NSString stringWithFormat:@"%d",[task.totalComments integerValue]]];
        
        return header;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Task* task = [_taskFeeds objectAtIndex:section];
    if(!task.isCollapsed)
    {
        return 1+MIN(3, [task.totalComments intValue])+1+(([task.totalComments intValue]>3)?1:0);
    }
    else
    {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_taskFeeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the number of rows in the section.
    CGFloat rowHeight = 0;
    
    Task* task = [_taskFeeds objectAtIndex:indexPath.section];
    if(indexPath.row == 0)
        rowHeight = 80;
    else if(indexPath.row == 1 && [task.totalComments intValue] > 3 )
    {
        rowHeight = 30;
    }
    else if((indexPath.row-1-(([task.totalComments intValue]>3)?1:0)) < MIN(3,[task.totalComments intValue]))
    {
        Comment* comment = [task.comments objectAtIndex:indexPath.row-1-(([task.totalComments intValue]>3)?1:0)];
        float w;
        UIApplication *application = [UIApplication sharedApplication];
        if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
        {
            w = CGRectGetHeight([UIScreen mainScreen].bounds) - 70;
        }
        else
        {
            w = CGRectGetWidth([UIScreen mainScreen].bounds) - 70;
        }
        rowHeight += MAX(60.0,[comment cellHeightForWidth:w]);
    }
    else
    {
        if(task.editingComment)
        {
            if(task.attachComment)
                rowHeight = 160.0;
            else
                rowHeight = 100.0;
        }
        else
            rowHeight = 50.0;
    }
    
    return rowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task* task = [_taskFeeds objectAtIndex:indexPath.section];
    if(indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"HomeFeedCell";
        HomeFeedCell *cell = (HomeFeedCell*)[tblView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if(cell == nil)
        {
            cell = [[HomeFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell.collapseExpandButton addTarget:self action:@selector(collapseExpandAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.collapseExpandButton.tag = indexPath.section;
        objc_setAssociatedObject(cell.collapseExpandButton, "HomeFeedCell", cell, OBJC_ASSOCIATION_ASSIGN);
        
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openTaskMenu:)];
        [longPress setNumberOfTouchesRequired:1];
        [longPress setMinimumPressDuration:0.5];
        [cell.collapseExpandButton addGestureRecognizer:longPress];
        objc_setAssociatedObject(longPress, "HomeFeedCell", cell, OBJC_ASSOCIATION_RETAIN);
        
        [cell.detailDisclosure addTarget:self action:@selector(showTaskDetail:) forControlEvents:UIControlEventTouchUpInside];
        cell.detailDisclosure.tag = indexPath.section;
        
        [cell.taskStatus addTarget:self action:@selector(changeTaskStatus:) forControlEvents:UIControlEventTouchUpInside];
        cell.taskStatus.tag = indexPath.section;
        [cell fillDataWithTask:task];
        cell.editing = NO;
        UISwipeGestureRecognizer * pan = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
        [pan setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:pan];
        
        [cell.taskStatus setImage:[task getTaskStatusImage] forState:UIControlStateNormal];
        
        [cell.locationBtn addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
        cell.locationBtn.tag = indexPath.section;
        
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height)];
        [v setBackgroundColor:[UIColor
                               colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f]];
        [cell setSelectedBackgroundView:v];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        return cell;
    }
    else if(indexPath.row == 1 && [task.totalComments intValue] > 3 )
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ViewCommentsCell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ViewCommentsCell"];
            cell.detailTextLabel.numberOfLines = 1;
            cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:29.0/255.0 green:153.0/255.0 blue:202.0/255.0 alpha:1.0];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"View all %d comments",[task.totalComments intValue]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if((indexPath.row-1-(([task.totalComments intValue]>3)?1:0)) < MIN(3,[task.totalComments intValue]))
    {
        NSString* nibName = @"CommentCell";
        Comment* comment = [task.comments objectAtIndex:indexPath.row-1-(([task.totalComments intValue]>3)?1:0)];
        CommentCell *cell = (CommentCell*)[tblView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
        if(cell == nil)
        {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nibName];
        }
        
        cell.readMoreTarget = self;
        cell.readMoreAction = @selector(showFullComment:);
        objc_setAssociatedObject(cell, "IndexPath", indexPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        [cell.locationBtn addTarget:self action:@selector(showCommentMap:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(cell.locationBtn, "Location", comment.location, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        cell.showReadMore = YES;
        float w;
        UIApplication *application = [UIApplication sharedApplication];
        if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
        {
            w = CGRectGetHeight([UIScreen mainScreen].bounds) - 70;
        }
        else
        {
            w = CGRectGetWidth([UIScreen mainScreen].bounds) - 70;
        }
        [cell fillDataWithComment:comment forWidth:w];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteComment:)];
        [longPress setNumberOfTouchesRequired:1];
        [longPress setMinimumPressDuration:0.5];
        [cell.contentView addGestureRecognizer:longPress];
        objc_setAssociatedObject(longPress, "Comment", comment, OBJC_ASSOCIATION_ASSIGN);
        return cell;
    }
    else
    {
        
        NSString* nibName = @"ComposeCommentCell";
        ComposeCommentCell *cell = (ComposeCommentCell*)[tblView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
        if(cell == nil)
        {
            cell = [[ComposeCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nibName];
        }
        [cell.commenterImage loadImageFromURL:[User currentUser].MobileImageUrl];
        cell.target = self;
        cell.action = @selector(composeComment:);
        cell.cancelTarget = self;
        cell.cancelAction = @selector(composeCommentCancel:);
        cell.postTarget = self;
        cell.postAction = @selector(composeCommentPost:);
        [cell.speakBtn addTarget:self action:@selector(speakAction:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(cell.speakBtn, "Cell", cell, OBJC_ASSOCIATION_RETAIN);
        
        cell.task = task;
        [cell setupCell];
        
        if([_currentCommentEditingIndex isEqual:indexPath])
            [cell.commentTextView becomeFirstResponder];
        
        objc_setAssociatedObject(cell, "IndexPath", indexPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Task* task = [_taskFeeds objectAtIndex:indexPath.section];
    if(indexPath.row == 1 && [task.totalComments intValue] > 3 )
    {
        CommentVC* vc = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:nil];
        [vc setTask:task];
        _lastSelectedTaskIndex = indexPath.section;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}


-(void)showMap:(UIButton*)sender
{
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:sender.tag];
    MapVC* vc = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
    vc.location = task.location;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showCommentMap:(UIButton*)sender
{
    Location* location = objc_getAssociatedObject(sender, "Location");
    MapVC* vc = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
    vc.location = location;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)composeComment:(ComposeCommentCell*)cell
{
    NSIndexPath* indexPath = objc_getAssociatedObject(cell, "IndexPath");
    if([_currentCommentEditingIndex isEqual:indexPath])
    {
        [tblView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        return;
    }
    
    _currentCommentEditingIndex = indexPath;
    [tblView beginUpdates];
    [tblView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]withRowAnimation:UITableViewRowAnimationNone];
    [tblView endUpdates];
    
    [tblView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
   
}

- (void)composeCommentCancel:(ComposeCommentCell*)cell
{
    [tblView beginUpdates];
    NSIndexPath* indexPath = objc_getAssociatedObject(cell, "IndexPath");
    _currentCommentEditingIndex = nil;
    [tblView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    [tblView endUpdates];
    [self.speechToTextObj stopRecording:YES];
}

- (void)composeCommentPost:(ComposeCommentCell*)cell
{
    [tblView beginUpdates];
    NSIndexPath* indexPath = objc_getAssociatedObject(cell, "IndexPath");
    _currentCommentEditingIndex = nil;
    [tblView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    [tblView endUpdates];
}



- (void)deleteComment:(UILongPressGestureRecognizer*)recong
{
    if(recong.state == UIGestureRecognizerStateBegan)
    {
        Comment* comment = objc_getAssociatedObject(recong, "Comment");
        
        if (comment.IsDeleted)
        {
            [self.view makeToast:@"This comment is already deleted."];
            
        }
        else if (!comment.CanDelete)
        {
            [self.view makeToast:@"You can't delete this comment."];
            
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to delete this comment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
            objc_setAssociatedObject(alert, "AlertComment", comment, OBJC_ASSOCIATION_RETAIN);
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ;
        Comment* comment = objc_getAssociatedObject(alertView, "AlertComment");
        objc_removeAssociatedObjects(alertView);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCallBack:) name:@"DeleteCommentNotifier" object:nil];
        [[TaskDocument sharedInstance] deleteComment:comment ofTaskId:comment.task.taskId];
    }
}

- (void)deleteCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(deleteCommentReload:) withObject:[note object] waitUntilDone:NO];
}

-(void)deleteCommentReload:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(object && [object isKindOfClass:[NSString class]])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else{
        [[TaskDocument sharedInstance] refreshHomeFeed];
    }
}

-(void)panGestureCallback:(UIPanGestureRecognizer*)ges
{
    HomeFeedCell* cell = (HomeFeedCell*)[ges view];
    [cell removeGestureRecognizer:ges];
    [UIView animateWithDuration:1.0 animations:^{
        NSMutableArray* arr = [NSMutableArray array];
        NSIndexPath *indexpath = [tblView indexPathForCell:cell];
        UITableViewHeaderFooterView* footer = [tblView footerViewForSection:indexpath.section];
        if(footer)
            [arr addObject:footer];
        for(int i =0;i< [tblView numberOfRowsInSection:indexpath.section];i++)
            [arr addObject:[tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexpath.section]]];
        for(UIView* v in arr)
        {
            CGRect rect = v.frame;
            rect.origin.x += rect.size.width;
            [v setFrame:rect];
        }
    } completion:^(BOOL finished) {
        [self performSelector:@selector(cellAnimationComplete:) withObject:cell afterDelay:0.3];
        
    }];
}

- (void)cellAnimationComplete:(HomeFeedCell*)cell
{
    [UIView animateWithDuration:1.0 animations:^{
        NSMutableArray* arr = [NSMutableArray array];
        NSIndexPath *indexpath = [tblView indexPathForCell:cell];
        UITableViewHeaderFooterView* footer = [tblView footerViewForSection:indexpath.section];
        if(footer)
            [arr addObject:footer];
        for(int i =0;i< [tblView numberOfRowsInSection:indexpath.section];i++)
            [arr addObject:[tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexpath.section]]];
        for(UIView* v in arr)
        {
            CGRect rect = v.frame;
            rect.origin.x = 0;
            [v setFrame:rect];
        }
    } completion:^(BOOL finished)
    {
        _selectedIndexPath = [tblView indexPathForCell:cell];
        cell.taskStatus.selected = YES;
        Task* task = [_taskFeeds objectAtIndex:_selectedIndexPath.section];
        [self changeTaskStatusCompleteForTask:task withSender:cell];
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
        Task* task = [_taskFeeds objectAtIndex:_selectedIndexPath.section];
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
        //[[TaskDocument sharedInstance] refreshHomeFeed];
    }
    else
    {
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndex:_selectedIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        [tblView endUpdates];
        [self.view makeToast:@"Error in status change"];
        
    }
    
}

- (void)openComments:(UIButton*)btn
{
    Task* task = [_taskFeeds objectAtIndex:btn.tag];
    CommentVC* vc = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:nil];
    [vc setTask:task];
    _lastSelectedTaskIndex = btn.tag;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)collapseExpandAction:(UIButton*)sender
{
    if(!tableReloading)
    {
        HomeFeedCell * cell = objc_getAssociatedObject(sender, "HomeFeedCell");
        [cell setSelected:YES animated:YES];
        Task* task = [_taskFeeds objectAtIndex:sender.tag];
        task.isCollapsed = !task.isCollapsed;
    
    
        tableReloading = YES;
        [tblView beginUpdates];
        [tblView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
        [tblView endUpdates];
        tableReloading = NO;
    }
}

-(void)showTaskDetail:(UIButton*)sender
{
    Task* task = [_taskFeeds objectAtIndex:sender.tag];
    TaskDetailVC* taskDetailvc = [[TaskDetailVC alloc] initWithNibName:@"TaskDetailVC" bundle:nil];
    taskDetailvc.task = task;
    taskDetailvc.target = self;
    [self.navigationController pushViewController:taskDetailvc animated:YES];
}


-(void)changeTaskStatus:(UIButton*)sender
{
    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:sender.tag];
    Task* task = [_taskFeeds objectAtIndex:sender.tag];
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



-(void)btnDiscussionPressed:(UIButton*)sender{
    
    
}

-(void)btnFollowIdeaPressed:(UIButton*)sender{
    
    
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

- (void)orientationChange:(NSNotification*)note
{
    if(filterTaskPopover != nil){
        filterTaskPopover = nil;
        [self filterTaskDoneAction:filterTaskDoneBtn];
        
    }
    
    //[self.view endEditing:YES];
    
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
        HomeFeedCell* cell = objc_getAssociatedObject(ges, "HomeFeedCell");
        _selectedIndexPath = [tblView indexPathForCell:cell];
        UIActionSheet* actionSheet= nil;
        if(cell.task.HasNudge)
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Nudge assignee",@"Delete this task",@"Share this task",@"Edit this task",nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete this task",@"Share this task",@"Edit this task",nil];
        }
        
    
        if(DEVICE_IS_TABLET)
        {
            CGRect rect = cell.collapseExpandButton.frame;
            [actionSheet showFromRect:rect inView:cell.collapseExpandButton animated:YES];
        }
        else
            [actionSheet showInView:self.view];
        
        objc_setAssociatedObject(actionSheet, "HomeFeedCellAction", cell, OBJC_ASSOCIATION_RETAIN);
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    projectMenuSheet = nil;
}
#pragma mark - UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1000)
    {
        Portfolio* portfolio = [TaskDocument sharedInstance].selectedPortfolio;
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create Project"])
        {
            [self performSelector:@selector(openCreateProject:) withObject:portfolio afterDelay:0.1];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Manage Members"])
        {
            [self performSelector:@selector(openManagePortfolioUser:) withObject:portfolio afterDelay:0.1];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Members"])
        {
            [self performSelector:@selector(openPortfolioUser:) withObject:portfolio afterDelay:0.1];
        }
        projectMenuSheet = nil;
    }
    else if(actionSheet.tag == 1001)
    {
        Project* project = [TaskDocument sharedInstance].selectedProject;
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create New Task"])
        {
            [self performSelector:@selector(openTaskCreator:) withObject:nil afterDelay:0.1];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Manage Members"])
        {
            [self performSelector:@selector(openManageProjectUser:) withObject:project afterDelay:0.1];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Members"])
        {
           [self performSelector:@selector(openProjectUser:) withObject:project afterDelay:0.1];
        }

        projectMenuSheet = nil;
    }
    else
    {
        HomeFeedCell* cell = objc_getAssociatedObject(actionSheet, "HomeFeedCellAction");
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
            [[TaskDocument sharedInstance] ChangeFollowTask:cell.task.taskId follow:[NSString stringWithFormat:@"%d",[cell.task.FollowTaskFlag intValue]]];
        }
        else if([btnTitle isEqualToString:@"Follow this task"])
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeFollowTaskCallBack:) name:@"ChangeFollowTaskNotifier" object:nil];
            [[TaskDocument sharedInstance] ChangeFollowTask:cell.task.taskId follow:[NSString stringWithFormat:@"%d",[cell.task.FollowTaskFlag intValue]]];
        }
        else if([btnTitle isEqualToString:@"Share this task"])
        {
            [self performSelector:@selector(openManageTaskUser:) withObject:cell.task afterDelay:0.1];
        }
        else if([btnTitle isEqualToString:@"Edit this task"])
        {
            Task* task = cell.task;
            [self performSelector:@selector(openEditTask:) withObject:task afterDelay:0.1];
            
        }
    }
}

- (IBAction)createProjectAction:(id)sender
{
    [self openCreateProject:[TaskDocument sharedInstance].selectedPortfolio];
}
- (IBAction)managePortfolioUserAction:(id)sender
{
    [self openManagePortfolioUser:[TaskDocument sharedInstance].selectedPortfolio];
}
- (IBAction)createTaskAction:(id)sender
{
    [self openTaskCreator:nil];
}
- (IBAction)manageProjectUserAction:(id)sender
{
    [self openManageProjectUser:[TaskDocument sharedInstance].selectedProject];
}

- (void)openCreateProject:(Portfolio*)portfolio
{
    CreatePortfolioVC* vc = [[CreatePortfolioVC alloc] initWithNibName:@"CreatePortfolioVC" bundle:nil];
    vc.portfolioType = CreateTypeProject;
    vc.selectedPortfolio= portfolio;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)openManagePortfolioUser:(Portfolio*)portfolio
{
    ManagePortfolioUserVC* vc = [[ManagePortfolioUserVC alloc] initWithNibName:@"ManagePortfolioUserVC" bundle:nil];
    vc.portfolioUserType = ManagePortfolioUserTypePortfolio;
    vc.portfolio= portfolio;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)openPortfolioUser:(Portfolio*)portfolio
{
    PortfolioUserVC* vc = [[PortfolioUserVC alloc] initWithNibName:@"PortfolioUserVC" bundle:nil];
    vc.portfolioUserType = PortfolioUserTypePortfolio;
    vc.portfolio= portfolio;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)openManageProjectUser:(Project*)project
{
    ManagePortfolioUserVC* vc = [[ManagePortfolioUserVC alloc] initWithNibName:@"ManagePortfolioUserVC" bundle:nil];
    vc.portfolioUserType = ManagePortfolioUserTypeProject;
    vc.project= project;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)openProjectUser:(Project*)project
{
    PortfolioUserVC* vc = [[PortfolioUserVC alloc] initWithNibName:@"PortfolioUserVC" bundle:nil];
    vc.portfolioUserType = PortfolioUserTypeProject;
    vc.project= project;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (void)openManageTaskUser:(Task*)task
{
    ManageTaskUserVC* vc = [[ManageTaskUserVC alloc] initWithNibName:@"ManageTaskUserVC" bundle:nil];
    vc.task = task;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        navVC.navigationItem.title = @"Manage Task Users";
    }];
}

- (void)openEditTask:(Task*)task
{
    EditTaskVC* taskDetailvc = [[EditTaskVC alloc] initWithNibName:@"EditTaskVC" bundle:nil];
    taskDetailvc.task = task;
    [self.navigationController pushViewController:taskDetailvc animated:YES];
}

- (void)postCommentCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(postComment:) withObject:[note object] waitUntilDone:NO];
}

- (void)postComment:(id)sender
{
    if([sender isKindOfClass:[Comment class]])
    {
        [[TaskDocument sharedInstance] refreshHomeFeed];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
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
        Task* task = [_taskFeeds objectAtIndex:[_selectedIndexPath section]];
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

- (IBAction)speakAction:(UIButton*)sender
{
    sender.enabled = NO;
    _currentComposeCommentCell = objc_getAssociatedObject(sender, "Cell");
    [self.speechToTextObj beginRecording];
}

#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    return [_currentComposeCommentCell didReceiveVoiceResponse:data];
}

- (void)showSineWaveView:(SineWaveViewController *)view
{
    [hiddenTextView resignFirstResponder];
    [hiddenTextView setInputView:view.view];
    [hiddenTextView becomeFirstResponder];
   // [_currentComposeCommentCell showSineWaveView:view];
}

- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    [hiddenTextView resignFirstResponder];
    [hiddenTextView setInputView:nil];
    [_currentComposeCommentCell dismissSineWaveView:view cancelled:wasCancelled];
}


- (void)showLoadingView
{
    [_currentComposeCommentCell showLoadingView];
}
- (void)requestFailedWithError:(NSError *)error
{
    [_currentComposeCommentCell requestFailedWithError:error];
}




- (void)openCalendar
{
    EventVC* vc = [[EventVC alloc] initWithNibName:@"EventVC" bundle:nil];
//    CreateEventVC* vc = [[CreateEventVC alloc] initWithNibName:@"CreateEventVC" bundle:nil];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

@end
