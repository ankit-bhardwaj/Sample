//
//  CommentVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface CommentVC : UIViewController

@property(nonatomic,retain) Task* task;
@property(nonatomic,assign) BOOL composeComment;
@end
