//
//  taskCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/10/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "taskCell.h"

@implementation taskCell

- (void)awakeFromNib
{
    // Initialization code
    [[self.container layer] setCornerRadius:5.0f];
    [[self.container layer] setBorderColor:[UIColor colorWithRed:41.0/255.0 green:152.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor];
    [[self.container layer] setBorderWidth:1.0f];
    [[self.container layer] setMasksToBounds:YES];
    //[self.name setTextColor:[UIColor colorWithRed:29/255.0 green:153.0/255 blue:202.0/255 alpha:1.0f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
