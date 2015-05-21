//
//  Event.h
//  Crunn
//
//  Created by Ashish Maheshwari on 12/15/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property (nonatomic, retain) NSNumber       *eventId;
@property (nonatomic, retain) NSString       *name;
@property (nonatomic, retain) NSString       *summary;
@property (nonatomic, retain) NSString       *location;
@property (nonatomic, retain) NSDate         *startDate;
@property (nonatomic, retain) NSDate         *endDate;
@property (nonatomic, retain) User           *creator;
@property (nonatomic, retain) NSMutableArray*invitees;

+ (Event*) getEventFromDict:(NSDictionary*)dict;

@end
