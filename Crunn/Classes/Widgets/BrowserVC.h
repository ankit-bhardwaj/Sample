//
//  BrowserVC.h
//  mCampus
//
//  Created by Scott Guyer on 10/13/09.
//  Copyright 2009 DubMeNow, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BrowserVC : UIViewController <UIWebViewDelegate>
{
	// public interface
	NSString* pageTitle;
	NSString* url;
	NSString* content;
    
	// IB-enabled Interface
	UIWebView* webView;
	UIToolbar* toolbar;		// future use
	
}

@property(nonatomic, copy)				NSString*	pageTitle;
@property(nonatomic, copy)				NSString*	url;
@property(nonatomic, copy)				NSString*	content;
@property(nonatomic, retain)				NSString*	strFrom;
@property(nonatomic, retain)				NSString*	strMeeting;
@property(nonatomic, retain)				NSString*	sessionName;




@property(nonatomic, readonly, retain) IBOutlet	UIWebView*	webView;
@property(nonatomic, readonly, retain) IBOutlet	UIToolbar*	toolbar;

- (IBAction) openInSafari;


@end
