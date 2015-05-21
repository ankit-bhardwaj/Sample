//
//  MyMeetingDetailVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 2/12/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "MyMeetingDetailVC.h"
#import "Meeting.h"
#import "Comment.h"
#import "CommentCell.h"
#import "MyMeetingSlotCell.h"
#import "GSAsynImageView.h"
#import "TaskFeedFooterView.h"

#import "MeetingCommentVC.h"
#import "MeetingDetailVC.h"
#import "EventDocument.h"

@interface MyMeetingDetailVC ()
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITableView *commentTableView;
    IBOutlet UITableView * meetingSlotsTableView;
    IBOutlet UIView* headerView;
    IBOutlet UILabel* titleLbl;
    IBOutlet UILabel* dateLbl;
    IBOutlet UIView* descriptionView;
    IBOutlet UITextView* noteTxt;
    IBOutlet UIView* meetingSlotsView;
    IBOutlet GSAsynImageView* creatorImage;
    
    IBOutlet UIView* commentPostView;
    IBOutlet UIButton* commentPostBtn;
    
    NSIndexPath* _selectedIndexPath;
    NSMutableArray* _slots;
}
- (IBAction)mettingDetailAction:(id)sender;
- (IBAction)openComments:(id)sender;
@end

@implementation MyMeetingDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString* saveTitle = @"Save";
    SEL action = @selector(saveTaskAction);
    switch ([self.meeting.Status integerValue]) {
        case 0:
            if(self.meeting.CreatorDetails.UserId == [User currentUser].UserId)
            {
                saveTitle = @"Finalize";
                action = @selector(finalizeMeetingAction);
            }
            break;
        case 1:
            saveTitle = @"Done";
            action = @selector(doneAction);
            break;
            
        default:
            break;
    }
    
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:saveTitle style:UIBarButtonItemStylePlain target:self action:action];
    
    UIBarButtonItem * fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBtn,fixedSpace,cancelBtn, nil] animated:YES];
    
    UIImageView* img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cruun_logo.png"]];
    [img setFrame:CGRectMake(0, 0, 150, 35)];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    UIBarButtonItem * logo = [[UIBarButtonItem alloc] initWithCustomView:img];
    [self.navigationItem setLeftBarButtonItem:logo];
    
    _slots = [[NSMutableArray alloc] init];
    
    if([self.meeting.Status integerValue] == 0)
    {
        for(MeetingProposal* proposal in self.meeting.MeetingProposalsList)
        {
            for(MeetingProposalSlot* slot in proposal.MeetingSlotsList)
            {
                [_slots addObject:slot];
                for(MeetingSlotParticipant* slotParticipant in slot.MeetingSlotParticipants)
                {
                    slotParticipant.TmpStatus = slotParticipant.Status;
                }
            }
        }
    }
    else
    {
        for(MeetingProposal* proposal in self.meeting.MeetingProposalsList)
        {
            for(MeetingProposalSlot* slot in proposal.MeetingSlotsList)
            {
                if([slot.Status integerValue] == 1)
                    [_slots addObject:slot];
                for(MeetingSlotParticipant* slotParticipant in slot.MeetingSlotParticipants)
                {
                    slotParticipant.TmpStatus = slotParticipant.Status;
                }
            }
        }
    }
    
    
    
    [commentTableView registerNib:[UINib nibWithNibName:@"CommentCell" bundle:nil]  forCellReuseIdentifier:@"CommentCell"];
    
    [meetingSlotsTableView registerNib:[UINib nibWithNibName:@"MyMeetingSlotCell" bundle:nil]  forCellReuseIdentifier:@"MyMeetingSlotCell"];
    
    [commentTableView registerClass:[TaskFeedFooterView class] forHeaderFooterViewReuseIdentifier:@"TaskFeedFooterView"];
    
    titleLbl.text = self.meeting.Title;
    dateLbl.text = [NSString stringWithFormat:@"Created: %@",[[self.meeting.CreatedOnTimeString componentsSeparatedByString:@"|"] firstObject]];
    
    [creatorImage loadImageFromURL:self.meeting.CreatorDetails.MobileImageUrl];
    
    
    if(!NSSTRING_HAS_DATA(self.meeting.Description))
    {
        descriptionView.hidden =YES;
        CGRect rect = meetingSlotsView.frame;
        rect.origin.y = descriptionView.frame.origin.y;
        rect.size.height = MIN([self.meeting.Status integerValue] == 0?(IS_IPAD?4:3):1,_slots.count)*(95)+10;
        [meetingSlotsView setFrame:rect];
        
        rect = meetingSlotsTableView.frame;
        rect.size.height = meetingSlotsView.frame.size.height - 10;
        [meetingSlotsTableView setFrame:rect];
        
        
        rect = headerView.frame;
        rect.size.height = meetingSlotsView.frame.size.height+meetingSlotsView.frame.origin.y;
        [headerView setFrame:rect];
    }
    else
    {
        noteTxt.text = self.meeting.Description;
        noteTxt.scrollEnabled = NO;
        
        NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.meeting.Description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
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
            UIFont* font = [UIFont fontWithDescriptor:des size:11.0];
            [attrs addAttribute:NSFontAttributeName value:font range:range];
        }
        noteTxt.attributedText = attrs;
        
        CGRect rect = descriptionView.frame;
        CGRect paragraphRect = [attrs boundingRectWithSize:CGSizeMake(noteTxt.bounds.size.width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        rect.size.height = paragraphRect.size.height+20;
        [descriptionView setFrame:rect];
        
        rect = meetingSlotsView.frame;
        rect.origin.y = descriptionView.frame.origin.y+descriptionView.frame.size.height;
        rect.size.height = MIN([self.meeting.Status integerValue] == 0?(IS_IPAD?4:3):1,_slots.count)*(95)+10;
        [meetingSlotsView setFrame:rect];
        
        rect = meetingSlotsTableView.frame;
        rect.size.height = meetingSlotsView.frame.size.height - 10;
        [meetingSlotsTableView setFrame:rect];
        
        rect = headerView.frame;
        rect.size.height = meetingSlotsView.frame.origin.y + meetingSlotsView.frame.size.height ;
        [headerView setFrame:rect];
        
    }
    
    [commentTableView setTableFooterView:commentPostView];
    [self reloadCommentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCommentNotifier:) name:@"PostCommentNotifier" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)reloadCommentNotifier:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadCommentView) withObject:nil waitUntilDone:NO];
}

- (void)reloadCommentView
{
    [commentTableView reloadData];
    if(self.meeting.MeetingComments.count)
    {
        Comment* comment = [self.meeting.MeetingComments objectAtIndex:0];
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
        float height = MAX(60.0,[comment cellHeightForWidth:w]);
        CGRect rect = commentTableView.frame;
        rect.origin.y = headerView.frame.size.height+ headerView.frame.origin.y-4;
        rect.size.height = height+20.0+commentPostView.frame.size.height;
        [commentTableView setFrame:rect];
        
        CGSize size = scrollView.bounds.size;
        size.height = rect.origin.y + rect.size.height;
        [scrollView setContentSize:size];
    }
    else
    {
        CGRect rect = commentTableView.frame;
        rect.origin.y = headerView.frame.size.height+ headerView.frame.origin.y-4;
        rect.size.height = commentPostView.frame.size.height;
        [commentTableView setFrame:rect];
        
        CGSize size = scrollView.bounds.size;
        size.height = rect.origin.y + rect.size.height;
        [scrollView setContentSize:size];
        
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(IS_IPAD)
    {
        //[meetingSlotsTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [meetingSlotsTableView numberOfSections])] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)reloadView
{
    NSString* saveTitle = @"Save";
    SEL action = @selector(saveTaskAction);
    switch ([self.meeting.Status integerValue]) {
        case 0:
            if(self.meeting.CreatorDetails.UserId == [User currentUser].UserId)
            {
                saveTitle = @"Finalize";
                action = @selector(finalizeMeetingAction);
            }
            break;
        case 1:
            saveTitle = @"Done";
            action = @selector(doneAction);
            break;
            
        default:
            break;
    }
    
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:saveTitle style:UIBarButtonItemStylePlain target:self action:action];
    
    UIBarButtonItem * fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBtn,fixedSpace,cancelBtn, nil] animated:YES];
    
    if(!_slots)
        _slots = [[NSMutableArray alloc] init];
    [_slots removeAllObjects];
    
    if([self.meeting.Status integerValue] == 0)
    {
        for(MeetingProposal* proposal in self.meeting.MeetingProposalsList)
        {
            for(MeetingProposalSlot* slot in proposal.MeetingSlotsList)
            {
                [_slots addObject:slot];
                for(MeetingSlotParticipant* slotParticipant in slot.MeetingSlotParticipants)
                {
                    slotParticipant.TmpStatus = slotParticipant.Status;
                }
            }
        }
    }
    else
    {
        for(MeetingProposal* proposal in self.meeting.MeetingProposalsList)
        {
            for(MeetingProposalSlot* slot in proposal.MeetingSlotsList)
            {
                if([slot.Status integerValue] == 1)
                    [_slots addObject:slot];
                for(MeetingSlotParticipant* slotParticipant in slot.MeetingSlotParticipants)
                {
                    slotParticipant.TmpStatus = slotParticipant.Status;
                }
            }
        }
    }
    
    titleLbl.text = self.meeting.Title;
    dateLbl.text = [NSString stringWithFormat:@"Created: %@",[[self.meeting.CreatedOnTimeString componentsSeparatedByString:@"|"] firstObject]];
    
    [creatorImage loadImageFromURL:self.meeting.CreatorDetails.MobileImageUrl];
    
    
    if(!NSSTRING_HAS_DATA(self.meeting.Description))
    {
        descriptionView.hidden =YES;
        CGRect rect = meetingSlotsView.frame;
        rect.origin.y = descriptionView.frame.origin.y;
        rect.size.height = MIN([self.meeting.Status integerValue] == 0?3:1,_slots.count)*(95)+10;
        [meetingSlotsView setFrame:rect];
        
        rect = meetingSlotsTableView.frame;
        rect.size.height = meetingSlotsView.frame.size.height - 10;
        [meetingSlotsTableView setFrame:rect];
        
        rect = headerView.frame;
        rect.size.height = meetingSlotsView.frame.size.height+meetingSlotsView.frame.origin.y;
        [headerView setFrame:rect];
    }
    else
    {
        noteTxt.text = self.meeting.Description;
        noteTxt.scrollEnabled = NO;
        
        NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.meeting.Description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
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
            UIFont* font = [UIFont fontWithDescriptor:des size:11.0];
            [attrs addAttribute:NSFontAttributeName value:font range:range];
        }
        noteTxt.attributedText = attrs;
        
        CGRect rect = descriptionView.frame;
        CGRect paragraphRect = [attrs boundingRectWithSize:CGSizeMake(noteTxt.bounds.size.width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        rect.size.height = paragraphRect.size.height+20;
        [descriptionView setFrame:rect];
        
        rect = meetingSlotsView.frame;
        rect.origin.y = descriptionView.frame.origin.y+descriptionView.frame.size.height;
        rect.size.height = MIN([self.meeting.Status integerValue] == 0?3:1,_slots.count)*(95)+10;
        [meetingSlotsView setFrame:rect];
        
        rect = meetingSlotsTableView.frame;
        rect.size.height = meetingSlotsView.frame.size.height - 10;
        [meetingSlotsTableView setFrame:rect];
        
        rect = headerView.frame;
        rect.size.height = meetingSlotsView.frame.origin.y + meetingSlotsView.frame.size.height ;
        [headerView setFrame:rect];
        
    }
    
    [commentTableView setTableFooterView:commentPostView];
    [self reloadCommentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finalizeMeetingAction
{
    if(_selectedIndexPath)
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finalaizeMeetingSlotNotifier:) name:@"FinalaizeMeetingNotifier" object:nil];
        MeetingProposalSlot* slot = [_slots objectAtIndex:_selectedIndexPath.row];
        [[EventDocument sharedInstance] finalizeMeetingSlot:slot.SlotId forMeeting:self.meeting];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select one slot to be finalized." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void)saveTaskAction
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSlotStatusNotifier:) name:@"UpdateSlotStatusNotifier" object:nil];
    [[EventDocument sharedInstance] updateSlotStatus:_slots forMeeting:self.meeting];
}

- (void)doneAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finalaizeMeetingSlotNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(finalizeMeetingCallBack:) withObject:[note object] waitUntilDone:NO];
}

- (void)finalizeMeetingCallBack:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if([object isKindOfClass:[Meeting class]])
    {
        self.meeting = (Meeting*)object;
        [self reloadView];
    }
    else if([object isKindOfClass:[NSString class]])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void)updateSlotStatusNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(updateSlotStatusCallBack:) withObject:[note object] waitUntilDone:NO];
}

- (void)updateSlotStatusCallBack:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if([object isKindOfClass:[Meeting class]])
    {
        self.meeting = (Meeting*)object;
        [self reloadView];
    }
    else if([object isKindOfClass:[NSString class]])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
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
    if(tableView == commentTableView)
        return 5.0;
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == commentTableView)
        return 1.0;
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == meetingSlotsTableView)
        return 1;
    else if([self.meeting.TotalComments intValue] == 0)
        return 0;
    else
        return MAX([self.meeting.TotalComments intValue] > 1?2:1, 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == meetingSlotsTableView)
       return [_slots count];
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == commentTableView)
    {
        if(indexPath.row == 0 && [self.meeting.TotalComments intValue] > 1 )
        {
            return 30.0;
        }
        else
        {
            Comment* comment = [self.meeting.MeetingComments objectAtIndex:0];
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
            return MAX(60.0,[comment cellHeightForWidth:w]);
        }
    }
    return 90.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == commentTableView)
    {
        if(indexPath.row == 0 && [self.meeting.TotalComments intValue] > 1 )
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ViewCommentsCell"];
            if(!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ViewCommentsCell"];
                cell.detailTextLabel.numberOfLines = 1;
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
                cell.detailTextLabel.textColor = [UIColor colorWithRed:29.0/255.0 green:153.0/255.0 blue:202.0/255.0 alpha:1.0];
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"View all %d comments",[self.meeting.TotalComments intValue]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else
        {
            
            NSString* nibName = @"CommentCell";
            Comment* comment = [self.meeting.MeetingComments objectAtIndex:0];
            CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
            if(cell == nil)
            {
                cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nibName];
            }
            
            cell.readMoreTarget = self;
            cell.readMoreAction = @selector(showFullComment:);
            objc_setAssociatedObject(cell, "IndexPath", indexPath, OBJC_ASSOCIATION_COPY_NONATOMIC);
            
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
    }
    
    NSString* nibName = @"MyMeetingSlotCell";
    MyMeetingSlotCell *cell = (MyMeetingSlotCell*)[tableView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[MyMeetingSlotCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nibName];
    }
    MeetingProposalSlot* slot = [_slots objectAtIndex:indexPath.section];
    cell.slot = slot;
    cell.meeting = self.meeting;
    
    [cell redrawCell];
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == commentTableView)
    {
        MeetingCommentVC* vc = [[MeetingCommentVC alloc] initWithNibName:@"MeetingCommentVC" bundle:nil];
        [vc setMeeting:self.meeting];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        if(_selectedIndexPath)
            [tableView deselectRowAtIndexPath:_selectedIndexPath animated:YES];
        _selectedIndexPath = indexPath;
    }
}

- (void)openComments:(UIButton*)btn
{
    MeetingCommentVC* vc = [[MeetingCommentVC alloc] initWithNibName:@"MeetingCommentVC" bundle:nil];
    [vc setMeeting:self.meeting];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)showFullComment:(CommentCell*)cell
{
    NSIndexPath* indexpath = objc_getAssociatedObject(cell, "IndexPath");
    if( indexpath)
    {
        [commentTableView beginUpdates];
        [commentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
        [commentTableView endUpdates];
    }
    
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
        //[[TaskDocument sharedInstance] deleteComment:comment ofTaskId:comment.task.taskId];
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
       // [[TaskDocument sharedInstance] refreshHomeFeed];
    }
}

- (IBAction)mettingDetailAction:(id)sender
{
    MeetingDetailVC* vc = [[MeetingDetailVC alloc] initWithNibName:@"MeetingDetailVC" bundle:nil];
    vc.meeting = self.meeting;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
