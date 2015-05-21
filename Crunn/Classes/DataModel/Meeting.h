//
//  Meeting.h
//  Crunn
//
//  Created by Ashish Maheshwari on 12/15/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Meeting : NSObject

@property (nonatomic, retain) NSNumber       *AttachId;
@property (nonatomic, retain) NSString       *CommentTextId;
@property (nonatomic, retain) NSDate         *CreateDate;
@property (nonatomic, retain) NSString       *CreatedOnTimeString;
@property (nonatomic, retain) User           *CreatorDetails;
@property (nonatomic, retain) NSString       *Description;
@property (nonatomic, retain) NSNumber       *Duration;
@property (nonatomic, retain) NSNumber       *FormId;
@property (nonatomic, retain) NSDate         *LastUpdateDate;
@property (nonatomic, retain) NSString       *Location;
@property (nonatomic, retain) NSNumber       *LoggedInUserId;
@property (nonatomic, retain) NSMutableArray*MeetingAttachments;
@property (nonatomic, retain) NSMutableArray*MeetingComments;
@property (nonatomic, retain) NSMutableArray         *MeetingDatesList;
@property (nonatomic, retain) NSNumber       *MeetingId;
@property (nonatomic, retain) NSString       *MeetingLink;
@property (nonatomic, retain) NSString       *MeetingNameOrEmail;
@property (nonatomic, retain) NSMutableArray*MeetingProposalsList;//MeetingProposal
@property (nonatomic, retain) NSNumber       *MoreCommentsCount;
@property (nonatomic, retain) NSString       *NewComment;
@property (nonatomic, retain) NSString       *NewCommentPrompt;
@property (nonatomic, retain) NSNumber       *ParentId;
@property (nonatomic, retain) NSMutableArray       *ParticipantsList;//MeetingParticipant
@property (nonatomic, retain) NSString       *RecipientEmailList;
@property (nonatomic, retain) NSNumber       *Status;
@property (nonatomic, retain) NSString       *Title;
@property (nonatomic, retain) NSNumber       *TotalComments;
@property (nonatomic, retain) NSString       *UpdateId;
@property (nonatomic, retain) NSString       *UpdateId2;
@property (nonatomic, retain) NSString       *UploadId;
@property (nonatomic, retain) NSMutableArray       *_meetingComments;

+ (Meeting*) getMeetingFromDict:(NSDictionary*)dict;


/*{
 "AttachId": null,
 "CancelFlag": 0,
 "CommentTextId": "txt40332",
 "CreateDate": "/Date(1423243585257+0000)/",
 "CreatedOnTimeString": "Fri, Feb 6 at 10:56 pm|",
 "CreatorDetails": {
 "Email": "ashishmaheshwari2@gmail.com",
 "FirstName": "Ashish",
 "FormattedName": "Ashish Maheshwari",
 "IsGuest": false,
 "LastName": "Maheshwari",
 "WcfAccessToken": null,
 "HasPhoto": true,
 "MobileImageUrl": "UploadedFiles/MobileApp/Profile/49434.gif",
 "UserEmail": null,
 "UserId": 49434,
 "UserUploadedProfileImage": false
 },
 "Description": "",
 "Duration": 0,
 "FormId": null,
 "LastUpdateDate": "/Date(-62135596800000+0000)/",
 "Location": "",
 "LoggedInUserId": 0,
 "MeetingAttachments": [],
 "MeetingComments": [],
 "MeetingDatesList": null,
 "MeetingId": 40332,
 "MeetingLink": null,
 "MeetingNameOrEmail": null,
 "MeetingProposalsList": [
 {
 "MeetingId": 40332,
 "MeetingSlotsList": [
 {
 "IsSlotFinalize": 0,
 "MeetingEndTime": "/Date(1424426400000)/",
 "MeetingId": 40332,
 "MeetingProposedDate": "/Date(1424390400000)/",
 "MeetingSlotParticipants": [
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42609,
 "SlotId": 41103,
 "SlotParticipantId": 49434,
 "Status": 0,
 "StatusColor": ""
 },
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42610,
 "SlotId": 41103,
 "SlotParticipantId": 49435,
 "Status": 0,
 "StatusColor": ""
 }
 ],
 "MeetingStartTime": "/Date(1424422800000)/",
 "SlotId": 41103,
 "SlotParticipantId": 0,
 "Status": 0
 },
 {
 "IsSlotFinalize": 0,
 "MeetingEndTime": "/Date(1424430000000)/",
 "MeetingId": 40332,
 "MeetingProposedDate": "/Date(1424390400000)/",
 "MeetingSlotParticipants": [
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42611,
 "SlotId": 41104,
 "SlotParticipantId": 49434,
 "Status": 0,
 "StatusColor": ""
 },
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42612,
 "SlotId": 41104,
 "SlotParticipantId": 49435,
 "Status": 0,
 "StatusColor": ""
 }
 ],
 "MeetingStartTime": "/Date(1424426400000)/",
 "SlotId": 41104,
 "SlotParticipantId": 0,
 "Status": 0
 }
 ],
 "ProposedDate": "/Date(1424390400000)/"
 },
 {
 "MeetingId": 40332,
 "MeetingSlotsList": [
 {
 "IsSlotFinalize": 0,
 "MeetingEndTime": "/Date(1425117600000)/",
 "MeetingId": 40332,
 "MeetingProposedDate": "/Date(1425081600000)/",
 "MeetingSlotParticipants": [
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42613,
 "SlotId": 41105,
 "SlotParticipantId": 49434,
 "Status": 0,
 "StatusColor": ""
 },
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42614,
 "SlotId": 41105,
 "SlotParticipantId": 49435,
 "Status": 0,
 "StatusColor": ""
 }
 ],
 "MeetingStartTime": "/Date(1425114000000)/",
 "SlotId": 41105,
 "SlotParticipantId": 0,
 "Status": 0
 },
 {
 "IsSlotFinalize": 0,
 "MeetingEndTime": "/Date(1425121200000)/",
 "MeetingId": 40332,
 "MeetingProposedDate": "/Date(1425081600000)/",
 "MeetingSlotParticipants": [
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42615,
 "SlotId": 41106,
 "SlotParticipantId": 49434,
 "Status": 0,
 "StatusColor": ""
 },
 {
 "MeetingId": 40332,
 "MeetingSlotParticipantId": 42616,
 "SlotId": 41106,
 "SlotParticipantId": 49435,
 "Status": 0,
 "StatusColor": ""
 }
 ],
 "MeetingStartTime": "/Date(1425117600000)/",
 "SlotId": 41106,
 "SlotParticipantId": 0,
 "Status": 0
 }
 ],
 "ProposedDate": "/Date(1425081600000)/"
 }
 ],
 "MoreCommentsCount": 0,
 "NewComment": null,
 "NewCommentPrompt": "Write your comment...",
 "ParentId": 0,
 "ParticipantsList": [
 {
 "IsOrganizer": true,
 "MeetingId": 40332,
 "ParticipantDetails": {
 "Email": "ashishmaheshwari2@gmail.com",
 "FirstName": "Ashish",
 "FormattedName": "Ashish Maheshwari",
 "IsGuest": false,
 "LastName": "Maheshwari",
 "WcfAccessToken": null,
 "HasPhoto": true,
 "MobileImageUrl": "UploadedFiles/MobileApp/Profile/49434.gif",
 "UserEmail": null,
 "UserId": 49434,
 "UserUploadedProfileImage": false
 },
 "ParticipantId": 0
 },
 {
 "IsOrganizer": false,
 "MeetingId": 40332,
 "ParticipantDetails": {
 "Email": "ankitgla@gmail.com",
 "FirstName": "",
 "FormattedName": "ankitgla@gmail.com",
 "IsGuest": true,
 "LastName": "",
 "WcfAccessToken": null,
 "HasPhoto": true,
 "MobileImageUrl": "UploadedFiles/MobileApp/Profile/49435.gif",
 "UserEmail": null,
 "UserId": 49435,
 "UserUploadedProfileImage": false
 },
 "ParticipantId": 0
 }
 ],
 "RecipientEmailList": null,
 "Status": 0,
 "Title": "dadadad",
 "TotalComments": 0,
 "UpdateId": null,
 "UpdateId2": null,
 "UploadId": "fld40332",
 "_meetingComments": []
 }
 */
@end


@interface MeetingProposal : NSObject

@property (nonatomic, retain) NSNumber       *MeetingId;
@property (nonatomic, retain) NSMutableArray *MeetingSlotsList;//MeetingProposalSlot
@property (nonatomic, retain) NSDate         *ProposedDate;

+ (MeetingProposal*) getMeetingProposalFromDict:(NSDictionary*)dict;

@end


@interface MeetingProposalSlot : NSObject

@property (nonatomic, retain) NSNumber       *IsSlotFinalize;
@property (nonatomic, retain) NSDate         *MeetingEndTime;
@property (nonatomic, retain) NSNumber       *MeetingId;
@property (nonatomic, retain) NSDate         *MeetingProposedDate;
@property (nonatomic, retain) NSMutableArray *MeetingSlotParticipants;//MeetingSlotParticipant
@property (nonatomic, retain) NSDate         *MeetingStartTime;
@property (nonatomic, retain) NSNumber       *SlotId;
@property (nonatomic, retain) NSNumber       *SlotParticipantId;
@property (nonatomic, retain) NSNumber       *Status;

+ (MeetingProposal*) getMeetingProposalSlotFromDict:(NSDictionary*)dict;

@end


@interface MeetingSlotParticipant : NSObject

@property (nonatomic, retain) NSNumber       *MeetingId;
@property (nonatomic, retain) NSNumber       *MeetingSlotParticipantId;
@property (nonatomic, retain) NSNumber       *SlotId;
@property (nonatomic, retain) NSNumber       *SlotParticipantId;
@property (nonatomic, retain) NSNumber       *Status;
@property (nonatomic, retain) NSNumber       *TmpStatus;
@property (nonatomic, retain) NSString       *StatusColor;

+ (MeetingSlotParticipant*) getMeetingSlotParticipantFromDict:(NSDictionary*)dict;

@end



@interface MeetingParticipant : NSObject

@property (nonatomic, retain) NSNumber       *IsOrganizer;
@property (nonatomic, retain) NSNumber       *MeetingId;
@property (nonatomic, retain) User              *ParticipantDetails;
@property (nonatomic, retain) NSNumber       *ParticipantId;

+ (MeetingParticipant*) getMeetingParticipantFromDict:(NSDictionary*)dict;

@end
