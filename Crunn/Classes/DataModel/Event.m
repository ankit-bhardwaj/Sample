//
//  Event.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/15/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "Event.h"
#import "EventDocument.h"
#import "NSString+HTML.h"
#import "NSString+MD5.h"

@implementation Event

+ (Event*) getEventFromDict:(NSDictionary*)dict
{
    Event* c = [Event new];
    c.name = [NS_NOT_NULL([dict objectForKey:@"EventDescription"]) stringByConvertingHTMLToPlainText];
    c.summary = NS_NOT_NULL([dict objectForKey:@"EventDetails"]);
    c.eventId = NS_NOT_NULL([dict objectForKey:@"EventId"]);
    c.location = NS_NOT_NULL([dict objectForKey:@"EventLocation"]);
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy H:'00'"];
    c.startDate = [df dateFromString: NS_NOT_NULL([dict objectForKey:@"StartDate"])];
    c.endDate = [df dateFromString:NS_NOT_NULL([dict objectForKey:@"EndDate"])];

    NSArray* users = NS_NOT_NULL([dict objectForKey:@"Invitees"]);
    if(users && users.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in users)
        {
            //User* user = [User getUserForDictionary:d];
            //[tmp addObject:user];
        }
        c.invitees = tmp;
    }
    c.creator = [User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"Creator"])];
    return c;
}

@end
