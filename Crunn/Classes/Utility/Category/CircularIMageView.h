//
//  CircularIMageView.h
//  DemoSocial
//
//  Created by Ashish Maheshwari on 02/12/12.
//  Copyright (c) 2012 iTF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Comment.h"

@interface CircularIMageView : UIImageView
{
    
}

@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, strong) MPMoviePlayerController *player;

-(void)loadImageFromURL:(NSString*)urlStr;
-(void)loadVideoThumbnail:(NSString*)urlStr;
-(void)networkOperationDone;
-(void)loadImageFromURLForAttachment:(Attachment*)attachment;
@end
