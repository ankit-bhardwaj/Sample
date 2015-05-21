//
//  ProjectListVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/8/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface StatusListVC : UITableViewController

@property(nonatomic,strong)id target;

@property(nonatomic,assign)SEL action;

@property(nonatomic,retain)Task* task;

@property(nonatomic,retain)NSString* selectedStatus;

@property(nonatomic,retain)UIPopoverController* popOver;
@end
