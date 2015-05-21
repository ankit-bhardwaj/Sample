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

@interface CommentCell : UITableViewCell
@property (nonatomic, retain) IBOutlet GSAsynImageView* commenterImage;
@property (nonatomic, retain) IBOutlet UILabel* commenterName;
@property (nonatomic, retain) IBOutlet UILabel* commentDate;
@property (nonatomic, retain) IBOutlet UIView* commentSuperView;
@property (nonatomic, retain) IBOutlet UILabel* comment;
@property (nonatomic, retain) IBOutlet UIView* roundedView;
@property (nonatomic, retain) IBOutlet UIScrollView* attachmentScrollView;
@property (nonatomic, retain) IBOutlet UIButton* readMore;
@property (nonatomic, assign) BOOL showReadMore;
@property (nonatomic, retain) IBOutlet UIImageView* showEmailIcon;
@property (nonatomic, retain) Comment* commentObj;
@property(nonatomic,strong)id readMoreTarget;
@property(nonatomic,assign)SEL readMoreAction;
@property(nonatomic,retain)IBOutlet UIButton* locationBtn;

-(void)fillDataWithComment:(Comment*)comment forWidth:(CGFloat)w;
@end
