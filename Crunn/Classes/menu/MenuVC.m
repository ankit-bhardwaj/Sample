//
//  LeftViewController.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "MenuVC.h"
#import "UserDocument.h"
#import "GSAsynImageView.h"
#import "MMDrawerController.h"
#import "HomeVC.h"
#import "RecentFeedVC.h"
#import "TaskDocument.h"
#import "UIImage+Additions.h"
#import "CreatePortfolioVC.h"
#import "ManagePortfolioUserVC.h"
#import "MyTaskVC.h"
#import "PortfolioUserVC.h"
#import "MyMeetingsVC.h"
#import "LocationService.h"

#define HOME_SECTION        0
#define MY_TASKS_SECTION    1
#define PRIVATE_SECTION     2
#define RECTENT_SECTION     3
#define PORTFOLIO_SECTION   4
#define SETTINGS_SECTION    5
#define MEETING_SECTION     7

@interface MenuVC (){

    IBOutlet UITableView* leftTableView;
    IBOutlet UILabel* userName;
    IBOutlet UISwitch* pushSwitch;
    NSArray* homeItems;
    NSArray* myTasksItems;
    NSArray* privateMsgItems;
    NSArray* recentActivityItems;
    NSMutableArray* portfoliosItems;
    NSMutableArray* myMeetingItems;

    NSMutableDictionary* _portfolioViewState;
    NSMutableArray* settingsItems;
    IBOutlet GSAsynImageView* imageView;
    
    UIButton* _selectedMenuBtn;
}
@property(nonatomic,retain)NSIndexPath* selectedIndexPath;
@property(nonatomic,retain)NSString* selectedRowTitle;
@end

@implementation MenuVC

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
    
    _portfolioViewState = [[NSMutableDictionary alloc] init];
    [leftTableView setTableFooterView:[UIView new]];

    homeItems = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Home",@"title",@"menuHome.png",@"icon", nil],nil] ;
    myTasksItems = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"My Tasks",@"title",@"menuMyTasks.png",@"icon", nil],nil] ;
    
    privateMsgItems = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Private Messages (coming soon)",@"title",@"menuPrivateMessages.png",@"icon", nil],nil] ;
    
    recentActivityItems = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Recent Activity",@"title",@"menuReventActivity.png",@"icon", nil],nil] ;
    
    portfoliosItems = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"My Portfolios",@"title",@"menuMyPortfolio.png",@"icon", nil], nil];
    
    myMeetingItems = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"My Meetings",@"title",@"menuMyMeeting.png",@"icon", nil], nil];
    
    settingsItems = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Settings",@"title",@"menuSettings.png",@"icon", nil], nil];
    [settingsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Notifications",@"title",@"menuNotifications.png",@"icon", [NSNumber numberWithBool:YES],@"subrow",nil]];
    if([User currentUser].IsSubscribed)
        [settingsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Send my location",@"title",@"menuLocation.png",@"icon", [NSNumber numberWithBool:YES],@"subrow",nil]];
    [settingsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Signout",@"title",[NSNumber numberWithBool:NO],@"subrow", nil]];
    
    userName.text = [User currentUser].FormattedName;
    // Do any additional setup after loading the view from its nib.
    imageView.image = [UIImage imageNamed:@"avatar.png"];
    NSString* halfPhotoUrl = [User currentUser].MobileImageUrl;
    if(NSSTRING_HAS_DATA(halfPhotoUrl))
    {
        [imageView loadImageFromURL:halfPhotoUrl];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotifierCallBack:) name:@"PushNotifier" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectListCallBack:) name:@"ProjectListNotifier" object:nil];
    
    [[TaskDocument sharedInstance] getProjectList];
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.selectedRowTitle = @"Home";
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftTableView.bounds.size.width, 40)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont boldSystemFontOfSize:14.0]];
    [lbl setTextColor:[UIColor whiteColor]];
    [leftTableView setTableFooterView:lbl];
    [lbl setTextAlignment:NSTextAlignmentRight];
    NSString* appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [lbl setText:[NSString stringWithFormat:@"Version %@",appVersionString]];
    
    [self reloadview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[TaskDocument sharedInstance] getProjectList];
}


- (void)projectListCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadview) withObject:nil waitUntilDone:NO];
}

- (void)reloadview
{
    [portfoliosItems removeAllObjects];
    [portfoliosItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"My Portfolios",@"title",@"menuMyPortfolio.png",@"icon", nil]];
    for(Portfolio* portfolio in [[TaskDocument sharedInstance] portfolios])
    {
        [portfoliosItems addObject:portfolio];
        if(![_portfolioViewState objectForKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]])
            [_portfolioViewState setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]];
        BOOL flag = [[_portfolioViewState objectForKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]] boolValue];
        if(flag)
            [portfoliosItems addObjectsFromArray:portfolio.Projects];
    }
    [leftTableView reloadData];
}

- (void)reloadPortfolio
{
    [portfoliosItems removeAllObjects];
    [portfoliosItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"My Portfolios",@"title",@"menuMyPortfolio.png",@"icon", nil]];
    for(Portfolio* portfolio in [[TaskDocument sharedInstance] portfolios])
    {
        [portfoliosItems addObject:portfolio];
        if(![_portfolioViewState objectForKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]])
            [_portfolioViewState setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]];
        BOOL flag = [[_portfolioViewState objectForKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]] boolValue];
        if(flag)
            [portfoliosItems addObjectsFromArray:portfolio.Projects];
    }
    [leftTableView beginUpdates];
    [leftTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [leftTableView numberOfSections])] withRowAnimation:UITableViewRowAnimationFade];
    [leftTableView endUpdates];
}


- (void)pushNotifierCallBack:(NSNotification*)note
{
    [leftTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case HOME_SECTION:
            return [homeItems count];
            break;
        case MY_TASKS_SECTION:
            return [myTasksItems count];
            break;
        case PRIVATE_SECTION:
            return [privateMsgItems count];
            break;
        case RECTENT_SECTION:
            return [recentActivityItems count];
            break;
        case PORTFOLIO_SECTION:
            return [portfoliosItems count];
            break;
        case MEETING_SECTION:
            return [myMeetingItems count];
            break;
        case SETTINGS_SECTION:
            return [settingsItems count];
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
    [v setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:136.0/255.0 blue:139.0/255.0 alpha:1.0]];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 4)
    {
        id d = [portfoliosItems objectAtIndex:indexPath.row];
        if([d isKindOfClass:[Project class]])
        {
            return 32.0;
        }
    }
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    cell.accessoryView = nil;
    
    UIButton* selectedBg = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectedBg addTarget:self action:@selector(rowSelected:) forControlEvents:UIControlEventTouchUpInside];
    [selectedBg setFrame:CGRectMake(0, 5,  250, 40-10)];
    [selectedBg setTag:1001];
    [cell.contentView addSubview:selectedBg];
    objc_setAssociatedObject(selectedBg, "SelctedIndexPath", indexPath, OBJC_ASSOCIATION_RETAIN);
    
    
    if(indexPath.section == HOME_SECTION)
    {
        NSDictionary* d = [homeItems objectAtIndex:indexPath.row];
        BOOL subrow = [[d objectForKey:@"subrow"] boolValue];
        
        cell.textLabel.text = [d objectForKey:@"title"];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
        [imgView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:imgView];
        imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
        
        if(subrow){cell.indentationLevel = 6;imgView.frame = CGRectMake(30, 10, 20, 20);}
        else cell.indentationLevel = 3;
    }
    else if(indexPath.section == MY_TASKS_SECTION)
    {
        NSDictionary* d = [myTasksItems objectAtIndex:indexPath.row];
        BOOL subrow = [[d objectForKey:@"subrow"] boolValue];
        
        cell.textLabel.text = [d objectForKey:@"title"];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
        [imgView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:imgView];
        imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
        
        if(subrow){cell.indentationLevel = 6;imgView.frame = CGRectMake(30, 10, 20, 20);}
        else cell.indentationLevel = 3;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //selectedBg.hidden = YES;
    }
    else if(indexPath.section == PRIVATE_SECTION)
    {
        NSDictionary* d = [privateMsgItems objectAtIndex:indexPath.row];
        BOOL subrow = [[d objectForKey:@"subrow"] boolValue];
        
        cell.textLabel.text = [d objectForKey:@"title"];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
        [imgView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:imgView];
        imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
        
        if(subrow){cell.indentationLevel = 6;imgView.frame = CGRectMake(30, 10, 20, 20);}
        else cell.indentationLevel = 3;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        selectedBg.hidden = YES;
    }
    else if(indexPath.section == RECTENT_SECTION)
    {
        NSDictionary* d = [recentActivityItems objectAtIndex:indexPath.row];
        BOOL subrow = [[d objectForKey:@"subrow"] boolValue];
        
        cell.textLabel.text = [d objectForKey:@"title"];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
        [imgView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:imgView];
        imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
        
        if(subrow){cell.indentationLevel = 6;imgView.frame = CGRectMake(30, 10, 20, 20);}
        else cell.indentationLevel = 3;
    }
    else if(indexPath.section == PORTFOLIO_SECTION)
    {
        if(indexPath.row == 0)
        {
            NSDictionary* d = [portfoliosItems objectAtIndex:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = [d objectForKey:@"title"];
            cell.indentationLevel = 3;
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
            [imgView setContentMode:UIViewContentModeCenter];
            [cell.contentView addSubview:imgView];
            imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
            
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(tableView.bounds.size.width - 100, 0, 40 , 40)];
            [btn setImage:[UIImage imageNamed:@"add_portfolio.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(addPortfolios:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            selectedBg.hidden = YES;
            
        }
        else
        {
            id d = [portfoliosItems objectAtIndex:indexPath.row];
            if([d isKindOfClass:[Portfolio class]])
            {
                Portfolio* portfolio = (Portfolio*)d;
                NSString* str = [portfolio PortfolioName];
                if([str length] < 18)
                    cell.textLabel.text = str;
                else
                    cell.textLabel.text = [str stringByReplacingCharactersInRange:NSMakeRange(18, [str length]-18) withString:@"..."];
                cell.indentationLevel = 4.0;
                
                UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(0, 0, 20 , 40)];
                [btn setImage:[UIImage imageNamed:@"arrow_up.png"] forState:UIControlStateSelected];
                [btn setImage:[UIImage imageNamed:@"arrow_down.png"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(togglePortfolio:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = btn;
                btn.tag = indexPath.row;
                btn.selected = [[_portfolioViewState objectForKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]] boolValue];
                [selectedBg setFrame:CGRectMake(30, 5, tableView.bounds.size.width-105, 40-10)];
                UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(30, 0, tableView.bounds.size.width, 1)];
                [sep setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:136.0/255.0 blue:139.0/255.0 alpha:1.0]];
                [cell.contentView addSubview:sep];
                
                UIButton* addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [addBtn setFrame:CGRectMake(tableView.bounds.size.width - 80, 0, 40 , 40)];
                [addBtn setImage:[UIImage imageNamed:@"menu_settings.png"] forState:UIControlStateNormal];
                [addBtn addTarget:self action:@selector(addProject:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:addBtn];
                objc_setAssociatedObject(addBtn, "portfolio", portfolio, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            else if([d isKindOfClass:[Project class]])
            {
                cell.indentationLevel = 5;
                cell.accessoryView = nil;
                UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(50, 1, tableView.bounds.size.width, 1)];
                [sep setBackgroundColor:[UIColor colorWithRed:132.0/255.0 green:136.0/255.0 blue:139.0/255.0 alpha:1.0]];
                [cell.contentView addSubview:sep];
                [selectedBg setFrame:CGRectMake(45, 4, tableView.bounds.size.width-85, 32-8)];
                Project* p = (Project*)d;
                if(NSSTRING_HAS_DATA([p ProjectName]))
                {
                    cell.textLabel.text = [p ProjectName];
                    UIButton* addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    [addBtn setFrame:CGRectMake(0, 0, 20, 32)];
                    [addBtn setImage:[UIImage imageNamed:@"menu_settings.png"] forState:UIControlStateNormal];
                    [addBtn addTarget:self action:@selector(projectSettingAction:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = addBtn;
                    objc_setAssociatedObject(addBtn, "project", p, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
                else
                {
                    selectedBg.hidden = YES;
                    cell.textLabel.text = @"No Project";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                
            }
        }
        
    }
    else if(indexPath.section == MEETING_SECTION)
    {
        NSDictionary* d = [myMeetingItems objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [d objectForKey:@"title"];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
        [imgView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:imgView];
        imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
    }
    else if(indexPath.section == SETTINGS_SECTION)
    {
        NSDictionary* d = [settingsItems objectAtIndex:indexPath.row];
        if(indexPath.row == 0)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            selectedBg.hidden = YES;
        }
        else if(indexPath.row == 1)
        {
            UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 22)];
            [sw addTarget:self action:@selector(pushToggle:) forControlEvents:UIControlEventValueChanged];
            BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:@"PushEnabled"];
            [sw setOn:flag];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            selectedBg.hidden = YES;
        }
        else if(indexPath.row == 2 && [User currentUser].IsSubscribed)
        {
            UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 22)];
            [sw addTarget:self action:@selector(pushLocationToggle:) forControlEvents:UIControlEventValueChanged];
            BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"];
            [sw setOn:flag];
            cell.accessoryView = sw;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            selectedBg.hidden = YES;
        }
        else
        {
            selectedBg.hidden = NO;
            [selectedBg setFrame:CGRectMake(0, 4, 250, 32-8)];
        }
        BOOL subrow = [[d objectForKey:@"subrow"] boolValue];
        
        cell.textLabel.text = [d objectForKey:@"title"];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 29, 23)];
        [imgView setContentMode:UIViewContentModeCenter];
        [cell.contentView addSubview:imgView];
        imgView.image = [UIImage imageNamed:[d objectForKey:@"icon"]];
        if(subrow){cell.indentationLevel = 5;imgView.frame = CGRectMake(30, 10, 20, 20);}
        else cell.indentationLevel = 3;
    }
    
    [selectedBg setImage:[UIImage imageWithColor:[UIColor clearColor] andSize:selectedBg.frame.size] forState:UIControlStateNormal];
    [selectedBg setImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.0 alpha:0.6] andSize:selectedBg.frame.size] forState:UIControlStateSelected];
    
    if([self.selectedRowTitle isEqualToString:cell.textLabel.text] && [self.selectedIndexPath isEqual:indexPath])
        [selectedBg setSelected:YES];
    else
        selectedBg.selected = NO;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)rowSelected:(UIButton*)btn
{
    btn.selected = YES;
    NSIndexPath* indexpath = objc_getAssociatedObject(btn, "SelctedIndexPath");
    [self tableView:leftTableView selectRowAtIndexPath:indexpath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView selectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.selectedIndexPath)
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        UIButton* selectedBg = (UIButton*)[cell.contentView viewWithTag:1001];
        selectedBg.selected = NO;
    }
    self.selectedIndexPath = indexPath;
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedRowTitle = cell.textLabel.text;
    
    MMDrawerController* drwayer = [APPDELEGATE drawerController];
    UINavigationController * navigationController = drwayer.centerViewController;
    if(indexPath.section == HOME_SECTION)
    {
        [[TaskDocument sharedInstance] getHomeFeedForPortfolio:nil andProject:nil];
        UIViewController *centerViewController = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
        [navigationController setViewControllers:[NSArray arrayWithObject:centerViewController]];
        [drwayer setCenterViewController:navigationController withCloseAnimation:YES completion:^(BOOL finished) {
            
        }];
    }
    else if(indexPath.section == MY_TASKS_SECTION)
    {
        [TaskDocument sharedInstance].selectedPortfolio = nil;
        [TaskDocument sharedInstance].selectedProject = nil;

        [[TaskDocument sharedInstance] refreshMyTasks];
        UIViewController *centerViewController = [[MyTaskVC alloc] initWithNibName:@"MyTaskVC" bundle:nil];
        [navigationController setViewControllers:[NSArray arrayWithObject:centerViewController]];
        [drwayer setCenterViewController:navigationController withCloseAnimation:YES completion:^(BOOL finished) {
            
        }];
    }
    else if(indexPath.section == PRIVATE_SECTION)
    {
    }
    else if(indexPath.section == RECTENT_SECTION)
    {
        UIViewController *centerViewController = [[RecentFeedVC alloc] initWithNibName:@"RecentFeedVC" bundle:nil];
        navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
        [drwayer setCenterViewController:navigationController withCloseAnimation:YES completion:^(BOOL finished) {
            
        }];
    }
    else if(indexPath.section == PORTFOLIO_SECTION)
    {
        if(indexPath.row == 0)
            return;
        Project* project = nil;
        Portfolio* portfolio = nil;
        if(indexPath.row != 0)
        {
            id d = [portfoliosItems objectAtIndex:indexPath.row];
            if([d isKindOfClass:[Project class]])
            {
                project = (Project*)d;
                portfolio = project.portfolio;
            }
            else
                portfolio = (Portfolio*)d;
        }
       [[TaskDocument sharedInstance] getHomeFeedForPortfolio:portfolio andProject:project];
        UIViewController *centerViewController = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
        [navigationController setViewControllers:[NSArray arrayWithObject:centerViewController]];
        [drwayer setCenterViewController:navigationController withCloseAnimation:YES completion:^(BOOL finished) {
            
        }];
    }
    else if(indexPath.section == MEETING_SECTION)
    {
        UIViewController *centerViewController = [[MyMeetingsVC alloc] initWithNibName:@"MyMeetingsVC" bundle:nil];
        [navigationController setViewControllers:[NSArray arrayWithObject:centerViewController]];
        [drwayer setCenterViewController:navigationController withCloseAnimation:YES completion:^(BOOL finished) {
            
        }];
    }
    else if(indexPath.section == SETTINGS_SECTION)
    {
        if(indexPath.row > 1)
        {
            [User resetCurrentUser];
            [[UserDocument sharedInstance] enablePushNotification:NO];
            [LocationService stop];
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PushEnabled"];
            //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LocationEnabled"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"userLoggedIn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[TaskDocument sharedInstance] purgePrivateData];
            [APPDELEGATE loadLoginView];
        }
    }
}

- (void)togglePortfolio:(UIButton*)btn
{
    Portfolio* portfolio = [portfoliosItems objectAtIndex:btn.tag];
    btn.selected = !btn.selected;
    for(NSString* key in [_portfolioViewState allKeys])
    {
        [_portfolioViewState setObject:[NSNumber numberWithBool:NO] forKey:key];
    }
    [_portfolioViewState setObject:[NSNumber numberWithBool:btn.selected] forKey:[NSString stringWithFormat:@"%d",portfolio.PortfolioId]];
    [self reloadPortfolio];
}

- (void)addPortfolios:(UIButton*)btn
{
    MMDrawerController* drwayer = [APPDELEGATE drawerController];
    [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
        CreatePortfolioVC* vc = [[CreatePortfolioVC alloc] initWithNibName:@"CreatePortfolioVC" bundle:nil];
        vc.portfolioType = CreateTypePortfolio;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
            
        }];
    }];
    
    
}

- (void)addProject:(UIButton*)btn
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _selectedMenuBtn = btn;
    Portfolio* portfolio = objc_getAssociatedObject(btn, "portfolio");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector   (getPortfolioUserListCallBack:) name:@"GetPortfolioNotifier" object:nil];
    [[TaskDocument sharedInstance] getPortfolio:portfolio];
}

- (void)getPortfolioUserListCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openPortfolioMenu:) withObject:[note object] waitUntilDone:NO];
}

- (void)openPortfolioMenu:(id)note
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    Portfolio* portfolio = note;
    if(portfolio && [portfolio isKindOfClass:[Portfolio class]])
    {
        UIActionSheet* sheet = nil;
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        
        if(portfolio.CurrentUserCanAddProject || portfolio.PortfolioId == -1)
            [sheet addButtonWithTitle:@"Create Project"];
        
        if(portfolio.CurrentUserCanAddOtherUsers || portfolio.PortfolioId == -1)
            [sheet addButtonWithTitle:@"Manage Members"];
        else
            [sheet addButtonWithTitle:@"View Members"];
        
        if(portfolio.CurrentUserCanEditPortfolio)
            [sheet addButtonWithTitle:@"Edit Portfolio"];
        [sheet addButtonWithTitle:@"Cancel"];
        
        [sheet setCancelButtonIndex:[sheet numberOfButtons]-1];
        
        [sheet setTag:1000];
        MMDrawerController* drwayer = [APPDELEGATE drawerController];
        if(DEVICE_IS_TABLET)
        {
            CGRect rect = _selectedMenuBtn.frame;
            [sheet showFromRect:rect inView:_selectedMenuBtn.superview animated:YES];
        }
        else
            [sheet showInView:drwayer.view];
        objc_setAssociatedObject(sheet, "portfolio", portfolio, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
}

- (void)projectSettingAction:(UIButton*)btn
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _selectedMenuBtn = btn;
    Project* project = objc_getAssociatedObject(btn, "project");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector   (getProjectUserListCallBack:) name:@"GetProjectNotifier" object:nil];
    [[TaskDocument sharedInstance] getProject:project];
}

- (void)getProjectUserListCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openProjectMenu:) withObject:[note object] waitUntilDone:NO];
}

- (void)openProjectMenu:(id)note
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    Project* project = note;
    if(project && [project isKindOfClass:[Project class]])
    {
        UIActionSheet* sheet = nil;
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
        
        if(project.CurrentUserCanAddOtherUsers)
            [sheet addButtonWithTitle:@"Manage Members"];
        else
            [sheet addButtonWithTitle:@"View Members"];
        
        if(project.CurrentUserCanEditProject)
            [sheet addButtonWithTitle:@"Edit Project"];
        
        [sheet addButtonWithTitle:@"Cancel"];
        
        [sheet setCancelButtonIndex:[sheet numberOfButtons]-1];
        [sheet setTag:1001];
        
        MMDrawerController* drwayer = [APPDELEGATE drawerController];
        if(DEVICE_IS_TABLET)
        {
            CGRect rect = _selectedMenuBtn.frame;
            [sheet showFromRect:rect inView:_selectedMenuBtn.superview animated:YES];
        }
        else
            [sheet showInView:drwayer.view];
        objc_setAssociatedObject(sheet, "project", project, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1000)
    {
        Portfolio* portfolio = objc_getAssociatedObject(actionSheet, "portfolio");
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create Project"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                CreatePortfolioVC* vc = [[CreatePortfolioVC alloc] initWithNibName:@"CreatePortfolioVC" bundle:nil];
                vc.portfolioType = CreateTypeProject;
                vc.selectedPortfolio= portfolio;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Manage Members"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                ManagePortfolioUserVC* vc = [[ManagePortfolioUserVC alloc] initWithNibName:@"ManagePortfolioUserVC" bundle:nil];
                vc.portfolioUserType = ManagePortfolioUserTypePortfolio;
                vc.portfolio= portfolio;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Members"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                PortfolioUserVC* vc = [[PortfolioUserVC alloc] initWithNibName:@"PortfolioUserVC" bundle:nil];
                vc.portfolioUserType = PortfolioUserTypePortfolio;
                vc.portfolio= portfolio;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit Portfolio"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                CreatePortfolioVC* vc = [[CreatePortfolioVC alloc] initWithNibName:@"CreatePortfolioVC" bundle:nil];
                vc.portfolioType = EditTypePortfolio;
                vc.selectedPortfolio= portfolio;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
        
    }
    else if(actionSheet.tag == 1001)
    {
        Project* project = objc_getAssociatedObject(actionSheet, "project");
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Manage Members"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                ManagePortfolioUserVC* vc = [[ManagePortfolioUserVC alloc] initWithNibName:@"ManagePortfolioUserVC" bundle:nil];
                vc.portfolioUserType = ManagePortfolioUserTypeProject;
                vc.project= project;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Members"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                PortfolioUserVC* vc = [[PortfolioUserVC alloc] initWithNibName:@"PortfolioUserVC" bundle:nil];
                vc.portfolioUserType = PortfolioUserTypeProject;
                vc.project= project;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit Project"])
        {
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            [drwayer setCenterViewController:drwayer.centerViewController withCloseAnimation:YES completion:^(BOOL finished) {
                CreatePortfolioVC* vc = [[CreatePortfolioVC alloc] initWithNibName:@"CreatePortfolioVC" bundle:nil];
                vc.portfolioType = EditTypeProject;
                vc.selectedProject= project;
                vc.selectedPortfolio = project.portfolio;
                UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
                //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [drwayer.centerViewController presentViewController:navVC animated:YES completion:^{
                    
                }];
            }];
        }
    }
    objc_removeAssociatedObjects(actionSheet);
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

- (void)pushToggle:(UISwitch*)sw
{
    if(sw.on)
    {
        [[UserDocument sharedInstance] enablePushNotification:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PushEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[UserDocument sharedInstance] enablePushNotification:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PushEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)pushLocationToggle:(UISwitch*)sw
{
    if(sw.on)
    {
        [LocationService start];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LocationEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [LocationService stop];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LocationEnabled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
