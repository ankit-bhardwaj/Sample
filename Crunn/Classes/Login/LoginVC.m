//
//  LoginVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "LoginVC.h"
#import "SignUpVC.h"
#import "ForgotPasswordVC.h"
#import "UserDocument.h"
#import "MBProgressHUD.h"
#import "ScheduleWelcomeVC.h"
#import "CreateMeetingVC.h"
#import "ScheduleMeetingStepOneVC.h"
#import "ScheduleNavigationVC.h"

@interface LoginVC ()
{
    IBOutlet UITextField* userTxt;
    IBOutlet UITextField* passTxt;
    IBOutlet UISwitch*      keepMeLoggedInSwitch;
    MBProgressHUD *HUD;
}

- (IBAction)loginAction:(id)sender;
- (IBAction)signupAction:(id)sender;
- (IBAction)forgotPassAction:(id)sender;
- (IBAction)scheduleMeetingAction:(id)sender;
@end

@implementation LoginVC

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
    // Do any additional setup after loading the view from its nib.
        
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 22) ];
    [leftView setBackgroundColor:[UIColor clearColor]];
    UIImageView* userPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
    userPlaceholder.contentMode = UIViewContentModeScaleAspectFit;
    [userPlaceholder setImage:[UIImage imageNamed:@"username_placehoder.png"]];
    [leftView addSubview:userPlaceholder];
    userTxt.leftView = leftView;
    [userTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView* passleftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 22) ];
    [passleftView setBackgroundColor:[UIColor clearColor]];
    UIImageView* passPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 22)];
    passPlaceholder.contentMode = UIViewContentModeScaleAspectFit;
    [passPlaceholder setImage:[UIImage imageNamed:@"password_placeholder.png"]];
    [passleftView addSubview:passPlaceholder];
    passTxt.leftView = passleftView;
    [passTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    userTxt.layer.cornerRadius = 2.0;
    passTxt.layer.cornerRadius = 2.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(IBAction)loginAction:(id)sender
{
    [userTxt resignFirstResponder];
    [passTxt resignFirstResponder];
    
//    if(sender == nil)
//    {
//        if([userTxt isFirstResponder])
//            [userTxt resignFirstResponder];
//        else if([passTxt isFirstResponder])
//            [passTxt resignFirstResponder];
//    }
    
    NSString* userName = [userTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* password = [passTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(userName))
    {
        msg = @"Enter username";
    }
    if(!NSSTRING_HAS_DATA(password))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter password"];
    }
    
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [self addHUD];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:@"LoginNotifier" object:nil];
        [[UserDocument sharedInstance] loginWithUsername:userName andPassword:password];
    }
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

- (void) loginSuccess:(NSNotification*)note
{
    [HUD performSelectorOnMainThread:@selector(hide:) withObject:nil waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    
    if(![note object])
    {
//        User* c = [[UserDocument sharedInstance] user];

        [APPDELEGATE performSelectorOnMainThread:@selector(LoadMainView) withObject:nil waitUntilDone:NO];
    }
    else
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:[note object] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

-(IBAction)signupAction:(id)sender
{
    //[self.navigationController popViewControllerAnimated:NO];
    SignUpVC* vc = [[SignUpVC alloc] initWithNibName:@"SignUpVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:NO];
    
}


- (IBAction)forgotPassAction:(id)sender
{
    ForgotPasswordVC* vc = [[ForgotPasswordVC alloc] initWithNibName:@"ForgotPasswordVC" bundle:nil];
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
    if(textField == userTxt)
        [passTxt becomeFirstResponder];
    else
    {
        [self loginAction:nil];
    }
    return YES;
}

- (IBAction)scheduleMeetingAction:(id)sender
{
    ScheduleMeetingStepOneVC* vc = [[ScheduleMeetingStepOneVC alloc] initWithNibName:@"ScheduleMeetingStepOneVC" bundle:nil];
    ScheduleNavigationVC* navVC = [[ScheduleNavigationVC alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    //navVC.navigationBarHidden = YES;
    [self presentViewController:navVC animated:NO completion:^{
        
    }];
}

@end
