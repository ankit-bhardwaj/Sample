//
//  NSDictionary+KeyExists.h
//  Test
//
//  Created by Ashish Maheshwari on 3/17/10.
//  Copyright 2010 . All rights reserved.
//

@interface NSDictionary (KeyExists) 

- (BOOL) keyExists:(NSString *) key;
- (BOOL) valueForKeyIsNull:(NSString *) key;

@end
