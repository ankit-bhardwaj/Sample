//
//  CommentCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "GSAsynImageView.h"
#import "AttachmentButton.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)tapGestureAction:(UITapGestureRecognizer*)reg
{
    if(!self.readMore.hidden)
    {
        self.readMore.selected = !self.readMore.selected;
        self.commentObj.isExpanded = !self.commentObj.isExpanded;
        if(self.readMoreTarget && [self.readMoreTarget respondsToSelector:self.readMoreAction])
        {
            [self.readMoreTarget performSelector:self.readMoreAction withObject:self];
        }
    }
}

- (void)awakeFromNib
{
    // Initialization code
    [[self.roundedView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.roundedView layer] setBorderWidth:1.0f];
    [[self.roundedView layer] setCornerRadius:5.0f];
    //[[self.commenterImage layer] setMasksToBounds:YES];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)fillDataWithComment:(Comment*)comment forWidth:(CGFloat)w
{
    float y = 0.0;
    
    self.commentObj = comment;

    [self.commenterImage loadImageFromURL:comment.commenter.MobileImageUrl];
    self.commenterImage.target = self;
    self.commenterImage.action = @selector(assigneeImageTapped:);
    
    CGSize size = [comment.commenter.FormattedName sizeWithFont:self.commenterName.font constrainedToSize:CGSizeMake(FLT_MAX, self.commenterName.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect rect = self.commenterName.frame;
    rect.size.width = MIN(size.width, DEVICE_IS_TABLET?560:120);
    self.commenterName.frame = rect;
    self.commenterName.text = comment.commenter.FormattedName;
    
    self.commentDate.text = [[comment.createdDate componentsSeparatedByString:@"|"] firstObject];
    size = [self.commentDate.text sizeWithFont:self.commentDate.font constrainedToSize:CGSizeMake(FLT_MAX, self.commentDate.frame.size.height) lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect rect1 = self.commentDate.frame;
    rect1.origin.x = rect.origin.x + rect.size.width + 5;
    rect1.size.width = MIN(size.width, 100);
    [self.commentDate setFrame:rect1];
   
    
    CGRect rect2 = self.showEmailIcon.frame;
    rect2.origin.x = rect1.origin.x + rect1.size.width + 5;
    [self.showEmailIcon setFrame:rect2];
    self.showEmailIcon.hidden = !comment.fromEmail;
    
    self.locationBtn.hidden = !comment.location;
    CGRect rect3 = self.locationBtn.frame;
    rect3.origin.x = self.showEmailIcon.hidden?(rect1.origin.x + rect1.size.width):(rect2.origin.x + rect2.size.width) + 5;
    [self.locationBtn setFrame:rect3];
    
    
    self.comment.attributedText = comment.attributedComment;
    
    
    rect = self.comment.frame;
    
    CGSize textSize = comment.attrCommentSize;
    [self.comment setNumberOfLines:0];
    if (textSize.height > 45)
    {
        [self.readMore setHidden:NO];
        self.readMore.selected = comment.isExpanded;
        if(!comment.isExpanded)
        {
            textSize.height = 45;
            [self.comment setNumberOfLines:3];
        }
    }
    else
    {
        [self.readMore setHidden:YES];
    }
    
    rect.size.height = textSize.height;
    self.comment.frame = rect;
    
    y = rect.origin.y + rect.size.height;
    CGRect readmorerect = self.readMore.frame;
    readmorerect.origin.y = y;
    self.readMore.frame = readmorerect;
    if (!self.readMore.hidden)
    {
        y += self.readMore.frame.size.height;
    }
    y+=5;
    [self.attachmentScrollView setHidden:YES];
    
    for(UIView* v in self.attachmentScrollView.subviews)
    {
        if([v isKindOfClass:[AttachmentButton class]] || [v isKindOfClass:[GSAsynImageView class]])
            [v removeFromSuperview];
    }
    for(UIView* v in self.roundedView.subviews)
    {
        if([v isKindOfClass:[AttachmentButton class]])
            [v removeFromSuperview];
    }
    NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
    if(comment.Attachments && comment.Attachments.count)
    {
        BOOL scrollViewAdded = NO;
        int xoffset = 0;
        int yoffset = 0;
        for(Attachment* attachment in comment.Attachments)
        {
            if([imageContentTypes containsObject:attachment.ContentType])
            {
                if(!scrollViewAdded)
                {
                    [self.attachmentScrollView setHidden:NO];
                   
                    scrollViewAdded = YES;
                    CGRect rect = self.attachmentScrollView.frame;
                    rect.origin.y = y;
                    [self.attachmentScrollView setFrame:rect];
                    y+= self.attachmentScrollView.bounds.size.height + 5;
                }
                GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 44, 44)];
                attachmentImage.target = self;
                attachmentImage.action = @selector(showAttachment:);
                attachmentImage.attachment = attachment;
                [attachmentImage loadImageFromURLForAttachment:attachment];
                [self.attachmentScrollView addSubview:attachmentImage];
                [self.attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
                [[attachmentImage layer] setCornerRadius:3.0f];
                [[attachmentImage layer] setBorderWidth:1.0f];
                [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
                [[attachmentImage layer] setMasksToBounds:YES];
                [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
                
                
                xoffset += 50;
            }
            else
            {
                
                AttachmentButton* showAttachmentBtn = [AttachmentButton buttonWithType:UIButtonTypeCustom];
                showAttachmentBtn.attachment = attachment;
                CGRect rect = self.comment.frame;
                rect.origin.y = y;
                rect.size.height = 16;
                [showAttachmentBtn setFrame:rect];
                [showAttachmentBtn setTitle:attachment.OriginalName forState:UIControlStateNormal];
                [showAttachmentBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
                [showAttachmentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                [showAttachmentBtn addTarget:self action:@selector(showAttachment:) forControlEvents:UIControlEventTouchUpInside];
                [showAttachmentBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [showAttachmentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                showAttachmentBtn.titleEdgeInsets  = UIEdgeInsetsMake(0, 5, 0, 0);
                [showAttachmentBtn setImage:[UIImage imageNamed:@"iconAttachment.png"] forState:UIControlStateNormal];
                [self.roundedView addSubview:showAttachmentBtn];
                y+=rect.size.height+5;
                
            }
            
        }
        y+=10;
    }

//    CGRect r = self.frame;
//    r.size.height = y;
//    self.frame = r;
}

- (void)assigneeImageTapped:(GSAsynImageView*)imageview
{
    [[APPDELEGATE window] makeToast:self.commentObj.commenter.Email duration:3.0 position:CSToastPositionCenter title:self.commentObj.commenter.FormattedName image:imageview.image];
}

-(IBAction)readMore:(UIButton*)sender
{
    if(!self.readMore.hidden)
    {
        self.readMore.selected = !self.readMore.selected;
        self.commentObj.isExpanded = !self.commentObj.isExpanded;
        if(self.readMoreTarget && [self.readMoreTarget respondsToSelector:self.readMoreAction])
        {
            [self.readMoreTarget performSelector:self.readMoreAction withObject:self];
        }
    }

}

-(void)showAttachment:(AttachmentButton*)sender
{
    Attachment* attachment = sender.attachment;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAttachment" object:attachment];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
    CGPoint touchPoint = [touch locationInView:self.comment];
    if(touchPoint.x > 0 && touchPoint.y)
        [self readMore:self.readMore];
}
@end
