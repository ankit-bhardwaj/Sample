//
//  ImageDownloaderOp.m
//  mCampus
//
//  Created by Ashish Maheshwari on 6/29/10.
//  Copyright 2010 Erixir Inc Limited. All rights reserved.
//

#import "ImageDownloaderOp.h"


@implementation ImageDownloaderOp
@synthesize imageData;
@synthesize target;
@synthesize action;




- (id) initWithUrl:(NSString*)sourceUrl
{
	if ( (self = [super init]) )
	{
		NSLog(@"%s: %@", __FUNCTION__, sourceUrl);
		imageData = nil;
		url = [sourceUrl copy];
        httpContentType = @"";
	}
	return self;
}




- (void)processReceivedData
{
	if ( receivedData != nil )
		imageData = receivedData;
	if ( ! [self isCancelled] )
	{
		if ( (target != NULL) && [target respondsToSelector:action] )
		{
			[target performSelector:action withObject:imageData];
		}
	}
}

@end
