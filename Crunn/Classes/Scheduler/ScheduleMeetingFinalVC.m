//
//  ScheduleMeetingFinalVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 1/12/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "ScheduleMeetingFinalVC.h"
#import "EventDocument.h"
#import "UserDocument.h"
#import "BrowserVC.h"
#import "ScheduleNavigationVC.h"

@interface ScheduleMeetingFinalVC ()
{
    IBOutlet UILabel* meetingTitleLbl;
    IBOutlet UILabel* meetingLinkLbl;
    IBOutlet UILabel* meetingInviteesLbl;
    IBOutlet UILabel* signupinfoLbl;
    IBOutlet UITextField* passwordTxt;
    IBOutlet UIButton* signupBtn;
}

- (IBAction)meetingLinkAction:(id)sender;
@end

@implementation ScheduleMeetingFinalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
    
    NSDictionary* d = [EventDocument sharedInstance].currentMeetingInfo;
    meetingTitleLbl.text = [d objectForKey:@"Title"];
    meetingLinkLbl.text = self.meetingLink;
    meetingInviteesLbl.text = [[d objectForKey:@"RecipientEmailList"] stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    
    passwordTxt.layer.cornerRadius = 2.0;
    passwordTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    passwordTxt.layer.borderWidth = 1.0;
    passwordTxt.leftView = [self leftViewWithImage:@"password_placeholder.png"];
    [passwordTxt setLeftViewMode:UITextFieldViewModeAlways];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)meetingLinkAction:(id)sender
{
    BrowserVC* vc = [[BrowserVC alloc] initWithNibName:@"BrowserView" bundle:nil];
    [vc setUrl:self.meetingLink];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (NSString*)validate
{
    return nil;
}

- (IBAction)signupAction:(id)sender
{
    NSString* password = [passwordTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSDictionary* d = [EventDocument sharedInstance].currentMeetingInfo;
    NSDictionary* creator = [d objectForKey:@"CreatorDetails"];
    NSString* email = [creator objectForKey:@"Email"];
    if(!passwordTxt.hidden)
    {
        
        if(!NSSTRING_HAS_DATA( password))
        {
            UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [av show];
            return;
        }
        
        
        NSString* timeZone = [creator objectForKey:@"TimeZone"];
        
        NSString* first = [creator objectForKey:@"FirstName"];
        NSString* last = [creator objectForKey:@"LastName"];
        
        NSDictionary* jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email",first,@"firstName",last,@"lastName",timeZone,@"timeZone",password, @"password", nil];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registrationNotifier:) name:@"RegisterNotifier" object:nil];
        [[UserDocument sharedInstance] registerWithUser:jsonDictionary];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotifier:) name:@"LoginNotifier" object:nil];
        [[UserDocument sharedInstance] loginWithUsername:email andPassword:password];
    }
}

- (void) registrationNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    
    [self performSelectorOnMainThread:@selector(registrationSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

- (void) loginNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    
    [self performSelectorOnMainThread:@selector(loginSuccess:) withObject:[note object] waitUntilDone:NO];
}

- (void)loginSuccess:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

    if(!object)
    {
        [APPDELEGATE LoadMainView];
    }
    else
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (void)registrationSuccess:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    if(!object)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [APPDELEGATE LoadMainView];
        
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Welcome to Grapple" message:@"\nYou will now be able to streamline your work efficiently.\n\nWe have created four simple tasks for you. These will just take a few seconds to finish and will get you started with Grapple." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
        [self performSelector:@selector(dismissAlert:) withObject:av afterDelay:10.0];
    }
    else
    {
        passwordTxt.hidden= YES;
        signupinfoLbl.hidden = YES;
        [signupBtn setTitle:@"Login" forState:UIControlStateNormal];
        if([object isEqualToString:@"AlreadyHaveAnAccount"])
            object = @"We already have an account with this email address in our system.Log in to your account to manage your meeting invites, calendar, and much more.";
            
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (void)dismissAlert:(UIAlertView*)av
{
    if(av.visible)
        [av dismissWithClickedButtonIndex:-1 animated:YES];
}

@end
