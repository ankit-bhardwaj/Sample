//
//  Meeting.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/15/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "Meeting.h"
#import "EventDocument.h"
#import "NSString+HTML.h"
#import "NSString+MD5.h"
#import "Comment.h"

@implementation Meeting

+ (Meeting*) getMeetingFromDict:(NSDictionary*)dict
{
    Meeting* c = [Meeting new];
    c.AttachId = NS_NOT_NULL([dict objectForKey:@"AttachId"]);
    c.CommentTextId = NS_NOT_NULL([dict objectForKey:@"CommentTextId"]);
    c.CreateDate = [NS_NOT_NULL([dict objectForKey:@"CreateDate"]) getJSONDate];
    c.CreatedOnTimeString = NS_NOT_NULL([dict objectForKey:@"CreatedOnTimeString"]);
    c.CreatorDetails = [User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"CreatorDetails"])];
    c.Description = NS_NOT_NULL([dict objectForKey:@"Description"]);
    c.Duration = NS_NOT_NULL([dict objectForKey:@"Duration"]);
    c.FormId = NS_NOT_NULL([dict objectForKey:@"FormId"]);    
    c.LastUpdateDate = [NS_NOT_NULL([dict objectForKey:@"LastUpdateDate"]) getJSONDate];
    c.Location = NS_NOT_NULL([dict objectForKey:@"Location"]);
    c.LoggedInUserId = NS_NOT_NULL([dict objectForKey:@"LoggedInUserId"]);
    c.MeetingAttachments = NS_NOT_NULL([dict objectForKey:@"MeetingAttachments"]);
    c.MeetingDatesList = NS_NOT_NULL([dict objectForKey:@"MeetingDatesList"]);
    c.MeetingId = NS_NOT_NULL([dict objectForKey:@"MeetingId"]);
    c.MeetingLink = NS_NOT_NULL([dict objectForKey:@"MeetingLink"]);
    c.MeetingNameOrEmail = NS_NOT_NULL([dict objectForKey:@"MeetingNameOrEmail"]);
    
    c.MoreCommentsCount = NS_NOT_NULL([dict objectForKey:@"MoreCommentsCount"]);
    c.NewComment = NS_NOT_NULL([dict objectForKey:@"NewComment"]);
    c.NewCommentPrompt = NS_NOT_NULL([dict objectForKey:@"NewCommentPrompt"]);
    c.ParentId = NS_NOT_NULL([dict objectForKey:@"ParentId"]);
    c.RecipientEmailList = NS_NOT_NULL([dict objectForKey:@"RecipientEmailList"]);
    c.Status = NS_NOT_NULL([dict objectForKey:@"Status"]);
    c.Title = NS_NOT_NULL([dict objectForKey:@"Title"]);
    c.TotalComments = NS_NOT_NULL([dict objectForKey:@"TotalComments"]);
    c.UpdateId = NS_NOT_NULL([dict objectForKey:@"UpdateId"]);
    c.UpdateId2 = NS_NOT_NULL([dict objectForKey:@"UpdateId2"]);
    c.UploadId = NS_NOT_NULL([dict objectForKey:@"UploadId"]);
    c._meetingComments = NS_NOT_NULL([dict objectForKey:@"_meetingComments"]);


    NSArray* ProposalsList = NS_NOT_NULL([dict objectForKey:@"MeetingProposalsList"]);
    if(ProposalsList && ProposalsList.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in ProposalsList)
        {
            MeetingProposal* obj = [MeetingProposal getMeetingProposalFromDict:d];
            [tmp addObject:obj];
        }
        c.MeetingProposalsList = tmp;
    }
    
    NSArray* users = NS_NOT_NULL([dict objectForKey:@"ParticipantsList"]);
    if(users && users.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in users)
        {
            MeetingParticipant* user = [MeetingParticipant getMeetingParticipantFromDict:d];
            [tmp addObject:user];
        }
        c.ParticipantsList = tmp;
    }
    
    NSArray* comments = NS_NOT_NULL([dict objectForKey:@"MeetingComments"]);
    if(comments && comments.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in comments)
        {
            Comment* cmnt = [Comment getCommentFromDict:d];
            [tmp addObject:cmnt];
        }
        c.MeetingComments = tmp;
    }
    
    if(!c.MeetingComments)
        c.MeetingComments = [NSMutableArray new];
    
    return c;
}

@end


@implementation MeetingProposal

+ (MeetingProposal*) getMeetingProposalFromDict:(NSDictionary*)dict
{
    MeetingProposal* c = [MeetingProposal new];
    c.MeetingId = NS_NOT_NULL([dict objectForKey:@"MeetingId"]);
    c.ProposedDate = [NS_NOT_NULL([dict objectForKey:@"ProposedDate"]) getJSONDate];
    
    NSArray* slots = NS_NOT_NULL([dict objectForKey:@"MeetingSlotsList"]);
    if(slots && slots.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in slots)
        {
            MeetingProposalSlot* obj = [MeetingProposalSlot getMeetingProposalSlotFromDict:d];
            [tmp addObject:obj];
        }
        c.MeetingSlotsList = tmp;
    }
    return c;
}

@end

@implementation MeetingProposalSlot

+ (MeetingProposalSlot*) getMeetingProposalSlotFromDict:(NSDictionary*)dict
{
    MeetingProposalSlot* c = [MeetingProposalSlot new];
    c.IsSlotFinalize = NS_NOT_NULL([dict objectForKey:@"IsSlotFinalize"]);
    c.MeetingEndTime = [NS_NOT_NULL([dict objectForKey:@"MeetingEndTime"]) getJSONDate];
    c.MeetingId = NS_NOT_NULL([dict objectForKey:@"MeetingId"]);
    c.MeetingProposedDate = [NS_NOT_NULL([dict objectForKey:@"MeetingProposedDate"]) getJSONDate];
    c.MeetingStartTime = [NS_NOT_NULL([dict objectForKey:@"MeetingStartTime"]) getJSONDate];
    c.SlotId = NS_NOT_NULL([dict objectForKey:@"SlotId"]);
    c.SlotParticipantId = NS_NOT_NULL([dict objectForKey:@"SlotParticipantId"]);
    c.Status = NS_NOT_NULL([dict objectForKey:@"Status"]);
    
    NSArray* slots = NS_NOT_NULL([dict objectForKey:@"MeetingSlotParticipants"]);
    if(slots && slots.count > 0)
    {
        NSMutableArray* tmp = [[NSMutableArray alloc] init];
        for (NSDictionary* d in slots)
        {
            MeetingSlotParticipant* obj = [MeetingSlotParticipant getMeetingSlotParticipantFromDict:d];
            [tmp addObject:obj];
        }
        c.MeetingSlotParticipants = tmp;
    }
    return c;
}

@end

@implementation MeetingSlotParticipant

+ (MeetingSlotParticipant*) getMeetingSlotParticipantFromDict:(NSDictionary*)dict
{
    MeetingSlotParticipant* c = [MeetingSlotParticipant new];
    c.MeetingId = NS_NOT_NULL([dict objectForKey:@"MeetingId"]);
    c.MeetingSlotParticipantId = NS_NOT_NULL([dict objectForKey:@"MeetingSlotParticipantId"]);
    c.SlotId = NS_NOT_NULL([dict objectForKey:@"SlotId"]);
    c.SlotParticipantId = NS_NOT_NULL([dict objectForKey:@"SlotParticipantId"]);
    c.Status = NS_NOT_NULL([dict objectForKey:@"Status"]);
    c.TmpStatus = c.Status;
    c.StatusColor = NS_NOT_NULL([dict objectForKey:@"StatusColor"]);
    return c;
}

@end


@implementation MeetingParticipant

+ (MeetingParticipant*) getMeetingParticipantFromDict:(NSDictionary*)dict
{
    MeetingParticipant* c = [MeetingParticipant new];
    c.IsOrganizer = NS_NOT_NULL([dict objectForKey:@"IsOrganizer"]);
    c.MeetingId = NS_NOT_NULL([dict objectForKey:@"MeetingId"]);
    c.ParticipantDetails =[User getUserForDictionary:NS_NOT_NULL([dict objectForKey:@"ParticipantDetails"])];
    c.ParticipantId = NS_NOT_NULL([dict objectForKey:@"ParticipantId"]);
    return c;
}

@end
