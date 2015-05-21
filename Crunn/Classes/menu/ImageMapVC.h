//
//  ImageMapVC.h
//  mqApp
//
//  Created by Ashish Maheshwari on 12/2/09.
//  Copyright Erixir Inc Limited, Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Comment.h"
@class TouchScrollView;


@interface ImageMapVC : UIViewController <UIScrollViewDelegate, UIScrollViewDelegate>
{
	TouchScrollView* scrollView;
	UIBarButtonItem* locateButton;
	
	NSString*        mapImageSrc;
	CGPoint          focusPoint;
	
	UIImageView*  _imgView;
	
	int                _zoom;
	NSArray*           _zoomScaleMap;
	
	CGPoint            _tapLocation;
	
	BOOL               _loading;
	
	CALayer*           _marker;

}
@property (nonatomic, retain)Attachment* attachment;

@property(nonatomic,retain) IBOutlet TouchScrollView* scrollView;
@property(nonatomic,retain) IBOutlet UIBarButtonItem* locateButton;
@property(nonatomic,retain) NSString* mapImageSrc;
@property(nonatomic,retain) UIImage* mapImage;
@property(nonatomic,assign) CGPoint focusPoint;




@end

