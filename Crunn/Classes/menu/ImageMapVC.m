//
//  ImageMapVC.m
//  mqApp
//
//  Circumference of equator = 40,075.16 km
//    111.3198889 km / lon
//  Circumference of n/s poles = 40,008 km
//    222.2666667 km / lat
//
//  Created by Ashish Maheshwari on 12/2/09.
//  Copyright Erixir Inc Limited, Inc 2009. All rights reserved.
//

#import "ImageMapVC.h"
#import "TouchScrollView.h"


@interface ImageMapVC (Private)
- (void) recenterWithOffset:(CGPoint)pt ;
- (void) loadMap ;
@end



#define DOUBLE_TAP_DELAY 0.35


@implementation ImageMapVC
{
    CGRect initialPostion;
    float minZoomScale;
    BOOL _isZooming;
}
@synthesize scrollView;
@synthesize locateButton;
@synthesize mapImageSrc;
@synthesize focusPoint;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
    [self setupLeftMenuButton];
    
        UIColor * barColor = [UIColor
                              colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
  
    
	_loading = NO;
	_zoom = 12; // default street level zoom
	// This is a mapquest provided conversion for zoom value [1:16] to 1/20th of a
	
	_imgView = [[UIImageView alloc] initWithFrame:[scrollView bounds]];
	
	[scrollView setDelegate:self];
	[scrollView setMaximumZoomScale:2.0];
	[scrollView setMinimumZoomScale:-1.0];
	[scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
	[scrollView setDelegate:self];
	
	[scrollView addSubview:_imgView];
	[scrollView setContentSize:[_imgView bounds].size];
	
}


- (void) updateMap
{
	if ( _loading )
		return;
	
	[self loadMap];
}



- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self updateMap];
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	CGRect f, b;
	
	if ( fromInterfaceOrientation == UIInterfaceOrientationPortrait )
	{
		// we are now in landscape		
		[self.navigationController setNavigationBarHidden:YES animated:YES];		
		f = [self.view frame];
		b = [self.view bounds];
	}
	else
	{
		// we are now in portrait
		[self.navigationController setNavigationBarHidden:NO animated:YES];			
		f = [self.view frame];
		b = [self.view bounds];		
	}
	
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	CGRect f, b;
	
	if ( toInterfaceOrientation == UIInterfaceOrientationPortrait )
	{
		// we are going to portrait		
			
		f = [self.view frame];
		b = [self.view bounds];
	}
	else
	{
		// we are going to landscape
		
		f = [self.view frame];
		b = [self.view bounds];		
	}
}


- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void) handleSingleTap
{
	// TODO: use _tapLocation
}

- (void) handleDoubleTap
{
	if(!_isZooming)
	{
		[self updateMapZoomIn];
	}
	else
	{
		[self updateMapZoomOut];
	}
}


- (void)updateMapZoomIn
{
	if ( _loading )
		return;
	
    if(self.mapImage != nil)
    {
        _isZooming = YES;
        
		CGSize sz = [self.mapImage size];
		
        
 		UIDevice* d =[UIDevice currentDevice];
		if([d.systemVersion floatValue] >= 3.2)
			[scrollView setZoomScale:1.0 animated:YES];
		else
			[scrollView setZoomScale:1.0 animated:NO];
        
		[scrollView setContentOffset:CGPointZero];
		[_imgView setFrame:CGRectMake( 0, 0, sz.width, sz.height)];
		[scrollView setContentSize:sz];
		if ( ! CGPointEqualToPoint( focusPoint, CGPointZero) )
		{
			unsigned int xDiff = sz.width - focusPoint.x;
			unsigned int yDiff = sz.height - focusPoint.y;
			if(xDiff > 0 && yDiff > 0)
			{
				if(xDiff > 160 || yDiff > 220)
					[scrollView scrollRectToVisible:CGRectMake(0, 0, focusPoint.x + 160, focusPoint.y + 220) animated:NO];
				else
					[scrollView scrollRectToVisible:CGRectMake(0, 0, focusPoint.x + xDiff, focusPoint.y + yDiff) animated:NO];
			}
		}
		else {
			CGSize viewSize = [scrollView bounds].size;
			unsigned int x = MIN(sz.width,(_tapLocation.x * sz.height)/viewSize.height);
			unsigned int y = MIN(sz.height,(_tapLocation.y * sz.height)/viewSize.height);
			if(x > sz.width || y > sz.height)
				[scrollView scrollRectToVisible:CGRectMake(0, 0,x,y) animated:NO];
			else
				[scrollView scrollRectToVisible:CGRectMake(0, 0,x + 160,y + 220) animated:NO];
		}
        [scrollView setZoomScale:1.2];
	}
}


- (void)updateMapZoomOut
{
	if ( _loading )
		return;

	_isZooming = NO;
    //	CGSize sz = [img size];
	
	
	[_imgView setImage:self.mapImage];
	
	// TODO: alotta config work here
	[scrollView setMinimumZoomScale:minZoomScale];
	[scrollView setMaximumZoomScale:1.0];
	
	[scrollView zoomToRect:initialPostion animated:NO];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // cancel any pending handleSingleTap messages
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleSingleTap) object:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	_tapLocation = [touch locationInView:scrollView];
	
	if ([touch tapCount] == 1)
	{
		[self performSelector:@selector(handleSingleTap) withObject:nil afterDelay:0.35];
	} else if([touch tapCount] == 2)
	{
		[self handleDoubleTap];
	}
}



#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imgView;
}



- (void) renderImage:(UIImage*)img
{
	if ( img == nil )
		return;
	
    self.mapImage = img;
    
	CGSize sz = [img size];
	CGSize viewSize = [scrollView bounds].size;
	double imgRatio = sz.width / sz.height;
	double viewRatio = viewSize.width / viewSize.height;
    
	[scrollView setContentOffset:CGPointZero];
	[scrollView setContentSize:sz];
	[_imgView setFrame:CGRectMake( 0, 0, sz.width, sz.height)];
	
	if ( imgRatio != 1 && imgRatio > viewRatio )
	{
		//CGRect rect = scrollView.frame;
		//scrollView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
		//scrollView.frame = rect;
	}
	
	[_imgView setImage:img];
    
	
	initialPostion = CGRectZero;
	initialPostion.size = sz;
    // image taller than viewport
    initialPostion.size.height = sz.height;
    initialPostion.size.width = sz.height * viewRatio;
    minZoomScale = viewSize.width / sz.width;

    [scrollView setZoomScale:0.5];
	[scrollView setMinimumZoomScale:0.1];
	[scrollView setMaximumZoomScale:10.0];
}




- (void) loadMap
{
    if(self.attachment)
    {
        NSString* url = [NSString stringWithFormat:@"%@/home/DownloadFile?fileId=%@&fileName=%@&fileUrl=%@&contentType=%@",BASE_FILE_PATH,self.attachment.Id,[self fullEscapeString:self.attachment.OriginalName],[self fullEscapeString:self.attachment.FileUrl],[self fullEscapeString:self.attachment.ContentType]];
        
        [AppDelegate startShowingNetworkActivity];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             if([(NSHTTPURLResponse*)response statusCode] !=200 || connectionError)
             {
                 data = nil;
             }
             [self performSelectorOnMainThread:@selector(downlaodComplete:) withObject:data waitUntilDone:NO];
             
         }];
    }
    else if(NSSTRING_HAS_DATA(self.mapImageSrc))
    {
        UIImage* img = [UIImage imageWithContentsOfFile:self.mapImageSrc];
        if ( img != nil )
            [self renderImage:img];
    }
    
	
}


- (void)downlaodComplete:(NSData*)data
{
    [AppDelegate stopShowingNetworkActivity];
    if(data)
    {
        [self setupRightMenuButton];
        UIImage* img = [UIImage imageWithData:data];
        if ( img != nil )
            [self renderImage:img];
    }
    else
    {

    }
}

- (CFStringRef) fullEscapeString:(NSString*)source
{
	// http://www.ietf.org/rfc/rfc2396.txt
	// Section 2.2
	// ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |
    //	"$" | ","
	CFStringRef urlString =
    CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
                                            (CFStringRef)source,
                                            NULL,
                                            CFSTR(":;/?@&=+$,"),
                                            kCFStringEncodingUTF8);
	
	return urlString;
}

-(void)setupLeftMenuButton
{
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalViewControllerAnimated:) ];
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:leftDrawerButton, nil] animated:YES];
}

-(void)setupRightMenuButton{
    UIBarButtonItem * leftDrawerButton = [[UIBarButtonItem alloc] initWithTitle:@"Download" style:UIBarButtonItemStyleBordered target:self action:@selector(downloadAttachment:) ];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:leftDrawerButton, nil] animated:YES];
}

- (void)downloadAttachment:(id)sender
{
    [self.view makeToast:@"Downloading Done"];
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end
