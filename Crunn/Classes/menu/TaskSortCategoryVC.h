//
//  TaskSortCategoryVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYPopoverController.h"

@interface TaskSortCategoryVC : UITableViewController

@property(nonatomic,retain)id target;
@property(nonatomic,assign)SEL action;
@end
