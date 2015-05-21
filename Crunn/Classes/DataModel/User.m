
//
//  User.m
//  iBetting
//
//  Created by Ashish Maheshwari on 4/7/14.
//  Copyright (c) 2014 Fellax Labs. All rights reserved.
//

#import "User.h"

static User* _user = nil;

@implementation User
@synthesize Email;
@synthesize FirstName;
@synthesize FormattedName;
@synthesize IsGuest;
@synthesize LastName;
@synthesize WcfAccessToken;
@synthesize HasPhoto;
@synthesize MobileImageUrl;
@synthesize UserEmail;
@synthesize UserId;
@synthesize UserUploadedProfileImage;
@synthesize IsSubscribed;

- (NSString*)displayString
{
    return [FirstName stringByAppendingFormat:@" %@",LastName];
}

+ (User*) getUserForDictionary:(NSDictionary*)dict
{
    User* c = [User new];
    c.Email = NS_NOT_NULL([dict objectForKey:@"Email"]);
    c.FirstName = NS_NOT_NULL([dict objectForKey:@"FirstName"]);
    c.FormattedName = NS_NOT_NULL([dict objectForKey:@"FormattedName"]);
    
    c.IsGuest = [[dict objectForKey:@"IsGuest"] boolValue];
    c.IsSubscribed = [[dict objectForKey:@"IsSubscribed"] boolValue];
    c.LastName = NS_NOT_NULL([dict objectForKey:@"LastName"]);
    NSString* token = NS_NOT_NULL([dict objectForKey:@"WcfAccessToken"]);
    if(NSSTRING_HAS_DATA(token))
        c.WcfAccessToken = token;
    c.HasPhoto = [[dict objectForKey:@"HasPhoto"] boolValue];
    c.MobileImageUrl = NS_NOT_NULL([dict objectForKey:@"MobileImageUrl"]);
    c.UserEmail = NS_NOT_NULL([dict objectForKey:@"UserEmail"]);
    c.UserId = [[dict objectForKey:@"UserId"] intValue];
    
    c.UserUploadedProfileImage = [[dict objectForKey:@"UserUploadedProfileImage"] boolValue];
    
    return c;
}

+ (void) setUserForDictionary:(NSDictionary*)dict
{
    User* c = [User getUserForDictionary:dict];

    _user = c;
    NSData* d = [NSKeyedArchiver archivedDataWithRootObject:_user];
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:@"User"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (User*)currentUser
{
    if(!_user)
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSData* data = [defaults objectForKey:@"User"];
        if(data && data.length > 0)
        {
            _user = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else
            return nil;
    }
    return _user;
}

+ (void)resetCurrentUser
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"User"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _user = nil;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.Email forKey:@"Email"];
    [coder encodeObject:self.FirstName forKey:@"FirstName"];
    [coder encodeObject:self.FormattedName forKey:@"FormattedName"];
    [coder encodeBool:self.IsGuest forKey:@"IsGuest"];
    [coder encodeBool:self.IsSubscribed forKey:@"IsSubscribed"];
    [coder encodeObject:self.LastName forKey:@"LastName"];
    [coder encodeObject:self.WcfAccessToken forKey:@"WcfAccessToken"];
    [coder encodeBool:self.HasPhoto forKey:@"HasPhoto"];
    [coder encodeObject:self.MobileImageUrl forKey:@"MobileImageUrl"];
    [coder encodeObject:self.UserEmail forKey:@"UserEmail"];
    [coder encodeInteger:self.UserId forKey:@"UserId"];
    [coder encodeBool:self.UserUploadedProfileImage forKey:@"UserUploadedProfileImage"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init]))
	{
        self.Email = [coder decodeObjectForKey:@"Email"];
        self.FirstName = [coder decodeObjectForKey:@"FirstName"];
        self.FormattedName = [coder decodeObjectForKey:@"FormattedName"];
        self.IsGuest = [coder decodeBoolForKey:@"IsGuest"];
        self.IsSubscribed = [coder decodeBoolForKey:@"IsSubscribed"];
        self.LastName = [coder decodeObjectForKey:@"LastName"];
        self.WcfAccessToken = [coder decodeObjectForKey:@"WcfAccessToken"];
        self.HasPhoto = [coder decodeBoolForKey:@"HasPhoto"];
        self.MobileImageUrl = [coder decodeObjectForKey:@"MobileImageUrl"];
        self.UserEmail = [coder decodeObjectForKey:@"UserEmail"];
        self.UserId = [coder decodeIntForKey:@"UserId"];
        self.UserUploadedProfileImage = [coder decodeBoolForKey:@"UserUploadedProfileImage"];
    }
    return self;

}

@end

@implementation ProjectUser


+ (ProjectUser*) getProjectUserForDictionary:(NSDictionary*)dict
{
    ProjectUser* c = [ProjectUser new];
    c.AssociationType = [NS_NOT_NULL([dict objectForKey:@"AssociationType"]) intValue];
    c.CanAddOtherUser = [NS_NOT_NULL([dict objectForKey:@"CanAddOtherUser"]) boolValue];
    c.Follow = [NS_NOT_NULL([dict objectForKey:@"Follow"]) boolValue];
    
    c.IsUserEnabled = [[dict objectForKey:@"IsUserEnabled"] boolValue];
    c.UserName = NS_NOT_NULL([dict objectForKey:@"UserName"]);
    c.UserPermission = [[dict objectForKey:@"UserPermission"] intValue];
    c.UserPermissionDescription = NS_NOT_NULL([dict objectForKey:@"UserPermissionDescription"]);
    c.UserPermissionDescriptionToDisplay = NS_NOT_NULL([dict objectForKey:@"UserPermissionDescriptionToDisplay"]);
    c.UserProfile = [User getUserForDictionary:[dict objectForKey:@"UserProfile"]];
    
    return c;
}

@end


