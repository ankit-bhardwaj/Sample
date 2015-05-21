//
//  Task.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "Task.h"
#import "Comment.h"
#import "TaskDocument.h"
#import "NSString+HTML.h"
#import "NSString+MD5.h"

@implementation Task
@synthesize taskId;
@synthesize name;
@synthesize summary;
@synthesize highPriority;
@synthesize project;
@synthesize assignee;
@synthesize dueDate;
@synthesize comments;
@synthesize CreatedOnTimeString;



+ (Task*) getTaskFromDict:(NSDictionary*)dict
{
    Task* c = [Task new];
    c.name = [NS_NOT_NULL([dict objectForKey:@"TaskDescription"]) stringByConvertingHTMLToPlainText];
    c.summary = NS_NOT_NULL([dict objectForKey:@"TaskDetails"]);
    c.taskId = NS_NOT_NULL([dict objectForKey:@"TaskId"]);
    c.totalComments = NS_NOT_NULL([dict objectForKey:@"TotalComments"]);
    NSString* createdDateString = NS_NOT_NULL([dict objectForKey:@"CreatedOnTimeString"]);
    c.CreatedOnTimeString = [[createdDateString componentsSeparatedByString:@"|"] firstObject];
    c.ProjectName = NS_NOT_NULL([dict objectForKey:@"ProjectName"]);
    c.project = [Project getProjectFromDict:dict];
    c.highPriority = [NS_NOT_NULL([dict objectForKey:@"IsHighPriority"]) boolValue];
    c.StatusTypeDescription = NS_NOT_NULL([dict objectForKey:@"StatusTypeDescription"]);
    c.creator = [User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"CreatorDetails"])];
    c.assignee = [User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"AssigneeDetails"])];
    c.IsCompleted = [NS_NOT_NULL([dict objectForKey:@"IsCompleted"]) boolValue];
    c.DueDateString = [NS_NOT_NULL([dict objectForKey:@"DueDateString"]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* doDateString = NS_NOT_NULL([dict objectForKey:@"DoDateString"]);
    NSArray* tmp = [doDateString componentsSeparatedByString:@"|"];
    if(tmp && tmp.count > 1)
        c.DoDateString = [tmp objectAtIndex:1];
    c.FollowTaskFlag = NS_NOT_NULL([dict objectForKey:@"FollowTaskFlag"]);
    c.StatusTypeId = NS_NOT_NULL([dict objectForKey:@"StatusTypeId"]);
    c.CircleId = NS_NOT_NULL([dict objectForKey:@"CircleId"]);
    c.LastUpdatedBy = NS_NOT_NULL([dict objectForKey:@"LastUpdatedBy"]);
    c.GroupId = NS_NOT_NULL([dict objectForKey:@"GroupId"]);
    c.CanEdit = [NS_NOT_NULL([dict objectForKey:@"CanEdit"]) boolValue];
    c.CanEditAssignee = [NS_NOT_NULL([dict objectForKey:@"CanEditAssignee"]) boolValue];
    c.ColorCode = NS_NOT_NULL([dict objectForKey:@"ColorCode"]);
    c.HasNudge = [NS_NOT_NULL([dict objectForKey:@"HasNudge"]) boolValue];
    c.BelongsToTodaysAgenda = [NS_NOT_NULL([dict objectForKey:@"BelongsToTodaysAgenda"]) boolValue];
    
    NSString* completedDateString = NS_NOT_NULL([dict objectForKey:@"CompletedOnString"]);
    c.CompletedOnString = [[completedDateString componentsSeparatedByString:@"|"] firstObject];
    c.CompletedById = NS_NOT_NULL([dict objectForKey:@"CompletedById"]);
    c.CompletedByName = NS_NOT_NULL([dict objectForKey:@"CompletedByName"]);
    
    if(NS_NOT_NULL([dict objectForKey:@"TaskComments"]))
    {
        NSArray* taskComments = [dict objectForKey:@"TaskComments"];
        NSMutableArray* comments = [[NSMutableArray alloc] init];
        for (NSDictionary* d in taskComments)
        {
            Comment* cmnt = [Comment getCommentFromDict:d];
            cmnt.task = c;
            [comments addObject:cmnt];
        }
        //if(comments.count > 3)
        //    [comments removeObjectsInRange:NSMakeRange(3, ([comments count] -3))];
        c.comments = [NSMutableArray arrayWithArray:comments];
    }
    NSArray* atts = NS_NOT_NULL([dict objectForKey:@"TaskAttachments"]);
    if(atts && atts.count > 0)
    {
        NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        NSMutableArray* imgTmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in atts)
        {
            Attachment* cmnt = [Attachment getAttachmentFromDict:d];
            if([imageContentTypes containsObject:cmnt.ContentType])
            {
                [imgTmp addObject:cmnt];
            }
            else
            {
                [tmp addObject:cmnt];
            }
        }
        [tmp insertObjects:imgTmp atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [imgTmp count])]];
        c.Attachments = tmp;
    }
    NSArray* users = NS_NOT_NULL([dict objectForKey:@"UserList"]);
    if(users && users.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in users)
        {
            TaskUser* user = [TaskUser getTaskUserFromDict:d];
            [tmp addObject:user];
        }
        c.UserList = tmp;
    }
    c.summary = c.summary;
    c.taskStatus = [c.StatusTypeId intValue];
    c.LastUpdateDateTimeString = NS_NOT_NULL([dict objectForKey:@"LastUpdateDateTimeString"]); //Sun, Jul 20 at 05:57 pm
    NSString* formattedUpdatedDate = [[c.LastUpdateDateTimeString componentsSeparatedByString:@"|"] firstObject];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, LLL d 'at' hh:mm a"];
    c.lastUpdatedDate = [df dateFromString:formattedUpdatedDate];
    
    c.HasReminder = [NS_NOT_NULL([dict objectForKey:@"HasReminder"]) boolValue];
    if(c.HasReminder)
        c.AutoReminder = [AutoReminder getAutoReminderFromDict:[dict objectForKey:@"AutoReminder"]];
    
//    NSDictionary* location = NS_NOT_NULL([dict objectForKey:@"Location"]);
//    if(location && location.count > 0)
        c.location = [Location getLocationFromDict:dict];
    
    c.tempCommentFilePaths = [[NSMutableArray alloc] init];
    c.tempCommentDBFilePaths = [[NSMutableArray alloc] init];
    
    NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[c.summary dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
    NSMutableDictionary* tmpDict= [NSMutableDictionary dictionary];
    [attrs enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, [attrs length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont *font = (UIFont*)value;
        [tmpDict setObject:[font fontDescriptor] forKey:NSStringFromRange(range)];
    }];
    
    for(NSString* r in [tmpDict allKeys])
    {
        NSRange range = NSRangeFromString(r);
        UIFontDescriptor* des = [tmpDict objectForKey:r];
        NSString* fontface = [des objectForKey:UIFontDescriptorFaceAttribute];
        des = [des fontDescriptorWithFamily:@"Helvetica"];
        des = [des fontDescriptorWithFace:fontface];
        UIFont* font = [UIFont fontWithDescriptor:des size:11.0];
        [attrs addAttribute:NSFontAttributeName value:font range:range];
    }
    c.attrSummary = attrs;
    return c;
}

- (NSComparisonResult)sortCompare:(Task*)other
{
    return [self.lastUpdatedDate compare:other.lastUpdatedDate];
}


- (UIImage*)getTaskStatusImage
{
    UIImage* image = nil;
    switch (self.taskStatus)
    {
        case TaskStatusNew:
            image = [UIImage imageNamed:@"task_New.png"];
            break;
        case TaskStatusAccept:
            image = [UIImage imageNamed:@"task_Accepted.png"];
            break;
        case TaskStatusDecline:
            image = [UIImage imageNamed:@"task_Decline.png"];
            break;
        case TaskStatus25Complete:
            image = [UIImage imageNamed:@"task_25Complete.png"];
            break;
        case TaskStatus50Complete:
            image = [UIImage imageNamed:@"task_50complete.png"];
            break;
        case TaskStatus75Complete:
            image = [UIImage imageNamed:@"task_75Complete.png"];
            break;
        case TaskStatusCompleted:
            image = [UIImage imageNamed:@"task_Completed.png"];
            break;
            
        default:
            break;
    }
    return image;
}


- (NSString*)getTaskStatusName
{
    NSString* string = nil;
    NSArray* taskStatuses = [[TaskDocument sharedInstance] taskStatusList];
    if(taskStatuses && taskStatuses.count > 6)
    {
        switch (self.taskStatus)
        {
            case TaskStatusNew:
                string = [taskStatuses objectAtIndex:0];
                break;
            case TaskStatusAccept:
                string = [taskStatuses objectAtIndex:1];
                break;
            case TaskStatusDecline:
                string = [taskStatuses objectAtIndex:2];
                break;
            case TaskStatus25Complete:
                string = [taskStatuses objectAtIndex:3];
                break;
            case TaskStatus50Complete:
                string = [taskStatuses objectAtIndex:4];
                break;
            case TaskStatus75Complete:
                string = [taskStatuses objectAtIndex:5];
                break;
            case TaskStatusCompleted:
                string = [taskStatuses objectAtIndex:6];
                break;
                
            default:
                break;
        }
    }
    else
    {
        
        switch (self.taskStatus)
        {
            case TaskStatusNew:
                string = @"New";
                break;
            case TaskStatusAccept:
                string = @"Accepted";
                break;
            case TaskStatusDecline:
                string = @"Declined";
                break;
            case TaskStatus25Complete:
                string = @"25% Complete";
                break;
            case TaskStatus50Complete:
                string = @"50% Complete";
                break;
            case TaskStatus75Complete:
                string = @"75% Complete";
                break;
            case TaskStatusCompleted:
                string = @"Completed";
                break;
                
            default:
                break;
        }
    }
    return string;
}

+ (TaskStatus)getTaskStatus:(NSString*)status{
    
    TaskStatus tStatus;
    if ([[status lowercaseString] isEqualToString:@"new"]) {
        tStatus = TaskStatusNew;
    }
    else if ([[status lowercaseString] isEqualToString:@"accept"]) {
        tStatus = TaskStatusAccept;
    }
    else if ([[status lowercaseString] isEqualToString:@"decline"]) {
        tStatus = TaskStatusDecline;
    }
    else if ([[status lowercaseString] isEqualToString:@"25% complete"]) {
        tStatus = TaskStatus25Complete;
    }
    else if ([[status lowercaseString] isEqualToString:@"50% complete"]) {
        tStatus = TaskStatus50Complete;
    }
    else if ([[status lowercaseString] isEqualToString:@"75% complete"]) {
        tStatus = TaskStatus75Complete;
    }
    else if ([[status lowercaseString] isEqualToString:@"completed"]) {
        tStatus = TaskStatusCompleted;
    }
    
    return tStatus;
    
    
}


@end


@implementation TaskSortCategory



+ (TaskSortCategory*) getTaskCategoryFromDict:(NSDictionary*)dict
{
    TaskSortCategory* c = [TaskSortCategory new];
    c.DisplayOrder = NS_NOT_NULL([dict objectForKey:@"DisplayOrder"]);
    c.SortByColumnScript = NS_NOT_NULL([dict objectForKey:@"SortByColumnScript"]);
    c.SortByDescription = NS_NOT_NULL([dict objectForKey:@"SortByDescription"]);
    c.SortId = NS_NOT_NULL([dict objectForKey:@"SortId"]);
    return c;
}

+ (TaskSortCategory*)createTaskSortCategory
{
    TaskSortCategory* c =[TaskSortCategory new];
    c.DisplayOrder = [NSNumber numberWithInt:0];
    c.SortByDescription = @"Recent activity";
    c.SortByColumnScript = @"ts.lastupdatedatetime desc";
    c.SortId = [NSNumber numberWithInt:0];

    return c;
}

+ (TaskSortCategory*)deafultTaskSortCategory
{
    TaskSortCategory* c = nil;
    if([TaskDocument sharedInstance].taskSortingCategories.count>1)
    {
        c = [[TaskDocument sharedInstance].taskSortingCategories objectAtIndex:1];
    }
    else
    {
        c = [TaskSortCategory createTaskSortCategory];
    }
    
    return c;
}

+ (TaskSortCategory*)deafultPortfolioTaskSortCategory
{
    TaskSortCategory* c = nil;
    if([TaskDocument sharedInstance].taskSortingCategories.count>1)
    {
        c = [[TaskDocument sharedInstance].taskSortingCategories objectAtIndex:0];
    }
    else
    {
        c =[TaskSortCategory new];
        c.DisplayOrder = [NSNumber numberWithInt:0];
        c.SortByDescription = @"Created date";
        c.SortByColumnScript = @"ts.createdon desc";
        c.SortId = [NSNumber numberWithInt:0];
    }
    
    return c;
}



@end


@implementation TaskUser



+ (TaskUser*) getTaskUserFromDict:(NSDictionary*)dict
{
    TaskUser* c = [TaskUser new];
    c.AssociationType = NS_NOT_NULL([dict objectForKey:@"AssociationType"]);
    c.Follow = [NS_NOT_NULL([dict objectForKey:@"Follow"]) boolValue];
    c.IsUserEnabled = [NS_NOT_NULL([dict objectForKey:@"IsUserEnabled"]) boolValue];
    c.UserPermission = NS_NOT_NULL([dict objectForKey:@"UserPermission"]);
    c.UserProfile = [User getUserForDictionary: NS_NOT_NULL([dict objectForKey:@"UserProfile"])];
    return c;
}
@end


@implementation AutoReminder



+ (AutoReminder*) getAutoReminderFromDict:(NSDictionary*)dict
{
    AutoReminder* c = [AutoReminder new];
    c.DaysFrequency = NS_NOT_NULL([dict objectForKey:@"DaysFrequency"]);
    c.ReminderId = NS_NOT_NULL([dict objectForKey:@"ReminderId"]);
    NSString* date = NS_NOT_NULL([dict objectForKey:@"ReminderStartDate"]);
    c.ReminderStartDate = [date getJSONDate];
    c.UserId = NS_NOT_NULL([dict objectForKey:@"UserId"]);
    c.IsReminderToday = [NS_NOT_NULL([dict objectForKey:@"IsReminderToday"]) boolValue];
    c.Title = NS_NOT_NULL([dict objectForKey:@"Title"]);
    if(!c.Title)
        c.Title = [c displayString];
    return c;
}



- (NSString*) displayString
{
    NSMutableString* str = [NSMutableString string];
    
    switch ([self.DaysFrequency intValue]) {
        case 0:
            [str appendFormat:@"On"];
            break;
        case 1:
            [str appendFormat:@"Every day "];
            [str appendFormat:@"starting"];
            break;
        case 2:
            [str appendFormat:@"Every 2 days "];
            [str appendFormat:@"starting"];
            break;
        case 3:
            [str appendFormat:@"Every 3 days "];
            [str appendFormat:@"starting"];
            break;
        case 4:
            [str appendFormat:@"Every 4 days "];
            [str appendFormat:@"starting"];
            break;
        case 5:
            [str appendFormat:@"Every 5 days "];
            [str appendFormat:@"starting"];
            break;
        case 6:
            [str appendFormat:@"Every 6 days "];
            [str appendFormat:@"starting"];
            break;
        case 7:
            [str appendFormat:@"Every week "];
            [str appendFormat:@"starting"];
            break;
        case 14:
            [str appendFormat:@"Every 2 weeks "];
            [str appendFormat:@"starting"];
            break;
        case 30:
            [str appendFormat:@"Every month "];
            [str appendFormat:@"starting"];
            break;
            
        default:
            break;
    }
    
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM d"];
    [str appendFormat:@" %@",[df stringFromDate:self.ReminderStartDate]];
    return str;
}

- (void)setDaysFrequencyFromString:(NSString*)str
{
    if([str isEqualToString:@"day"])
        self.DaysFrequency = [NSNumber numberWithInt:1];
    else if([str isEqualToString:@"2 days"])
        self.DaysFrequency = [NSNumber numberWithInt:2];
    else if([str isEqualToString:@"3 days"])
        self.DaysFrequency = [NSNumber numberWithInt:3];
    else if([str isEqualToString:@"4 days"])
        self.DaysFrequency = [NSNumber numberWithInt:4];
    else if([str isEqualToString:@"5 days"])
        self.DaysFrequency = [NSNumber numberWithInt:5];
    else if([str isEqualToString:@"week"])
        self.DaysFrequency = [NSNumber numberWithInt:7];
    else if([str isEqualToString:@"2 weeks"])
        self.DaysFrequency = [NSNumber numberWithInt:14];
    else if([str isEqualToString:@"month"])
        self.DaysFrequency = [NSNumber numberWithInt:30];
}

- (NSString*)getDaysFrequencyString
{
    switch ([self.DaysFrequency intValue]) {
        case 0:
            return @"";
            break;
        case 1:
            return @"day";
            break;
        case 2:
            return @"2 days";
            break;
        case 3:
            return @"3 days";
            break;
        case 4:
            return @"4 days";
            break;
        case 5:
            return @"5 days";
            break;
        case 6:
            return @"6 days";
            break;
        case 7:
            return @"week";
            break;
        case 14:
            return @"2 weeks";
            break;
        case 30:
            return @"month";
            break;
            
        default:
            break;
    }
    return @"";
}
@end


@implementation Location



+ (Location*) getLocationFromDict:(NSDictionary*)dict
{
    NSNumber* lat = NS_NOT_NULL([dict objectForKey:@"Latitude"]);
    NSNumber* lng = NS_NOT_NULL([dict objectForKey:@"Longitude"]);
    if([lat doubleValue] == 0 && [lng doubleValue] == 0)
        return nil;
    Location* c = [Location new];
    c.latitude = lat;
    c.longitude = lng;
    c.address = NS_NOT_NULL([dict objectForKey:@"LocationAddress"]);
    [c setCoordinate:CLLocationCoordinate2DMake([c.latitude doubleValue], [c.longitude doubleValue])];
    return c;
}

- (NSString*)title
{
    return self.address;
}

- (NSString*)subtitle
{
    return @"";
}

@end