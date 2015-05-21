
#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>

@property(nonatomic, retain)NSString    *Email;
@property(nonatomic, retain)NSString    *FirstName;
@property(nonatomic, retain)NSString    *FormattedName;
@property(nonatomic) BOOL               IsGuest;
@property(nonatomic, retain)NSString    *LastName;
@property(nonatomic, retain)NSString    *WcfAccessToken;
@property(nonatomic) BOOL               HasPhoto;
@property(nonatomic, retain)NSString    *MobileImageUrl;
@property(nonatomic, retain)NSString    *UserEmail;
@property(nonatomic,assign) int                UserId;
@property(nonatomic) BOOL               UserUploadedProfileImage;
@property(nonatomic, retain)NSData    *photoData;
@property(nonatomic) BOOL               IsSubscribed;

- (NSString*)displayString;
+ (User*) getUserForDictionary:(NSDictionary*)dict;
+ (void) setUserForDictionary:(NSDictionary*)dict;
+ (User*)currentUser;
+ (void)resetCurrentUser;
@end


@interface ProjectUser : NSObject

@property(nonatomic, assign)int     AssociationType;
@property(nonatomic)BOOL            CanAddOtherUser;
@property(nonatomic)BOOL            Follow;
@property(nonatomic)BOOL            IsUserEnabled;
@property(nonatomic, retain)NSString    *UserName;
@property(nonatomic, assign)int         UserPermission;
@property(nonatomic, retain)NSString    *UserPermissionDescription;
@property(nonatomic, retain)NSString    *UserPermissionDescriptionToDisplay;
@property(nonatomic, retain)User        *UserProfile;

+ (ProjectUser*) getProjectUserForDictionary:(NSDictionary*)dict;
@end


