//
//  PDKBaseOperation.h
//  pdkcore
//
//  Created by Tarek Osman on 1/13/11.
//  Copyright 2011 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticatedURLConnectionOp.h"

@class PDKBaseDocument;


/**
 * The base operation used for most network requests. This will call back to the document 
 * with a success or failure using PDKLoadingOpProtocol
 */
@interface PDKBaseOperation : AuthenticatedURLConnectionOp 
{
	PDKBaseDocument* _doc;
	NSMutableDictionary* _userInfo;
}

@property(nonatomic, retain) PDKBaseDocument*     _doc; 
@property(nonatomic, retain) NSMutableDictionary* _userInfo;


/**
 Create an operation with a url and the document
 Note: this will call the document back using the PDKLoadingOpProtocol
 
 \param urlString URL
 \param doc The document to use to callback to
 \return an operation initialized with the URL and document
 */ 
- (id)initWithURLString:(NSString *)urlString forDocument:(PDKBaseDocument *)doc;


/**
 Create an operation with a request and the document.
 Note: this will call the document back using the PDKLoadingOpProtocol
 
 \param request the request
 \param doc the document to use to callback to
 \return an operation initialized with the request and document
 */ 
- (id)initWithRequest:(NSMutableURLRequest *)request forDocument:(PDKBaseDocument *)doc;


@end
