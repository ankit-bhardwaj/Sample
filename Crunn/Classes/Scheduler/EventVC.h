//
//  EventVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 12/16/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@interface EventVC : UIViewController
@property (strong, nonatomic) JTCalendar *calendar;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;
@end
