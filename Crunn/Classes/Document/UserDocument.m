//
//  UserDocument.m
//  mygivingbook
//
//  Created by Ashish Maheshwari on 7/6/13.
//
//

#import "UserDocument.h"
#import "PDKBaseOperation.h"
#import "User.h"
#import "TimeZone.h"

static UserDocument* _sharedInstance = nil;

@implementation UserDocument
{
    PDKBaseOperation* _timeZoneOp;
    PDKBaseOperation* _loginOp;
    PDKBaseOperation* _signupOp;
    PDKBaseOperation* _forgotPasswordOp;
    PDKBaseOperation* _getUserProfileOp;
    PDKBaseOperation* _enablePushNotificationOp;
}




+(UserDocument*)sharedInstance
{
    if(_sharedInstance == nil)
    {
        _sharedInstance = [[UserDocument alloc] init];
    }
    return _sharedInstance;
}

- (id)init
{
    if( self == [super init])
    {
        _timeZones = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fetchTimeZones
{
    if(_timeZoneOp)
        return;
    
    NSString* path = [NSString stringWithFormat:@"%@/UtilityWebService.svc/GetTimeZones",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];

    
    [request setHTTPMethod:@"POST"];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _timeZoneOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_timeZoneOp];
}


- (void)loginWithUsername:(NSString*)username andPassword:(NSString*)password
{
    if(_loginOp)
        return;
    
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/Login",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"userName", password, @"password", nil];
   
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _loginOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_loginOp];
}

- (void)registerWithUser:(NSDictionary*)jsonDictionary
{
    if(_signupOp)
        return;
   
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/Register",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _signupOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_signupOp];
}

- (void)forgotPasswordForUsername:(NSString*)username
{
    if(_forgotPasswordOp)
        return;
    
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/ForgotPassword",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
     NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:username, @"email", nil];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
   
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _forgotPasswordOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_forgotPasswordOp];
}


- (void)getUserProfile
{
    if(_getUserProfileOp)
        return;
    
    User* user = [User currentUser];
    
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/GetUserProfileById?userId=%d",BASE_SERVER_PATH,user.UserId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    [request setHTTPMethod:@"GET"];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _getUserProfileOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_getUserProfileOp];
}

-(void)enablePushNotification:(BOOL)allow
{
    if(_enablePushNotificationOp)
        return;
    
    User* user = [User currentUser];
    
    NSString* path = [NSString stringWithFormat:@"%@/User.svc/SetNotification",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId",[self authToken], @"registrationKey",APP_KEY, @"appKey",[NSNumber numberWithBool:allow], @"notify",nil];
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId", nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _enablePushNotificationOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_enablePushNotificationOp];
}


#pragma mark-
#pragma mark PDKLoadingOpProtocol
- (void)operation:(PDKBaseOperation *)theOp didFinishWithData:(id)dataObj
{
	if ( theOp )
	{
        if(theOp == _timeZoneOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetTimeZonesResult"];
            
            if(result && result.count)
            {
                [self.timeZones removeAllObjects];
                for(NSDictionary* d in result)
                    [self.timeZones addObject:[TimeZone getTimeZone:d]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeZoneNotifier" object:self.timeZones];
            }
            else
            {
                //[self.timeZones removeAllObjects];
                //[self.timeZones addObjectsFromArray:[NSTimeZone knownTimeZoneNames]];
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeZoneNotifier" object:self.timeZones];
            }
            
            if (theOp == _timeZoneOp)
                _timeZoneOp = nil;
        }
        else if(theOp == _loginOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* LoginResult = [dict objectForKey:@"LoginResult"];
            
            int UserId = [[LoginResult objectForKey:@"UserId"] integerValue];
            // -1 if login fails
            if(UserId > 0)
            {
                [User setUserForDictionary:LoginResult];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotifier" object:nil];
            }
            else
            {
                NSString* msg = @"Not a valid email or password.";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotifier" object:msg];
            }
            
           if (theOp == _loginOp)
                _loginOp = nil;
        }
        else if(theOp == _signupOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* LoginResult = [dict objectForKey:@"RegisterResult"];
            
            NSInteger UserId = [[LoginResult objectForKey:@"UserId"] integerValue];
            // -1 if login fails
            if(UserId > 0)
            {
                [User setUserForDictionary:LoginResult];
                [self performSelectorOnMainThread:@selector(getUserProfile) withObject:nil waitUntilDone:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RegisterNotifier" object:nil];
            }
            else
            {
                NSString* msg = nil;
                //if ([msg length] <= 0) {
                    //msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                //}
                
                //msg = @"We already have an account with this email address in our system. If it belongs to you and you have forgotten the password, please click on 'Forgot Password' on the login screen.";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RegisterNotifier" object:@"AlreadyHaveAnAccount"];
            }
            
            if (theOp == _signupOp)
                _signupOp = nil;
            
        }
        else if(theOp == _forgotPasswordOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            BOOL result = [[dict objectForKey:@"ForgotPasswordResult"] boolValue];
            
            
            // -1 if login fails
            if(result)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ForgotPasswordNotifier" object:nil];
            }
            else
            {
                NSString* msg = @"We don't have this email address in our records.";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ForgotPasswordNotifier" object:msg];
            }
            
            if (theOp == _forgotPasswordOp)
                _forgotPasswordOp = nil;
        }
        else if(theOp == _getUserProfileOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* LoginResult = [dict objectForKey:@"GetUserProfileByIdResult"];
            
            int UserId = [[LoginResult objectForKey:@"UserId"] integerValue];
            // -1 if login fails
            if(UserId > 0)
            {
                [User setUserForDictionary:LoginResult];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUserProfileNotifier" object:nil];
            }
            else
            {
                NSString* msg = nil;
                //if ([msg length] <= 0) {
                msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                //}
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUserProfileNotifier" object:msg];
            }
            
            if (theOp == _getUserProfileOp)
                _getUserProfileOp = nil;
            
        }
        else if(theOp == _enablePushNotificationOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"SetNotificationResult"];
            
            // -1 if login fails
            if(result && [result localizedCaseInsensitiveCompare:@"Success"] == NSOrderedSame)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotifier" object:nil];
            }
            else
            {
                NSString* msg = nil;
                //if ([msg length] <= 0) {
                msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                //}
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotifier" object:msg];
            }
            
            if (theOp == _enablePushNotificationOp)
                _enablePushNotificationOp = nil;
            
        }
	}
}

- (void)operation:(PDKBaseOperation *)theOp didFinishWithError:(NSError *)err
{
    if(theOp == _timeZoneOp)
    {
        _timeZoneOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeZoneNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _loginOp)
    {
        _loginOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _signupOp)
    {
        _signupOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RegisterNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _forgotPasswordOp)
    {
        _forgotPasswordOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ForgotPasswordNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _getUserProfileOp)
    {
        _getUserProfileOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetUserProfileNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _enablePushNotificationOp)
    {
        _enablePushNotificationOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PushNotifier" object:[err localizedDescription]];
    }
}

@end
