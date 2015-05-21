//
//  TransTaskCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/27/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TransTaskCell.h"
#import "UIColor-Expanded.h"

@implementation TransTaskCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillDataWithTask:(Task*)atask{
    
    self.task = atask;
    [self.assigneeImage loadImageFromURL:self.task.creator.MobileImageUrl];
    self.taskDescription.text = self.task.name;
    self.taskStatus.selected = [self.task taskStatus]==TaskStatusCompleted?YES:NO;
    if(atask.ColorCode)
    {
        self.taskStatusView.backgroundColor = [UIColor colorWithHexString:[[atask.ColorCode stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString]];
    }
    else
    {
        self.taskStatusView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    }
    
    NSString* dueDate = [[[self.task.DueDateString componentsSeparatedByString:@"|"] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray* details = [NSMutableArray array];
    if(NSSTRING_HAS_DATA(self.task.ProjectName))
        [details addObject:self.task.ProjectName];
    
    if(self.task.creator.UserId > 0)
        [details addObject:self.task.creator.UserId==[User currentUser].UserId?@"Me":self.task.creator.FormattedName];
    
    if(NSSTRING_HAS_DATA(dueDate))
        [details addObject:dueDate];
    
    if(details.count)
        self.otherDetail.text = [details componentsJoinedByString:@" | "];
    else
        self.otherDetail.text = @"";
    
}

- (IBAction)changeColor:(id)sender
{
    
}

@end
