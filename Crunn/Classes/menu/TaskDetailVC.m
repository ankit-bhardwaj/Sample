//
//  TaskDetailVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TaskDetailVC.h"
#import "CreatorDetailCell.h"
#import "TaskSubDetailsCell.h"
#import "TaskDocument.h"
#import "CommentVC.h"
#import "EditTaskVC.h"
#import "Comment.h"
#import "AttachmentCell.h"
#import "ShowAttachmentVC.h"
#import "TaskUserCell.h"
#import "ImageMapVC.h"
#import "ManageTaskUserVC.h"

#import "KalViewController.h"
#import "MapVC.h"

#define INTRO_SETION            0
#define DESCRIPTION_SETION      1
#define ATTACHMENT_SETION       2
#define PRIORITY_SETION         3
#define PROJECT_SETION          4
#define ASSIGNEE_SETION         5
#define REMINDER_SETION         6
#define DUE_DATE_SETION         7
#define USER_SETION             8


@interface TaskDetailVC ()
{
    NSMutableArray* _sections;
    KalViewController* kal;
    UIPopoverController* datePopover;
}
@property (nonatomic, assign)BOOL isExpanded;
@property(nonatomic, retain)UIButton* markCompleteBtn;
-(IBAction)openComment;
-(IBAction)gotItAction;
-(IBAction)nudgeAction;
-(IBAction)btnTabChangePressed:(UIButton*)sender;
@end



@implementation TaskDetailVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if (DEVICE_IS_TABLET) {
        nibNameOrNil = @"TaskDetailVC1";
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sections = [[NSMutableArray alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               
                                               [UIFont systemFontOfSize:16.0],NSFontAttributeName,
                                               shadow, NSShadowAttributeName, nil];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    self.navigationItem.title = @"Task Details";
    
    if (self.task.CanEdit || self.task.CanEditAssignee)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTaskDetailCallBack:) name:@"GetTaskDetailNotifier" object:nil];
    [[TaskDocument sharedInstance] getTaskDetailForId:self.task.taskId];
    
    [self reloadData];
}



- (void)getTaskDetailCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openTaskDetailScreen:) withObject:[note object] waitUntilDone:NO];
}

- (void)openTaskDetailScreen:(Task*)task
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if([task isKindOfClass:[Task class]])
    {
        self.task.taskStatus = task.taskStatus;
        self.task.FollowTaskFlag = task.FollowTaskFlag;
        self.task.summary = task.summary;
        self.task.Attachments = task.Attachments;
        self.task.HasNudge = task.HasNudge;
        self.task.UserList = task.UserList;
        self.task.highPriority = task.highPriority;
    }
    [self reloadData];
}

- (void)reloadData
{
    
    [_sections removeAllObjects];
    [_sections addObject:[NSNumber numberWithInt:INTRO_SETION]];
    if(NSSTRING_HAS_DATA( self.task.summary))
        [_sections addObject:[NSNumber numberWithInt:DESCRIPTION_SETION]];
    if(self.task.Attachments && self.task.Attachments.count)
        [_sections addObject:[NSNumber numberWithInt:ATTACHMENT_SETION]];
    [_sections addObject:[NSNumber numberWithInt:PRIORITY_SETION]];
    [_sections addObject:[NSNumber numberWithInt:PROJECT_SETION]];
    [_sections addObject:[NSNumber numberWithInt:ASSIGNEE_SETION]];
    if(self.task.HasReminder)
        [_sections addObject:[NSNumber numberWithInt:REMINDER_SETION]];
    if(self.task.DueDateString && [self.task.DueDateString length])
        [_sections addObject:[NSNumber numberWithInt:DUE_DATE_SETION]];
    [_sections addObject:[NSNumber numberWithInt:USER_SETION]];
    [self.tblView reloadData];

    
    for(UIView* v in self.bottomView.subviews)
        [v removeFromSuperview];
    
    NSMutableArray* actionItems = [NSMutableArray array];
    [actionItems addObject:[NSNumber numberWithInt:0]];
    if(self.task.CanEditAssignee && self.task.taskStatus == TaskStatusNew && (self.task.assignee.UserId == [User currentUser].UserId))
         [actionItems addObject:[NSNumber numberWithInt:1]];
    if(self.task.HasNudge)
        [actionItems addObject:[NSNumber numberWithInt:2]];
    [actionItems addObject:[NSNumber numberWithInt:3]];
    
    float x = 0;
    for(NSNumber *num in actionItems)
    {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect rect;
        float commentWidth;
        switch ([num intValue])
        {
            case 0:
            {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTitle:@"Comment" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(openComment) forControlEvents:UIControlEventTouchUpInside];
                [btn setImage:[UIImage imageNamed:@"comment_normal_small.png"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"comment_selected_small.png"] forState:UIControlStateSelected];
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                rect = CGRectMake(x, 0,MAX(120, self.bottomView.bounds.size.width/[actionItems count]), self.bottomView.bounds.size.height);
                [btn setFrame:rect];
                [self.bottomView addSubview:btn];
                
                UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width,self.bottomView.bounds.size.height-8)];
                [lbl setText:[NSString stringWithFormat:@"%d",[self.task.totalComments integerValue]]];
                lbl.font = [UIFont systemFontOfSize:11.0];
                [lbl setTextAlignment:NSTextAlignmentCenter];
                [lbl setBackgroundColor:[UIColor clearColor]];
                lbl.autoresizingMask = UIViewAutoresizingNone;
                commentWidth = rect.size.width;
                lbl.userInteractionEnabled = NO;
                [btn addSubview:lbl];
                self.commentCntLbl = lbl;
                
                CGPoint superPoint = btn.center;
                CGPoint point = self.commentCntLbl.center;
                point.x = superPoint.x - 30;
                [self.commentCntLbl setCenter:point];
                break;
            }
            case 1:
            {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setTitle:@"Got it" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(gotItAction) forControlEvents:UIControlEventTouchUpInside];
                [btn setImage:[UIImage imageNamed:@"gotit.png"] forState:UIControlStateNormal];
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
                float width = MAX(70, (self.bottomView.bounds.size.width-commentWidth)/([actionItems count]-1))-1;
                rect = CGRectMake(x-1, 0,width, self.bottomView.bounds.size.height);
                [self.bottomView addSubview:btn];
                break;
            }
            case 2:
            {
                [btn setTitle:@"Nudge" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(nudgeAction) forControlEvents:UIControlEventTouchUpInside];
                float width = MAX(60, (self.bottomView.bounds.size.width-commentWidth)/([actionItems count]-1))-1;
                rect = CGRectMake(x-1, 0,width, self.bottomView.bounds.size.height);
                [self.bottomView addSubview:btn];
                break;
            }
            case 3:
            {
                [btn setTitle:@"More" forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(btnTabChangePressed:) forControlEvents:UIControlEventTouchUpInside];
                float width = MAX(60, (self.bottomView.bounds.size.width-commentWidth)/([actionItems count]-1))-1;
                rect = CGRectMake(x-1, 0,width, self.bottomView.bounds.size.height);
                [self.bottomView addSubview:btn];
                break;
            }
            default:
                break;
        }
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [btn setFrame:rect];
        [btn setTitleColor:[UIColor colorWithRed:29.0/255.0 green:153.0/255.0 blue:202.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(x+rect.size.width+1, 5, 1, self.bottomView.bounds.size.height-10)];
        [v setBackgroundColor:[UIColor lightGrayColor]];
        v.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self.bottomView addSubview:v];
        
        x+= rect.size.width+2;
    }
    
}


-(void)editAction
{
    EditTaskVC* vc = [[EditTaskVC alloc] initWithNibName:@"EditTaskVC" bundle:nil];
    vc.task = self.task;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)btnTabChangePressed:(UIButton*)sender
{
    NSString* followUnfollowString = [self.task.FollowTaskFlag boolValue] == YES?@"Un-follow this task":@"Follow this task";
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete this task",followUnfollowString,@"Share this task", nil];
    
    if(DEVICE_IS_TABLET)
    {
        CGRect rect = sender.frame;
        [actionSheet showFromRect:rect inView:sender.superview animated:YES];
    }
    else
        [actionSheet showInView:self.view];
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

-  (IBAction)openComment
{
    CommentVC* vc = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:nil];
    [vc setTask:self.task];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)gotItAction
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusChangeCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
    [[TaskDocument sharedInstance] setTaskStatusComplete:self.task.taskId];
}

-(void)markCompleteAction:(UIButton*)sender
{
    if (sender.selected) {
        return;
    }
    self.markCompleteBtn = sender;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Mark Status" message:@"Are you sure you want to mark this task as Completed?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
  /*  sender.selected = !sender.selected;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusChangeCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
    if(sender.selected)
        [[TaskDocument sharedInstance] setTaskStatusComplete:self.task.taskId];
    else
        [[TaskDocument sharedInstance] setTaskStatusNew:self.task.taskId];*/
}
-(void)taskStatusChangeCallBack:(NSNotification*)note{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(taskStatusChangeSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

-(void)taskStatusChangeSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]])
    {
        if(self.task.taskStatus == TaskStatusCompleted)
        {
            self.task.taskStatus = TaskStatusNew;
        }
        else
        {
            self.task.taskStatus = TaskStatusCompleted;
            
        }
        self.task.StatusTypeDescription = [self.task getTaskStatusName];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [self reloadData];
}


-(IBAction)nudgeAction
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommentCallBack:) name:@"PostCommentNotifier" object:nil];
    [[TaskDocument sharedInstance] saveCommentNudgeForTaskId:self.task.taskId];
}

- (void)postCommentCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(postComment:) withObject:[note object] waitUntilDone:NO];
}

- (void)postComment:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([sender isKindOfClass:[Comment class]])
    {
    }
}
#pragma mark - UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {
        self.markCompleteBtn.selected = !self.markCompleteBtn.selected;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskStatusChangeCallBack:) name:@"TaskStatusChangeNotifier" object:nil];
        [[TaskDocument sharedInstance] setTaskStatusComplete:self.task.taskId];
    }

}
#pragma mark - UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    switch (buttonIndex) {
        case 0:
        {
            if(self.task.CanEdit)
            {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTaskCallBack:) name:@"DeleteTaskNotifier" object:nil];
                [[TaskDocument sharedInstance] deleteTask:self.task.taskId];
            }
            else
            {
                [self.view makeToast:@"You can't delete this task."];
                
            }
            break;
        }
        case 1:
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeFollowTaskCallBack:) name:@"ChangeFollowTaskNotifier" object:nil];
            [[TaskDocument sharedInstance] ChangeFollowTask:self.task.taskId follow:[NSString stringWithFormat:@"%d",[self.task.FollowTaskFlag intValue]]];
            break;
        case 2:
        {
            ManageTaskUserVC* vc = [[ManageTaskUserVC alloc] initWithNibName:@"ManageTaskUserVC" bundle:nil];
            vc.target = self;
            vc.action = @selector(assigneeSelected:);
            vc.task = self.task;
            UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            navVC.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navVC animated:YES completion:^{
                navVC.navigationItem.title = @"Manage Task Users";
            }];
        }
        default:
            break;
    }

}


-(void)ChangeFollowTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(changeFollowTaskSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)changeFollowTaskSuccess:(id)sender
{
    
    if ([sender isKindOfClass:[NSNumber class]])
    {
        self.task.FollowTaskFlag = [NSNumber numberWithBool:![self.task.FollowTaskFlag boolValue]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTaskDetailCallBack:) name:@"GetTaskDetailNotifier" object:nil];
        [[TaskDocument sharedInstance] getTaskDetailForId:self.task.taskId];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
        if (self.target && [self.target respondsToSelector:@selector(refresh:)]) {
            [self.target performSelector:@selector(refresh:) withObject:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showFullDescription:(TaskSubDetailsCell*)cell
{
    NSIndexPath* indexpath = [self.tblView indexPathForCell:cell];
    self.isExpanded = !self.isExpanded;
    if(indexpath)
    {
        //[self.tblView reloadData];
        [self.tblView beginUpdates];
        //[self.tblView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self.tblView numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
        [self.tblView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tblView endUpdates];
    }
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger index = [[_sections objectAtIndex:section] intValue];

    if(index == USER_SETION)
        return self.task.UserList.count;
        // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSUInteger index = [[_sections objectAtIndex:section] intValue];
    CGFloat sectionheight = 32;
    switch (index) {
        case 0:
            sectionheight = 0;
            break;
            
        default:
            break;
    }
    return sectionheight;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSUInteger index = [[_sections objectAtIndex:section] intValue];
    UIView* headerView = nil;
 
        switch (index) {
            case INTRO_SETION:
                break;
                
            case DESCRIPTION_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, tableView.bounds.size.width-20, 21)];
                
                [title setText:@"Description"];
                 //title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width - 20, 1)];
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                //seperator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                [headerView addSubview:title];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
            case ATTACHMENT_SETION:
            {
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, tableView.bounds.size.width-20, 21)];
                
                [title setText:@"Attachments"];
                //title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width - 20, 1)];
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
               // seperator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                [headerView addSubview:title];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
            case PRIORITY_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                UILabel* leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, tableView.bounds.size.width/2.0, 21)];
                
                [leftLabel setText:@"Priority"];
                //leftLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                
                UILabel* rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width/2.0+10, 8, tableView.bounds.size.width/2.0, 21)];
                [rightLabel setText:@"Status"];
                //rightLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width -20, 1)];
               // seperator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [leftLabel setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [rightLabel setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [leftLabel setFont:[UIFont systemFontOfSize:14.0f]];
                [rightLabel setFont:[UIFont systemFontOfSize:14.0f]];
                [headerView addSubview:leftLabel];
                [headerView addSubview:rightLabel];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
                
            case PROJECT_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                UIImageView* titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,20,20)];
                [titleImage setImage:[UIImage imageNamed:@"projectList_btn.png"]];
                [headerView addSubview:titleImage];
                
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, tableView.bounds.size.width - 50, 21)];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [title setText:@"Project"];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [headerView addSubview:title];
                
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
            break;
            case ASSIGNEE_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                UIImageView* titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,20,20)];
                [titleImage setImage:[UIImage imageNamed:@"assignee_btn.png"]];
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, tableView.bounds.size.width - 50, 21)];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [title setText:@"Assignee"];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [headerView addSubview:titleImage];
                [headerView addSubview:title];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
            case REMINDER_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, tableView.bounds.size.width - 50, 21)];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [title setText:@"Auto Reminder"];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [headerView addSubview:title];
                
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
                
            case DUE_DATE_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, tableView.bounds.size.width - 50, 21)];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [title setText:@"Due Date"];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [headerView addSubview:title];
                
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
            case USER_SETION:{
                
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
                UIImageView* titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,20,20)];
                [titleImage setImage:[UIImage imageNamed:@"user_list.png"]];
                //titleImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
                UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, tableView.bounds.size.width - 50, 21)];
                [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [title setText:@"Visible to"];
                //title.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
                //seperator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
                [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
                [headerView addSubview:titleImage];
                [headerView addSubview:title];
                [headerView addSubview:seperator];
                [headerView setBackgroundColor:[UIColor whiteColor]];
                
            }
                break;
                
        }

        return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [[_sections objectAtIndex:indexPath.section] intValue];
    
    // Return the number of rows in the section.
    CGFloat rowHeight = 32;
    
    switch (index) {
        case INTRO_SETION:
            rowHeight = 92;
            break;
        case DESCRIPTION_SETION:
        {
            
                UIFont *font =[UIFont fontWithName:@"Helvetica" size:14.0];
                [self.task.attrSummary addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [self.task.attrSummary length])];
                CGRect paragraphRect = [self.task.attrSummary boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 20, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
                
                rowHeight = paragraphRect.size.height+20;
            
            if (rowHeight > 63)
            {
                if(!self.isExpanded)
                    rowHeight = 84;
                else
                    rowHeight += 21;
            }
        }
        break;
        case ATTACHMENT_SETION:
        {
            rowHeight = 5;
            NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
            BOOL scrollViewAdded = NO;
            for(Attachment* attachment in self.task.Attachments)
            {
                if([imageContentTypes containsObject:attachment.ContentType])
                {
                    if(!scrollViewAdded)
                    {
                        rowHeight += 46.0;
                        scrollViewAdded = YES;
                    }
                }
                else
                {
                    rowHeight += 22.0;
                }
            }
        }
            break;
            
        case USER_SETION:
            rowHeight = 32;
            break;
        default:
            break;
    }
    
    return rowHeight;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    NSUInteger index = [[_sections objectAtIndex:indexPath.section] intValue];
    UITableViewCell* cell = nil;
    
    if (index == INTRO_SETION)
    {
        cell = [self cellForFirstSection:tableView];
    }
    else if (index == ATTACHMENT_SETION)
    {
        static NSString *AttachmentCellIdentifier = @"AttachmentCell";
        
        cell = (AttachmentCell*)[tableView dequeueReusableCellWithIdentifier:AttachmentCellIdentifier];
        
        if (cell == nil) {
            NSString* nibName = DEVICE_IS_TABLET?@"AttachmentCell1":@"AttachmentCell";
            NSArray* arrAllObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
            if (arrAllObjects) {
                for (id object in arrAllObjects)
                {
                    if ([object isKindOfClass:[AttachmentCell class]]) {
                        cell = (AttachmentCell*)object;
                        break;
                    }
                }
            }
        }
        [(AttachmentCell*)cell fillDataWithAttachments:self.task.Attachments];
    }
    else if(index == DESCRIPTION_SETION || index == PRIORITY_SETION || index == PROJECT_SETION || index == ASSIGNEE_SETION || index == REMINDER_SETION || index == DUE_DATE_SETION)
    {
        static NSString *TaskSubDetailsCellIdentifier = @"TaskSubDetailsCell";
        
        cell = (TaskSubDetailsCell*)[tableView dequeueReusableCellWithIdentifier:TaskSubDetailsCellIdentifier];
        
        if (cell == nil) {
            NSString* nibName = DEVICE_IS_TABLET?@"TaskSubDetailsCell1":@"TaskSubDetailsCell";
            NSArray* arrAllObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
            if (arrAllObjects) {
                for (id object in arrAllObjects) {
                    if ([object isKindOfClass:[TaskSubDetailsCell class]]) {
                        cell = (TaskSubDetailsCell*)object;
                        break;
                    }
                }
            }
        }
        ((TaskSubDetailsCell*)cell).readMore.hidden = YES;
        switch (index)
        {
            case DESCRIPTION_SETION:
            {
                [((TaskSubDetailsCell*)cell).priorityView setHidden:YES];
                [((TaskSubDetailsCell*)cell).visibleToView setHidden:YES];
                [((TaskSubDetailsCell*)cell).subDetailLabel setHidden:NO];
                float rowHeight;
                ((TaskSubDetailsCell*)cell).subDetailLabel.numberOfLines = 0;
               
                    NSDictionary* dict = nil;
                
                    CGRect paragraphRect = [self.task.attrSummary boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-20, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
                    
                    rowHeight = paragraphRect.size.height+20;
                    ((TaskSubDetailsCell*)cell).subDetailLabel.attributedText =self.task.attrSummary;
                
               
                if (rowHeight > 84)
                {
                    ((TaskSubDetailsCell*)cell).readMoreTarget = self;
                    ((TaskSubDetailsCell*)cell).readMoreAction = @selector(showFullDescription:);
                    ((TaskSubDetailsCell*)cell).readMore.hidden = NO;
                    if(!self.isExpanded){
                        rowHeight = 63;
                        [((TaskSubDetailsCell*)cell).subDetailLabel setNumberOfLines:3];
                    }
                    
                    ((TaskSubDetailsCell*)cell).readMore.selected = self.isExpanded;
                }
                
                CGRect frame = ((TaskSubDetailsCell*)cell).subDetailLabel.frame;
                frame.size.height = rowHeight;
                ((TaskSubDetailsCell*)cell).subDetailLabel.frame = frame;
                CGRect readMoreframe = ((TaskSubDetailsCell*)cell).readMore.frame;
                readMoreframe.origin.y = rowHeight;
                ((TaskSubDetailsCell*)cell).readMore.frame = readMoreframe;

                break;
            }
            case PRIORITY_SETION:
                [((TaskSubDetailsCell*)cell).priorityView setHidden:NO];
                [((TaskSubDetailsCell*)cell).visibleToView setHidden:YES];
                [((TaskSubDetailsCell*)cell).subDetailLabel setHidden:YES];
                ((TaskSubDetailsCell*)cell).priorityLabel.text = self.task.highPriority == true ?@"   High":@"Normal";
                ((TaskSubDetailsCell*)cell).priorityImage.hidden = !self.task.highPriority;
                
                CGRect statusFrame = ((TaskSubDetailsCell*)cell).statusImage.frame;
                statusFrame.origin.x = tableView.bounds.size.width/2.0;
                ((TaskSubDetailsCell*)cell).statusImage.frame = statusFrame;
                
                CGRect statusLabelFrame = ((TaskSubDetailsCell*)cell).statusLabel.frame;
                statusLabelFrame.origin.x = statusFrame.origin.x + statusFrame.size.width + 2;
                ((TaskSubDetailsCell*)cell).statusLabel.frame = statusLabelFrame;

                
                ((TaskSubDetailsCell*)cell).statusLabel.text = [self.task getTaskStatusName];
                ((TaskSubDetailsCell*)cell).statusImage.image = [self.task getTaskStatusImage];
                break;
            case PROJECT_SETION:
                [((TaskSubDetailsCell*)cell).priorityView setHidden:YES];
                [((TaskSubDetailsCell*)cell).visibleToView setHidden:YES];
                [((TaskSubDetailsCell*)cell).subDetailLabel setHidden:NO];
                ((TaskSubDetailsCell*)cell).subDetailLabel.text = self.task.ProjectName;
                break;
            case ASSIGNEE_SETION:
                [((TaskSubDetailsCell*)cell).priorityView setHidden:YES];
                [((TaskSubDetailsCell*)cell).visibleToView setHidden:YES];
                [((TaskSubDetailsCell*)cell).subDetailLabel setHidden:NO];
                ((TaskSubDetailsCell*)cell).subDetailLabel.text = [User currentUser].UserId==self.task.assignee.UserId? @"Me":self.task.assignee.FormattedName;
                break;
            case REMINDER_SETION:
                ((TaskSubDetailsCell*)cell).priorityImage.hidden = YES;
                ((TaskSubDetailsCell*)cell).visibletoImage.hidden = YES;
                ((TaskSubDetailsCell*)cell).statusImage.hidden = YES;
                [((TaskSubDetailsCell*)cell).reminderBtn setHidden:NO];
                [((TaskSubDetailsCell*)cell).reminderLabel setHidden:NO];
                ((TaskSubDetailsCell*)cell).reminderLabel.text = self.task.AutoReminder.Title;
                ((TaskSubDetailsCell*)cell).reminderTarget = self;
                ((TaskSubDetailsCell*)cell).reminderAction = @selector(openReminderEditor:);
                if(self.task.AutoReminder.IsReminderToday)[((TaskSubDetailsCell*)cell).reminderBtn setImage:[UIImage imageNamed:@"redBell"] forState:UIControlStateNormal];
                break;
            case DUE_DATE_SETION:
                [((TaskSubDetailsCell*)cell).priorityView setHidden:YES];
                [((TaskSubDetailsCell*)cell).visibleToView setHidden:YES];
                ((TaskSubDetailsCell*)cell).priorityImage.hidden = YES;
                ((TaskSubDetailsCell*)cell).visibletoImage.hidden = YES;
                ((TaskSubDetailsCell*)cell).statusImage.hidden = YES;
                ((TaskSubDetailsCell*)cell).subDetailLabel.hidden = NO;
                ((TaskSubDetailsCell*)cell).subDetailLabel.text = [[[self.task.DueDateString componentsSeparatedByString:@"|"] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                break;
                
            default:
                break;
                
        }
        
    }
    else
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
        TaskUser* user = [self.task.UserList objectAtIndex:indexPath.row];
        [(TaskUserCell*)cell fillDataForUser:user];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (UITableViewCell *)cellForFirstSection:(UITableView *)tableView
{
    
    static NSString *CreatorDetailCellIdentifier = @"CreatorDetailCell";
    CreatorDetailCell* cell = nil;
    cell = (CreatorDetailCell*)[tableView dequeueReusableCellWithIdentifier:CreatorDetailCellIdentifier];
    
    if (cell == nil) {
        NSArray* arrAllObjects = [[NSBundle mainBundle] loadNibNamed:@"CreatorDetailCell" owner:self options:nil];
        if (arrAllObjects) {
            for (id object in arrAllObjects) {
                if ([object isKindOfClass:[CreatorDetailCell class]]) {
                    cell = (CreatorDetailCell*)object;
                    break;
                }
            }
        }
    }
    cell.creatorName.text = self.task.name;
    cell.createdDate.text = [NSString stringWithFormat:@"Created: %@",self.task.CreatedOnTimeString];
    cell.markComplete.hidden = (self.task.taskStatus == TaskStatusCompleted) || !(self.task.CanEdit || self.task.CanEditAssignee);
    cell.markCompleteLbl.hidden = cell.markComplete.hidden;
    [cell.markComplete addTarget:self action:@selector(markCompleteAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.markComplete.userInteractionEnabled = self.task.CanEditAssignee||self.task.CanEdit;
    cell.markComplete.selected = [self.task taskStatus]==TaskStatusCompleted?YES:NO;
    [cell.creatorImage loadImageFromURL:self.task.creator.MobileImageUrl];
    
    cell.locationBtn.hidden = !self.task.location;
    [cell.locationBtn addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size = [cell.createdDate.text sizeWithFont:cell.createdDate.font constrainedToSize:CGSizeMake(FLT_MAX, cell.createdDate.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect rect1 = cell.createdDate.frame;
    rect1.size.width = MIN(size.width,IS_IPAD?180:155);
    [cell.createdDate setFrame:rect1];
    
    CGRect rect3 = cell.locationBtn.frame;
    rect3.origin.x = (rect1.origin.x + rect1.size.width) + 3;
    [cell.locationBtn setFrame:rect3];
    
    return cell;
}

-(void)showMap:(UIButton*)sender
{
    Task* task = [[[TaskDocument sharedInstance] homeFeeds] objectAtIndex:sender.tag];
    MapVC* vc = [[MapVC alloc] initWithNibName:@"MapVC" bundle:nil];
    vc.location = self.task.location;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
   [self.tblView reloadData];
    CGPoint superPoint = self.commentCntLbl.superview.center;
    CGPoint point = self.commentCntLbl.center;
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        point.x = superPoint.x +14;
    }
    else
    {
        point.x = superPoint.x - 70;
    }
    [self.commentCntLbl setCenter:point];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}


- (void)openReminderEditor:(TaskSubDetailsCell*)cell
{
    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeSingle CalendarModeType:CalendarModeTypeReminder];
    kal.selectedDate = self.task.AutoReminder.ReminderStartDate;
    [kal setReminderWithType:[self.task.AutoReminder getDaysFrequencyString]];
    
    kal.delegate = self;
    kal.dataSource = nil;
    kal.minAvailableDate = [NSDate date];
    kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateCancelAction:)];
    
    UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setReminderDateAction:)];
    [setItem setWidth:50.0];
    UIBarButtonItem* clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(clearReminderDateAction:)];
    kal.navigationItem.rightBarButtonItems = @[setItem,clearItem];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:kal];
    if(DEVICE_IS_TABLET)
    {
        //kal.view.frame = CGRectMake(0, 0, 320, 560);
        datePopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        [datePopover setPopoverContentSize:CGSizeMake(320, 560)];
        datePopover.delegate = self;
        [datePopover presentPopoverFromRect:cell.reminderBtn.frame inView:cell.reminderBtn.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
    else
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)setDateAction:(UIBarButtonItem*)item
{
    if(DEVICE_IS_TABLET)
    {
        [datePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
//    NSMutableDictionary* thirdObject = [contentArray lastObject];
//    if(NSSTRING_HAS_DATA( value))
//        [thirdObject setObject:value forKey:@"name"];
//    else
//        [thirdObject setObject:@"None" forKey:@"name"];
    [_tblView reloadData];
    datePopover = nil;
    kal = nil;
}

- (void)clearDateAction:(UIBarButtonItem*)item
{
    if(DEVICE_IS_TABLET)
    {
        [datePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
   // NSMutableDictionary* thirdObject = [contentArray lastObject];
  //  [thirdObject setObject:@"None" forKey:@"name"];
    [_tblView reloadData];
}

- (void)dateCancelAction:(UIBarButtonItem*)item
{
    if(DEVICE_IS_TABLET)
    {
        [datePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)setReminderDateAction:(UIBarButtonItem*)item
{
    if(self.task.AutoReminder == nil)
        self.task.AutoReminder = [AutoReminder new];
    
    if([kal isAutoReminderOn])
    {
        [self.task.AutoReminder setDaysFrequencyFromString:[kal reminderFrequency]];
    }
    self.task.AutoReminder.ReminderStartDate = [kal selectedDate];
    //    if([_autoReminder.ReminderStartDate isEqual:[kal selectedDate]])
    //        _autoReminder.IsReminderToday = YES;
    //    else
    //        _autoReminder.IsReminderToday = NO;
    
    
    if(DEVICE_IS_TABLET)
    {
        [datePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    datePopover = nil;
    kal = nil;
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setReminderNotifier:) name:@"SetReminderNotifier" object:nil];
    [[TaskDocument sharedInstance] setReminder:self.task.AutoReminder forTaskId:self.task];
}

- (void)clearReminderDateAction:(UIBarButtonItem*)item
{
    if(DEVICE_IS_TABLET)
    {
        [datePopover dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeReminderNotifier:) name:@"RemoveReminderNotifier" object:nil];
    [[TaskDocument sharedInstance] removeReminder:self.task.AutoReminder forTaskId:self.task];
}

- (void)setReminderNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(setReminderCallBack:) withObject:[note object] waitUntilDone:NO];
}

-(void)setReminderCallBack:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[AutoReminder class]])
    {
        self.task.HasReminder = YES;
        [_tblView reloadData];
        [self.view makeToast:@"Reminder has set successfully."];
        
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)removeReminderNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(removeReminderCallBack:) withObject:[note object] waitUntilDone:NO];
}

-(void)removeReminderCallBack:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[AutoReminder class]])
    {
        self.task.AutoReminder =  nil;
        self.task.HasReminder = NO;
        [_sections removeObject:[NSNumber numberWithInt:REMINDER_SETION]];
        [_tblView reloadData];
        [self.view makeToast:@"Reminder has removed successfully."];
        
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (NSDate*)defaultReminderDate
{
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour:0];
    [components setMinute: 0];
    [components setSecond: 1];
    NSDate *startDate = [gregorian dateFromComponents: components];
    return startDate;
}

@end
