//
//  BaseDocument.m
//  pdkcore
//
//  Created by Tarek Osman on 1/13/11.
//  Copyright 2011 Erixir Inc Limited. All rights reserved.
//

#import "PDKBaseDocument.h"

@implementation PDKBaseDocument

@synthesize instanceKey; 

+ (PDKBaseDocument*)getInstanceWithKey:(NSString*)key
{	
	return [[self alloc] initWithInstanceKey:key]; 
}

- (void)postNotificationOnMainThreadWithName:(NSString *)name object:(id)obj
{
	NSNotification* n = [NSNotification notificationWithName:name object:obj];
	
	if ( [[NSThread currentThread] isMainThread] )  
	{
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}
	else 
	{
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:n waitUntilDone:NO];
	}
}

- (void)operation:(PDKBaseOperation *)theOp didFinishWithError:(NSError *)err
{
	NSLog(@"Override this method in subclass");
}

- (void)operation:(PDKBaseOperation *)theOp didFinishWithData:(id)dataObj
{
	NSLog(@"Override this method in subclass");
}

-(id)initWithInstanceKey:(NSString *)key
{
	NSLog(@"Override this method in subclass");
	return nil; 
}

- (NSString*)authToken
{
    NSString* device = [User currentUser].WcfAccessToken;
    if(!NSSTRING_HAS_DATA(device))
        device = [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
    if(!NSSTRING_HAS_DATA(device))
        device = @"APA91bEAlf702h39s6w9vDmBe_f5v41S3wFMUhZ4uyP6zpfwYVu4AAoIOHBVQsEOAC4XBBH-1VdpUzEaLfpj-X6uYnQR3UqRf3DfhDO96ioLfAWBck09chHjIxMHdH9bHw1S0IhraoUE9Ocl9BojFGDCXrRL4Kx_Qg";
    return device;
}

- (NSString*)serverUrl
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"production"])
    {
        return PROD_SERVER_PATH;
    }
    else
    {
        return DEV_SERVER_PATH;
    }
    
}
@end
