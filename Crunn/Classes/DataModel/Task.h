//
//  Task.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Portfolio.h"
#import "User.h"
#include <MapKit/MapKit.h>

typedef enum
{
    TaskStatusNew           = 1,
    TaskStatusAccept        = 4,
    TaskStatusDecline       = 3,
    TaskStatus25Complete    = 6,
    TaskStatus50Complete    = 7,
    TaskStatus75Complete    = 8,
    TaskStatusCompleted     = 2,
}TaskStatus;
@class AutoReminder;
@class Location;
@interface Task : NSObject

@property (nonatomic, retain) NSNumber       *taskId;
@property (nonatomic, retain) NSString       *name;
@property (nonatomic, retain) NSString       *summary;
@property (nonatomic, retain) NSMutableAttributedString       *attrSummary;
@property (nonatomic)         BOOL           highPriority;
@property (nonatomic, retain) Project        *project;
@property (nonatomic, retain) NSString*     ProjectName;
@property (nonatomic, retain) User          *assignee;
@property (nonatomic, retain) User*         creator;
@property (nonatomic, retain) NSDate        *dueDate;
@property (nonatomic, retain) NSMutableArray*comments;
@property (nonatomic, retain) NSString*     CreatedOnTimeString;
@property (nonatomic, retain) NSNumber*     totalComments;
@property (nonatomic, retain) NSString*     CompletedOnString;
@property (nonatomic, retain) NSString*     CompletedByName;
@property (nonatomic, retain) NSNumber*     CompletedById;
@property (nonatomic, assign) BOOL          IsCompleted;
@property (nonatomic, retain) NSString*     DueDateString;
@property (nonatomic, retain) NSString*     DoDateString;
@property (nonatomic, retain) NSString*     LastUpdateDateTimeString;
@property (nonatomic, retain) NSDate*       lastUpdatedDate;
@property (nonatomic, assign) BOOL          CanEdit;
@property (nonatomic, assign) BOOL          CanEditAssignee;
@property (nonatomic, assign) BOOL          CanEditStatus;
@property (nonatomic, retain) NSNumber*     CircleId;
@property (nonatomic, retain) NSString*     StatusTypeDescription;
@property (nonatomic, assign) BOOL          CommentVisibility;
@property (nonatomic, assign) BOOL          isCollapsed;
@property (nonatomic, retain) NSNumber*     FollowTaskFlag;
@property (nonatomic, retain) NSNumber*     StatusTypeId;
@property (nonatomic, retain) NSNumber*     LastUpdatedBy;
@property (nonatomic, retain) NSNumber*     GroupId;
@property (nonatomic, assign) TaskStatus    taskStatus;
@property (nonatomic, retain) NSArray*      Attachments;
@property (nonatomic, retain) NSArray*      UserList;
@property (nonatomic, retain) NSString*     ColorCode;
@property (nonatomic, assign) BOOL          HasNudge;
@property (nonatomic, assign) BOOL          BelongsToTodaysAgenda;
@property (nonatomic, assign) BOOL          HasReminder;
@property (nonatomic, retain) AutoReminder* AutoReminder;

@property (nonatomic, assign) BOOL          editingComment;
@property (nonatomic, assign) BOOL          attachComment;
@property (nonatomic, retain) NSString*     tempComment;
@property (nonatomic, retain) NSMutableArray*     tempCommentFilePaths;
@property (nonatomic, retain) NSMutableArray*     tempCommentDBFilePaths;
@property (nonatomic, retain) Location*     location;

+ (Task*) getTaskFromDict:(NSDictionary*)dict;
- (NSComparisonResult)sortCompare:(Task*)other;
- (UIImage*)getTaskStatusImage;
- (NSString*)getTaskStatusName;
+ (TaskStatus)getTaskStatus:(NSString*)status;
@end



@interface TaskSortCategory : NSObject

@property(nonatomic, retain)NSNumber    *DisplayOrder;
@property(nonatomic, retain)NSString    *SortByColumnScript;
@property(nonatomic, retain)NSString    *SortByDescription;
@property(nonatomic, retain)NSNumber    *SortId;


+ (TaskSortCategory*) getTaskCategoryFromDict:(NSDictionary*)dict;
+ (TaskSortCategory*)createTaskSortCategory;
+ (TaskSortCategory*)deafultTaskSortCategory;
+ (TaskSortCategory*)deafultPortfolioTaskSortCategory;
@end


@interface TaskUser : NSObject

@property(nonatomic, retain)NSNumber    *AssociationType;
@property(nonatomic, assign)BOOL        Follow;
@property(nonatomic, assign)BOOL        IsUserEnabled;
@property(nonatomic, retain)NSNumber    *UserPermission;
@property(nonatomic, retain)User        *UserProfile;


+ (TaskUser*) getTaskUserFromDict:(NSDictionary*)dict;
@end

@interface AutoReminder : NSObject

@property(nonatomic, retain)NSNumber    *DaysFrequency;
@property(nonatomic, assign)BOOL        IsReminderToday;
@property(nonatomic, retain)NSNumber    *ReminderId;
@property(nonatomic, retain)NSDate      *ReminderStartDate;
@property(nonatomic, retain)NSNumber    *TaskId;
@property(nonatomic, retain)NSString    *Title;
@property(nonatomic, retain)NSNumber    *UserId;

+ (AutoReminder*) getAutoReminderFromDict:(NSDictionary*)dict;
- (NSString*) displayString;
- (void)setDaysFrequencyFromString:(NSString*)str;
- (NSString*)getDaysFrequencyString;
@end

@interface Location : NSObject<MKAnnotation>

@property(nonatomic, retain)NSNumber    *latitude;
@property(nonatomic, retain)NSNumber    *longitude;
@property(nonatomic, assign)CLLocationCoordinate2D coordinate;
@property(nonatomic, retain)NSString    *address;

+ (Location*) getLocationFromDict:(NSDictionary*)dict;

@end
