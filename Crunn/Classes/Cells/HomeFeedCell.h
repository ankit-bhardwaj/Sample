//
//  HomeFeedCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "GSAsynImageView.h"
#import "HomeVC.h"

@interface HomeFeedCell : UITableViewCell

@property(nonatomic,assign)BOOL isExpended;
@property(nonatomic,retain)IBOutlet GSAsynImageView* assigneeImage;
@property(nonatomic,retain)IBOutlet UILabel* taskDescription;
@property(nonatomic,retain)IBOutlet UILabel* otherDetail;
@property(nonatomic,retain)IBOutlet UIButton* collapseExpandButton;
@property(nonatomic,retain)IBOutlet UIButton* detailDisclosure;
@property(nonatomic,retain)IBOutlet UIButton* taskStatus;
@property(nonatomic,retain)IBOutlet UIImageView* highPriorityView;
@property(nonatomic,retain)IBOutlet UIButton* reminderBtn;
@property(nonatomic,retain)IBOutlet UIButton* followBtn;
@property(nonatomic,retain)IBOutlet UIButton* locationBtn;

@property(nonatomic,retain)Task* task;


-(void)fillDataWithTask:(Task*)atask;
- (IBAction)reminderAction:(id)sender;
- (IBAction)followAction:(id)sender;


@end
