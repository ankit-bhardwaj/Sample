//
//  Portfolio.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Portfolio : NSObject
@property(nonatomic, retain)NSArray    *Projects;
@property(nonatomic, retain)NSString   *PortfolioName;
@property(nonatomic, retain)NSString    *PortfolioDescription;
@property(nonatomic, assign)NSInteger  PortfolioId;
@property(nonatomic, retain)NSArray     *UserList;
@property(nonatomic)BOOL                CanEditPortfolio;
@property(nonatomic,retain)ProjectUser* CurrentUserAssociation;
@property(nonatomic)BOOL                CurrentUserCanAddOtherUsers;
@property(nonatomic)BOOL                CurrentUserCanAddProject;
@property(nonatomic)BOOL                CurrentUserCanEditPortfolio;
@property(nonatomic)BOOL                CurrentUserDeletePortfolio;
@property(nonatomic)BOOL                CurrentUserFollowPortfolio;
@property(nonatomic)int                 CurrentUserPemission;
@property(nonatomic)BOOL                IsCreator;
@property(nonatomic)BOOL                IsShared;
@property(nonatomic,retain)ProjectUser* Owner;
@property(nonatomic, retain)NSString   *CreatedDateString;

+ (Portfolio*) getPortfolioProjectsFromDict:(NSDictionary*)dict;
- (BOOL)hasProject;
@end


@interface Project : NSObject

@property(nonatomic, retain)NSString    *ProjectNickName;
@property(nonatomic, retain)NSString    *ProjectName;
@property(nonatomic, retain)NSString    *ProjectDescription;
@property(nonatomic, assign)NSUInteger  ProjectId;
@property(nonatomic, retain)Portfolio   *portfolio;
@property(nonatomic, retain)NSArray     *UserList;
@property(nonatomic)BOOL                CanEditPortfolio;
@property(nonatomic,retain)ProjectUser* CurrentUserAssociation;
@property(nonatomic)BOOL                CurrentUserCanAddOtherUsers;
@property(nonatomic)BOOL                CurrentUserCanArchiveProject;
@property(nonatomic)BOOL                CurrentUserCanDeleteAllAttachments;
@property(nonatomic)BOOL                CurrentUserCanDeleteProject;
@property(nonatomic)BOOL                CurrentUserCanDownloadProjectAsPdf;
@property(nonatomic)BOOL                CurrentUserCanEditProject;
@property(nonatomic)BOOL                CurrentUserCanMoveProject;
@property(nonatomic)BOOL                CurrentUserFollowTask;
@property(nonatomic)int                 CurrentUserPermission;
@property(nonatomic)BOOL                IsCreator;
@property(nonatomic)BOOL                IsShared;
@property(nonatomic,retain)ProjectUser* Owner;
@property(nonatomic, retain)NSString   *CreatedDateString;

+ (Project*) getProjectFromDict:(NSDictionary*)dict;
- (NSComparisonResult)sortCompare:(Project*)other;

@end
