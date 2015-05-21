//
//  ForgotPasswordVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "ValidationHelper.h"
#import "UserDocument.h"
#import "MBProgressHUD.h"

@interface ForgotPasswordVC ()
{
    IBOutlet UITextField* emailText;
    MBProgressHUD *HUD;
}

- (IBAction)submitAction:(id)sender;

- (IBAction)backAction:(id)sender;

@end

@implementation ForgotPasswordVC

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
    emailText.layer.cornerRadius = 2.0;
    
    emailText.leftView = [self leftViewWithImage:@"email_placeholder.png"];
    [emailText setLeftViewMode:UITextFieldViewModeAlways];
}

- (UIView*)leftViewWithImage:(NSString*)imgstr
{
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 22) ];
    [leftView setBackgroundColor:[UIColor clearColor]];
    UIImageView* userPlaceholder = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    //userPlaceholder.contentMode = UIViewContentModeCenter;
    [userPlaceholder setImage:[UIImage imageNamed:imgstr]];
    [leftView addSubview:userPlaceholder];
    return leftView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(id)sender
{
    [emailText resignFirstResponder];
    
    NSString* msg = @"";
    NSString* email = [emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!NSSTRING_HAS_DATA(email))
    {
        msg = [msg stringByAppendingString:@"Please type your valid email address"];
    }
    else if(![ValidationHelper validateEmail:email])
    {
        msg = [msg stringByAppendingString:@"Email Id is not valid"];
    }
    
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else{
        [self addHUD];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ForgotPasswordResult:) name:@"ForgotPasswordNotifier" object:nil];
        [[UserDocument sharedInstance] forgotPasswordForUsername:email];
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

- (void) ForgotPasswordResult:(NSNotification*)note
{
    [HUD performSelectorOnMainThread:@selector(hide:) withObject:nil waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    
    if(![note object])
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" message:@"We sent you an email with instructions to reset your password. Please check your email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
    }
    else
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:[note object] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}


- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController performSelectorOnMainThread:@selector(popViewControllerAnimated:) withObject:nil waitUntilDone:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self submitAction:nil];
    return YES;
}
@end
