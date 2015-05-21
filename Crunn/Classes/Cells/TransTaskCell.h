//
//  TransTaskCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/27/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularIMageView.h"
#import "Task.h"

@interface TransTaskCell : UITableViewCell

@property(nonatomic,assign)BOOL isExpended;
@property(nonatomic,retain)IBOutlet CircularIMageView* assigneeImage;
@property(nonatomic,retain)IBOutlet UILabel* taskDescription;
@property(nonatomic,retain)IBOutlet UILabel* otherDetail;
@property(nonatomic,retain)IBOutlet UIButton* taskStatus;
@property(nonatomic,retain)IBOutlet UIButton* taskStatusView;
@property(nonatomic,retain)Task* task;

- (IBAction)changeColor:(id)sender;
-(void)fillDataWithTask:(Task*)atask;
@end
