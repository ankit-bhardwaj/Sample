//
//  ScheduleMeetingStepOneVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleMeetingStepOneVC : UIViewController
@property(nonatomic,retain)NSDate*  startDate;
@property(nonatomic,retain)NSDate*  endDate;
- (NSString*)validate;
@end
