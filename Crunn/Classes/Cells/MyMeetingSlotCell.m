//
//  MyMeetingSlotCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 2/12/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "MyMeetingSlotCell.h"
#import "UIImage+Additions.h"
#import "SWTableViewCell.h"

@implementation MyMeetingSlotCell
{
    UIColor* _selectedSlotColor;
}
- (void)awakeFromNib {

    // Initialization code
    
    self.mainView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.mainView.layer.borderWidth = 1.0;
    
    [self.greenCount setBackgroundImage:[UIImage imageWithColor:self.greenCount.backgroundColor andSize:self.greenCount.frame.size] forState:UIControlStateNormal];
    [self.yellowCount setBackgroundImage:[UIImage imageWithColor:self.yellowCount.backgroundColor andSize:self.yellowCount.frame.size] forState:UIControlStateNormal];
    [self.redCount setBackgroundImage:[UIImage imageWithColor:self.redCount.backgroundColor andSize:self.redCount.frame.size] forState:UIControlStateNormal];
    [self.whiteCount setBackgroundImage:[UIImage imageWithColor:self.whiteCount.backgroundColor andSize:self.whiteCount.frame.size] forState:UIControlStateNormal];
    if(IS_IPAD)
    {
        CGRect rect = self.mainView.frame;
        rect.size.width -= 430;
        [self.mainView setFrame:rect];
        
        rect = self.feedbackCountView.frame;
        rect.size.width -= 500;
        [self.feedbackCountView setFrame:rect];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (MeetingParticipant*)getMeetingParticipantFromMeetingSlotParticipant:(MeetingSlotParticipant*) slotParticipant
{
    for(MeetingParticipant* participant in self.meeting.ParticipantsList)
    {
        if([slotParticipant.SlotParticipantId integerValue] == participant.ParticipantDetails.UserId)
        {
            return participant;
        }
    }
    return nil;
}

- (void)redrawCell
{
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"MMMM"];
    self.monthLbl.text = [df stringFromDate:self.slot.MeetingProposedDate];
    [df setDateFormat:@"d"];
    self.dateLbl.text = [df stringFromDate:self.slot.MeetingProposedDate];
    [df setDateFormat:@"h:mma"];
    self.slotsLbl.text = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:self.slot.MeetingStartTime],[df stringFromDate:self.slot.MeetingEndTime]];
    
    [self.creatorImageView loadImageFromURL:[User currentUser].MobileImageUrl];
    self.feedbackCountView.hidden = YES;
    if([User currentUser].UserId == self.meeting.CreatorDetails.UserId || [self.slot.Status integerValue] == 1)
    {
        UIView* selectedBg = [[UIView alloc] initWithFrame:self.bounds];
        [selectedBg setBackgroundColor:[UIColor colorWithRed:177.0/255.0 green:209.0/255.0 blue:202.0/255.0 alpha:1.0]];
        self.selectedBackgroundView = selectedBg;
        self.feedbackCountView.hidden = NO;
        self.optionsView.hidden = YES;
    }
    else
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    int greenCount = 0;
    int yellowCount = 0;
    int redCount = 0;
    int whiteCount = 0;
    
    float x = 2;
    float y = 2;
    for(MeetingSlotParticipant* slotParticipant in self.slot.MeetingSlotParticipants)
    {
        MeetingParticipant* participant = [self getMeetingParticipantFromMeetingSlotParticipant:slotParticipant];
        {
            GSAsynImageView* img = [[GSAsynImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
            [img setImage:[UIImage imageNamed:@"avatar_small.png"]];
            [img loadImageFromURL:participant.ParticipantDetails.MobileImageUrl];
            [self.attendeesView addSubview:img];
            x+= img.frame.size.width + 4;
            if(x>= self.attendeesView.bounds.size.width)
                y+= img.frame.size.height + 4;
            
            if([User currentUser].UserId != self.meeting.CreatorDetails.UserId && participant.ParticipantDetails.UserId == [User currentUser].UserId)
            {
                self.slotParticipant = slotParticipant;
                if([slotParticipant.Status integerValue] != 0)
                {
                    //[self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
                
            }
            UIColor* borderColor = [UIColor whiteColor];
            switch ([slotParticipant.TmpStatus integerValue]) {
                case 0:
                {
                    _selectedSlotColor = nil;
                    whiteCount++;
                    borderColor = self.whiteCount.backgroundColor;
                    break;
                }
                case 2:
                {
                    _selectedSlotColor = self.greenCount.backgroundColor;
                    [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    greenCount++;
                    borderColor = self.greenCount.backgroundColor;
                    break;
                }
                case 1:
                {
                    _selectedSlotColor = self.yellowCount.backgroundColor;
                    [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    yellowCount++;
                    borderColor = self.yellowCount.backgroundColor;
                    break;
                }
                case 3:
                {
                    _selectedSlotColor = self.redCount.backgroundColor;
                    [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    redCount++;
                    borderColor = self.redCount.backgroundColor;
                    break;
                }
                    
                default:
                    break;
            }
            [[img layer] setBorderColor:borderColor.CGColor];
        }
    }
    [self.greenCount setTitle:[NSString stringWithFormat:@"%d",greenCount] forState:UIControlStateNormal];
    [self.yellowCount setTitle:[NSString stringWithFormat:@"%d",yellowCount] forState:UIControlStateNormal];
    [self.redCount setTitle:[NSString stringWithFormat:@"%d",redCount] forState:UIControlStateNormal];
    [self.whiteCount setTitle:[NSString stringWithFormat:@"%d",whiteCount] forState:UIControlStateNormal];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:10.0];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell setLeftUtilityButtons:[self leftButtons] WithButtonWidth:self.optionsView.bounds.size.width];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:self.optionsView.bounds.size.width/3.0];
    }
    
    if(_selectedSlotColor)
    {
        cell.leftUtilityButtons = [NSArray array];
        cell.textLabel.text = @"";
        cell.backgroundColor =  _selectedSlotColor;
    }
    else
        cell.textLabel.text = @"Swipe right for Yes,swipe left for more options";
    
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     self.greenCount.backgroundColor title:@"Yes" titleColor:[UIColor lightGrayColor] size:CGSizeMake(self.optionsView.bounds.size.width/3.0, 38.0)];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     self.yellowCount.backgroundColor title:@"May be"  titleColor:[UIColor lightGrayColor] size:CGSizeMake(self.optionsView.bounds.size.width/3.0, 38.0)];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     self.redCount.backgroundColor title:@"No" titleColor:[UIColor lightGrayColor] size:CGSizeMake(self.optionsView.bounds.size.width/3.0, 38.0)];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     self.greenCount.backgroundColor title:@""  titleColor:[UIColor lightGrayColor] size:CGSizeMake(self.optionsView.bounds.size.width, 38.0)];
    
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            _selectedSlotColor = self.greenCount.backgroundColor;
            self.slotParticipant.TmpStatus = [NSNumber numberWithInteger:0];
            [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            _selectedSlotColor = self.greenCount.backgroundColor;
            self.slotParticipant.TmpStatus = [NSNumber numberWithInteger:index];
            [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            //[cell hideUtilityButtonsAnimated:YES];
            break;
        }
        case 1:
        {
            _selectedSlotColor = self.yellowCount.backgroundColor;
            self.slotParticipant.TmpStatus = [NSNumber numberWithInteger:index];
            [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case 2:
        {
            _selectedSlotColor = self.redCount.backgroundColor;
            self.slotParticipant.TmpStatus = [NSNumber numberWithInteger:index];
            [self.optionsView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

@end
