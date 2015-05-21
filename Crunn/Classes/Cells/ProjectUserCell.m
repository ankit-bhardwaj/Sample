//
//  ProjectUserCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/26/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ProjectUserCell.h"

@implementation ProjectUserCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillDataForUser:(TaskUser*)user
{
    self.name.text = user.UserProfile.FormattedName;
    self.email.text = user.UserProfile.Email;
    self.image.image = [UIImage imageNamed:@"avatar_small.png"];
    [self.image loadImageFromURL:user.UserProfile.MobileImageUrl];

    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    if(user.Follow)
        [img setImage:[UIImage imageNamed:@"user_following.png"]];
    else
        [img setImage:[UIImage imageNamed:@"user_not_following.png"]];
    self.accessoryView = img;
    
    self.canAddStatusBtn.hidden = YES;
}

- (void)fillDataForProjectUser:(ProjectUser*)user
{
    self.name.text = [user.UserProfile.FormattedName stringByAppendingFormat:@", %@",user.UserPermissionDescription];
    self.email.text = user.UserProfile.Email;
    self.image.image = [UIImage imageNamed:@"avatar_small.png"];
    [self.image loadImageFromURL:user.UserProfile.MobileImageUrl];
    
    if(user.Follow)
        [self.followImage setImage:[UIImage imageNamed:@"user_following.png"]];
    else
        [self.followImage setImage:[UIImage imageNamed:@"user_not_following.png"]];
    self.accessoryView = nil;
    
    self.canAddStatusBtn.selected = !user.CanAddOtherUser;
}

@end
