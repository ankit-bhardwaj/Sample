//
//  EventDocument.h
//  Crunn
//
//  Created by Ashish Maheshwari on 12/15/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "PDKBaseDocument.h"
#import "Portfolio.h"
#import "Meeting.h"

@interface EventDocument : PDKBaseDocument
@property(nonatomic,retain)NSMutableArray*  homeEvents;
@property(nonatomic,assign)NSInteger        homeEventIndex;
@property(nonatomic,retain)Project          *selectedProject;
@property(nonatomic,retain)Portfolio       *selectedPortfolio;
@property(nonatomic,assign)NSInteger        selectedMeetingInterval;
@property(nonatomic,retain)NSMutableDictionary       *currentMeetingInfo;
@property(nonatomic,retain)NSMutableArray            *currentMeetingDates;
@property(nonatomic,retain)NSMutableArray            *currentMeetingSlots;
@property(nonatomic,retain)NSMutableArray       *currentMeetingRecipientList;
@property(nonatomic,retain)NSMutableArray*  myMeetings;
@property(nonatomic,assign)NSInteger        myMeetingIndex;
@property(nonatomic,assign)BOOL             myMeetingUpdateRequire;


+(EventDocument*)sharedInstance;

- (void)createEvent:(NSDictionary*)dict;
- (void)refreshHomeEvents;
- (void)getHomeEvents;
- (void)getHomeEventForPortfolio:(Portfolio*)portfolio andProject:(Project*)p;
- (void)createMeeting;
- (void)uploadAttachments:(NSArray*)array;
- (void)fetchMyMeetings;
- (void)refreshMyMeetings;
- (void)postComment:(NSDictionary*)params;
- (void)finalizeMeetingSlot:(NSNumber*)slotId forMeeting:(Meeting*)meeting;
- (void)updateSlotStatus:(NSArray*)slots forMeeting:(Meeting*)meeting;
@end
