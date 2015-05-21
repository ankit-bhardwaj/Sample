//
//  RightViewController.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "RecentFeedVC.h"
#import "TaskDocument.h"
#import "CreateTaskVC.h"
#import "Activity.h"
#import "RecentActivityCell.h"
#import "GetMoreTableFooter.h"
#import "CommentVC.h"
#import "CustomBadge.h"

@interface RecentFeedVC ()
{
    IBOutlet UITableView* tableView;
    GetMoreTableFooter *_getFooterView;
    UIImageView* _cruunLogo;
    CustomBadge* badgeView;
}
@end

@implementation RecentFeedVC

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
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer * twoFingerDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerDoubleTap:)];
    [twoFingerDoubleTap setNumberOfTapsRequired:2];
    [twoFingerDoubleTap setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:twoFingerDoubleTap];
    
    
    [self setupLeftMenuButton];
    [self setupRightMenuButton];
    
        UIColor * barColor = [UIColor
                              colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  
    
    [tableView registerNib:[UINib nibWithNibName:@"RecentActivityCell" bundle:nil]  forCellReuseIdentifier:@"RecentActivityCell"];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 1001;
    [tableView addSubview:refreshControl];
    [refreshControl beginRefreshing];
    
    _getFooterView = [[GetMoreTableFooter alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [_getFooterView setState:TableFooterNormal];
    [tableView setTableFooterView:_getFooterView];
    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recentActivityCallBack:) name:@"RecentActivityNotifier" object:nil];
    [[TaskDocument sharedInstance] refreshRecentFeed];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)setupRightMenuButton{
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

- (void)notificationTapped:(id)sender
{
    if(!badgeView.hidden)
        [[TaskDocument sharedInstance] refreshHomeFeed];
}

#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _cruunLogo.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _cruunLogo.hidden = YES;
}

-(void)openTaskCreator:(id)sender
{
    CreateTaskVC* vc = [[CreateTaskVC alloc] initWithNibName:@"CreateTaskVC" bundle:nil];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}


-(void)doubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideLeft completion:nil];
}

-(void)twoFingerDoubleTap:(UITapGestureRecognizer*)gesture{
    [self.mm_drawerController bouncePreviewForDrawerSide:MMDrawerSideRight completion:nil];
}

- (void)recentActivityCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadView:) withObject:[note object] waitUntilDone:NO];
}

- (void)reloadView:(NSArray*)tmp
{
    UIRefreshControl* cnt = (UIRefreshControl*)[tableView viewWithTag:1001];
    [cnt endRefreshing];
    
    if(tmp && [tmp isKindOfClass:[NSArray class]] && tmp.count > 0)
    {
        if([TaskDocument sharedInstance].recentActivityIndex > 1)
        {
            [tableView beginUpdates];
            [tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([tableView numberOfSections], [tmp count])] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else
            [tableView reloadData];
    }
    if(![TaskDocument sharedInstance].activities.count)
        [_getFooterView setState:TableFooterNoData];
    else if(!tmp || tmp.count ==0)
        [_getFooterView setState:TableFooterNoMoreData];
}

- (void)refresh:(UIRefreshControl*)control
{
    [control beginRefreshing];
    [[TaskDocument sharedInstance] refreshRecentFeed];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[TaskDocument sharedInstance].activities count];
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity* activity = [[[TaskDocument sharedInstance] activities] objectAtIndex:indexPath.section];
    
    CGSize size;
    
    
    CGRect paragraphRect = [activity.attrSummary boundingRectWithSize:CGSizeMake(tv.bounds.size.width-20, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    size = paragraphRect.size;
    
    return 134+size.height+5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}


/*
 - (CGFloat)textViewHeightForAttributedText:(NSString*)text andWidth: (CGFloat)width {
 UITextView *calculationView = [[UITextView alloc] init];
 [calculationView setText:text];
 CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
 return size.height;
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecentActivityCell";
    RecentActivityCell *cell = (RecentActivityCell*)[tv dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[RecentActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Activity* activity = [[[TaskDocument sharedInstance] activities] objectAtIndex:indexPath.section];
    User* fromUser = activity.ByUserDetail;
    cell.nameLbl.text = fromUser.FormattedName;
    cell.dateLbl.text = [[activity.ActivityDateString componentsSeparatedByString:@"|"] firstObject];
    cell.projectLbl.text = [NSString stringWithFormat:@"%@ | %@",activity.FolderName,fromUser.FormattedName];
    cell.titleLbl.text = activity.TaskDescription;
    [cell.userImageView loadImageFromURL:fromUser.MobileImageUrl];
    if([activity.TotalComments integerValue])
        [cell.commentLbl setText:[activity.TotalComments stringValue]];
    else
        cell.commentLbl.text = @"";
    //cell.commentBtn.enabled = [activity.TotalComments integerValue];
    cell.commentBtn.tag = indexPath.section;
    [cell.commentBtn addTarget:self
                         action:@selector(openComment:) forControlEvents:UIControlEventTouchDown];
 
        
        cell.descriptionLbl.attributedText = activity.attrSummary;
    
    return cell;
}

- (void)openComment:(UIButton*)btn
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    Activity* activity = [[[TaskDocument sharedInstance] activities] objectAtIndex:btn.tag];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTaskDetailCallBack:) name:@"GetTaskDetailNotifier" object:nil];
    [[TaskDocument sharedInstance] getTaskDetailForId:activity.TaskId];
}

- (void)getTaskDetailCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openCommentScreen:) withObject:[note object] waitUntilDone:NO];
}

- (void)openCommentScreen:(Task*)task
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    CommentVC* vc = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:nil];
    [vc setTask:task];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float height = [UIScreen mainScreen].bounds.size.height;
    if(scrollView.contentOffset.y >= (scrollView.contentSize.height - height))
    {
        [_getFooterView setState:TableFooterLoading];
        [[TaskDocument sharedInstance] getRecentFeed];
    }
}

@end
