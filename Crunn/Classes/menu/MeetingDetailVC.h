//
//  MeetingDetailVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meeting.h"

@interface MeetingDetailVC : UIViewController
@property (nonatomic, retain)Meeting *meeting;
@property (nonatomic, retain)IBOutlet UITableView* tblView;
@property (nonatomic, retain) UILabel* commentCntLbl;

@property(nonatomic, assign)id target;
@end
