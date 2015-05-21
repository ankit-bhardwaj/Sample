//
//  RecentActivityCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/12/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "RecentActivityCell.h"

@implementation RecentActivityCell

- (void)awakeFromNib
{
    [self.userImageView setImage:[UIImage imageNamed:@"avatar_small.png"]];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    float height = 0;
    CGRect rect = [self.descriptionLbl frame];
    rect.size.height = self.frame.size.height - 134;
    [self.descriptionLbl setFrame:rect];
    height = rect.origin.y + rect.size.height;
    
    rect = [self.sepLine frame];
    rect.origin.y = height;
    [self.sepLine setFrame:rect];
    height = rect.origin.y + rect.size.height;
    
    rect = [self.commentView frame];
    rect.origin.y = height;
    [self.commentView setFrame:rect];
    height = rect.origin.y + rect.size.height;
}

@end
