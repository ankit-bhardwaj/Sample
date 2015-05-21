//
//  TaskSubDetailsCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TaskSubDetailsCell.h"

@implementation TaskSubDetailsCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)readMore:(UIButton*)sender
{
    if(!self.readMore.hidden)
    {
        NSLog(@"read more selected = %d",self.readMore.selected);
        self.readMore.selected = !self.readMore.selected;
        
        if(self.readMoreTarget && [self.readMoreTarget respondsToSelector:self.readMoreAction])
        {
            [self.readMoreTarget performSelector:self.readMoreAction withObject:self];
        }
    }
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        [self readMore:self.readMore];
}

-(IBAction)reminder:(UIButton*)sender
{
    if(self.reminderTarget && [self.reminderTarget respondsToSelector:self.reminderAction])
    {
        [self.reminderTarget performSelector:self.reminderAction withObject:self];
    }
    
}

@end
