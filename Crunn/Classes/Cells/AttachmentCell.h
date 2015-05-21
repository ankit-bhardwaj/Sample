//
//  CommentCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAsynImageView.h"
#import "Comment.h"

@interface AttachmentCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UIView* seperator;
@property (nonatomic, retain) IBOutlet UIScrollView* attachmentScrollView;
-(void)fillDataWithAttachments:(NSArray*)attachments;
@end
