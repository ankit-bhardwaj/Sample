//
//  TimeZone.m
//  Crunn
//
//  Created by Ashish Maheshwari on 8/4/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TimeZone.h"

@implementation TimeZone

+ (TimeZone*)getTimeZone:(NSDictionary*)d
{
    TimeZone* zone = [TimeZone new];
    zone.ZoneCode = [d objectForKey:@"ZoneCode"];
    zone.ZoneString = [d objectForKey:@"ZoneString"];
    return zone;
}
@end
