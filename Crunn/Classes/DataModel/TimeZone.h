//
//  TimeZone.h
//  Crunn
//
//  Created by Ashish Maheshwari on 8/4/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeZone : NSObject
@property(nonatomic, retain)NSString    *ZoneCode;
@property(nonatomic, retain)NSString    *ZoneString;
+ (TimeZone*)getTimeZone:(NSDictionary*)d;
@end
