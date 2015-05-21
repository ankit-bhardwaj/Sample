//
//  PortfolioDetailVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 4/7/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "PortfolioDetailVC.h"
#import "TaskDocument.h"
#import "CreatePortfolioVC.h"
#import "TaskSubDetailsCell.h"
#import "AttachmentCell.h"
#import "TaskUserCell.h"
#import "CreatorDetailCell.h"

#define INTRO_SETION            0
#define DESCRIPTION_SETION      1
#define ATTACHMENT_SETION       2
#define PORTFOLIO_SECTION        3

#define PROJECTS_SECTION        4
#define USER_SETION             5


@interface PortfolioDetailVC ()
{
    NSMutableArray* _sections;
}
@property (nonatomic, assign)BOOL isExpanded;

@end

@implementation PortfolioDetailVC

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
    if(self.portfolioType == DetailTypePortfolio)
    {
        self.navigationItem.title = @"Portfolio Details";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDetailCallBack:) name:@"GetPortfolioNotifier" object:nil];
        [[TaskDocument sharedInstance] getPortfolio:self.selectedPortfolio];
    }
    else
    {
        self.navigationItem.title = @"Project Details";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDetailCallBack:) name:@"GetProjectNotifier" object:nil];
        [[TaskDocument sharedInstance] getProject:self.selectedProject];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
    
    
    [self reloadData];
}

-(void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)getDetailCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openDetailScreen:) withObject:[note object] waitUntilDone:NO];
}

- (void)openDetailScreen:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if([object isKindOfClass:[Portfolio class]])
    {
        Portfolio* portfolio = (Portfolio*)object;
        self.selectedPortfolio = portfolio;
    }
    else if([object isKindOfClass:[Project class]])
    {
        Project* project = (Project*)object;
        self.selectedProject = project;
    }
    [self reloadData];
}

- (void)reloadData
{
    
    [_sections removeAllObjects];
    
    if(self.portfolioType == DetailTypePortfolio)
    {
        [_sections addObject:[NSNumber numberWithInt:INTRO_SETION]];
        if(NSSTRING_HAS_DATA( self.selectedPortfolio.PortfolioDescription))
            [_sections addObject:[NSNumber numberWithInt:DESCRIPTION_SETION]];
        if(self.selectedPortfolio.Projects.count)
            [_sections addObject:[NSNumber numberWithInt:PROJECTS_SECTION]];
        [_sections addObject:[NSNumber numberWithInt:USER_SETION]];
    }
    else
    {
        [_sections addObject:[NSNumber numberWithInt:INTRO_SETION]];
        if(NSSTRING_HAS_DATA( self.selectedProject.ProjectDescription))
            [_sections addObject:[NSNumber numberWithInt:DESCRIPTION_SETION]];
        [_sections addObject:[NSNumber numberWithInt:PORTFOLIO_SECTION]];
        [_sections addObject:[NSNumber numberWithInt:USER_SETION]];
    }
    [self.tblView reloadData];
    
}


-(void)editAction
{
    CreatePortfolioVC* vc = [[CreatePortfolioVC alloc] initWithNibName:@"CreatePortfolioVC" bundle:nil];
    if(self.portfolioType == DetailTypePortfolio)
    {
        vc.portfolioType = EditTypePortfolio;
        vc.selectedPortfolio = self.selectedPortfolio;
    }
    else
    {
        vc.portfolioType = EditTypeProject;
        vc.selectedProject = self.selectedProject;
    }
    [self.navigationController pushViewController:vc animated:YES];
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
    {
        if(self.portfolioType == DetailTypePortfolio)
            return self.selectedPortfolio.UserList.count;
        else
            return self.selectedProject.UserList.count;
    }
    else if(index == PROJECTS_SECTION)
    {
        if(self.portfolioType == DetailTypePortfolio)
            return self.selectedPortfolio.Projects.count;
    }
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
            [title setFont:[UIFont systemFontOfSize:14.0f]];
            [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width - 20, 1)];
            [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
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
            [title setFont:[UIFont systemFontOfSize:14.0f]];
            [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width - 20, 1)];
            [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            [headerView addSubview:title];
            [headerView addSubview:seperator];
            [headerView setBackgroundColor:[UIColor whiteColor]];
            
        }
            break;
            
        case PORTFOLIO_SECTION:{
            
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
            UIImageView* titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,20,20)];
            [titleImage setImage:[UIImage imageNamed:@"projectList_btn.png"]];
            [headerView addSubview:titleImage];
            
            UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, tableView.bounds.size.width - 50, 21)];
            [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            [title setText:@"Portfolio"];
            [title setFont:[UIFont systemFontOfSize:14.0f]];
            [headerView addSubview:title];
            
            UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
            [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            [headerView addSubview:seperator];
            [headerView setBackgroundColor:[UIColor whiteColor]];
            
        }
            break;
        case PROJECTS_SECTION:{
            
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
            UIImageView* titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,20,20)];
            [titleImage setImage:[UIImage imageNamed:@"projectList_btn.png"]];
            UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, tableView.bounds.size.width - 50, 21)];
            [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            [title setFont:[UIFont systemFontOfSize:14.0f]];
            [title setText:@"Projects"];
            UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
            [seperator setBackgroundColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            [headerView addSubview:titleImage];
            [headerView addSubview:title];
            [headerView addSubview:seperator];
            [headerView setBackgroundColor:[UIColor whiteColor]];
            
        }
            break;
       
        case USER_SETION:{
            
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
            UIImageView* titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,8,20,20)];
            [titleImage setImage:[UIImage imageNamed:@"user_list.png"]];
            UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, tableView.bounds.size.width - 50, 21)];
            [title setTextColor:[UIColor colorWithRed:29/255.0 green:153/255.0 blue:202/255.0 alpha:1.0f]];
            [title setFont:[UIFont systemFontOfSize:14.0f]];
            [title setText:@"Visible to"];
            UIView* seperator = [[UIView alloc] initWithFrame:CGRectMake(10, 31, tableView.bounds.size.width-20, 1)];
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
            
            NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.selectedPortfolio?self.selectedPortfolio.PortfolioDescription:self.selectedProject.ProjectDescription dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
            UIFont *font =[UIFont fontWithName:@"Helvetica" size:14.0];
            [attrs addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [attrs length])];
            CGRect paragraphRect = [attrs boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 20, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
            
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
        //[(AttachmentCell*)cell fillDataWithAttachments:self.task.Attachments];
    }
    else if(index == DESCRIPTION_SETION )
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
                NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.selectedPortfolio?self.selectedPortfolio.PortfolioDescription:self.selectedProject.ProjectDescription dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:&dict error:nil];
                NSMutableDictionary* tmp= [NSMutableDictionary dictionary];
                [attrs enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, [attrs length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
                    UIFont *font = (UIFont*)value;
                    [tmp setObject:[font fontDescriptor] forKey:NSStringFromRange(range)];
                }];
                
                for(NSString* r in [tmp allKeys])
                {
                    NSRange range = NSRangeFromString(r);
                    UIFontDescriptor* des = [tmp objectForKey:r];
                    NSString* fontface = [des objectForKey:UIFontDescriptorFaceAttribute];
                    des = [des fontDescriptorWithFamily:@"Helvetica"];
                    des = [des fontDescriptorWithFace:fontface];
                    UIFont* font = [UIFont fontWithDescriptor:des size:14.0];
                    [attrs addAttribute:NSFontAttributeName value:font range:range];
                }
                CGRect paragraphRect = [attrs boundingRectWithSize:CGSizeMake(tableView.bounds.size.width-20, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
                
                rowHeight = paragraphRect.size.height+20;
                ((TaskSubDetailsCell*)cell).subDetailLabel.attributedText =attrs;
                
                
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
        TaskUser* user = [self.selectedPortfolio?self.selectedPortfolio.UserList:self.selectedProject.UserList objectAtIndex:indexPath.row];
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
    cell.creatorName.text = self.selectedPortfolio?self.selectedPortfolio.PortfolioName:self.selectedProject.ProjectName;
    cell.createdDate.text = [NSString stringWithFormat:@"Created: %@",self.selectedPortfolio?self.selectedPortfolio.CreatedDateString:self.selectedProject.CreatedDateString];
    cell.markComplete.hidden = YES;
    cell.markCompleteLbl.hidden = YES;
    [cell.creatorImage loadImageFromURL:self.selectedPortfolio?self.selectedPortfolio.Owner.UserProfile.MobileImageUrl:self.selectedProject.Owner.UserProfile.MobileImageUrl];
    
    cell.locationBtn.hidden = YES;
    
    CGSize size = [cell.createdDate.text sizeWithFont:cell.createdDate.font constrainedToSize:CGSizeMake(FLT_MAX, cell.createdDate.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect rect1 = cell.createdDate.frame;
    rect1.size.width = MIN(size.width,IS_IPAD?180:155);
    [cell.createdDate setFrame:rect1];
    
    CGRect rect3 = cell.locationBtn.frame;
    rect3.origin.x = (rect1.origin.x + rect1.size.width) + 3;
    [cell.locationBtn setFrame:rect3];
    
    return cell;
}

@end
