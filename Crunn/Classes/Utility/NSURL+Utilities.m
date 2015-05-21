//
//  NSURL+Utilities.m
//  mCampus
//
//  Created by Ashish Maheshwari on 7/21/10.
//  Copyright 2010 Erixir Inc Limited. All rights reserved.
//

#import "NSURL+Utilities.h"


@implementation NSURL (Utilities)


- (NSURL*) urlByReplacingHost:(NSString*)host andPort:(NSUInteger)port
{
	NSMutableString* newUrl = [[NSMutableString alloc] init];
	
	[newUrl appendString:[self scheme]];
	[newUrl appendString:@"://"];
	[newUrl appendString:host];
	[newUrl appendFormat:@":%u", port];
	
	NSString* tmp = [self relativePath];
	if ( NSSTRING_HAS_DATA( tmp) )
		[newUrl appendString:tmp];
	else
		[newUrl appendString:@"/"];
	
	tmp = [self query];
	if ( NSSTRING_HAS_DATA( tmp) )
		[newUrl appendFormat:@"?%@", tmp];
	
	NSURL* result = [NSURL URLWithString:newUrl];

	
	return result;
}

@end
