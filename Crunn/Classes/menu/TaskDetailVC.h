//
//  TaskDetailVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
@interface TaskDetailVC : UIViewController
@property (nonatomic, retain)Task *task;
@property (nonatomic, retain)IBOutlet UITableView* tblView;
@property (nonatomic, assign) IBOutlet UIView *bottomView;
@property (nonatomic, retain) UILabel* commentCntLbl;

@property(nonatomic, assign)id target;
@end
