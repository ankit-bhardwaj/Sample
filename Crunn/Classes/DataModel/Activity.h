//
//  Activity.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/12/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Task.h"

@interface Activity : NSObject

@property(nonatomic, retain)NSString    *ActivityDateString;
@property(nonatomic, retain)NSNumber    *ActivityId;
@property(nonatomic, retain)NSString    *ActivityText;

@property(nonatomic, retain)NSArray    *AttachmentList;
@property(nonatomic, retain)User        *ByUserDetail;
@property(nonatomic, retain)NSString    *CommentDetails;

@property(nonatomic, retain)NSString    *EmailReceivedDateTimeString;
@property(nonatomic, retain)NSNumber    *FolderId;
@property(nonatomic, retain)NSString    *FolderName;

@property(nonatomic, retain)User        *ForUserDetail;
@property(nonatomic, retain)NSNumber    *GroupId;
@property(nonatomic, retain)NSNumber    *ParentId;

@property(nonatomic, retain)NSNumber    *ParentTypeId;
@property(nonatomic, retain)NSNumber    *PortfolioId;
@property(nonatomic, retain)NSString    *PortfolioName;
@property(nonatomic, retain)NSString    *TaskDescription;

@property(nonatomic, retain)NSString    *TaskDetails;
@property(nonatomic, retain)NSNumber    *TaskId;
@property(nonatomic, retain)NSNumber    *TotalComments;

@property(nonatomic, retain)NSNumber    *TypeId;
@property(nonatomic, retain)NSString    *TypeName;
@property(nonatomic, assign)BOOL        ViewedFlag;

@property(nonatomic, retain)NSAttributedString    *attrSummary;

@property(nonatomic, retain)Task        *task;

+ (Activity*) getActivityFromDict:(NSDictionary*)dict;

- (NSString*)summary;

@end
