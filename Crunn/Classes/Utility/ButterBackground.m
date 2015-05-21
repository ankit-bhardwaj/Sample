//
//  Background.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ButterBackground.h"

@implementation ButterBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    
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
        [[UIImage imageNamed:@"background-Portrait.png"] drawInRect:self.bounds];
    else
        [[UIImage imageNamed:@"background-Landscape.png"] drawInRect:self.bounds];
}


@end
