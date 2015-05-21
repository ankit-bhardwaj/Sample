//
//  Background.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

@interface Background : UIView

@property (nonatomic,strong) AVPlayer* videoPlayer;
@property (nonatomic,strong) AVPlayerLayer* videoPlayerLayer;
@property (nonatomic,strong) UIImageView* backgroundImageView;

- (void)pauseMovie;
@end
