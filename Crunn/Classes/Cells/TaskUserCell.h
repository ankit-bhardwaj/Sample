//
//  TaskUserCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/26/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAsynImageView.h"
#import "Task.h"
#import "Meeting.h"

@interface TaskUserCell : UITableViewCell

@property (nonatomic, retain) IBOutlet GSAsynImageView* image;
@property (nonatomic, retain) IBOutlet UILabel* name;
@property (nonatomic, retain) IBOutlet UILabel* email;
@property (nonatomic, retain) IBOutlet UIButton* deleteBtn;
- (void)fillDataForUser:(TaskUser*)user;
- (void)fillDataForProjectUser:(ProjectUser*)user;
- (void)fillMeetingParticipationList:(MeetingParticipant*)user;

@end
