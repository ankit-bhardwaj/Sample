//
//  ManageTaskUserVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface ManageTaskUserVC : UIViewController

@property(nonatomic,strong)id target;

@property(nonatomic,assign)SEL action;
@property(nonatomic,retain)Task* task;
@end
