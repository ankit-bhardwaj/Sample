//
//  AssigneeListVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssigneeListVC : UITableViewController

@property(nonatomic,strong)id target;

@property(nonatomic,assign)SEL action;

@property(nonatomic,assign)BOOL isMultiSelect;

@property(nonatomic,strong)User* selectedAssignee;

@property(nonatomic,strong)NSMutableArray* selectedAssignees;

@end
