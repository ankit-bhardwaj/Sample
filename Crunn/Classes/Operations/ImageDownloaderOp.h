//
//  ImageDownloaderOp.h
//  mCampus
//
//  Created by Ashish Maheshwari on 6/29/10.
//  Copyright 2010 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticatedURLConnectionOp.h"


@interface ImageDownloaderOp : AuthenticatedURLConnectionOp 
{
	NSData* imageData;
	
	id<NSObject> target;
	SEL          action;
}

@property (nonatomic,readonly) NSData* imageData;
@property (nonatomic,retain)   id<NSObject> target;
@property (nonatomic,assign)   SEL action;

- (id) initWithUrl:(NSString*)sourceUrl;

@end
