//
//  TaskDocument.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
#import "Portfolio.h"
#import "PDKBaseDocument.h"
#import "Comment.h"

@interface TaskDocument : PDKBaseDocument
@property(nonatomic,retain)NSMutableArray*  homeFeeds;
@property(nonatomic,retain)NSMutableArray*  myTaskFeed;
@property(nonatomic,retain)NSMutableArray*  myAgendaFeed;
@property(nonatomic,assign)BOOL             homeFeedUpdateRequire;
@property(nonatomic,assign)BOOL             myTaskFeedUpdateRequire;
@property(nonatomic,assign)BOOL             homeFeedTaskUpdateRequire;
@property(nonatomic,retain)NSMutableArray*  taskSortingCategories;
@property(nonatomic,retain)NSMutableArray*  portfolios;
@property(nonatomic,retain)NSMutableArray*  projects;
@property(nonatomic,retain)NSMutableArray*  assignees;
@property(nonatomic,retain)NSMutableArray*  activities;
@property(nonatomic,retain)NSMutableArray*  taskComments;
@property(nonatomic,retain)NSMutableArray*  taskUserList;
@property(nonatomic,retain)NSMutableArray*  taskStatusList;
@property(nonatomic,retain)TaskSortCategory* sortCategory;
@property(nonatomic,assign)BOOL             isHomeFeedCollaspe;
@property(nonatomic,assign)BOOL             isMyTasksCollaspe;
@property(nonatomic,assign)NSInteger        homeFeedIndex;
@property(nonatomic,assign)NSInteger        myTaskFeedIndex;
@property(nonatomic,assign)BOOL             closedTask;
@property(nonatomic,assign)NSInteger       taskCommentIndex;
@property(nonatomic,assign)NSInteger        recentActivityIndex;
@property(nonatomic,retain)Project          *selectedProject;
@property(nonatomic,retain)Portfolio       *selectedPortfolio;
@property(nonatomic,retain)NSString*        myProjectId;
@property(nonatomic,assign)NSInteger        editingComment;
@property(nonatomic,retain)NSMutableArray*  allABContacts;
@property(nonatomic,assign)BOOL             hasJustCreatedPortfolio;
@property(nonatomic,retain)NSMutableDictionary*  searchCriteria;

+(TaskDocument*)sharedInstance;

- (void)getProjectList;
- (void)getTaskStatusList;
- (void)getAssigneeListForSearch:(NSString*)searchTerm;
- (void)createTask:(NSDictionary*)dict;
- (void)uploadTaskAttachments:(NSArray*)array;
- (void)refreshHomeFeed;
- (void)getHomeFeed;
- (void)getHomeFeedForPortfolio:(Portfolio*)portfolio andProject:(Project*)p;
- (void)getTaskSortingCategories:(NSString*)listCat;
- (void)getRecentFeed;
- (void)refreshRecentFeed;

//Task
- (void)getTaskDetailForId:(NSNumber*)taskID;
- (void)refreshTaskCommentsForId:(NSNumber*)taskID;
- (void)getTaskCommentsForId:(NSNumber*)taskID;
- (void)getTaskUserListForId:(NSNumber*)taskID;
- (void)setTaskStatusComplete:(NSNumber*)taskID;
- (void)setTaskStatusNew:(NSNumber*)taskID;
- (void)setTaskStatusAccepted:(NSNumber*)taskID;
- (void)deleteTask:(NSNumber*)taskID;
- (void)ChangeFollowTask:(NSNumber*)taskID follow:(NSString*)follow;
- (void)saveCommentNudgeForTaskId:(NSNumber*)taskID;
- (void)updateTask:(NSDictionary*)dict;
- (void)postComment:(NSDictionary*)params;
- (void)shareTask:(Task*)task withUser:(User*)other andFollow:(BOOL)follow;
- (void)setStatus:(NSString*)status taskID:(NSNumber*)taskId;
- (void)deleteComment:(Comment*)comment ofTaskId:(NSNumber*)taskId;

//Portfolio
- (void)createPortfolio:(NSDictionary*)dict;
- (void)createProject:(NSDictionary*)dict;
- (void)getPortfolio:(Portfolio*)portfolio;
- (void)getProject:(Project*)project;
- (void)editPortfolio:(NSDictionary*)dict;
- (void)editProject:(NSDictionary*)dict;
- (void)addUser:(User*)adduser forPortfolio:(Portfolio*)portfolio andFollow:(BOOL)follow andCanAddUser:(BOOL)canAdd;
- (void)addUser:(User*)adduser forProject:(Project*)project  andFollow:(BOOL)follow andCanAddUser:(BOOL)canAdd;
- (void)deleteUser:(ProjectUser*)user forPortfolio:(Portfolio*)portfolio;
- (void)deleteUser:(ProjectUser*)deluser forProject:(Project*)project;

- (void)purgePrivateData;

//My Tasks
- (void)refreshMyTasks;
- (void)getMyTaskFeed;
- (void)setMyAgenda:(BOOL)flag forTask:(NSNumber*)taskId withOrder:(NSString*)taskOrder;

- (void)setReminder:(AutoReminder*)reminder forTaskId:(Task*)task;
- (void)removeReminder:(AutoReminder*)reminder forTaskId:(Task*)task;

- (void)requestForABAccess;
-(NSArray *)contactsContainingEmail:(NSString *)email;
-(NSArray *)getAllABContacts;

- (void)refreshSearchFeed;
- (void)getSearchFeed;
@end
