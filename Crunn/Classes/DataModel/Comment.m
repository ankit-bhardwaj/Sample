//
//  Comment.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "Comment.h"

@implementation Comment


+ (Comment*) getCommentFromDict:(NSDictionary*)dict
{
    Comment* c = [Comment new];
    c.commentId = NS_NOT_NULL([dict objectForKey:@"CommentId"]);
    NSDictionary* d = [dict objectForKey:@"CreatorDetails"];
    if([d isKindOfClass:[NSDictionary class]])
        c.commenter = [User getUserForDictionary:d];
    c.comment = NS_NOT_NULL([dict objectForKey:@"CommentDetails"]);
    c.createdDate = NS_NOT_NULL([dict objectForKey:@"CommentDateTimeString"]);
    c.DeletedDateTimeString = NS_NOT_NULL([dict objectForKey:@"DeletedDateTimeString"]);
    c.CanDelete = [NS_NOT_NULL([dict objectForKey:@"CanDelete"]) boolValue];
    c.IsDeleted = [NS_NOT_NULL([dict objectForKey:@"IsDeleted"]) boolValue];
    if(c.IsDeleted)
        c.comment = [NSString stringWithFormat:@"deleted his/her comment on %@",[[c.DeletedDateTimeString componentsSeparatedByString:@"|"]firstObject]];
    c.CommentHtmlId = NS_NOT_NULL([dict objectForKey:@"CommentHtmlId"]);
    c.CommentType = NS_NOT_NULL([dict objectForKey:@"CommentType"]);
    c.comment = c.comment;
    NSString* email = NS_NOT_NULL([dict objectForKey:@"EmailReceivedDateTimeString"]);
    if(NSSTRING_HAS_DATA(email))
        c.fromEmail = YES;
    
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    NSMutableArray* imgTmp = [[NSMutableArray alloc] init];
    NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
    NSArray* att = NS_NOT_NULL([dict objectForKey:@"Attachments"]);
    for(NSDictionary* d in att)
    {
        Attachment* cmnt = [Attachment getAttachmentFromDict:d];
        if([imageContentTypes containsObject:cmnt.ContentType])
        {
            [imgTmp addObject:cmnt];
        }
        else
        {
            [tmp addObject:cmnt];
        }
        
    }
    [tmp insertObjects:imgTmp atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [imgTmp count])]];
    if(tmp.count>0)
        c.Attachments = [NSArray arrayWithArray:tmp];
    
    c.location = [Location getLocationFromDict:dict];
    
    NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[c.comment dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
    NSMutableDictionary* tmpDict= [NSMutableDictionary dictionary];
    [attrs enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, [attrs length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont *font = (UIFont*)value;
        [tmpDict setObject:[font fontDescriptor] forKey:NSStringFromRange(range)];
    }];
    
    for(NSString* r in [tmpDict allKeys])
    {
        NSRange range = NSRangeFromString(r);
        UIFontDescriptor* des = [tmpDict objectForKey:r];
        NSString* fontface = [des objectForKey:UIFontDescriptorFaceAttribute];
        des = [des fontDescriptorWithFamily:@"Helvetica"];
        des = [des fontDescriptorWithFace:fontface];
        UIFont* font = [UIFont fontWithDescriptor:des size:11.0];
        [attrs addAttribute:NSFontAttributeName value:font range:range];
    }
    c.attributedComment = attrs;
    return c;
}

- (float)cellHeightForWidth:(float)width
{
    float rowHeight = 19;
    CGSize textSize;
    
    CGRect paragraphRect = [self.attributedComment boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    textSize = paragraphRect.size;
    int numberOflines = ceilf( textSize.height/14.0);
    textSize.height+=numberOflines* 1.0;
    
    self.attrCommentSize = textSize;

    if (textSize.height > 45)
    {
        if(!self.isExpanded)
            textSize.height = 45;
        textSize.height += 18;
    }
    
    rowHeight += textSize.height + 5;
    
    if(self.Attachments && self.Attachments.count)
    {
        NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
        BOOL scrollViewAdded = NO;
        for(Attachment* attachment in self.Attachments)
        {
            if([imageContentTypes containsObject:attachment.ContentType])
            {
                if(!scrollViewAdded)
                {
                    rowHeight += 50.0;
                    scrollViewAdded = YES;//added this line to skip this condition after addition of single scrollview;
                }
            }
            else
            {
                rowHeight += 22.0;
            }
        }
    }
    rowHeight+= 20;
    
    return rowHeight;
}
@end

@implementation Attachment


+ (Attachment*) getAttachmentFromDict:(NSDictionary*)dict
{
    Attachment* c = [Attachment new];
    c.ActivityId = NS_NOT_NULL([dict objectForKey:@"ActivityId"]);
    c.CommentId = [dict objectForKey:@"CommentId"];
    c.ContentType = NS_NOT_NULL([dict objectForKey:@"ContentType"]);
    c.DateCreatedString = NS_NOT_NULL([dict objectForKey:@"DateCreatedString"]); //
    c.FileExtention = NS_NOT_NULL([dict objectForKey:@"FileExtention"]);
    c.FileUrl = NS_NOT_NULL([dict objectForKey:@"FileUrl"]);
    c.MidsizeImageFileUrl = NS_NOT_NULL([dict objectForKey:@"MidsizeImageFileUrl"]);
    c.MobileAppFileUrl = NS_NOT_NULL([dict objectForKey:@"MobileAppFileUrl"]);
    c.OriginalName = NS_NOT_NULL([dict objectForKey:@"OriginalName"]);
    c.Id = NS_NOT_NULL([dict objectForKey:@"Id"]);
    c.ExternalVendorType = NS_NOT_NULL([dict objectForKey:@"ExternalVendorType"]);

    return c;
}
@end