//
//  GSAsynImageView.m
//  DemoSocial
//
//  Created by Ashish Maheshwari on 02/12/12.
//  Copyright (c) 2012 iTF. All rights reserved.
//

#import "CircularIMageView.h"
#import "AppDelegate.h"
#import "Comment.h"

@implementation CircularIMageView
@synthesize indicator;
@synthesize urlString;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setImage:[UIImage imageNamed:@"avatar.png"]];
        [[self layer] setBorderColor:[UIColor clearColor].CGColor];
        [[self layer] setCornerRadius:self.bounds.size.width/2.0];
        [[self layer] setMasksToBounds:YES];

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setImage:[UIImage imageNamed:@"avatar.png"]];
        [[self layer] setBorderColor:[UIColor clearColor].CGColor];
        [[self layer] setCornerRadius:self.bounds.size.width/2.0];
        [[self layer] setMasksToBounds:YES];

    }
    return self;
}

-(void)loadImageFromURL:(NSString*)urlStr
{
    if(urlStr.length==0){
        return;
    }
    if([urlStr hasPrefix:@"/"])
        self.urlString = [NSString stringWithFormat:@"%@%@",BASE_FILE_PATH,urlStr];
    else
        self.urlString = [NSString stringWithFormat:@"%@/%@",BASE_FILE_PATH,urlStr];

    
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *profilePicPath = [documentFilePath stringByAppendingPathComponent:[urlString lastPathComponent]];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:profilePicPath])
    {
        self.image = [UIImage imageWithContentsOfFile:profilePicPath];
    }
    else if(![APPDELEGATE registerNetworkURL:urlStr forObserver:self])
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             [self performSelectorOnMainThread:@selector(updateImage:) withObject:data waitUntilDone:NO];
         }];
    }
}

-(void)loadImageFromURLForAttachment:(Attachment*)attachment
{
    if(attachment.MobileAppFileUrl.length==0){
        return;
    }
    self.urlString = [NSString stringWithFormat:@"%@%@",BASE_FILE_PATH,attachment.MobileAppFileUrl];
    
    [self.indicator removeFromSuperview];
    self.indicator = nil;
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    [self addSubview:indicator];
    
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *profilePicPath = [documentFilePath stringByAppendingPathComponent:[urlString lastPathComponent]];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:profilePicPath])
    {
        self.image = [UIImage imageWithContentsOfFile:profilePicPath];
        [self.indicator removeFromSuperview];
        self.indicator = nil;
    }
    else if(![APPDELEGATE registerNetworkURL:attachment.MobileAppFileUrl forObserver:self])
    {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             [self performSelectorOnMainThread:@selector(updateImage:) withObject:data waitUntilDone:NO];
             
         }];
    }
}

- (void)updateImage:(NSData*)data
{
    if(data)
    {
        UIImage* image = [UIImage imageWithData:data];
        if(image)
        {
            self.image = image;
            NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
            NSString *profilePicPath = [documentFilePath stringByAppendingPathComponent:[urlString lastPathComponent]];
            [[NSFileManager defaultManager] createFileAtPath:profilePicPath contents:data attributes:nil];
        }
        else
        {
            self.image = [UIImage imageNamed:@"placeholder_image.png"];
        }
        
    }
    [self.indicator removeFromSuperview];
    self.indicator = nil;
}

-(void)loadVideoThumbnail:(NSString*)urlStr
{
    if(urlStr.length==0){
        return;
    }
    self.urlString = urlStr;
    
    [self.indicator removeFromSuperview];
    self.indicator = nil;

    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    [self addSubview:indicator];
    
    [self performSelectorInBackground:@selector(loadThumbView) withObject:nil];
}


-(void)loadThumbView
{
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *thumbName = [[[urlString lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    
    NSString *profilePicPath = [documentFilePath stringByAppendingPathComponent:thumbName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:profilePicPath])
    {
        [self performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:profilePicPath] waitUntilDone:YES] ;
        
        [indicator removeFromSuperview];
        self.indicator = nil;

    }
    else
    {
        NSData *thumbnail = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[urlString stringByDeletingLastPathComponent] stringByAppendingPathComponent:thumbName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];

        if(!thumbnail)
            thumbnail = UIImagePNGRepresentation([UIImage imageNamed:@"default-video.png"]);
        else
        {
            [[NSFileManager defaultManager] createFileAtPath:profilePicPath contents:thumbnail attributes:nil];
        }
        
        [self performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:thumbnail] waitUntilDone:YES] ;
        
        [indicator removeFromSuperview];
        self.indicator = nil;
    }
    
    
}

-(void)loadView
{
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *profilePicPath = [documentFilePath stringByAppendingPathComponent:[urlString lastPathComponent]];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:profilePicPath])
    {
        sleep(100);
    }
    else
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
        User* user = [User currentUser];
        [request setHTTPMethod:@"POST"];
        NSDictionary *headerFieldsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json", @"Content-Type",[self authToken], @"authToken",APP_KEY, @"appKey",[NSString stringWithFormat:@"%d",user.UserId], @"userId",  nil];
        
        [request setAllHTTPHeaderFields:headerFieldsDict];
        NSURLResponse* response = nil;
        NSData *picData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        
//        NSData *picData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        if(picData)
            [[NSFileManager defaultManager] createFileAtPath:profilePicPath contents:picData attributes:nil];
    }
    
    [APPDELEGATE weekenNetworkURL:urlString];
    
    [indicator removeFromSuperview];
    self.indicator = nil;
    
}

- (NSString*)authToken
{
    NSString* device = [User currentUser].WcfAccessToken;
    if(!NSSTRING_HAS_DATA(device))
        device = [[NSUserDefaults standardUserDefaults] objectForKey:@"authToken"];
    if(!NSSTRING_HAS_DATA(device))
        device = @"APA91bEAlf702h39s6w9vDmBe_f5v41S3wFMUhZ4uyP6zpfwYVu4AAoIOHBVQsEOAC4XBBH-1VdpUzEaLfpj-X6uYnQR3UqRf3DfhDO96ioLfAWBck09chHjIxMHdH9bHw1S0IhraoUE9Ocl9BojFGDCXrRL4Kx_Qg";
    return device;
}

-(void)networkOperationDone
{
    NSString *documentFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *profilePicPath = [documentFilePath stringByAppendingPathComponent:[urlString lastPathComponent]];

    if([[NSFileManager defaultManager] fileExistsAtPath:profilePicPath])
    {
        [self performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:profilePicPath] waitUntilDone:YES] ;
    }
    else
    {
        [self performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageNamed:@"DefaultAvatar.png"] waitUntilDone:YES] ;
    }
    
    [indicator removeFromSuperview];
    self.indicator = nil;

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
