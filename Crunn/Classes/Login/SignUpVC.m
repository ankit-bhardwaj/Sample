//
//  SignUpVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "SignUpVC.h"
#import "LoginVC.h"
#import "ValidationHelper.h"
#import "UserDocument.h"
#import "TimeZoneSelectorVC.h"

@interface SignUpVC ()
{
    IBOutlet UITextField* firstTxt;
    IBOutlet UITextField* lastTxt;
    IBOutlet UITextField* emailTxt;
    IBOutlet UITextField* passTxt;
    IBOutlet UITextField* confPassTxt;
    IBOutlet UIButton*    timeZoneBtn;
    
    IBOutlet UIScrollView* scrollView;
    
    MBProgressHUD *HUD;
}

- (IBAction)timeZoneAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)signupAction:(id)sender;

@end

@implementation SignUpVC

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

    
    [[UserDocument sharedInstance] fetchTimeZones];
    
    // Do any additional setup after loading the view from its nib.
    [scrollView setContentSize:CGSizeMake(320, 480)];
    
    firstTxt.layer.cornerRadius = 2.0;
    lastTxt.layer.cornerRadius = 2.0;
    emailTxt.layer.cornerRadius = 2.0;
    passTxt.layer.cornerRadius = 2.0;
    confPassTxt.layer.cornerRadius = 2.0;
    timeZoneBtn.layer.cornerRadius = 2.0;
    
    
    firstTxt.leftView = [self leftViewWithImage:@"username_placehoder.png"];
    [firstTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    lastTxt.leftView = [self leftViewWithImage:@"username_placehoder.png"];
    [lastTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    emailTxt.leftView = [self leftViewWithImage:@"email_placeholder.png"];
    [emailTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    passTxt.leftView = [self leftViewWithImage:@"password_placeholder.png"];
    [passTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    confPassTxt.leftView = [self leftViewWithImage:@"password_placeholder.png"];
    [confPassTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    
    //NSString* timeZone = [[NSTimeZone systemTimeZone] name];
    //[timeZoneBtn setTitle:timeZone forState:UIControlStateSelected];
    //timeZoneBtn.selected = YES;
}

- (UIView*)leftViewWithImage:(NSString*)imgstr
{
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 22) ];
    [leftView setBackgroundColor:[UIColor clearColor]];
    UIImageView* userPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
    userPlaceholder.contentMode = UIViewContentModeScaleAspectFit;
    [userPlaceholder setImage:[UIImage imageNamed:imgstr]];
    [leftView addSubview:userPlaceholder];
    return leftView;
}


- (IBAction)timeZoneAction:(id)sender
{
    TimeZoneSelectorVC* vc = [[TimeZoneSelectorVC alloc] initWithNibName:@"TimeZoneSelectorVC" bundle:nil];
    vc.target = self;
    vc.action = @selector(timeZoneSelected:);
    UINavigationController* nvvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvvc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nvvc animated:YES completion:nil];
}

- (void)timeZoneSelected:(NSString*)timeZone
{
    timeZoneBtn.selected = YES;
    [timeZoneBtn setTitle:timeZone forState:UIControlStateSelected];
}

-(IBAction)signupAction:(id)sender
{
    if(sender == nil)
    {
        if([firstTxt isFirstResponder])
            [firstTxt resignFirstResponder];
        else if([lastTxt isFirstResponder])
            [lastTxt resignFirstResponder];
        else if([emailTxt isFirstResponder])
            [emailTxt resignFirstResponder];
        else if([passTxt isFirstResponder])
            [passTxt resignFirstResponder];
        else if([confPassTxt isFirstResponder])
            [confPassTxt resignFirstResponder];
    }
    NSString* first = [firstTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* last = [lastTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* email = [emailTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* password = [passTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* confPass = [confPassTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(first))
    {
        msg = @"Enter First name";
    }
    if(!NSSTRING_HAS_DATA(last))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter Last name"];
    }
    if(!NSSTRING_HAS_DATA(last))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter Last name"];
    }
    if(!NSSTRING_HAS_DATA(email))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter Email Id"];
    }
    else if(![ValidationHelper validateEmail:email])
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Email Id is not valid"];
    }
    if(!NSSTRING_HAS_DATA(password))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter Password"];
    }
    else if([password length] < 6)
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"The Password must be 6 character long"];
    }
    
    if(!NSSTRING_HAS_DATA(confPass))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter Confirm Password"];
    }
    else if(![confPass isEqualToString:password])
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Password and Confirm Password should be same"];
    }
    
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else{
        NSString* timeZone = [timeZoneBtn titleForState:UIControlStateSelected];
        NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email",first,@"firstName",last,@"lastName",timeZone,@"timeZone",password, @"password", nil];
        
        [self addHUD];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationNotifier:) name:@"RegisterNotifier" object:nil];
        [[UserDocument sharedInstance] registerWithUser:jsonDictionary];

    }
    //    [APPDELEGATE LoadMainView];
}

- (void) addHUD
{
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [HUD show:YES];
}

- (void) registrationNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    
    [self performSelectorOnMainThread:@selector(registrationSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

- (void)registrationSuccess:(id)object
{
    [HUD hide:YES];
   
    if(!object)
    {
        [APPDELEGATE LoadMainView];
        
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Welcome to Grapple" message:@"\nYou will now be able to streamline your work efficiently.\n\nWe have created four simple tasks for you. These will just take a few seconds to finish and will get you started with Grapple." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self performSelector:@selector(dismissAlert:) withObject:av afterDelay:10.0];
    }
    else
    {
        if([object isEqualToString:@"AlreadyHaveAnAccount"])
            object = @"We already have an account with this email address in our system. If it belongs to you and you have forgotten the password, please click on 'Forgot Password' on the login screen.";
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (void)dismissAlert:(UIAlertView*)av
{
    if(av.visible)
        [av dismissWithClickedButtonIndex:-1 animated:YES];
}




-(IBAction)loginAction:(id)sender
{
    //[self.navigationController popViewControllerAnimated:NO];
    LoginVC* vc = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField == firstTxt)
        [lastTxt becomeFirstResponder];
    else if(textField == lastTxt)
        [emailTxt becomeFirstResponder];
    else if(textField == emailTxt)
        [passTxt becomeFirstResponder];
    else if(textField == passTxt)
        [confPassTxt becomeFirstResponder];
    else
    {
        [self signupAction:nil];
    }
    return YES;
}

@end
