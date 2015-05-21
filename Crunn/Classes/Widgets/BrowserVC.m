//
//  BrowserVC.m
//  mCampus
//
//  Created by Scott Guyer on 10/13/09.
//  Copyright 2009 DubMeNow, Inc. All rights reserved.
//

#import "BrowserVC.h"

@implementation BrowserVC

@synthesize pageTitle, url, webView, toolbar, content;
@synthesize strFrom,sessionName,strMeeting;


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ( self = [super initWithNibName:nibName bundle:nibBundle] )
	{
		pageTitle	= nil;
		url			= nil;
		content     = nil;
	}
	
	return self;
}

- (id) init
{
	if (self = [super init])
	{
		pageTitle	= nil;
		url			= nil;
		webView		= nil;
		toolbar		= nil;
		content     = nil;
        sessionName = nil;
        strMeeting=nil;
	}
	return self;
}






- (void) downloadComplete:(NSData*)htmlData
{

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
	
}



- (NSString*) getDestinationUrl:(NSString*)fromUrl
{
	NSString* urlString = nil;
	if ( ([fromUrl rangeOfString:@"http://"].location != 0) && ([fromUrl rangeOfString:@"https://"].location != 0) )
		urlString = [NSString stringWithFormat:@"http://%@", fromUrl];
	else
		urlString = fromUrl;
	
	NSString* theUrl = nil;
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];	 
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSURL* u = [NSURL URLWithString:urlString];	
	NSString* q = [u query];
	NSRange b = [q rangeOfString:@"destination"];
	if ( (q != nil) && (b.location != NSNotFound) )
	{
		NSString* sub = [q substringFromIndex:b.location+12];		
		NSRange e = [sub rangeOfString:@"&"];
		if ( e.location != NSNotFound )	
			theUrl = [[sub substringToIndex:e.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		else
			theUrl = [sub stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	else
		theUrl = urlString;
	
	return theUrl;
}



- (void) startDownload
{

	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;	
}





- (void) viewDidLoad 
{
    [super viewDidLoad];
	if (NSSTRING_HAS_DATA( pageTitle))
	{
		//[self.navigationItem setTitle:self.pageTitle];
        self.navigationItem.title=self.pageTitle;
	}
	
	if (NSSTRING_HAS_DATA( url))
	{
		UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithTitle:@"Safari" 
															   style:UIBarButtonItemStylePlain
															  target:self 
															  action:@selector(openInSafari)];

        [self.navigationItem setRightBarButtonItem:bi];
        
        UIBarButtonItem* bi1 = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(doneAction)];
        [self.navigationItem setLeftBarButtonItem:bi1];
        
	}
	
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	//[DUBCoreMain recordTrackingEvent:sDNTE_ViewBrowser];
	
	webView.delegate = self;	// setup the delegate as the web view is shown
    
    [webView setScalesPageToFit:YES];
	
		if ( NSSTRING_HAS_DATA( url) )
		{
            //			[self startDownload];			
			NSString* destination = [self getDestinationUrl:url];
			NSURLRequest* req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:destination] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];				
			[webView loadRequest:req];
		}
    
	
}


- (void) viewWillDisappear:(BOOL)animated
{
		
    [webView stopLoading];	// in case the web view is still loading its content
	webView.delegate = nil;	// disconnect the delegate as the webview is hidden
    webView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

-(void)resetScrollView:(UIScrollView*)scroll
{
    CGFloat ratioAspect = webView.bounds.size.width/webView.bounds.size.height;

    scroll.minimumZoomScale = scroll.minimumZoomScale *ratioAspect;
    scroll.maximumZoomScale = scroll.maximumZoomScale *ratioAspect;
    
    [scroll zoomToRect:webView.bounds animated:NO];    
}
/*
 - (void) viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void) viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */


- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (IBAction) openInSafari 
{
    NSString* urlString = [self getDestinationUrl:self.url];
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


#pragma mark -
#pragma mark UIWebViewDelegate


- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* urlStr = [request.URL absoluteString];
    NSLog(@"%s: req 0x%x url %@", __FUNCTION__, (unsigned int)request, urlStr);
    if([urlStr hasPrefix:@"comgooglemaps:"])
        return NO;
        
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// starting the load, show the activity indicator in the status bar
    //	NSURLCache* c = [NSURLCache sharedURLCache];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    
	if ([error code] != NSURLErrorCancelled)
	{
		// load error, hide the activity indicator in the status bar
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		// log it
		NSLog(@"%s: browser failed to load page! ERROR: %@ %@", __FUNCTION__,
			  [error localizedDescription],
			  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
		
		// report the error inside the webview
		NSString* errorString = [NSString stringWithFormat:
								 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
								 error.localizedDescription];
		
		[webView loadHTMLString:errorString baseURL:nil];
	}
    
    if([error code] == 404)
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" 
                                                     message:@"Sorry, the page you requested was not found."
                                                    delegate:nil 
                                           cancelButtonTitle:@"Ok"
                                           otherButtonTitles:nil];
        [av show];
    }
}
-(void)callCommonMethod{
            [webView stringByEvaluatingJavaScriptFromString:@"CallCommonMethod()"];
}

- (void)doneAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

