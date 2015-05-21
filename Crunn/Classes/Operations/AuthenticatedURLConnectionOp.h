//
//  AuthenticatedURLConnectionOp.h
//  mCampus
//
//  Created by Mark D. Gerl on 11/17/09.
//  Copyright 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHTTPMethodGet @"GET"
#define kHTTPMethodPost @"POST"

@interface AuthenticatedURLConnectionOp : NSOperation
{
	// public interface
	@public
	BOOL				success;
	NSError*			error;
	
	// protected interface
	@protected
	NSString*			url;
	NSMutableData*		receivedData;
	
	BOOL				executing;
	BOOL				finished;
	
	
	//HTTP Request Props
	NSMutableURLRequest* httpRequest;
	NSString*			httpMethod;
	NSData*			    httpBody;
	NSString*			httpContentType;
	BOOL				isBasicAuthentication;
	
	// HTTP Reply Props
	NSUInteger          contentLength;
	NSString*           contentType;
	NSInteger           httpStatusCode;	
	
	
	BOOL done;
}

@property(nonatomic) BOOL success;
@property(readonly) NSError* error;
@property(nonatomic, copy) NSString* url;
@property(nonatomic, copy)NSMutableURLRequest* httpRequest;
@property(nonatomic, copy) NSString*		    httpMethod;
@property(nonatomic, copy) NSData*			httpBody;
@property(nonatomic, copy) NSString*		httpContentType;
@property(nonatomic, assign) NSInteger      httpStatusCode;
@property(nonatomic,assign) BOOL		isBasicAuthentication;
@property(nonatomic,readonly) NSString* contentType;
@property(nonatomic,readonly) NSUInteger contentLength;
@property(nonatomic,assign) BOOL		logging;

- (void)processReceivedData;
//- (NSString*)getAuthenticationCredentials;
- (void) startConnectionWithURL:(NSURL*) theURL;
- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)connError;


@end
