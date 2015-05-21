//
//  ShowAttachmentVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/16/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ShowAttachmentVC.h"


@interface ShowAttachmentVC ()

@end

@implementation ShowAttachmentVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupLeftMenuButton];
    if(self.attachment)
        [self setupRightMenuButton];
    
        UIColor * barColor = [UIColor
                              colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
        [self.navigationController.navigationBar setBarTintColor:barColor];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor: [UIColor colorWithWhite:0.0f alpha:0.750f]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               
                                               [UIFont systemFontOfSize:16.0],NSFontAttributeName,
                                               shadow, NSShadowAttributeName, nil];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    webview.delegate = self;
    webview.scalesPageToFit = YES;
    webview.scrollView.minimumZoomScale = 0.0;
    webview.scrollView.maximumZoomScale = 10.0;
  
    if (NSSTRING_HAS_DATA(self.url))
    {
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f]];
    }
    else if(self.attachment)
    {
        //self.navigationItem.title = self.attachment.OriginalName;
        NSString* url = [NSString stringWithFormat:@"%@/home/DownloadFile?fileId=%@&fileName=%@&fileUrl=%@&contentType=%@",BASE_FILE_PATH,self.attachment.Id,[self fullEscapeString:self.attachment.OriginalName],[self fullEscapeString:self.attachment.FileUrl],[self fullEscapeString:self.attachment.ContentType]];
        [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f]];
    }
    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [AppDelegate startShowingNetworkActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [AppDelegate stopShowingNetworkActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [AppDelegate stopShowingNetworkActivity];
}

- (void)downloadAttachment:(id)sender
{
    [self.view makeToast:@"Downloading Start"];
    NSString* url = [NSString stringWithFormat:@"%@/home/DownloadFile?fileId=%@&fileName=%@&fileUrl=%@&contentType=%@",BASE_FILE_PATH,self.attachment.Id,[self fullEscapeString:self.attachment.OriginalName],[self fullEscapeString:self.attachment.FileUrl],[self fullEscapeString:self.attachment.ContentType]];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if([(NSHTTPURLResponse*)response statusCode] !=200 || connectionError)
         {
             data = nil;
         }
         [self performSelectorOnMainThread:@selector(downlaodComplete:) withObject:data waitUntilDone:NO];
        
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)downlaodComplete:(NSData*)data
{
    if(data)
    {
        [self.view makeToast:@"Download Completed"];
    }
    else
    {
        [self.view makeToast:@"Error while downlaoding file"];
    }
}

@end
