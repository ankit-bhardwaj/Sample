//
//  CommentVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meeting.h"

@interface MeetingCommentVC : UIViewController

@property(nonatomic,retain) Meeting* meeting;
@property(nonatomic,assign) BOOL composeComment;
@end
