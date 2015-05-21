//
//  MyMeetingCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAsynImageView.h"

@interface MyMeetingCell : UITableViewCell
@property (nonatomic, retain) IBOutlet GSAsynImageView* creatorImage;
@property (nonatomic, retain) IBOutlet UILabel* creatorName;
@property (nonatomic, retain) IBOutlet UILabel* createdDate;

@end
