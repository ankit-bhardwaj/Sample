//
//  RecentActivityCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/12/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAsynImageView.h"

@interface RecentActivityCell : UITableViewCell
@property(nonatomic,strong)IBOutlet UILabel* nameLbl;
@property(nonatomic,strong)IBOutlet UILabel* dateLbl;
@property(nonatomic,strong)IBOutlet UILabel* projectLbl;
@property(nonatomic,strong)IBOutlet UILabel* titleLbl;
@property(nonatomic,strong)IBOutlet UILabel* descriptionLbl;
@property(nonatomic,strong)IBOutlet GSAsynImageView* userImageView;
@property(nonatomic,strong)IBOutlet UIView* commentView;
@property(nonatomic,strong)IBOutlet UILabel* commentLbl;
@property(nonatomic,strong)IBOutlet UIButton* commentBtn;
@property(nonatomic,strong)IBOutlet UIView* sepLine;
@end
