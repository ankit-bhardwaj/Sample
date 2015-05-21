//
//  TaskListVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/27/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TaskListVC.h"
#import "UIViewController+MMDrawerController.h"
#import "TransTaskCell.h"
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

#import "TransTaskCell.h"
#import "MapVC.h"

@interface TaskListVC ()
{
    IBOutlet UITableView* table;
    GetMoreTableFooter*_getFooterView;
    NSMutableArray* feedsArray;
    WYPopoverController* sortCategoryPopover;
    NSIndexPath* _selectedIndexPath;
}
@end

@implementation TaskListVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIImageView* logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, 70, 28)];
    [logoView setContentMode:UIViewContentModeScaleAspectFit];
    [logoView setImage:[UIImage imageNamed:@"cruun_logo.png"]];
    self.navigationItem.titleView = logoView;
    
    [self setupLeftMenuButton];
    [self setupRightMenuButton];
    
        UIColor * barColor = [UIColor
                              colorWithRed:25.0/255.0 green:76.0/255.0 blue:171.0/255.0 alpha:1.0];
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
   
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 1001;
    [table addSubview:refreshControl];
    [refreshControl beginRefreshing];
    
    _getFooterView = [[GetMoreTableFooter alloc] initWithFrame:CGRectMake(0, 0, table.bounds.size.width, 40)];
    [_getFooterView setState:TableFooterNormal];
    [table setTableFooterView:_getFooterView];
    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHomeFeedCallBackCallBack:) name:@"HomeFeedNotifier" object:nil];
    [[TaskDocument sharedInstance] refreshHomeFeed];
    [[TaskDocument sharedInstance] getTaskSortingCategories:@"MyTask"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([TaskDocument sharedInstance].homeFeedUpdateRequire)
        [[TaskDocument sharedInstance] refreshHomeFeed];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)reloadView:(NSArray*)tmp
{
    [table reloadData];
    if(![TaskDocument sharedInstance].homeFeeds.count)
        [_getFooterView setState:TableFooterNoData];
    else if(!tmp || tmp.count ==0)
        [_getFooterView setState:TableFooterNoMoreData];
    
    UIRefreshControl* cnt = (UIRefreshControl*)[table viewWithTag:1001];
    [cnt endRefreshing];
}

- (void)refresh:(UIRefreshControl*)control
{
    [control beginRefreshing];
    [[TaskDocument sharedInstance] refreshHomeFeed];
}


- (void)getHomeFeedCallBackCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadView:) withObject:[note object] waitUntilDone:NO];
}

-(void)setupLeftMenuButton
{
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menubutton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress:)];
    [leftDrawerButton setWidth:30.0];
    UIBarButtonItem * categoryBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showSortCategory:)];
    [categoryBtn setWidth:30.0];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:leftDrawerButton,categoryBtn, nil] animated:YES];
}

-(void)setupRightMenuButton
{
    UIBarButtonItem * rightDrawerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(openTaskCreator:)];
    [rightDrawerButton setWidth:30.0];
    UIBarButtonItem * notificationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"recentActivityNew.png"] style:UIBarButtonItemStylePlain  target:self action:@selector(notificationTapped:)];
    [notificationButton setWidth:30.0];
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
    
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}


- (IBAction)showSortCategory:(UIBarButtonItem*)sender
{
    TaskSortCategoryVC* vc = [[TaskSortCategoryVC alloc] initWithNibName:@"TaskSortCategoryVC" bundle:nil];
    vc.target = self;vc.action = @selector(categorySelected:);
    if(DEVICE_IS_TABLET)
    {
        sortCategoryPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [sortCategoryPopover setPopoverContentSize:CGSizeMake(280, 150)];
        sortCategoryPopover.delegate = self;
        [sortCategoryPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        sortCategoryPopover = [[WYPopoverController alloc] initWithContentViewController:vc];
        
        [sortCategoryPopover setPopoverContentSize:CGSizeMake(280, 220)];
        [sortCategoryPopover setDelegate:self];
        [sortCategoryPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    }
}

-(void)categorySelected:(TaskSortCategory*)category
{
    [[TaskDocument sharedInstance] setSortCategory:category];
    [[TaskDocument sharedInstance] refreshHomeFeed];
    [sortCategoryPopover dismissPopoverAnimated:YES];
    sortCategoryPopover = nil;
    //[sortCategoryBtn setTitle:[NSString stringWithFormat:@"Show: %@", category.SortByDescription] forState:UIControlStateNormal];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)popoverController
{
    sortCategoryPopover = nil;
    return YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [_getFooterView setState:TableFooterLoading];
        [[TaskDocument sharedInstance] getHomeFeed];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_getFooterView setState:TableFooterLoading];
    [[TaskDocument sharedInstance] getHomeFeed];
}

#pragma mark - UITableView Delegate Method


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the number of rows in the section.
    CGFloat rowHeight = 100.0;
//    
//    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:indexPath.section];
//    if (!task.isCollapsed)
//    {
//        rowHeight+= 42;
//        for (int  i = 0; i < [task.comments count]; i++)
//        {
//            if (i >= 3)
//            {
//                break;
//            }
//            Comment* comment = [task.comments objectAtIndex:i];
//            rowHeight += [comment cellHeightForWidth:(tableView.bounds.size.width-40) shouldShowReadMore:NO];
//        }
//        
//    }
    
    return rowHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 6.0) ];
    [v setBackgroundColor:[UIColor clearColor]];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[TaskDocument sharedInstance] homeFeeds] count];
}


/*
 - (CGFloat)textViewHeightForAttributedText:(NSString*)text andWidth: (CGFloat)width {
 UITextView *calculationView = [[UITextView alloc] init];
 [calculationView setText:text];
 CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
 return size.height;
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TransTaskCellIdentifier = @"TransTaskCell";
    TransTaskCell* cell = nil;
    cell = (TransTaskCell*)[tableView dequeueReusableCellWithIdentifier:TransTaskCellIdentifier];
    
    if (cell == nil) {
        NSArray* arrAllObjects = [[NSBundle mainBundle] loadNibNamed:@"TransTaskCell" owner:self options:nil];
        if (arrAllObjects) {
            for (id object in arrAllObjects) {
                if ([object isKindOfClass:[TransTaskCell class]]) {
                    cell = (TransTaskCell*)object;
                    break;
                }
            }
        }
    }
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:indexPath.section];

    
    [cell.taskStatus addTarget:self action:@selector(changeTaskStatus:) forControlEvents:UIControlEventTouchUpInside];
    cell.taskStatus.tag = indexPath.section;
    [cell fillDataWithTask:task];
    
    cell.editing = NO;
    UISwipeGestureRecognizer * pan = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureCallback:)];
    [pan setDirection:UISwipeGestureRecognizerDirectionRight];
    [cell addGestureRecognizer:pan];
    [cell.taskStatus setImage:[task getTaskStatusImage] forState:UIControlStateNormal];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:indexPath.section];
    TaskDetailVC* taskDetailvc = [[TaskDetailVC alloc] initWithNibName:@"TaskDetailVC" bundle:nil];
    taskDetailvc.task = task;
    taskDetailvc.target = self;
    [self.navigationController pushViewController:taskDetailvc animated:YES];
}

-(void)panGestureCallback:(UIPanGestureRecognizer*)ges
{
    TransTaskCell* cell = (TransTaskCell*)[ges view];
    [cell removeGestureRecognizer:ges];
    [UIView animateWithDuration:1.0 animations:^{
        CGRect rect = cell.frame;
        rect.origin.x += rect.size.width;
        [cell setFrame:rect];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(cellAnimationComplete:) withObject:cell afterDelay:0.3];
        
    }];
}

- (void)cellAnimationComplete:(TransTaskCell*)cell
{
    [UIView animateWithDuration:1.0 animations:^{
        CGRect rect = cell.superview.frame;
        rect.origin.x = 0;
        [cell.superview setFrame:rect];
    } completion:^(BOOL finished)
     {
         _selectedIndexPath = [table indexPathForCell:cell];
         cell.taskStatus.selected = YES;
         Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:_selectedIndexPath.section];
         if((task.CanEditAssignee||task.CanEdit) && task.taskStatus != TaskStatusCompleted)
         {
             [MBProgressHUD showHUDAddedTo:self.view animated:YES];
             [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusChangeCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
             
             [[TaskDocument sharedInstance] setTaskStatusComplete:task.taskId];
         }
         else
         {
             [self.view makeToast:@"You can not change status"];
             
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
        Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:_selectedIndexPath.section];
        if(task.taskStatus != TaskStatusCompleted)
            task.taskStatus = TaskStatusCompleted;
        else
            task.taskStatus = TaskStatusNew;
    }
    else
    {
        
    }
    [table beginUpdates];
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:_selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [table endUpdates];
}

- (void)openComments:(UIButton*)btn
{
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:btn.tag];
    CommentVC* vc = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:nil];
    [vc setTask:task];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)collapseExpandAction:(UIButton*)sender
{
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:sender.tag];
    task.isCollapsed = !task.isCollapsed;
    
    [table beginUpdates];
    [table reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:sender.tag]] withRowAnimation:UITableViewRowAnimationFade];
    [table endUpdates];
}

-(void)showTaskDetail:(UIButton*)sender
{
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:sender.tag];
    TaskDetailVC* taskDetailvc = [[TaskDetailVC alloc] initWithNibName:@"TaskDetailVC" bundle:nil];
    taskDetailvc.task = task;
    taskDetailvc.target = self;
    [self.navigationController pushViewController:taskDetailvc animated:YES];
}

-(void)changeTaskStatus:(UIButton*)sender
{
    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:sender.tag];
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:sender.tag];
    if((task.CanEditAssignee||task.CanEdit) && task.taskStatus != TaskStatusCompleted)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusGotItCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
        
        [[TaskDocument sharedInstance] setTaskStatusComplete:task.taskId];
    }
    else
    {
        [self.view makeToast:@"You can not change status"];
        
    }
    
}

- (void)taskStatusGotItCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(taskStatusChange:) withObject:[note object] waitUntilDone:NO];
}

-(IBAction)collapseExpandAllAction:(UIButton*)sender
{
    sender.selected = !sender.selected;
    
    NSArray* homeFeeds = [[TaskDocument sharedInstance] homeFeeds];
    for (Task* task in homeFeeds) {
        task.isCollapsed = sender.selected;
    }
    [[TaskDocument sharedInstance] setIsHomeFeedCollaspe:sender.selected];
    [table beginUpdates];
    [table reloadRowsAtIndexPaths:table.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    [table endUpdates];
    
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

@end
