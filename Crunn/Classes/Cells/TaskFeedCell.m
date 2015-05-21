//
//  TaskFeedCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TaskFeedCell.h"
#import "Task.h"
#import "TaskDocument.h"


@implementation TaskFeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    //[[self layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    //[[self layer] setBorderWidth:1.0f];
    [[self layer] setCornerRadius:2.0f];
    [[self layer] setMasksToBounds:YES];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

-(void)fillDataWithTask:(Task*)atask
{
    self.task = atask;
    [self.assigneeImage loadImageFromURL:self.task.creator.MobileImageUrl];
    self.taskDescription.text = self.task.name;
    self.taskStatus.selected = [self.task taskStatus]==TaskStatusCompleted?YES:NO;
    
    if(atask.taskStatus == TaskStatusCompleted)
    {
        self.taskDescription.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.taskDescription.textColor = [UIColor blackColor];
    }
    NSString* dueDate = [[[self.task.DueDateString componentsSeparatedByString:@"|"] firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray* details = [NSMutableArray array];
    if(NSSTRING_HAS_DATA(self.task.ProjectName))
        [details addObject:self.task.ProjectName];
    
    if(self.task.assignee.UserId > 0)
        [details addObject:self.task.assignee.UserId==[User currentUser].UserId?@"Me":self.task.assignee.FormattedName];
    
    if(NSSTRING_HAS_DATA(dueDate))
        [details addObject:dueDate];
    
    if(details.count)
        self.otherDetail.text = [details componentsJoinedByString:@" | "];
    else
        self.otherDetail.text = @"";
    
    BOOL isCollaspe = self.task.isCollapsed;
    self.otherDetail.hidden = isCollaspe;
    self.assigneeImage.hidden = isCollaspe;
    self.detailDisclosure.hidden = isCollaspe;
    self.taskStatus.hidden = isCollaspe;
    
    self.highPriorityView.hidden = !atask.highPriority;
    self.reminderBtn.hidden = isCollaspe || !atask.HasReminder;
    if(atask.AutoReminder.IsReminderToday)[self.reminderBtn setImage:[UIImage imageNamed:@"redBell.png"] forState:UIControlStateNormal];
    self.followBtn.selected = ![atask.FollowTaskFlag boolValue];
    self.locationBtn.hidden = !atask.location;
    
    if(self.reminderBtn.hidden)
        self.highPriorityView.frame = self.reminderBtn.frame;
    else
    {
        CGRect rect = self.highPriorityView.frame;
        rect.origin.x = self.reminderBtn.frame.origin.x - 24;
        self.highPriorityView.frame = rect;
        
    }
    
    if(self.reminderBtn.hidden && self.highPriorityView.hidden)
        self.locationBtn.frame = self.reminderBtn.frame;
    else if(self.reminderBtn.hidden && !self.highPriorityView.hidden)
    {
        CGRect rect = self.locationBtn.frame;
        rect.origin.x = self.highPriorityView.frame.origin.x - 24;
        self.locationBtn.frame = rect;
        
    }
    else if(!self.reminderBtn.hidden && self.highPriorityView.hidden)
    {
        CGRect rect = self.locationBtn.frame;
        rect.origin.x = self.reminderBtn.frame.origin.x - 32;
        self.locationBtn.frame = rect;
        
    }
}
- (IBAction)reminderAction:(id)sender
{
    AutoReminder* reminder = self.task.AutoReminder;
    [[APPDELEGATE window] makeToast:[NSString stringWithFormat:@"Reminder: %@",reminder.Title] duration:2 position:CSToastPositionBottom];
}

- (IBAction)followAction:(id)sender
{
    [MBProgressHUD showHUDAddedTo:[APPDELEGATE window] animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeFollowTaskCallBack:) name:@"ChangeFollowTaskNotifier" object:nil];
    [[TaskDocument sharedInstance] ChangeFollowTask:self.task.taskId follow:[NSString stringWithFormat:@"%d",[self.task.FollowTaskFlag intValue]]];
}

-(void)ChangeFollowTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(changeFollowTaskSuccess:) withObject:[note object] waitUntilDone:NO];
}

-(void)changeFollowTaskSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:[APPDELEGATE window] animated:YES];
    if ([sender isKindOfClass:[NSNumber class]])
    {
        self.task.FollowTaskFlag = [NSNumber numberWithBool:![self.task.FollowTaskFlag boolValue]];
        self.followBtn.selected = ![self.task.FollowTaskFlag boolValue];
        if([self.task.FollowTaskFlag boolValue])
            [[APPDELEGATE window] makeToast:@"You are now following this task." duration:2 position:CSToastPositionBottom];
        else
            [[APPDELEGATE window] makeToast:@"You are not following this task now." duration:2 position:CSToastPositionBottom];
        
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
}


@end
