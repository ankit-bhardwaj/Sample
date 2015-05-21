//
//  MyMeetingSlotCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 2/12/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAsynImageView.h"
#import "Meeting.h"

@interface MyMeetingSlotCell : UITableViewCell
@property(nonatomic,retain)IBOutlet UILabel* monthLbl;
@property(nonatomic,retain)IBOutlet UILabel* dateLbl;
@property(nonatomic,retain)IBOutlet UILabel* slotsLbl;
@property(nonatomic,retain)IBOutlet GSAsynImageView* creatorImageView;
@property(nonatomic,retain) IBOutlet UIView* attendeesView;
@property(nonatomic,retain) IBOutlet UIView* feedbackCountView;
@property(nonatomic,retain) IBOutlet UIView* mainView;
@property(nonatomic,retain) IBOutlet UITableView* optionsView;

@property(nonatomic,retain) IBOutlet UIButton* greenCount;
@property(nonatomic,retain) IBOutlet UIButton* yellowCount;
@property(nonatomic,retain) IBOutlet UIButton* redCount;
@property(nonatomic,retain) IBOutlet UIButton* whiteCount;
@property(nonatomic,retain) MeetingProposalSlot* slot;
@property(nonatomic,retain) MeetingSlotParticipant* slotParticipant;
@property(nonatomic,retain) Meeting* meeting;
- (void)redrawCell;

- (IBAction)selectOptionAction:(UIButton*)sender;
@end
