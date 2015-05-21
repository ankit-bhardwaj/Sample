//
//  PDKBaseOperation.m
//  pdkcore
//
//  Created by Tarek Osman on 1/13/11.
//  Copyright 2011 Erixir Inc Limited. All rights reserved.
//

#import "PDKBaseOperation.h"
#import "PDKBaseDocument.h"

@implementation PDKBaseOperation
@synthesize _doc,_userInfo; 


- (id)initWithURLString:(NSString *)urlString forDocument:(PDKBaseDocument *)doc
{
	if ( self = [super init] )
	{
		self.url  = urlString;
		self._doc =  doc;
		_userInfo = [NSMutableDictionary new];
	}
	
	return self;
}

- (id)initWithRequest:(NSMutableURLRequest *)request forDocument:(PDKBaseDocument *)doc
{
	if (self = [super init])
	{
		self.httpRequest = request;
		self._doc  = doc;
		_userInfo = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)processReceivedData
{
    if ( [self._doc respondsToSelector:@selector(operation:didFinishWithData:)] )
	{
		[self._doc operation:self didFinishWithData:receivedData];
	}
}


- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*)connError
{
	[super connection:connection didFailWithError:connError];

    if ( [self._doc respondsToSelector:@selector(operation:didFinishWithError:)] )
	{
		[self._doc operation:self didFinishWithError:connError];
	}
}

@end
