//
//  ProjectListVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/8/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Portfolio.h"

@interface ProjectListVC : UITableViewController

@property(nonatomic,strong)id target;

@property(nonatomic,assign)SEL action;
@property(nonatomic,strong)Project* selectedProject;
@property(nonatomic,strong)Portfolio* masterPortfolio;
@property(nonatomic,strong)Project* masterProject;
@property(nonatomic,retain)UIPopoverController* popOver;
@end
