//
//  UserDocument.h
//  mygivingbook
//
//  Created by Ashish Maheshwari on 7/6/13.
//
//

#import <Foundation/Foundation.h>
#import "PDKBaseDocument.h"
#import "User.h"

@interface UserDocument : PDKBaseDocument


@property(nonatomic,retain)NSMutableArray* timeZones;
+(UserDocument*)sharedInstance;
- (void)fetchTimeZones;
- (void)loginWithUsername:(NSString*)username andPassword:(NSString*)password;
- (void)registerWithUser:(NSDictionary*)jsonDictionary;
- (void)forgotPasswordForUsername:(NSString*)username;
-(void)enablePushNotification:(BOOL)allow;
- (void)getUserProfile;
@end
