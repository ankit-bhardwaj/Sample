//
//  Activity.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/12/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "Activity.h"

@implementation Activity


+ (Activity*) getActivityFromDict:(NSDictionary*)dict
{
    Activity* c = [Activity new];
    c.ActivityDateString = NS_NOT_NULL([dict objectForKey:@"ActivityDateString"]);
    c.ActivityId = NS_NOT_NULL([dict objectForKey:@"ActivityId"]);
    c.ActivityText = NS_NOT_NULL([dict objectForKey:@"ActivityText"]);
    c.AttachmentList = NS_NOT_NULL([dict objectForKey:@"AttachmentList"]);
    c.ByUserDetail = [User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"ByUserDetail"])];
    c.CommentDetails = NS_NOT_NULL([dict objectForKey:@"CommentDetails"]);
    c.EmailReceivedDateTimeString = NS_NOT_NULL([dict objectForKey:@"EmailReceivedDateTimeString"]);
    c.FolderId = NS_NOT_NULL([dict objectForKey:@"FolderId"]);
    c.FolderName = NS_NOT_NULL([dict objectForKey:@"FolderName"]);
    
    c.ForUserDetail = [User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"ForUserDetail"])];
    c.GroupId = NS_NOT_NULL([dict objectForKey:@"GroupId"]);
    c.ParentId = NS_NOT_NULL([dict objectForKey:@"ParentId"]);
    c.ParentTypeId = NS_NOT_NULL([dict objectForKey:@"ParentTypeId"]);
    c.PortfolioId = NS_NOT_NULL([dict objectForKey:@"PortfolioId"]);
    c.PortfolioName = NS_NOT_NULL([dict objectForKey:@"PortfolioName"]);
    c.TaskDescription = NS_NOT_NULL([dict objectForKey:@"TaskDescription"]);
    c.TaskDetails = NS_NOT_NULL([dict objectForKey:@"TaskDetails"]);
    NSString* taskID = NS_NOT_NULL([dict objectForKey:@"TaskId"]);
    if([taskID isKindOfClass:[NSString class]])
        c.TaskId = [NSNumber numberWithInteger:[taskID integerValue]];
    else
        c.TaskId = (NSNumber*)taskID;
    c.TotalComments = NS_NOT_NULL([dict objectForKey:@"TotalComments"]);
    
    c.TypeId = NS_NOT_NULL([dict objectForKey:@"TypeId"]);
    c.TypeName = NS_NOT_NULL([dict objectForKey:@"TypeName"]);
    c.ViewedFlag = [NS_NOT_NULL([dict objectForKey:@"ViewedFlag"]) boolValue];
    
    Task* task = [Task getTaskFromDict:dict];
    task.assignee = c.ForUserDetail;
    c.task = task;
    
    NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[[c summary] dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
    NSMutableDictionary* tmp= [NSMutableDictionary dictionary];
    [attrs enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, [attrs length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont *font = (UIFont*)value;
        [tmp setObject:[font fontDescriptor] forKey:NSStringFromRange(range)];
    }];
    
    for(NSString* r in [tmp allKeys])
    {
        NSRange range = NSRangeFromString(r);
        UIFontDescriptor* des = [tmp objectForKey:r];
        NSString* fontface = [des objectForKey:UIFontDescriptorFaceAttribute];
        des = [des fontDescriptorWithFamily:@"Helvetica"];
        des = [des fontDescriptorWithFace:fontface];
        UIFont* font = [UIFont fontWithDescriptor:des size:11.0];
        [attrs addAttribute:NSFontAttributeName value:font range:range];
    }
    c.attrSummary = attrs;
    return c;
}

- (NSString*)summary
{
    NSString* str = self.TypeName;
    if(NSSTRING_HAS_DATA(str))
        str = [str stringByAppendingString:@"\n\n"];
    if(NSSTRING_HAS_DATA(self.TaskDescription))
        str = [str stringByAppendingString:self.TaskDescription];
    if(NSSTRING_HAS_DATA(str))
        str = [str stringByAppendingString:@"\n\n"];
    if(NSSTRING_HAS_DATA(self.TaskDetails))
        str = [str stringByAppendingString:self.TaskDetails];
    return str;
}
@end
