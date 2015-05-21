//
//  TaskDocument.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/9/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TaskDocument.h"
#import "PDKBaseOperation.h"
#import "User.h"
#import "Portfolio.h"
#import "Activity.h"
#import "NSData+Base64.h"
#include <AddressBook/AddressBook.h>
#import "LocationService.h"

static TaskDocument* _sharedInstance = nil;

@implementation TaskDocument
{
    PDKBaseOperation* _homeFeedOp;
    PDKBaseOperation* _myTaskFeedOp;
    PDKBaseOperation* _recentFeedOp;
    
    PDKBaseOperation* _myAgendaTaskOp;
    
    PDKBaseOperation* _taskDetailOp;
    PDKBaseOperation* _taskCommentOp;
    PDKBaseOperation* _taskUserListOp;
    
    PDKBaseOperation* _taskStatusChangeOp;
    PDKBaseOperation* _getTaskStatusListOp;
    
    PDKBaseOperation* _projectListOp;
    PDKBaseOperation* _assigneeListOp;
    PDKBaseOperation* _shareTaskOp;
    
    PDKBaseOperation* _createTaskOp;
    PDKBaseOperation* _updateTaskOp;
    PDKBaseOperation* _deleteTaskOp;
    
    PDKBaseOperation* _setReminderOp;
    PDKBaseOperation* _removeReminderOp;
    
    PDKBaseOperation* _changeFollowTaskOp;
    PDKBaseOperation* _uploadTaskAttachmentOp;
    PDKBaseOperation* _postCommentOp;
    PDKBaseOperation* _deleteCommentOp;
    
    PDKBaseOperation* _taskSortingListOp;
    
    PDKBaseOperation* _createPortfolioOp;
    PDKBaseOperation* _createProjectOp;
    
    PDKBaseOperation* _editPortfolioOp;
    PDKBaseOperation* _editProjectOp;
    
    PDKBaseOperation* _getPortfolioOp;
    PDKBaseOperation* _getProjectOp;
    
    PDKBaseOperation* _addPortfolioUserOp;
    PDKBaseOperation* _addProjectUserOp;
    
    PDKBaseOperation* _deletePortfolioUserOp;
    PDKBaseOperation* _deleteProjectUserOp;
    
    
    NSMutableArray* _taskAttachmentFiles;
    NSString*       _attachmentFolderName;
    
    
}

+(TaskDocument*)sharedInstance
{
    if(_sharedInstance == nil)
    {
        _sharedInstance = [[TaskDocument alloc] init];
    }
    return _sharedInstance;
}

- (id)init
{
    if( self == [super init])
    {
        _homeFeeds = [[NSMutableArray alloc] init];
        _myTaskFeed = [[NSMutableArray alloc] init];
        _myAgendaFeed = [[NSMutableArray alloc] init];
        _portfolios = [[NSMutableArray alloc] init];
        _assignees = [[NSMutableArray alloc] init];
        _activities = [[NSMutableArray alloc] init];
        _taskSortingCategories = [[NSMutableArray alloc] init];
        _taskComments = [[NSMutableArray alloc] init];
        _taskUserList = [[NSMutableArray alloc] init];
        _taskStatusList = [[NSMutableArray alloc] init];
        _allABContacts = [[NSMutableArray alloc] init];
        _projects = [[NSMutableArray alloc] init];
        _searchCriteria = [[NSMutableDictionary alloc] init];
        self.sortCategory =[TaskSortCategory createTaskSortCategory];
        self.homeFeedUpdateRequire = YES;
        [self getTaskStatusList];
    }
    return self;
}

- (void)getHomeFeedForPortfolio:(Portfolio*)portfolio andProject:(Project*)p
{
    if(_homeFeedOp)
        return;
    
    [self.searchCriteria removeAllObjects];
    self.closedTask = NO;
    if(portfolio == nil)
        self.sortCategory = [TaskSortCategory deafultTaskSortCategory];
    else
        self.sortCategory = [TaskSortCategory deafultPortfolioTaskSortCategory];
    self.selectedPortfolio = portfolio;
    self.selectedProject = p;
    [self.homeFeeds removeAllObjects];
    _homeFeedIndex = 0;
    [self getHomeFeed];
}

- (void)refreshHomeFeed
{
    if(_homeFeedOp)
        return;
    
    _homeFeedIndex = 0;
    [self getHomeFeed];
}

- (void)getHomeFeed
{
    if(_homeFeedOp)
        return;
    
    _homeFeedIndex++;
    User* user = [User currentUser];
    
    NSData *jsonData;
    NSMutableURLRequest *request;
    if(self.searchCriteria.count == 0)
    {
        NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetTasks",BASE_SERVER_PATH];
        
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
        
        NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId", SESSION_KEY,@"sessionId",self.sortCategory.SortByColumnScript,@"taskSortBy",@"Home",@"listCategory",[NSNumber numberWithBool:self.closedTask],@"closedTask",[NSNumber numberWithInt:_homeFeedIndex],@"pageNumber",[NSNumber numberWithInt:10],@"pageSize",[NSNumber numberWithInt:3],@"commentCount",nil];
        
        if(self.selectedProject)
            [jsonDictionary setObject:[NSString stringWithFormat:@"%ld",self.selectedProject.ProjectId] forKey:@"projectId"];
        
        if(self.selectedPortfolio)
            [jsonDictionary setObject:[NSString stringWithFormat:@"%ld",self.selectedPortfolio.PortfolioId] forKey:@"portfolioId"];
        
        // Encode the message in JSON
        NSError *jsonError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    }
    else
    {
        NSString* path = [NSString stringWithFormat:@"%@/Search.svc/SearchTasks",BASE_SERVER_PATH];
        
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
        
        NSString* searchTerm = [self.searchCriteria objectForKey:@"searchKey"];
        //NSString* wordTerm = [self.searchCriteria objectForKey:@"wordKey"];
        NSArray* assignees = [self.searchCriteria objectForKey:@"assignee"];
        NSArray* creators = [self.searchCriteria objectForKey:@"creators"];
        NSArray* portfolios = [self.searchCriteria objectForKey:@"portfolios"];
        NSArray* projects = [self.searchCriteria objectForKey:@"project"];
        NSString* taskStatus = [self.searchCriteria objectForKey:@"includeDoneTask"];
        NSMutableString* assigneeTerms = [NSMutableString string];
        NSMutableString* creatorsTerms = [NSMutableString string];
        NSMutableString* portfolioTerms = [NSMutableString string];
        NSMutableString* projectTerms = [NSMutableString string];
        
        for(User* p in assignees)
        {
            if([assigneeTerms length] > 0)
                [assigneeTerms appendString:@","];
            [assigneeTerms appendFormat:@"%d",p.UserId];
        }
        for(User* p in creators)
        {
            if([creatorsTerms length] > 0)
                [creatorsTerms appendString:@","];
            [creatorsTerms appendFormat:@"%d",p.UserId];
        }
        
        for(Portfolio* p in portfolios)
        {
            if([portfolioTerms length] > 0)
                [portfolioTerms appendString:@","];
            [portfolioTerms appendFormat:@"%ld",(long)p.PortfolioId];
        }
        
        for(Project* p in projects)
        {
            if([projectTerms length] > 0)
                [projectTerms appendString:@","];
            [projectTerms appendFormat:@"%lu",(unsigned long)p.ProjectId];
        }
        
        
        NSMutableDictionary* searchDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"DueDays", @"N",@"Attachment",[NSNull null],@"SearchText",assigneeTerms,@"assignee",creatorsTerms,@"CreatedBy",[NSNull null],@"EndDueDate",taskStatus,@"TaskStatus",searchTerm,@"TxtSearchText",projectTerms,@"InProject",[NSNull null],@"StartDueDate",portfolioTerms,@"InPortfolio", nil];
        
        NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"LogInUserId", SESSION_KEY,@"SessionId",searchDict,@"SearchCriteria",[NSNumber numberWithInt:_homeFeedIndex],@"PageNumber",[NSNumber numberWithInt:10],@"PageSize",[NSNumber numberWithInt:3],@"CommentCount",nil];
        
        
        // Encode the message in JSON
        NSError *jsonError = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObject:jsonDictionary forKey:@"msgIn"] options:0 error:&jsonError];
    }
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _homeFeedOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_homeFeedOp];
}


- (void)refreshSearchFeed
{
    if(_homeFeedOp)
    {
        [_homeFeedOp cancel];
        _homeFeedOp = nil;
    }
    
    _homeFeedIndex = 0;
    [self getSearchFeed];
}

- (void)getSearchFeed
{
    if(_homeFeedOp)
        return;
    
    _homeFeedIndex++;
    User* user = [User currentUser];
    
    NSString* path = [NSString stringWithFormat:@"%@/Search.svc/SearchTasks",BASE_SERVER_PATH];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSString* searchTerm = [self.searchCriteria objectForKey:@"searchKey"];
    NSString* wordTerm = [self.searchCriteria objectForKey:@"wordKey"];
    NSArray* assignees = [self.searchCriteria objectForKey:@"assignee"];
    NSArray* creators = [self.searchCriteria objectForKey:@"creators"];
    NSArray* portfolios = [self.searchCriteria objectForKey:@"portfolios"];
    NSArray* projects = [self.searchCriteria objectForKey:@"project"];
    NSString* taskStatus = [self.searchCriteria objectForKey:@"includeDoneTask"];
    NSMutableString* assigneeTerms = [NSMutableString string];
    NSMutableString* creatorsTerms = [NSMutableString string];
    NSMutableString* portfolioTerms = [NSMutableString string];
    NSMutableString* projectTerms = [NSMutableString string];
    
    for(User* p in assignees)
    {
        if([assigneeTerms length] > 0)
            [assigneeTerms appendString:@","];
        [assigneeTerms appendFormat:@"%d",p.UserId];
    }
    for(User* p in creators)
    {
        if([creatorsTerms length] > 0)
            [creatorsTerms appendString:@","];
        [creatorsTerms appendFormat:@"%d",p.UserId];
    }
    
    for(Portfolio* p in portfolios)
    {
        if([portfolioTerms length] > 0)
            [portfolioTerms appendString:@","];
        [portfolioTerms appendFormat:@"%ld",(long)p.PortfolioId];
    }
    
    for(Project* p in projects)
    {
        if([projectTerms length] > 0)
            [projectTerms appendString:@","];
        [projectTerms appendFormat:@"%lu",(unsigned long)p.ProjectId];
    }
    
    
    NSMutableDictionary* searchDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"DueDays", @"N",@"Attachment",[NSNull null],@"SearchText",assigneeTerms,@"assignee",creatorsTerms,@"CreatedBy",[NSNull null],@"EndDueDate",taskStatus,@"TaskStatus",searchTerm,@"TxtSearchText",projectTerms,@"InProject",[NSNull null],@"StartDueDate",portfolioTerms,@"InPortfolio", nil];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"LogInUserId", SESSION_KEY,@"SessionId",searchDict,@"SearchCriteria",[NSNumber numberWithInt:_homeFeedIndex],@"PageNumber",[NSNumber numberWithInt:10],@"PageSize",[NSNumber numberWithInt:3],@"CommentCount",nil];
    
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObject:jsonDictionary forKey:@"msgIn"] options:0 error:&jsonError];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _homeFeedOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_homeFeedOp];
}

- (void)refreshMyTasks
{
    if(_myTaskFeedOp)
        return;
    
    _myTaskFeedIndex = 0;
    [self getMyTaskFeed];
}

- (void)getMyTaskFeed
{
    if(_myTaskFeedOp)
        return;
    
    _myTaskFeedIndex++;
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetTasks",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId", SESSION_KEY,@"sessionId",self.sortCategory.SortByColumnScript,@"taskSortBy",@"MyTask",@"listCategory",[NSNumber numberWithBool:self.closedTask],@"closedTask",[NSNumber numberWithInt:_myTaskFeedIndex],@"pageNumber",[NSNumber numberWithInt:10],@"pageSize",[NSNumber numberWithInt:0],@"commentCount",nil];
    
//    if(self.selectedProject)
//        [jsonDictionary setObject:[NSString stringWithFormat:@"%d",self.selectedProject.ProjectId] forKey:@"projectId"];
//    
//    if(self.selectedPortfolio)
//        [jsonDictionary setObject:[NSString stringWithFormat:@"%d",self.selectedPortfolio.PortfolioId] forKey:@"portfolioId"];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _myTaskFeedOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_myTaskFeedOp];
}

- (void)setMyAgenda:(BOOL)flag forTask:(NSNumber*)taskId withOrder:(NSString*)taskOrder
{
    if(_myAgendaTaskOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/SaveTaskOrder",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:taskOrder, @"ids", taskId,@"movedTaskId",[NSNumber numberWithBool:flag],@"movedToMyTask",[NSString stringWithFormat:@"%d",user.UserId],@"logInUserId",nil];
    
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _myAgendaTaskOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_myAgendaTaskOp];
}

- (void)getTaskSortingCategories:(NSString*)listCat
{
    if(_taskSortingListOp)
        return;
    
    User* user = [User currentUser];
    
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetSortColumn",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:listCat, @"listCategory",nil];
    
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _taskSortingListOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_taskSortingListOp];
}

- (void)refreshRecentFeed
{
    if(_recentFeedOp)
        return;
    
    _recentActivityIndex = 0;
    [self getRecentFeed];
}

- (void)getRecentFeed
{
    if(_recentFeedOp)
        return;
    
    _recentActivityIndex++;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetUserRecentActivities?sessionId=%@&pageNumber=%@&pageSize=%@&userId=%d",BASE_SERVER_PATH,SESSION_KEY,[NSString stringWithFormat:@"%d",_recentActivityIndex],@"10",user.UserId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _recentFeedOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_recentFeedOp];
}

- (void)getTaskDetailForId:(NSNumber*)taskID
{
    if(_taskDetailOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetTaskById?taskId=%@&sessionId=%@&logInUserId=%d",BASE_SERVER_PATH,[taskID stringValue],SESSION_KEY,user.UserId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _taskDetailOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_taskDetailOp];
}

- (void)refreshTaskCommentsForId:(NSNumber*)taskID
{
    if(_taskCommentOp)
        return;
    [_taskComments removeAllObjects];
    _taskCommentIndex = 0;
    [self getTaskCommentsForId:taskID];
}

- (void)getTaskCommentsForId:(NSString*)taskID
{
    if(_taskCommentOp)
        return;
    
    _taskCommentIndex++;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetTaskComments?taskId=%@&sessionId=%@&pageNumber=%@&pageSize=%@&logInUserId=%d",BASE_SERVER_PATH,taskID,SESSION_KEY,[NSString stringWithFormat:@"%ld",(long)_taskCommentIndex],@"5",user.UserId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    //[request setHTTPMethod:@"POST"];
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _taskCommentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_taskCommentOp];
}

- (void)getTaskUserListForId:(NSString*)taskID
{
    if(_taskUserListOp)
        return;
    [_taskUserList removeAllObjects];
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetTaskUsers",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId",taskID,@"taskId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _taskUserListOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_taskUserListOp];
}

- (void)getTaskStatusList
{
    if(_getTaskStatusListOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/GetTaskStatusList",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _getTaskStatusListOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_getTaskStatusListOp];
}


- (void)setTaskStatusComplete:(NSString*)taskID
{
    if(_taskStatusChangeOp)
        return;
    
    NSString* status = nil;
    if([_taskStatusList count]<=0)
        status = @"Completed";
    else
        status = [_taskStatusList lastObject];
    
    [self setStatus:status taskID:taskID];
}

- (void)setTaskStatusNew:(NSString*)taskID
{
    if(_taskStatusChangeOp)
        return;
    
    NSString* status = nil;
    if([_taskStatusList count]<=0)
        status = @"New";
    else
        status = [_taskStatusList firstObject];
    
    [self setStatus:status taskID:taskID];
}

- (void)setTaskStatusAccepted:(NSString*)taskID
{
    if(_taskStatusChangeOp)
        return;
    
    NSString* status = nil;
    if([_taskStatusList count]<=0)
        status = @"Accept";
    else
        status = [_taskStatusList objectAtIndex:1];
    
    [self setStatus:status taskID:taskID];
}

- (void)setStatus:(NSString*)status taskID:(NSString*)taskId
{
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/ChangeTaskStatus",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:user.UserId], @"logInUserId",[NSNumber numberWithInteger:[taskId intValue]],@"taskId",status,@"taskStatus", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _taskStatusChangeOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_taskStatusChangeOp];
}

- (void)getProjectList
{
    if(_projectListOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/GetUserPortFolioProjects",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _projectListOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_projectListOp];
}


- (void)getAssigneeListForSearch:(NSString*)searchTerm
{
    if(_assigneeListOp)
        return;
    
    if(!searchTerm)
        searchTerm = @"";
    [_assignees removeAllObjects];
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/GetUserAddressBook",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId", searchTerm,@"prefix",@"-1",@"returncount",nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _assigneeListOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_assigneeListOp];
}

- (void)shareTask:(Task*)task withUser:(User*)other andFollow:(BOOL)follow
{
    if(_shareTaskOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/ShareTask",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",task.taskId,@"taskId",other.Email,@"email",[NSNumber numberWithInt:follow],@"FollowTask",nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _shareTaskOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_shareTaskOp];
}


- (void)createTask:(NSDictionary*)dict
{
    if(_createTaskOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/PutTask",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _createTaskOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_createTaskOp];
}

- (void)updateTask:(NSDictionary*)dict
{
    if(_updateTaskOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/UpdateTask",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _updateTaskOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_updateTaskOp];
}


- (void)uploadTaskAttachments:(NSArray*)array
{
    if(_uploadTaskAttachmentOp)
        return;
    _attachmentFolderName = nil;

    if(!_taskAttachmentFiles)
        _taskAttachmentFiles = [[NSMutableArray alloc] init];
    [_taskAttachmentFiles removeAllObjects];
    [_taskAttachmentFiles addObjectsFromArray:array];
    [self uploadTaskAttachment];
}

- (void)uploadTaskAttachment
{
    if(_uploadTaskAttachmentOp)
        return;
    
    NSString* filePath = [_taskAttachmentFiles firstObject];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/UploadFile",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",[filePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    [request setHTTPMethod:@"POST"];
    
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    NSDictionary *headerFieldsDict = nil;
    if(NSSTRING_HAS_DATA( _attachmentFolderName))
    {
        headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:contentType, @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",_attachmentFolderName,@"tempFolderName",SESSION_KEY,@"sessionId",nil];
    }
    else
    {
        headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:contentType, @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",nil];
    }
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _uploadTaskAttachmentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_uploadTaskAttachmentOp];
}

- (void)setReminder:(AutoReminder*)reminder forTaskId:(Task*)task
{
    if(_setReminderOp)
        return;
    
    if(!reminder.ReminderId)reminder.ReminderId = [NSNumber numberWithInt:0];
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/PutTaskReminder",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];//2014-10-31T16:54:00
    NSDictionary *reminderDict = [NSDictionary dictionaryWithObjectsAndKeys:[reminder.DaysFrequency stringValue], @"DaysFrequency",reminder.IsReminderToday?@"true":@"false", @"IsReminderToday",[reminder.ReminderId stringValue], @"ReminderId",[self jsonStringFormDate:reminder.ReminderStartDate], @"ReminderStartDate",[task.taskId stringValue], @"TaskId",@"", @"Title", nil];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:reminderDict,@"taskreminder",[NSNumber numberWithInt:user.UserId], @"logInUserId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _setReminderOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_setReminderOp];
}

- (NSString*) jsonStringFormDate:(NSDate*)date
{
    //provide string in this format " /Date(1288933200000-0400)/ "
    if ( date )
    {
        NSNumber* seconds = [NSNumber numberWithLongLong:[date timeIntervalSince1970]*1000];
        NSString* sec = [seconds stringValue];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"Z"];
        NSString* timeZone = [formatter stringFromDate:date];
        
        return [NSString stringWithFormat:@"/Date(%@%@)/",sec,timeZone];
    }
    else
        return nil;
}

- (void)removeReminder:(AutoReminder*)reminder forTaskId:(Task*)task
{
    if(_removeReminderOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/RemoveTaskReminder",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];//2014-10-31T16:54:00
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:task.taskId, @"taskId",[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",  nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _removeReminderOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_removeReminderOp];
}


- (void)ChangeFollowTask:(NSString*)taskID follow:(NSString*)follow
{
    if(_changeFollowTaskOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/ChangeFollowTask",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
     NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",taskID,@"taskId",follow,@"follow", nil];
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _changeFollowTaskOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_changeFollowTaskOp];
}

- (void)deleteTask:(NSString*)taskID
{
    if(_deleteTaskOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/DeleteTask",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",taskID,@"taskId", nil];
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _deleteTaskOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_deleteTaskOp];
}

- (void)saveCommentNudgeForTaskId:(NSString*)taskID
{
    if(_postCommentOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/PutComment",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",taskID,@"taskId",@"",@"commentDetails",SESSION_KEY,@"sessionId",@"www",@"tempFolderName",[NSNumber numberWithBool:YES],@"isNudge", nil];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"])
    {
        if(![LocationService isValidLocation])
        {
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enable location services in iphone location settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else
        {
            [jsonDictionary setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.latitude] forKey:@"latitude"];
            [jsonDictionary setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.longitude] forKey:@"longtitude"];
            [jsonDictionary setObject:[LocationService addressString] forKey:@"locationAddress"];
        }
    }
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _postCommentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_postCommentOp];
}


- (void)postComment:(NSDictionary*)params
{
    if(_postCommentOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/PutComment",BASE_SERVER_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
       // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _postCommentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_postCommentOp];
}

- (void)deleteComment:(Comment*)comment ofTaskId:(NSString*)taskId
{
    if(_deleteCommentOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Task.svc/DeleteComment",BASE_SERVER_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
     NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",taskId,@"taskId",comment.commentId,@"commentId",SESSION_KEY,@"sessionId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _deleteCommentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_deleteCommentOp];
}



- (void)createPortfolio:(NSDictionary*)dict
{
    if(_createPortfolioOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/CreatePortfolio",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _createPortfolioOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_createPortfolioOp];
}

- (void)createProject:(NSDictionary*)dict
{
    if(_createProjectOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/CreateProject",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _createProjectOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_createProjectOp];
}

- (void)editPortfolio:(NSDictionary*)dict
{
    if(_editPortfolioOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/EditPortfolio",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _editPortfolioOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_editPortfolioOp];
}

- (void)editProject:(NSDictionary*)dict
{
    if(_editProjectOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/EditProject",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _editProjectOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_editProjectOp];
}


- (void)getPortfolio:(Portfolio*)portfolio
{
    if(_getPortfolioOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/GetPortfolio",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",[NSString stringWithFormat:@"%ld",(long)portfolio.PortfolioId],@"portfolioId",nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _getPortfolioOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_getPortfolioOp];
}

- (void)getProject:(Project*)project
{
    if(_getProjectOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/GetProject",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
     NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",[NSString stringWithFormat:@"%d",project.ProjectId],@"projectId",nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _getProjectOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_getProjectOp];
}

- (void)addUser:(User*)adduser forPortfolio:(Portfolio*)portfolio andFollow:(BOOL)follow  andCanAddUser:(BOOL)canAdd
{
    if(_addPortfolioUserOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/AddPortfolioUser",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",portfolio.PortfolioId], @"portfolioId",adduser.Email,@"email",[NSNumber numberWithBool:canAdd],@"canAddOtherUser",[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",[NSNumber numberWithBool:follow],@"follow", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _addPortfolioUserOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_addPortfolioUserOp];
}

- (void)addUser:(User*)adduser forProject:(Project*)project  andFollow:(BOOL)follow andCanAddUser:(BOOL)canAdd
{
    if(_addProjectUserOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/AddProjectUser",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",project.ProjectId], @"projectId",adduser.Email,@"email",[NSNumber numberWithBool:canAdd],@"canAddOtherUser",project.ProjectName,@"projectName",[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",[NSNumber numberWithBool:follow],@"follow", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    _addProjectUserOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_addProjectUserOp];
}

- (void)deleteUser:(ProjectUser*)user forPortfolio:(Portfolio*)portfolio
{
    if(_deletePortfolioUserOp)
        return;
    
    User* loginUser = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/DeletePortfolioUser",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",portfolio.PortfolioId], @"portfolioId",[NSString stringWithFormat:@"%d",loginUser.UserId], @"logInUserId",[NSString stringWithFormat:@"%d",user.UserProfile.UserId],@"deleteUserId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",loginUser.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _deletePortfolioUserOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_deletePortfolioUserOp];
}

- (void)deleteUser:(ProjectUser*)deluser forProject:(Project*)project
{
    if(_deleteProjectUserOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/PortfolioProject.svc/DeleteProjectUser",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",project.ProjectId], @"projectId",[NSString stringWithFormat:@"%d",user.UserId], @"logInUserId",[NSString stringWithFormat:@"%d",deluser.UserProfile.UserId],@"deleteUserId", nil];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    _deleteProjectUserOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_deleteProjectUserOp];
}

#pragma mark-
#pragma mark PDKLoadingOpProtocol
- (void)operation:(PDKBaseOperation *)theOp didFinishWithData:(id)dataObj
{
	if ( theOp )
	{
        if(theOp == _homeFeedOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetTasksResult"];
            if(!result)
                result = [dict objectForKey:@"SearchTasksResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                self.homeFeedUpdateRequire = NO;
                if(_homeFeedIndex == 1)
                    [_homeFeeds removeAllObjects];
                
                if(result.count==0)
                    _homeFeedIndex--;
                
                for(NSDictionary* d in result)
                {
                    Task* task = [Task getTaskFromDict:d];
                    task.isCollapsed = _isHomeFeedCollaspe;
                    [_homeFeeds addObject:task];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeFeedNotifier" object:result];
            }
            else
            {
                _homeFeedIndex--;
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeFeedNotifier" object:nil];
            }
            
            if (theOp == _homeFeedOp)
                _homeFeedOp = nil;
        }
        else if(theOp == _myTaskFeedOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetTasksResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                if(_myTaskFeedIndex == 1)
                {
                    [_myTaskFeed removeAllObjects];
                    [_myAgendaFeed removeAllObjects];
                }
                
                if(result.count==0)
                    _myTaskFeedIndex--;
                
                for(NSDictionary* d in result)
                {
                    Task* t = [Task getTaskFromDict:d];
                    t.isCollapsed = _isMyTasksCollaspe;
                    if(t.BelongsToTodaysAgenda)
                        [_myAgendaFeed addObject:t];
                    else
                        [_myTaskFeed addObject:t];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyTaskFeedNotifier" object:result];
            }
            else
            {
                _myTaskFeedIndex--;
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyTaskFeedNotifier" object:nil];
            }
            
            if (theOp == _myTaskFeedOp)
                _myTaskFeedOp = nil;
        }
        else if(theOp == _myAgendaTaskOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"SaveTaskOrderResult"];
            
            if(result && [result isKindOfClass:[NSString class]] && [result isEqualToString:@"Success"])
            {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAgendaTaskNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAgendaTaskNotifier" object:nil];
            }
            
            if (theOp == _myAgendaTaskOp)
                _myAgendaTaskOp = nil;
        }
        else if(theOp == _taskSortingListOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetSortColumnResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                [_taskSortingCategories removeAllObjects];
                
                for(NSDictionary* d in result)
                {
                    if([[d objectForKey:@"SortByColumnScript"] localizedCaseInsensitiveCompare:@"sort"] != NSOrderedSame )
                        [_taskSortingCategories addObject:[TaskSortCategory getTaskCategoryFromDict:d]];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskSortingListNotifier" object:nil];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskSortingListNotifier" object:msg];
            }
            
            if (theOp == _taskSortingListOp)
                _taskSortingListOp = nil;
        }
        else if(theOp == _recentFeedOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetUserRecentActivitiesResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                if(_recentActivityIndex ==  1)
                    [_activities removeAllObjects];
                
                if(result.count==0)
                    _recentActivityIndex--;
                
                for(NSDictionary* d in result)
                    [_activities addObject:[Activity getActivityFromDict:d]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RecentActivityNotifier" object:result];
            }
            else
            {
                _recentActivityIndex--;
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RecentActivityNotifier" object:nil];
            }
            
            if (theOp == _recentFeedOp)
                _recentFeedOp = nil;
        }
        else if(theOp == _taskDetailOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"GetTaskByIdResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                Task* task = [Task getTaskFromDict:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskDetailNotifier" object:task];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskDetailNotifier" object:msg];
            }
            
            if (theOp == _taskDetailOp)
                _taskDetailOp = nil;
        }
        else if(theOp == _taskCommentOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetTaskCommentsResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                if(_taskCommentIndex ==  1)
                    [_taskComments removeAllObjects];
                
                if(result.count==0)
                    _taskCommentIndex--;
                NSMutableArray* tmp = [NSMutableArray array];
                for(NSDictionary* d in result)
                    [tmp addObject:[Comment getCommentFromDict:d]];
                
                [_taskComments insertObjects:[[tmp reverseObjectEnumerator] allObjects] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tmp count])]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskCommentNotifier" object:_taskComments];
            }
            else
            {
                _taskCommentIndex--;
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskCommentNotifier" object:msg];
            }
            
            if (theOp == _taskCommentOp)
                _taskCommentOp = nil;
        }
        else if(theOp == _taskUserListOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetTaskUsersResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                
                for(NSDictionary* d in result)
                    [_taskUserList addObject:[TaskUser getTaskUserFromDict:d]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskUserListNotifier" object:_taskUserList];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskUserListNotifier" object:msg];
            }
            
            if (theOp == _taskUserListOp)
                _taskUserListOp = nil;
        }
        else if(theOp == _getTaskStatusListOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetTaskStatusListResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                [_taskStatusList removeAllObjects];
                [_taskStatusList addObjectsFromArray:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskStatusListNotifier" object:nil];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskStatusListNotifier" object:msg];
            }
            
            if (theOp == _getTaskStatusListOp)
                _getTaskStatusListOp = nil;
        }
        else if(theOp == _taskStatusChangeOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"ChangeTaskStatusResult"];
            
            if(result && [[result lowercaseString] isEqualToString:@"success"])
            {
                self.homeFeedUpdateRequire = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskStatusChangeNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskStatusChangeNotifier" object:msg];
            }
            
            if (theOp == _taskStatusChangeOp)
                _taskStatusChangeOp = nil;
        }
        else if(theOp == _postCommentOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"PutCommentResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                Comment* cmnt = [Comment getCommentFromDict:result];
                self.homeFeedTaskUpdateRequire = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommentNotifier" object:cmnt];
            }
            else
            {
                NSString* msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommentNotifier" object:msg];
            }
            
            if (theOp == _postCommentOp)
                _postCommentOp = nil;
        }
        else if(theOp == _projectListOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetUserPortFolioProjectsResult"];
            
            if(result && [result isKindOfClass:[NSArray class]] && result.count > 0)
            {
                [_portfolios removeAllObjects];
                [_projects removeAllObjects];
                for(NSDictionary* d in result)
                {
                    Portfolio* portfolio = [Portfolio getPortfolioProjectsFromDict:d];
                    [_portfolios addObject:portfolio];
                    [_projects addObjectsFromArray:portfolio.Projects];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectListNotifier" object:nil];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectListNotifier" object:msg];
            }
            
            if (theOp == _projectListOp)
                _projectListOp = nil;
        }
        else if(theOp == _assigneeListOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetUserAddressBookResult"];
            
            if(result && [result isKindOfClass:[NSArray class]] && result.count > 0)
            {
                for(NSDictionary* d in result)
                    [_assignees addObject:[User getUserForDictionary:d]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AssigneeListNotifier" object:nil];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AssigneeListNotifier" object:msg];
            }
            
            if (theOp == _assigneeListOp)
                _assigneeListOp = nil;
        }
        else if(theOp == _createTaskOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"PutTaskResult"];
            
            if(result && [result isKindOfClass:[NSString class]] && [[result lowercaseString] isEqualToString:@"success"])
            {
                self.homeFeedUpdateRequire = YES;
                self.myTaskFeedUpdateRequire = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateTaskNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else if(result && [result isKindOfClass:[NSDictionary class]])
            {
                Task* task = [Task getTaskFromDict:(NSDictionary*)result];
                [_homeFeeds insertObject:task atIndex:0];
                _homeFeedTaskUpdateRequire = YES;
                self.myTaskFeedUpdateRequire = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateTaskNotifier" object:task];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateTaskNotifier" object:msg];
            }
            
            if (theOp == _createTaskOp)
                _createTaskOp = nil;
        }
        else if(theOp == _updateTaskOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"UpdateTaskResult"];
            
            if(result && [[result lowercaseString] isEqualToString:@"success"])
            {
                self.homeFeedUpdateRequire = YES;
                self.myTaskFeedUpdateRequire = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTaskNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTaskNotifier" object:msg];
            }
            
            if (theOp == _updateTaskOp)
                _updateTaskOp = nil;
        }
        
        else if(theOp == _deleteTaskOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"DeleteTaskResult"];
            
            if(result && [[result lowercaseString] isEqualToString:@"success"])
            {
                self.homeFeedUpdateRequire = YES;
                self.myTaskFeedUpdateRequire = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteTaskNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteTaskNotifier" object:msg];
            }
            
            if (theOp == _deleteTaskOp)
                _deleteTaskOp = nil;
        }
        else if(theOp == _changeFollowTaskOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"ChangeFollowTaskResult"];
            
            if(result && [[result lowercaseString] isEqualToString:@"success"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFollowTaskNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFollowTaskNotifier" object:msg];
            }
            
            if (theOp == _changeFollowTaskOp)
                _changeFollowTaskOp = nil;
        }
        else if(theOp == _shareTaskOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"ShareTaskResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareTaskNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareTaskNotifier" object:msg];
            }
            
            if (theOp == _shareTaskOp)
                _shareTaskOp = nil;
        }
        else if(theOp == _uploadTaskAttachmentOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            if (theOp == _uploadTaskAttachmentOp)
                _uploadTaskAttachmentOp = nil;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"UploadFileResult"];
            
            if(result && [result isKindOfClass:[NSString class]] && NSSTRING_HAS_DATA(result))
            {
                //self.homeFeedUpdateRequire = YES;
                [_taskAttachmentFiles removeObjectAtIndex:0];
                
                if([_taskAttachmentFiles count]==0)
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadTaskAttachmentNotifier" object:[NSDictionary dictionaryWithObject:result forKey:@"TempFolderName"]];
                else
                {
                    _attachmentFolderName = result;
                    [self performSelectorOnMainThread:@selector(uploadTaskAttachment) withObject:nil waitUntilDone:NO];
                }
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [_taskAttachmentFiles removeAllObjects];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadTaskAttachmentNotifier" object:msg];
            }
        }
        else if(theOp == _deleteCommentOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"DeleteCommentResult"];
            
            if(result && [result isKindOfClass:[NSString class]])
            {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteCommentNotifier" object:[NSNumber numberWithInt:1]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteCommentNotifier" object:msg];
            }
            if (theOp == _deleteCommentOp)
                _deleteCommentOp = nil;
        }
        else if(theOp == _createPortfolioOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"CreatePortfolioResult"];
            
            if(result && [result isKindOfClass:[NSNumber class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePortfolioNotifier" object:result];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePortfolioNotifier" object:msg];
            }
            
            if (theOp == _createPortfolioOp)
                _createPortfolioOp = nil;
        }
        else if(theOp == _createProjectOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"CreateProjectResult"];
            
            if(result && (result && [result isKindOfClass:[NSNumber class]]))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateProjectNotifier" object:result];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateProjectNotifier" object:msg];
            }
            
            if (theOp == _createProjectOp)
                _createProjectOp = nil;
        }
        else if(theOp == _editPortfolioOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"EditPortfolioResult"];
            
            if(result && [result isKindOfClass:[NSNumber class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPortfolioNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPortfolioNotifier" object:msg];
            }
            
            if (theOp == _editPortfolioOp)
                _editPortfolioOp = nil;
        }
        else if(theOp == _editProjectOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"EditProjectResult"];
            
            if(result && (result && [result isKindOfClass:[NSNumber class]]))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EditProjectNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EditProjectNotifier" object:msg];
            }
            
            if (theOp == _editProjectOp)
                _editProjectOp = nil;
        }
        else if(theOp == _getPortfolioOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"GetPortfolioResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                Portfolio* portfolio = [Portfolio getPortfolioProjectsFromDict:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPortfolioNotifier" object:portfolio];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPortfolioNotifier" object:msg];
            }
            
            if (theOp == _getPortfolioOp)
                _getPortfolioOp = nil;
        }
        else if(theOp == _getProjectOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"GetProjectResult"];
            
            if(result && (result && [result isKindOfClass:[NSDictionary class]]))
            {
                Project* proj = [Project getProjectFromDict:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetProjectNotifier" object:proj];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetProjectNotifier" object:msg];
            }
            
            if (theOp == _getProjectOp)
                _getProjectOp = nil;
        }
        else if(theOp == _addPortfolioUserOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"AddPortfolioUserResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                ProjectUser* user = [ProjectUser getProjectUserForDictionary:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddPortfolioUserNotifier" object:user];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddPortfolioUserNotifier" object:msg];
            }
            
            if (theOp == _addPortfolioUserOp)
                _addPortfolioUserOp = nil;
        }
        else if(theOp == _addProjectUserOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"AddProjectUserResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                ProjectUser* user = [ProjectUser getProjectUserForDictionary:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddProjectUserNotifier" object:user];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddProjectUserNotifier" object:msg];
            }
            
            if (theOp == _addProjectUserOp)
                _addProjectUserOp = nil;
        }
        else if(theOp == _deletePortfolioUserOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"DeletePortfolioUserResult"];
            
            if(result && [[result lowercaseString] isEqualToString:@"success"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePortfolioUserNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePortfolioUserNotifier" object:msg];
            }
            
            if (theOp == _deletePortfolioUserOp)
                _deletePortfolioUserOp = nil;
        }
        else if(theOp == _deleteProjectUserOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"DeleteProjectUserResult"];
            
            if(result && [[result lowercaseString] isEqualToString:@"success"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteProjectUserNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteProjectUserNotifier" object:msg];
            }
            
            if (theOp == _deleteProjectUserOp)
                _deleteProjectUserOp = nil;
        }
        else if(theOp == _setReminderOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"PutTaskReminderResult"];
            
            if(result)
            {
                AutoReminder* reminder = [AutoReminder getAutoReminderFromDict:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetReminderNotifier" object:reminder];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetReminderNotifier" object:msg];
            }
            
            if (theOp == _setReminderOp)
                _setReminderOp = nil;
        }
        else if(theOp == _removeReminderOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSNumber* result = [dict objectForKey:@"RemoveTaskReminderResult"];
            
            if(result && [result isKindOfClass:[NSNumber class]] && [result intValue] == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveReminderNotifier" object:[NSNumber numberWithBool:YES]];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveReminderNotifier" object:msg];
            }
            
            if (theOp == _removeReminderOp)
                _removeReminderOp = nil;
        }
    }
}

- (void)operation:(PDKBaseOperation *)theOp didFinishWithError:(NSError *)err
{
    if(theOp == _projectListOp)
    {
        _projectListOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProjectListNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _assigneeListOp)
    {
        _assigneeListOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AssigneeListNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _createTaskOp)
    {
        _createTaskOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateTaskNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _updateTaskOp)
    {
        _updateTaskOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTaskNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _deleteTaskOp)
    {
        _deleteTaskOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteTaskNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _changeFollowTaskOp)
    {
        _changeFollowTaskOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFollowTaskNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _uploadTaskAttachmentOp)
    {
        _uploadTaskAttachmentOp = nil;
        [_taskAttachmentFiles removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadTaskAttachmentNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _homeFeedOp)
    {
        _homeFeedIndex--;
        _homeFeedOp = nil;
        [APPDELEGATE performSelectorOnMainThread:@selector(startShowingNoNetworkAlert) withObject:nil waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeFeedNotifier" object:[err description]];
    }
    else if(theOp == _myTaskFeedOp)
    {
        _myTaskFeedIndex--;
        _myTaskFeedOp = nil;
        [APPDELEGATE performSelectorOnMainThread:@selector(startShowingNoNetworkAlert) withObject:nil waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyTaskFeedNotifier" object:[err localizedFailureReason]];
    }
    else if(theOp == _recentFeedOp)
    {
        _recentActivityIndex--;
        _recentFeedOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecentActivityNotifier" object:nil];
    }
    else if(theOp == _taskCommentOp)
    {
        _taskCommentIndex--;
        _taskCommentOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskCommentNotifier" object:nil];
    }
    else if(theOp == _taskSortingListOp)
    {
        _taskSortingListOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskSortingListNotifier" object:nil];
    }
    else if(theOp == _taskUserListOp)
    {
        _taskUserListOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskUserListNotifier" object:nil];
    }
    else if(theOp == _taskStatusChangeOp)
    {
        _taskStatusChangeOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TaskStatusChangeNotifier" object:nil];
    }
    else if(theOp == _getTaskStatusListOp)
    {
        _getTaskStatusListOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskStatusListNotifier" object:nil];
    }
    else if(theOp == _postCommentOp)
    {
        _postCommentOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommentNotifier" object:[err localizedFailureReason]];
    }
    else if(theOp == _taskDetailOp)
    {
        _taskDetailOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTaskDetailNotifier" object:nil];
    }
    else if(theOp == _shareTaskOp)
    {
        _shareTaskOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareTaskNotifier" object:nil];
    }
    else if(theOp == _deleteCommentOp)
    {
        _deleteCommentOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteCommentNotifier" object:nil];
    }
    else if(theOp == _createPortfolioOp)
    {
        _createPortfolioOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePortfolioNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _createProjectOp)
    {
        _createProjectOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateProjectNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _editPortfolioOp)
    {
        _editPortfolioOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditPortfolioNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _editProjectOp)
    {
        _editProjectOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditProjectNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _getPortfolioOp)
    {
        _getPortfolioOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetPortfolioNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _getProjectOp)
    {
        _getProjectOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetProjectNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _addPortfolioUserOp)
    {
        _addPortfolioUserOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddPortfolioUserNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _addProjectUserOp)
    {
        _addProjectUserOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddProjectUserNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _deletePortfolioUserOp)
    {
        _deletePortfolioUserOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePortfolioUserNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _deleteProjectUserOp)
    {
        _deleteProjectUserOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteProjectUserNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _myAgendaTaskOp)
    {
        _myAgendaTaskOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAgendaTaskNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _setReminderOp)
    {
        _setReminderOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetReminderNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _removeReminderOp)
    {
        _removeReminderOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveReminderNotifier" object:[err localizedDescription]];
    }
}

- (void)purgePrivateData
{
    [_homeFeeds removeAllObjects];
    [_myTaskFeed removeAllObjects];
    [_myAgendaFeed removeAllObjects];
    [_portfolios removeAllObjects];
    [_projects removeAllObjects];
    [_assignees removeAllObjects];
    [_activities removeAllObjects];
    [_taskSortingCategories removeAllObjects];
    [_taskComments removeAllObjects];
    [_taskUserList removeAllObjects];
    [_taskStatusList removeAllObjects];
    [_allABContacts removeAllObjects];
    self.sortCategory =[TaskSortCategory createTaskSortCategory];
    self.homeFeedUpdateRequire = YES;
    self.myTaskFeedUpdateRequire = YES;
    self.homeFeedTaskUpdateRequire = YES;
    self.isHomeFeedCollaspe = YES;
    self.isMyTasksCollaspe = YES;
    self.homeFeedIndex = 0;
    self.myTaskFeedIndex = 0;
    self.taskCommentIndex = 0;
    self.recentActivityIndex = 0;
    
    self.selectedPortfolio = nil;
    self.selectedProject = nil;
    
    if(_homeFeedOp){[_homeFeedOp cancel];_homeFeedOp = nil;}
    if(_myTaskFeedOp){[_myTaskFeedOp cancel];_myTaskFeedOp = nil;}
    if(_recentFeedOp){[_recentFeedOp cancel];_recentFeedOp = nil;}
    if(_myAgendaTaskOp){[_myAgendaTaskOp cancel];_myAgendaTaskOp = nil;}
    if(_taskDetailOp){[_taskDetailOp cancel];_taskDetailOp = nil;}
    if(_taskCommentOp){[_taskCommentOp cancel]; _taskCommentOp = nil; }
    if(_taskUserListOp){[_taskUserListOp cancel];_taskUserListOp = nil;}
    if(_taskStatusChangeOp){[_taskStatusChangeOp cancel];_taskStatusChangeOp = nil;}
    if(_getTaskStatusListOp){[_getTaskStatusListOp cancel];_getTaskStatusListOp = nil;}
    if(_projectListOp){[_projectListOp cancel];_projectListOp = nil;}
    if(_assigneeListOp){[_assigneeListOp cancel];_assigneeListOp = nil;}
    if(_shareTaskOp){[_shareTaskOp cancel];_shareTaskOp = nil;}
    if(_createTaskOp){[_createTaskOp cancel];_createTaskOp = nil;}
    if(_updateTaskOp){[_updateTaskOp cancel];_updateTaskOp = nil;}
    if(_deleteTaskOp){[_deleteTaskOp cancel];_deleteTaskOp = nil;}
    if(_setReminderOp){[_setReminderOp cancel];_setReminderOp = nil;}
    if(_removeReminderOp){[_removeReminderOp cancel];_removeReminderOp = nil;}
    if(_changeFollowTaskOp){[_changeFollowTaskOp cancel];_changeFollowTaskOp = nil;}
    if(_uploadTaskAttachmentOp){[_uploadTaskAttachmentOp cancel];_uploadTaskAttachmentOp = nil;}
    if(_postCommentOp){[_postCommentOp cancel];_postCommentOp = nil;}
    if(_deleteCommentOp){[_deleteCommentOp cancel];_deleteCommentOp = nil;}
    if(_taskSortingListOp){[_taskSortingListOp cancel];_taskSortingListOp = nil;}
    if(_createPortfolioOp){[_createPortfolioOp cancel];_createPortfolioOp = nil;}
    if(_createProjectOp){[_createProjectOp cancel];_createProjectOp = nil;}
    if(_editPortfolioOp){[_editPortfolioOp cancel];_editPortfolioOp = nil;}
    if(_editProjectOp){[_editProjectOp cancel];_editProjectOp = nil;}
    if(_getPortfolioOp){[_getPortfolioOp cancel];_getPortfolioOp = nil;}
    if(_getProjectOp){[_getProjectOp cancel];_getProjectOp = nil;}
    if(_addPortfolioUserOp){[_addPortfolioUserOp cancel];_addPortfolioUserOp = nil;}
    if(_addProjectUserOp){[_addProjectUserOp cancel];_addProjectUserOp = nil;}
    if(_deletePortfolioUserOp){[_deletePortfolioUserOp cancel];_deletePortfolioUserOp = nil;}
    if(_deleteProjectUserOp){[_deleteProjectUserOp cancel];_deleteProjectUserOp = nil;}

}


- (void)requestForABAccess
{
    ABAddressBookRef addbook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addbook, ^(bool granted, CFErrorRef error){
        if(granted)
        {
        }
        else
        {
        }
    });
}

-(NSArray *)contactsContainingEmail:(NSString *)email
{
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return [NSArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSArray array];
    }
    
    
    NSMutableArray* results = [NSMutableArray array];
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef emails = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonEmailProperty);
        BOOL result = NO;
        for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
            NSString *contactEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, i);
            if ([[contactEmail lowercaseString] rangeOfString:[email lowercaseString]].location != NSNotFound) {
                result = YES;
                User* user = [User new];
                user.FormattedName = (__bridge NSString*)ABRecordCopyCompositeName((__bridge ABRecordRef)(record));
                user.Email = contactEmail;
                user.photoData = (__bridge NSData*)ABPersonCopyImageData((__bridge ABRecordRef)(record));
                [results addObject:user];
                break;
            }
        }
        CFRelease(emails);
        return result;
    }];
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);
    return results;
}

-(NSMutableArray *)getAllABContacts
{
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return [NSMutableArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSMutableArray array];
    }
    
    
    NSMutableArray* results = [NSMutableArray array];
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef emails = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonEmailProperty);
        BOOL result = NO;
        for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
            NSString *contactEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emails, i);
                result = YES;
                User* user = [User new];
                user.FormattedName = (__bridge NSString*)ABRecordCopyCompositeName((__bridge ABRecordRef)(record));
                user.Email = contactEmail;
                user.photoData = (__bridge NSData*)ABPersonCopyImageData((__bridge ABRecordRef)(record));
                [results addObject:user];
                break;
        }
        CFRelease(emails);
        return result;
    }];
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);
    [_allABContacts removeAllObjects];
    [_allABContacts addObjectsFromArray:results];
    return results;
}

@end
