//
//  MeetingDetailVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "MeetingDetailVC.h"
#import "CreatorDetailCell.h"
#import "TaskSubDetailsCell.h"
#import "EventDocument.h"
#import "CommentVC.h"
#import "Comment.h"
#import "AttachmentCell.h"
#import "ShowAttachmentVC.h"
#import "TaskUserCell.h"



#define INTRO_SETION            0
#define DESCRIPTION_SETION      1
#define ATTACHMENT_SETION       2


@interface MeetingDetailVC ()
{
    NSMutableArray* _sections;
    UIPopoverController* datePopover;
}
@property (nonatomic, assign)BOOL isExpanded;
@property(nonatomic, retain)UIButton* markCompleteBtn;
-(IBAction)openComment;
-(IBAction)gotItAction;
-(IBAction)nudgeAction;
-(IBAction)btnTabChangePressed:(UIButton*)sender;
@end



@implementation MeetingDetailVC

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
    self.navigationItem.title = @"Meeting Details";
    
    [self reloadData];
}



- (void)getTaskDetailCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openTaskDetailScreen:) withObject:[note object] waitUntilDone:NO];
}


- (void)reloadData
{
    [_sections removeAllObjects];
    [_sections addObject:[NSNumber numberWithInt:INTRO_SETION]];
    if(NSSTRING_HAS_DATA( self.meeting.Description))
        [_sections addObject:[NSNumber numberWithInt:DESCRIPTION_SETION]];
    if(self.meeting.MeetingAttachments && self.meeting.MeetingAttachments.count)
        [_sections addObject:[NSNumber numberWithInt:ATTACHMENT_SETION]];
    [self.tblView reloadData];

}


-  (IBAction)openComment
{
    CommentVC* vc = [[CommentVC alloc] initWithNibName:@"CommentVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
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
            
                NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.meeting.Description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
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
            for(Attachment* attachment in self.meeting.MeetingAttachments)
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
        [(AttachmentCell*)cell fillDataWithAttachments:self.meeting.MeetingAttachments];
    }
    else if(index == DESCRIPTION_SETION)
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
                    NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.meeting.Description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:&dict error:nil];
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
    cell.creatorName.text = self.meeting.CreatorDetails.FormattedName;
    cell.createdDate.text = [NSString stringWithFormat:@"Created: %@",[[self.meeting.CreatedOnTimeString componentsSeparatedByString:@"|"] firstObject]];
    cell.markCompleteLbl.hidden = YES;
    cell.markComplete.hidden = YES;
    [cell.creatorImage loadImageFromURL:self.meeting.CreatorDetails.MobileImageUrl];
    return cell;
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
@end
