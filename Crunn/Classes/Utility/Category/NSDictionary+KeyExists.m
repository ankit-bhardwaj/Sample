//
//  NSDictionary+KeyExists.m
//  Test
//
//  Created by Ashish Maheshwari on 3/17/10.
//  Copyright 2010 . All rights reserved.
//

#import "NSDictionary+KeyExists.h"


@implementation NSDictionary (KeyExists)

-(BOOL) keyExists:(NSString *)key {
	
	NSArray *anArray = [self allKeys];
	for (int i=0;i< [anArray count];i++)
	{
		if ([[anArray objectAtIndex:i] caseInsensitiveCompare:key] == 0) {
			return YES;
		}
	}
	return NO;
}


- (BOOL) valueForKeyIsNull:(NSString *) key {
	return ![self keyExists:key] || ((NSNull *)[self valueForKey:key] == [NSNull null]);
}

@end
