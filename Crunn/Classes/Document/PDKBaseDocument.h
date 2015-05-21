//
//  PDKBaseDocument.h
//  pdkcore
//
//  Created by Tarek Osman on 1/13/11.
//  Copyright 2011 Erixir Inc Limited. All rights reserved.
//

/*! \file DirectoryDocument.h
 \brief Description
 */

#import <Foundation/Foundation.h>
#import "PDKBaseOperation.h"



/** 
 * Base document. Acts as a controller between the model and the view. 
 */

@interface PDKBaseDocument : NSObject
{
	NSString*		instanceKey; 
}

@property(nonatomic, retain) NSString*		instanceKey;



/**
  Used to retreive an instance of a document. Note. this calls the subclasses initWithInstanceKey method
  \param key Instance key
  \return An instance of a document
 */
+ (PDKBaseDocument*)getInstanceWithKey:(NSString*)key;


/**
  Easy way to ensure that a notification is posted on the main thread.
  \param name Name of notification to post 
  \param obj Object to post (can be nil)
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name object:(id)obj; 


/**
  Should be overridden in a subclass. Do not call this directly, instead call getInstanceWithKey. 
  \param key Instance key
 */
- (id)initWithInstanceKey:(NSString*)key;


/**
 Operation callback to document.
 
 Operation failed. Look in PDKError for more information regarding the possible
 error types.
 
 \param theOp The operation that initiated the request.
 \param err The error
 */
- (void)operation:(PDKBaseOperation *)theOp didFinishWithError:(NSError *)err;


/**
 Operation callback to document.
 
 Operation succeeded.
 
 \param theOp The operation that initiated the request.
 \param dataObj The data
 */
- (void)operation:(PDKBaseOperation *)theOp didFinishWithData:(id)dataObj;

- (NSString*)serverUrl;

- (NSString*)authToken;
@end
