//
//  Background.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "Background.h"

@implementation Background

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self playMovie];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

        [self performSelector:@selector(playMovie) withObject:nil afterDelay:0.5];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if([[UIScreen mainScreen] bounds].size.height > 480)
            [[UIImage imageNamed:@"background-518h@2x.png"] drawInRect:self.bounds];
        else
            [[UIImage imageNamed:@"background.png"] drawInRect:self.bounds];
        
    }
    else if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        [[UIImage imageNamed:@"background-Portrait~ipad.png"] drawInRect:self.bounds];
    else
        [[UIImage imageNamed:@"background-Landscape~ipad.png"] drawInRect:self.bounds];
}


- (void)playMovie
{
    NSURL *movieOneItemURL = [[NSBundle mainBundle] URLForResource:@"welcome_video" withExtension:@"mp4"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movieOneItemURL options:nil];
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
     ^{
         // The completion block goes here.
         NSError *error = nil;
         AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
         
         if (status == AVKeyValueStatusLoaded)
         {
             [self performSelectorOnMainThread:@selector(openVideo:) withObject:asset waitUntilDone:NO];
         }
         else {
             // Deal with the error appropriately.
             NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
         }
     }];
}

- (void)openVideo:(AVURLAsset*)asset
{
    AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    //prepare player
    self.videoPlayer = [AVPlayer playerWithPlayerItem:item];
    self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    
    //[_backgroundImageView removeFromSuperview];
    //_backgroundImageView = nil;
    
    //prepare player layer
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPlayerLayer.frame = self.bounds;
    [self.layer insertSublayer:self.videoPlayerLayer atIndex:0];
    
    [self.videoPlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)pauseMovie
{
    if(self.videoPlayer)
        [self.videoPlayer pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

//called when playback completes
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.videoPlayer seekToTime:kCMTimeZero]; //rewind at the end of play
    [self.videoPlayer play];
    //other tasks
}

- (void)orientationChange:(NSNotification*)note
{
    self.videoPlayerLayer.frame = self.bounds;
}

@end
