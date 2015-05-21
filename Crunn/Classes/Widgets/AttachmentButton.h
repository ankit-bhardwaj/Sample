//
//  AttachmentButton.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/17/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface AttachmentButton : UIButton

@property(nonatomic,strong)Attachment* attachment;
@property(nonatomic,strong)NSString* localAttachmentPath;
@property(nonatomic,strong)NSString* serverAttachmentPath;
@end
