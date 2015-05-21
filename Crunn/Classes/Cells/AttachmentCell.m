//
//  CommentCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "AttachmentCell.h"
#import "Comment.h"
#import "GSAsynImageView.h"
#import "AttachmentButton.h"

@implementation AttachmentCell

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

- (void)awakeFromNib
{
    // Initialization code
//    [[self.commenterImage layer] setBorderColor:[UIColor colorWithRed:27/255.0 green:116/255.0 blue:160/255.0 alpha:1.0f].CGColor];
//    [[self.commenterImage layer] setBorderWidth:1.0f];
//    [[self.commenterImage layer] setCornerRadius:3.0f];
//    [[self.commenterImage layer] setMasksToBounds:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)fillDataWithAttachments:(NSArray*)attachments
{
    float y = 5.0;
    [self.attachmentScrollView setHidden:YES];
    NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
    BOOL scrollViewAdded = NO;
    int xoffset = 5;
    int yoffset = 0;
    CGRect rect = CGRectZero;
    for(Attachment* attachment in attachments)
    {
        if([imageContentTypes containsObject:attachment.ContentType])
        {
            if(!scrollViewAdded)
            {
                [self.attachmentScrollView setHidden:NO];
                y+= self.attachmentScrollView.frame.size.height;
                scrollViewAdded = YES;
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
            y+=5;
            AttachmentButton* showAttachmentBtn = [AttachmentButton buttonWithType:UIButtonTypeCustom];
            showAttachmentBtn.attachment = attachment;
            CGRect rect = self.attachmentScrollView.frame;
            rect.origin.y = y;
            rect.size.height = 16;
            [showAttachmentBtn setFrame:rect];
            [showAttachmentBtn setTitle:attachment.OriginalName forState:UIControlStateNormal];
            [showAttachmentBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
            [showAttachmentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [showAttachmentBtn addTarget:self action:@selector(showAttachment:) forControlEvents:UIControlEventTouchUpInside];
            [showAttachmentBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [showAttachmentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [showAttachmentBtn setImage:[UIImage imageNamed:@"iconAttachment.png"] forState:UIControlStateNormal];
            showAttachmentBtn.titleEdgeInsets  = UIEdgeInsetsMake(0, 5, 0, 0);
            [self addSubview:showAttachmentBtn];
            y+=rect.size.height;
        }
        
    }
    y+=5;
    
    
    self.seperator.frame = CGRectMake(self.seperator.frame.origin.x, y, self.seperator.bounds.size.width, self.seperator.frame.size.height);
    y++;
    
    rect = self.frame;
    rect.size.height = y;
    [self setFrame:rect];
    
}

-(void)showAttachment:(AttachmentButton*)sender
{
    Attachment* attachment = sender.attachment;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAttachment" object:attachment];
}

@end
