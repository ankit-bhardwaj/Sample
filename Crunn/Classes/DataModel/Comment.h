//
//  Comment.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Task.h"

@interface Comment : NSObject
@property(nonatomic, retain)NSString    *commentId;
@property(nonatomic, retain)User        *commenter; //CreatorDetails
@property(nonatomic, retain)NSString    *comment; //CommentDetails
@property(nonatomic, retain)NSAttributedString    *attributedComment; //CommentDetails
@property(nonatomic, assign)CGSize     attrCommentSize; //CommentDetailsSize
@property(nonatomic, retain)NSString    *createdDate; //CommentDateTimeString
@property(nonatomic, retain)NSArray      *Attachments;
@property(nonatomic, assign)BOOL        CanDelete;
@property(nonatomic, retain)NSString    *CommentHtmlId;
@property(nonatomic, retain)NSNumber    *CommentType;
@property(nonatomic, assign)BOOL        isExpanded;
@property(nonatomic, assign)BOOL        fromEmail;
@property(nonatomic, assign)BOOL        IsDeleted;
@property(nonatomic, retain)NSString    *DeletedDateTimeString; //DeletedDateTimeString
@property (nonatomic, retain) Location*     location;
@property(nonatomic, retain)Task    *task;


+ (Comment*) getCommentFromDict:(NSDictionary*)dict;
- (float)cellHeightForWidth:(float)width;

@end


@interface Attachment : NSObject

@property(nonatomic, retain)NSNumber    *ActivityId;
@property(nonatomic, retain)NSString    *CircleId; //CreatorDetails
@property(nonatomic, retain)NSString    *CircleName; //CommentDetails
@property(nonatomic, retain)NSNumber    *CommentId; //CommentDateTimeString
@property(nonatomic, retain)NSString    *ContentType;
@property(nonatomic, retain)NSString    *DateCreatedString;
@property(nonatomic, retain)NSString    *FileData;
@property(nonatomic, retain)NSString    *FileExtention;
@property(nonatomic, retain)NSNumber    *FileSize;
@property(nonatomic, retain)NSString    *FileUrl;
@property(nonatomic, retain)NSString    *Id;
@property(nonatomic, retain)NSString    *MidsizeImageFileUrl;
@property(nonatomic, retain)NSString    *MobileAppFileUrl;
@property(nonatomic, retain)NSString    *OriginalName;
@property(nonatomic, retain)NSNumber    *RecurringTaskId;
@property(nonatomic, retain)NSNumber    *SortOrder;
@property(nonatomic, retain)NSString    *TaskId;
@property(nonatomic, retain)NSString    *TaskName;
@property(nonatomic, retain)NSString    *UploadedBy;
@property(nonatomic, retain)NSNumber    *UploadedById;
@property(nonatomic, retain)NSNumber    *ViewType;
@property(nonatomic, retain)NSNumber    *ExternalVendorType;




+ (Attachment*) getAttachmentFromDict:(NSDictionary*)dict;

@end
