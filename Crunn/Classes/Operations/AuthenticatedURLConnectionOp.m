//
//  AuthenticatedURLConnectionOp.m
//  mCampus
//
//  Created by Mark D. Gerl on 11/17/09.
//  Copyright 2014 Erixir Inc Limited. All rights reserved.
//

#import "AuthenticatedURLConnectionOp.h"
#import "NSData+Base64.h"
#import "NSURL+Utilities.h"


@implementation AuthenticatedURLConnectionOp

@synthesize success;
@synthesize error;
@synthesize url;
@synthesize httpBody;
@synthesize httpContentType;
@synthesize httpStatusCode;
@synthesize httpMethod;
@synthesize contentType;
@synthesize contentLength;
@synthesize isBasicAuthentication;
@synthesize httpRequest;
@synthesize logging;

- (id) init
{
	if (self = [super init])
	{
		success		 = NO;
		error		 = NO;
		url			 = nil;
		receivedData = nil;
		finished	 = NO;
		executing	 = NO;
		httpBody = nil;
		httpMethod = kHTTPMethodGet;
		httpContentType = @"application/json";
		httpStatusCode = 0;
		contentType = nil;
		contentLength = 0;
		isBasicAuthentication = NO;
		httpRequest = nil;
		isBasicAuthentication = NO;
        logging = YES;
	}
	
	return self;
}



- (BOOL) isFinished
{
	return finished;
}


- (BOOL) isExecuting
{
	return executing;
}


- (BOOL) isConcurrent
{
	return NO;
}


- (NSURL*) urlByReplacingHost:(NSString*)host andPort:(NSUInteger)port fromURL:(NSURL*)sourceUrl
{
	NSMutableString* newUrl = [[NSMutableString alloc] init];
	
	[newUrl appendString:[sourceUrl scheme]];
	[newUrl appendString:@"://"];
	[newUrl appendString:host];
	[newUrl appendFormat:@":%u", port];
	
	NSString* tmp = [sourceUrl relativePath];
	if ( NSSTRING_HAS_DATA( tmp) )
		[newUrl appendString:tmp];
	else
		[newUrl appendString:@"/"];
	
	tmp = [sourceUrl query];
	if ( NSSTRING_HAS_DATA( tmp) )
		[newUrl appendFormat:@"?%@", tmp];

	NSURL* result = [NSURL URLWithString:newUrl];
	
	
	return result;
}

//-(NSURL*) newUrlForPath
-(NSURL*) getFileURLIfNecessary
{
	NSURL* urlObj = nil;
	if ( [self.url hasPrefix:@"http://"] || [self.url hasPrefix:@"https://"] )
		return [NSURL URLWithString:self.url];
	else
	{
		NSString* filePath;
		//	NSString* fileName = [self.url lastPathComponent];
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString* documentsDirectory = [paths objectAtIndex:0];
		filePath = [documentsDirectory stringByAppendingPathComponent:self.url];
		BOOL isDir = NO;
		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir] || isDir )
		{
			filePath = [filePath lastPathComponent];
			filePath = [[NSBundle mainBundle] pathForResource:filePath ofType:nil];
		}
		
		if(filePath != nil)
			urlObj = [NSURL fileURLWithPath:[filePath stringByExpandingTildeInPath]];
	}
	
	return urlObj; // *** caller must relese this! Ignore Clang
}

- (void) startConnectionWithURL:(NSURL*) theURL
{	
	[AppDelegate startShowingNetworkActivity];

	
	NSMutableURLRequest* theRequest = [NSMutableURLRequest requestWithURL:theURL
															  cachePolicy:NSURLRequestReturnCacheDataElseLoad
														  timeoutInterval:180.0];
	[theRequest setHTTPMethod:httpMethod];
	
	if(httpBody != nil )
		[theRequest setHTTPBody:httpBody];
	
	if(NSSTRING_HAS_DATA(httpContentType))
	{
		NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:httpContentType, @"Content-Type", nil];
		[theRequest setAllHTTPHeaderFields:headerFieldsDict];
	}
    
    NSLog(@"URL:- %@",[theURL absoluteString]);
    NSLog(@"Headers:- %@",[[theRequest allHTTPHeaderFields] description]);
	
	
	[theRequest setHTTPShouldHandleCookies:NO];
	
	NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) 
	{
		receivedData=[NSMutableData data];	// CLANG IGNORE
		// TODO: CLANG IGNORE - ignore the dangling 'theConnection' here; should make theConnection an instance variable
		// and fix other releases of it so it's only released on dealloc
	}
	else
	{
		// abort the run loop
		done = YES;
	}
}




- (void) startConnectionWithRequest:(NSMutableURLRequest*) theRequest
{	
	[AppDelegate startShowingNetworkActivity];
	
    
	[theRequest setTimeoutInterval:180.0];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
		
	
	[theRequest setHTTPShouldHandleCookies:NO];
    
    NSLog(@"URL:- %@",[theRequest.URL absoluteString]);
    NSLog(@"Headers:- %@",[[theRequest allHTTPHeaderFields] description]);
    NSLog(@"Body:- %@",[[NSString alloc] initWithData:[theRequest HTTPBody] encoding:NSASCIIStringEncoding]);
	
	NSURLConnection* theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) 
	{
		receivedData=[NSMutableData data];	// CLANG IGNORE
		// TODO: CLANG IGNORE - ignore the dangling 'theConnection' here; should make theConnection an instance variable
		// and fix other releases of it so it's only released on dealloc
	}
	else
	{
		// abort the run loop
		done = YES;
	}
	
	
}

- (void) start
{
	@autoreleasepool {
        
	
	
	//[self performSelectorOnMainThread:@selector(startConnection) withObject:nil waitUntilDone:NO];
	if (httpRequest != nil) 
	{
		self.url = [[self.httpRequest URL] description];

		NSURL* theURL = [self getFileURLIfNecessary];
		if ( theURL )  
			[httpRequest setURL:theURL];

		[self startConnectionWithRequest:httpRequest];
	}
	else if (NSSTRING_HAS_DATA(self.url)) 
	{
//		self.url = [self.url stringByReplacingOccurrencesOfString:@"demoadhoc.sales" withString:@"pdmobiledev"];

		NSURL* theURL = [self getFileURLIfNecessary];
		if ( theURL ) 
			[self startConnectionWithURL:theURL];
		else
			[self startConnectionWithURL:[NSURL URLWithString:self.url]];
		
	}
	else
	{
		if (!NSSTRING_HAS_DATA(self.url))
		{
			return;
		}
		
		done = NO;
	}

			
	
	
	
	do {
		
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		
	} while ( ! done );
	
	
	[self processReceivedData];	
	
	
	// Finish up for KVO
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	finished = YES;
	executing = NO;
	[self didChangeValueForKey:@"isFinished"];
	[self didChangeValueForKey:@"isExecuting"];
	
    }
}


#pragma mark -
#pragma mark Connection Delegate Callbacks

- (void) connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
	
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	NSHTTPURLResponse* resp = (NSHTTPURLResponse*) response;
	
	contentType = [NSString stringWithString:[resp MIMEType]];
	contentLength = [resp expectedContentLength];	
	
	if ( [resp respondsToSelector:@selector(statusCode)] )
		httpStatusCode = [resp statusCode];
	else
		httpStatusCode = 200;
	
	
    [receivedData setLength:0];
	
}


- (void) connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
	
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}


// FAILURE!!!
- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)connError
{
	error = connError;
	
	[AppDelegate stopShowingNetworkActivity];
	receivedData = nil;
	
	
    // inform the user
    NSLog(@"%s: Connection failed! *** ERROR: %@ %@", __FUNCTION__,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	done = YES;
}


// SUCCESS!!!
- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{	
	[AppDelegate stopShowingNetworkActivity];
	if(self.logging)
    {
        NSString* str = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
        NSLog(@"Response:- %@",str);
    }
    
	connection = nil;
	
	if ( httpStatusCode == 200)
	{		
		success = YES;		
	}
	else
	{
		error = [NSError errorWithDomain:@"AuthenticatedURLConnectionOp" code:httpStatusCode userInfo:nil];
		NSLog(@"%s: received an unexpected error code %d", __FUNCTION__, httpStatusCode);
	}
	
	done = YES;
}


- (BOOL) connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace*)protectionSpace
{
	
	return YES;	// ???
}


- (void) connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
	
	
//	if ([challenge previousFailureCount] == 0)
//	{
//		NSString* username = [[ConfigDocument sharedInstance] getUserConfigForKey:USER_USERNAME_KEY];
//		NSString* password = [[ConfigDocument sharedInstance] getUserConfigForKey:USER_PASSWORD_KEY];
//		if(username == nil)
//			username = @"";
//		if(password == nil)
//			password = @"";
//
//		
//		//NSURLCredential* newCredential=[NSURLCredential credentialWithUser:username
//		//																  password:password
//		//															   persistence:NSURLCredentialPersistenceForSession /*NSURLCredentialPersistenceNone*/];
//		
//		
//		NSURLCredential* newCredential=[[NSURLCredential alloc] initWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
//		[[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
//		[newCredential release];
//	}
//	else
//	{
//		[[challenge sender] cancelAuthenticationChallenge:challenge];
//		// inform the user that the user name and password
//		// in the preferences are incorrect
//		// [self showPreferencesCredentialsAreIncorrectPanel:self];
//	}
}


- (void) connection:(NSURLConnection*)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
	
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
	// Don't allow the darn thing to cache creds so we don't get challenged if a user logs in and logs out
	return NO;
}


//- (BOOL) connectionShouldUseCredentialStorage:(NSURLConnection*)connection
//{
//	_GTMDevLog(@"%s: ", __FUNCTION__);
//}

	
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	return cachedResponse;
}

#pragma mark -
#pragma mark SubClass methods

- (void)processReceivedData
{
	
}


@end
