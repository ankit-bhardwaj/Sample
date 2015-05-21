//
//  Portfolio.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "Portfolio.h"
#import "TaskDocument.h"

@implementation Portfolio

+ (Portfolio*) getPortfolioProjectsFromDict:(NSDictionary*)dict
{
    Portfolio* c = [Portfolio new];
    c.PortfolioName = NS_NOT_NULL([dict objectForKey:@"PortfolioName"]);
    c.PortfolioDescription = NS_NOT_NULL([dict objectForKey:@"PortfolioDescription"]);
    c.PortfolioId = [[dict objectForKey:@"PortfolioId"] integerValue];
    NSMutableArray* tmp = [NSMutableArray array];
    for(NSDictionary* d in [dict objectForKey:@"Projects"])
    {
        Project* p = [Project getProjectFromDict:d];
        p.portfolio = c;
        if(c.PortfolioId == -1 && [p.ProjectName isEqualToString:@"My Project"])
           [[TaskDocument sharedInstance] setMyProjectId:[NSString stringWithFormat:@"%d",p.ProjectId]];
        [tmp addObject:p];
    }
    c.Projects = [NSArray arrayWithArray:[tmp sortedArrayUsingSelector:@selector(sortCompare:)]];
    
    NSMutableArray* tmp1 = [NSMutableArray array];
    NSArray* userlist = NS_NOT_NULL([dict objectForKey:@"UserList"]);
    if(userlist && [userlist isKindOfClass:[NSArray class]])
    {
        for(NSDictionary* d in userlist)
        {
            ProjectUser *user = [ProjectUser getProjectUserForDictionary:d];
            [tmp1 addObject:user];
        }
        c.UserList = [NSArray arrayWithArray:tmp1];
    }
    
    c.CanEditPortfolio = [NS_NOT_NULL([dict objectForKey:@"CanEditPortfolio"]) boolValue];
    c.CurrentUserAssociation = [ProjectUser getProjectUserForDictionary: NS_NOT_NULL([dict objectForKey:@"CurrentUserAssociation"])];
    c.CurrentUserCanAddOtherUsers = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanAddOtherUsers"]) boolValue];
    c.CurrentUserCanAddProject = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanAddProject"]) boolValue];
    c.CurrentUserCanEditPortfolio = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanEditPortfolio"]) boolValue];
    c.CurrentUserDeletePortfolio = [NS_NOT_NULL([dict objectForKey:@"CurrentUserDeletePortfolio"]) boolValue];
    c.CurrentUserFollowPortfolio = [NS_NOT_NULL([dict objectForKey:@"CurrentUserFollowPortfolio"]) boolValue];
    c.CurrentUserPemission = [NS_NOT_NULL([dict objectForKey:@"CurrentUserPemission"]) boolValue];
    c.IsCreator = [NS_NOT_NULL([dict objectForKey:@"IsCreator"]) boolValue];
    c.IsShared= [NS_NOT_NULL([dict objectForKey:@"IsShared"]) boolValue];
    c.Owner = [ProjectUser getProjectUserForDictionary: NS_NOT_NULL([dict objectForKey:@"Owner"])];
    return c;
}

- (BOOL)hasProject
{
    BOOL flag = NO;
    for(Project* p in self.Projects)
    {
        if(NSSTRING_HAS_DATA(p.ProjectName))
        {
            flag = YES;
            break;
        }
    }
    return flag;
}

@end

@implementation Project

+ (Project*) getProjectFromDict:(NSDictionary*)dict
{
    Project* c = [Project new];
    c.ProjectName = NS_NOT_NULL([dict objectForKey:@"ProjectName"]);
    c.ProjectNickName = NS_NOT_NULL([dict objectForKey:@"ProjectNickName"]);
    c.ProjectDescription = NS_NOT_NULL([dict objectForKey:@"ProjectDescription"]);
    c.ProjectId = [[dict objectForKey:@"ProjectId"] integerValue];
    NSMutableArray* tmp = [NSMutableArray array];
    NSArray* userlist = NS_NOT_NULL([dict objectForKey:@"UserList"]);
    if(userlist && [userlist isKindOfClass:[NSArray class]])
    {
        for(NSDictionary* d in userlist)
        {
            ProjectUser *user = [ProjectUser getProjectUserForDictionary:d];
            if(user.AssociationType == 2)
                [tmp addObject:user];
        }
        c.UserList = [NSArray arrayWithArray:tmp];
    }
    
    c.CanEditPortfolio = [NS_NOT_NULL([dict objectForKey:@"CanEditPortfolio"]) boolValue];
    c.CurrentUserAssociation = [ProjectUser getProjectUserForDictionary: NS_NOT_NULL([dict objectForKey:@"CurrentUserAssociation"])];
    c.CurrentUserCanAddOtherUsers = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanAddOtherUsers"]) boolValue];
    c.CurrentUserCanArchiveProject = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanArchiveProject"]) boolValue];
    c.CurrentUserCanDeleteAllAttachments = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanDeleteAllAttachments"]) boolValue];
    c.CurrentUserCanDeleteProject = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanDeleteProject"]) boolValue];
    c.CurrentUserCanDownloadProjectAsPdf = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanDownloadProjectAsPdf"]) boolValue];
    c.CurrentUserCanEditProject = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanEditProject"]) boolValue];
    c.CurrentUserCanMoveProject = [NS_NOT_NULL([dict objectForKey:@"CurrentUserCanMoveProject"]) boolValue];
    c.CurrentUserFollowTask = [NS_NOT_NULL([dict objectForKey:@"CurrentUserFollowTask"]) boolValue];
    c.CurrentUserPermission = [NS_NOT_NULL([dict objectForKey:@"CurrentUserPermission"]) boolValue];
    c.IsCreator = [NS_NOT_NULL([dict objectForKey:@"IsCreator"]) boolValue];
    c.IsShared= [NS_NOT_NULL([dict objectForKey:@"IsShared"]) boolValue];
    c.Owner = [ProjectUser getProjectUserForDictionary: NS_NOT_NULL([dict objectForKey:@"Owner"])];
    return c;
}

- (NSComparisonResult)sortCompare:(Project*)other
{
    return [self.ProjectName localizedCaseInsensitiveCompare:other.ProjectName];
}
@end
