//
//  EventDocument.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/15/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "EventDocument.h"
#import "NSData+Base64.h"
#import "Event.h"
#import "Meeting.h"
#import "Comment.h"

static EventDocument* _sharedInstance = nil;


@implementation EventDocument
{
    PDKBaseOperation* _homeEventOp;
    PDKBaseOperation* _myTaskEventOp;
    PDKBaseOperation* _createEventOp;
    PDKBaseOperation* _updateEventOp;
    PDKBaseOperation* _uploadAttachmentOp;
    PDKBaseOperation* _myMeetingsOp;

    PDKBaseOperation* _postCommentOp;
    PDKBaseOperation* _finalizeSlotOp;
    PDKBaseOperation* _updateSlotOp;

    NSMutableArray* _eventAttachmentFiles;
    NSString*       _attachmentFolderName;
}

+(EventDocument*)sharedInstance
{
    if(_sharedInstance == nil)
    {
        _sharedInstance = [[EventDocument alloc] init];
    }
    return _sharedInstance;
}

- (id)init
{
    if( self == [super init])
    {
        _homeEvents = [[NSMutableArray alloc] init];
        _currentMeetingRecipientList = [NSMutableArray new];
        _currentMeetingDates = [NSMutableArray new];
        _currentMeetingSlots = [NSMutableArray new];
        _currentMeetingInfo = [NSMutableDictionary new];
        _myMeetings = [NSMutableArray new];
    }
    return self;
}

- (void)getHomeFeedForPortfolio:(Portfolio*)portfolio andProject:(Project*)p
{
    if(_homeEventOp)
        return;
    
    [self.homeEvents removeAllObjects];
    _homeEventIndex = 0;
    [self getHomeEvents];
}

- (void)refreshHomeEvents
{
    if(_homeEventOp)
        return;
    
    _homeEventIndex = 0;
    [self getHomeEvents];
}

- (void)getHomeEvents
{
    if(_homeEventOp)
        return;
    
    _homeEventIndex++;
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/Foo",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"userId", SESSION_KEY,@"sessionId",@"Home",@"listCategory",[NSNumber numberWithInt:_homeEventIndex],@"pageNumber",[NSNumber numberWithInt:10],@"pageSize",[NSNumber numberWithInt:3],@"commentCount",nil];
    
    if(self.selectedProject)
        [jsonDictionary setObject:[NSString stringWithFormat:@"%ld",self.selectedProject.ProjectId] forKey:@"projectId"];
    
    if(self.selectedPortfolio)
        [jsonDictionary setObject:[NSString stringWithFormat:@"%ld",self.selectedPortfolio.PortfolioId] forKey:@"portfolioId"];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _homeEventOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_homeEventOp];
}



- (void)createEvent:(NSDictionary*)dict
{
    if(_createEventOp)
        return;
    
    Event* evt = [Event getEventFromDict:dict];
    [_homeEvents addObject:evt];
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/SaveMeeting",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _createEventOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_createEventOp];
}

- (void)updateEvent:(NSDictionary*)dict
{
    if(_updateEventOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/UpdateEvent",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _updateEventOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_updateEventOp];
}

- (void)refreshMyMeetings
{
    if(_myMeetingsOp)
        return;
    
    _myMeetingIndex = 0;
    [self fetchMyMeetings];
}

- (void)fetchMyMeetings
{
    if(_myMeetingsOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/GetMeetings",BASE_SERVER_PATH];
    self.myMeetingIndex++;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",user.UserId], @"LogInUserId", SESSION_KEY,@"SessionId",[NSNumber numberWithInt:_myMeetingIndex],@"PageNumber",[NSNumber numberWithInt:10],@"PageSize",nil];
    
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:jsonDictionary,@"msgIn", nil] options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _myMeetingsOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_myMeetingsOp];
}

- (void)createMeeting
{
    if(_createEventOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/SaveMeeting",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:self.currentMeetingInfo,@"Meeting",[NSNumber numberWithInt:user.UserId],@"LogInUserId",[self.currentMeetingDates componentsJoinedByString:@","],@"Dates",[self.currentMeetingSlots componentsJoinedByString:@","],@"Slots",@"",@"TempFolderName",SESSION_KEY,@"SessionId", nil] forKey:@"msgIn"];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _createEventOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_createEventOp];
}

- (void)uploadAttachments:(NSArray*)array
{
    if(_uploadAttachmentOp)
        return;
    _attachmentFolderName = nil;
    
    if(!_eventAttachmentFiles)
        _eventAttachmentFiles = [[NSMutableArray alloc] init];
    [_eventAttachmentFiles removeAllObjects];
    [_eventAttachmentFiles addObjectsFromArray:array];
    [self uploadAttachment];
}

- (void)uploadAttachment
{
    if(_uploadAttachmentOp)
        return;
    
    NSString* filePath = [_eventAttachmentFiles firstObject];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/UploadFile",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",[filePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    NSDictionary *headerFieldsDict = nil;
    if(NSSTRING_HAS_DATA( _attachmentFolderName))
    {
        headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:contentType, @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",_attachmentFolderName,@"tempFolderName",SESSION_KEY,@"sessionId",nil];
    }
    else
    {
        headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:contentType, @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",nil];
    }
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _uploadAttachmentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_uploadAttachmentOp];
}

- (void)postComment:(NSDictionary*)params
{
    if(_postCommentOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/SaveMeetingComment",BASE_SERVER_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _postCommentOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_postCommentOp];
}

- (void)finalizeMeetingSlot:(NSNumber*)slotId forMeeting:(Meeting*)meeting
{
    if(_finalizeSlotOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/UpdateFinalSlot",BASE_SERVER_PATH];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:meeting.MeetingId,@"MeetingId",[NSNumber numberWithInt:user.UserId],@"LogInUserId",slotId,@"SlotId",nil] forKey:@"msgIn"];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _finalizeSlotOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_finalizeSlotOp];
}

- (void)updateSlotStatus:(NSArray*)slots forMeeting:(Meeting*)meeting
{
    if(_updateSlotOp)
        return;
    
    User* user = [User currentUser];
    NSString* path = [NSString stringWithFormat:@"%@/Meeting.svc/UpdateMeetingSlotParticipantsStatus",BASE_SERVER_PATH];
    
    NSMutableArray* jsonSlots = [NSMutableArray array];
    for(MeetingProposalSlot* slot in slots)
    {
        for(MeetingSlotParticipant* participant in slot.MeetingSlotParticipants)
        {
            if([participant.SlotParticipantId integerValue] == user.UserId)
            {
                [jsonSlots addObject:[NSDictionary dictionaryWithObjectsAndKeys:participant.TmpStatus,@"Status",participant.MeetingSlotParticipantId,@"MeetingSlotParticipantId", nil]];
            }
        }
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    
    NSDictionary* jsonDict = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:meeting.MeetingId,@"MeetingId",[NSNumber numberWithInt:user.UserId],@"LogInUserId",jsonSlots,@"slotList",nil] forKey:@"msgIn"];
    
    // Encode the message in JSON
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonData];
    
    NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",SESSION_KEY,@"sessionId",  nil];
    
    [request setAllHTTPHeaderFields:headerFieldsDict];
    
    _updateSlotOp = [[PDKBaseOperation alloc] initWithRequest:request forDocument:self];
    
    [[AppDelegate sharedOpQueue] addOperation:_updateSlotOp];
}

#pragma mark-
#pragma mark PDKLoadingOpProtocol
- (void)operation:(PDKBaseOperation *)theOp didFinishWithData:(id)dataObj
{
    if ( theOp )
    {
        if(theOp == _homeEventOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetEventsResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                if(_homeEventIndex == 1)
                    [_homeEvents removeAllObjects];
                
                if(result.count==0)
                    _homeEventIndex--;
                
                for(NSDictionary* d in result)
                {
                    Event* event = [Event getEventFromDict:d];
                    [_homeEvents addObject:event];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeEventNotifier" object:result];
            }
            else
            {
                _homeEventIndex--;
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeEventNotifier" object:nil];
            }
            
            if (theOp == _homeEventOp)
                _homeEventOp = nil;
        }
        else if(theOp == _myMeetingsOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSArray* result = [dict objectForKey:@"GetMeetingsResult"];
            
            if(result && [result isKindOfClass:[NSArray class]])
            {
                if(_myMeetingIndex == 1)
                    [_myMeetings removeAllObjects];
                
                if(result.count==0)
                    _myMeetingIndex--;
                
                for(NSDictionary* d in result)
                {
                    Meeting* event = [Meeting getMeetingFromDict:d];
                    [_myMeetings addObject:event];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyMeetingsNotifier" object:result];
            }
            else
            {
                _myMeetingIndex--;
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyMeetingsNotifier" object:nil];
            }
            
            if (theOp == _myMeetingsOp)
                _myMeetingsOp = nil;
        }

        else if(theOp == _createEventOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"SaveMeetingResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateMeetingNotifier" object:result];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateMeetingNotifier" object:msg];
            }
            
            if (theOp == _createEventOp)
                _createEventOp = nil;
        }
        else if(theOp == _uploadAttachmentOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            if (theOp == _uploadAttachmentOp)
                _uploadAttachmentOp = nil;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSString* result = [dict objectForKey:@"UploadFileResult"];
            
            if(result && [result isKindOfClass:[NSString class]] && NSSTRING_HAS_DATA(result))
            {
                [_eventAttachmentFiles removeObjectAtIndex:0];
                
                if([_eventAttachmentFiles count]==0)
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadAttachmentNotifier" object:[NSDictionary dictionaryWithObject:result forKey:@"TempFolderName"]];
                else
                {
                    _attachmentFolderName = result;
                    [self performSelectorOnMainThread:@selector(uploadAttachment) withObject:nil waitUntilDone:NO];
                }
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [_eventAttachmentFiles removeAllObjects];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadTaskAttachmentNotifier" object:msg];
            }
        }
        else if(theOp == _postCommentOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"SaveMeetingCommentResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                Comment* cmnt = [Comment getCommentFromDict:result];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommentNotifier" object:cmnt];
            }
            else
            {
                NSString* msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommentNotifier" object:msg];
            }
            
            if (theOp == _postCommentOp)
                _postCommentOp = nil;
        }
        else if(theOp == _finalizeSlotOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"UpdateFinalSlotResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* meeting = [result objectForKey:@"SavedMeeting"];
                Meeting* m = [Meeting getMeetingFromDict:meeting];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FinalaizeMeetingNotifier" object:m];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FinalaizeMeetingNotifier" object:nil];
            }
            
            if (theOp == _finalizeSlotOp)
                _finalizeSlotOp = nil;
        }
        else if(theOp == _updateSlotOp)
        {
            if ((dataObj == nil) || ([dataObj length] <= 0))
                return;
            
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:dataObj options:NSJSONReadingMutableContainers error:NULL];
            NSDictionary* result = [dict objectForKey:@"UpdateMeetingSlotParticipantsStatusResult"];
            
            if(result && [result isKindOfClass:[NSDictionary class]])
            {
                NSDictionary* meeting = [result objectForKey:@"SavedMeeting"];
                Meeting* m = [Meeting getMeetingFromDict:meeting];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSlotStatusNotifier" object:m];
            }
            else
            {
                NSString* msg = @"";
                if ([msg length] <= 0) {
                    msg = [[NSString alloc] initWithData:dataObj encoding:NSASCIIStringEncoding];;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSlotStatusNotifier" object:nil];
            }
            
            if (theOp == _updateSlotOp)
                _updateSlotOp = nil;
        }
    }
}


- (void)operation:(PDKBaseOperation *)theOp didFinishWithError:(NSError *)err
{
    if(theOp == _homeEventOp)
    {
        _homeEventOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeEventNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _createEventOp)
    {
        _createEventOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateMeetingNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _updateEventOp)
    {
        _updateEventOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateEventNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _myMeetingsOp)
    {
        _myMeetingsOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyMeetingsNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _postCommentOp)
    {
        _postCommentOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PostCommentNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _finalizeSlotOp)
    {
        _finalizeSlotOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FinalaizeMeetingNotifier" object:[err localizedDescription]];
    }
    else if(theOp == _updateSlotOp)
    {
        _updateSlotOp = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSlotStatusNotifier" object:[err localizedDescription]];
    }
}
@end
