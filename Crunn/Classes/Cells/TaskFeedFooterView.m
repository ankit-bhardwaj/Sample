//
//  TaskFeedFooterView.m
//  Crunn
//
//  Created by Ashish Maheshwari on 8/19/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "TaskFeedFooterView.h"

@implementation TaskFeedFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        _dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 200, 20)];
        [_dateLbl setFont:[UIFont systemFontOfSize:11.0]];
        [self.contentView addSubview:_dateLbl];
        
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setTitle:@"Comment" forState:UIControlStateNormal];
        [_commentBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
        [_commentBtn setTitleColor:[UIColor colorWithRed:29.0/255.0 green:153.0/255.0 blue:202.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_commentBtn setImage:[UIImage imageNamed:@"comment_normal_small.png"] forState:UIControlStateNormal];
        [_commentBtn setImage:[UIImage imageNamed:@"comment_disable_small.png"] forState:UIControlStateSelected];
        _commentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        CGRect rect = CGRectMake(self.bounds.size.width-105, 0,100, 40);
        [_commentBtn setFrame:rect];
        [self.contentView addSubview:_commentBtn];
        _commentBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _commentBtn.hidden = YES;
        
        _commentCount = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-106, 0, 40, 34)];
        [_commentCount setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.0]];
        [_commentCount setTextAlignment:NSTextAlignmentCenter];
        [_commentCount setBackgroundColor:[UIColor clearColor]];
        _commentCount.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _commentCount.userInteractionEnabled = NO;
        [self.contentView addSubview:_commentCount];
        _commentCount.hidden = YES;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
