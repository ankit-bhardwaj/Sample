//
//  ScheduleNavigationVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 1/10/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "ScheduleNavigationVC.h"
#import "CreateMeetingVC.h"
#import "ScheduleDatePickerVC.h"
#import "ScheduleInviteesVC.h"
#import "ScheduleMeetingFinalVC.h"
#import "ScheduleWelcomeVC.h"
#import "EventDocument.h"

@interface ScheduleNavigationVC ()
{
    int currentStep;
    UIBarButtonItem* stepOneButton;
    UIBarButtonItem* stepTwoButton;
    UIBarButtonItem* stepThreeButton;
    UIBarButtonItem* stepFourButton;
    UIBarButtonItem* stepDoneButton;
    
    UIBarButtonItem* nextButton;
    UIBarButtonItem* cancelButton;
    
    float actualHeight;
}
@end

@implementation ScheduleNavigationVC

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if(self)
    {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.toolbarHidden = NO;
    
    float width = 42.0;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
        width=56.0;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        width = 85.0;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
            width=100.0;
    }

    UIToolbar* upperToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [upperToolBar setBarTintColor:[UIColor colorWithRed:24.0/255.0 green:161.0/255.0 blue:226.0/255.0 alpha:1.0]];
    stepOneButton = [[UIBarButtonItem alloc] initWithTitle:@"STEP 1" style:UIBarButtonItemStylePlain target:nil action:nil];
    [stepOneButton setTintColor:[UIColor blackColor]];
    [stepOneButton setWidth:width];
    
     stepTwoButton = [[UIBarButtonItem alloc] initWithTitle:@"STEP 2" style:UIBarButtonItemStylePlain target:nil action:nil];
    [stepTwoButton setTintColor:[UIColor whiteColor]];
    [stepTwoButton setWidth:width];
    
    stepThreeButton = [[UIBarButtonItem alloc] initWithTitle:@"STEP 3" style:UIBarButtonItemStylePlain target:nil action:nil];
    [stepThreeButton setTintColor:[UIColor whiteColor]];
    [stepThreeButton setWidth:width];
    
     stepFourButton = [[UIBarButtonItem alloc] initWithTitle:@"STEP 4" style:UIBarButtonItemStylePlain target:nil action:nil];
    [stepFourButton setTintColor:[UIColor whiteColor]];
    [stepFourButton setWidth:width];
    
    stepDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style:UIBarButtonItemStylePlain target:nil action:nil];
    [stepDoneButton setTintColor:[UIColor whiteColor]];
    [stepDoneButton setWidth:width];
    
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:1.0];
    
    UIView* v1 = [[UIView alloc] initWithFrame:CGRectMake(0, 4, 1, 36)];
    [v1 setBackgroundColor:[UIColor grayColor]];
    UIBarButtonItem* line1 = [[UIBarButtonItem alloc] initWithCustomView:v1];
    
    UIView* v2 = [[UIView alloc] initWithFrame:CGRectMake(0, 4, 1, 36)];
    [v2 setBackgroundColor:[UIColor grayColor]];
    UIBarButtonItem* line2 = [[UIBarButtonItem alloc] initWithCustomView:v2];
    
    UIView* v3 = [[UIView alloc] initWithFrame:CGRectMake(0, 4, 1, 36)];
    [v3 setBackgroundColor:[UIColor grayColor]];
    UIBarButtonItem* line3 = [[UIBarButtonItem alloc] initWithCustomView:v3];
    
    UIView* v4 = [[UIView alloc] initWithFrame:CGRectMake(0, 4, 1, 36)];
    [v4 setBackgroundColor:[UIColor grayColor]];
    UIBarButtonItem* line4 = [[UIBarButtonItem alloc] initWithCustomView:v4];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
    {
        [upperToolBar setItems:[NSArray arrayWithObjects:stepOneButton,line1,fixedSpace,stepTwoButton,line2,fixedSpace,stepThreeButton,line3,fixedSpace,stepFourButton,line4,fixedSpace,stepDoneButton, nil]];
    }
    else
    {
        [upperToolBar setItems:[NSArray arrayWithObjects:stepOneButton,line1,fixedSpace,stepTwoButton,line2,fixedSpace,stepThreeButton,line3,fixedSpace,stepFourButton,line4, nil]];
    }
    [self.navigationBar addSubview:upperToolBar];
    [upperToolBar bringSubviewToFront:self.navigationBar];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self setuplowertoolbar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setuplowertoolbar
{
    UIToolbar* lowertoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [lowertoolbar setBarTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem* flexibleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 100, 36)];
    [btn setTitle:@"Next" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:151.0/255.0 blue:65.0/255.0 alpha:1.0]];
    nextButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [nextButton setTintColor:[UIColor whiteColor]];
    [nextButton setWidth:100.0];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [cancelButton setTintColor:[UIColor colorWithRed:24.0/255.0 green:161.0/255.0 blue:226.0/255.0 alpha:1.0]];
    [cancelButton setWidth:100.0];
    
    [lowertoolbar setItems:[NSArray arrayWithObjects:flexibleBtn,cancelButton,nextButton, nil]];
    lowertoolbar.tag = 1001;
    [self.toolbar addSubview:lowertoolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self setuplowertoolbar];
    actualHeight = self.visibleViewController.view.bounds.size.height;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)cleanAllAttachments{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:CREATETASK_ATTACHMENTS]) {
        [[NSFileManager defaultManager] removeItemAtPath:CREATETASK_ATTACHMENTS error:nil];
    }
    
}

- (IBAction)nextAction:(id)sender
{
    if([self.topViewController respondsToSelector:@selector(validate)])
    {
        NSString* validate = [self.topViewController performSelector:@selector(validate) withObject:nil];
        if(NSSTRING_HAS_DATA(validate)){
            [[[UIAlertView alloc] initWithTitle:@"" message:validate delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
    }
    [self showToolbar:YES];
    currentStep++;
    switch (currentStep) {
        case 0:
        {
            break;
        }
        case 1:
        {
            [cancelButton setTitle:@"Prev"];
            [stepOneButton setTintColor:[UIColor whiteColor]];
            [stepTwoButton setTintColor:[UIColor blackColor]];
            CreateMeetingVC* vc = [[CreateMeetingVC alloc] initWithNibName:@"CreateMeetingVC" bundle:nil];
            [self pushViewController:vc animated:NO];
            break;
        }
        case 2:
        {
            [self showToolbar:NO];
            [cancelButton setTitle:@"Prev"];
            [stepTwoButton setTintColor:[UIColor whiteColor]];
            [stepThreeButton setTintColor:[UIColor blackColor]];
            ScheduleDatePickerVC* vc = [[ScheduleDatePickerVC alloc] initWithNibName:@"ScheduleDatePickerVC" bundle:nil];
            [self pushViewController:vc animated:NO];
            break;
        }
        case 3:
        {
            [cancelButton setTitle:@"Prev"];
            UIButton* btn = (UIButton*)nextButton.customView;
            [btn setTitle:@"Send Invite" forState:UIControlStateNormal];
            [stepThreeButton setTintColor:[UIColor whiteColor]];
            [stepFourButton setTintColor:[UIColor blackColor]];
            ScheduleInviteesVC* vc = [[ScheduleInviteesVC alloc] initWithNibName:@"ScheduleInviteesVC" bundle:nil];
            [self pushViewController:vc animated:NO];
            break;
        }
        case 5:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
            
        default:
            break;
    }
}

- (void)showToolbar:(BOOL)show
{
    self.toolbar.hidden = !show;
    if(!show)
    {
        CGRect rect = self.view.frame;
        rect.size.height = actualHeight+ 44;
        [self.view setFrame:rect];
    }
    else
    {
        CGRect rect = self.view.frame;
        rect.size.height = actualHeight;
        [self.view setFrame:rect];
    }
}


- (IBAction)cancelAction:(UIBarButtonItem*)sender
{
    [self showToolbar:YES];
    if([sender.title isEqualToString:@"Cancel"] || [sender.title isEqualToString:@"Prev"])
    {
        if(self.viewControllers.count > 1)
        {
            currentStep--;
            if(currentStep == 2)
               [self showToolbar:NO];
            [self popViewControllerAnimated:YES];
        }
        else
        {
            [self cleanAllAttachments];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        currentStep = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearData" object:nil];
        [self popToRootViewControllerAnimated:YES];
    }
    [self updateToolbar];
}

- (void)updateToolbar
{
    [stepOneButton setTintColor:[UIColor whiteColor]];
    [stepTwoButton setTintColor:[UIColor whiteColor]];
    [stepThreeButton setTintColor:[UIColor whiteColor]];
    [stepFourButton setTintColor:[UIColor whiteColor]];
    [stepDoneButton setTintColor:[UIColor whiteColor]];
    switch (currentStep) {
        case 0:
        {
            NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18.0],NSFontAttributeName, nil];
            [cancelButton setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
            [cancelButton setTitle:@"Cancel"];
            [cancelButton setWidth:100.0];
            UIButton* btn = (UIButton*)nextButton.customView;
            [btn setTitle:@"Next" forState:UIControlStateNormal];
            [stepOneButton setTintColor:[UIColor blackColor]];
            break;
        }
        case 1:
        {
            [cancelButton setTitle:@"Prev"];
            [stepTwoButton setTintColor:[UIColor blackColor]];
            UIButton* btn = (UIButton*)nextButton.customView;
            [btn setTitle:@"Next" forState:UIControlStateNormal];
            break;
        }
        case 2:
        {
            UIButton* btn = (UIButton*)nextButton.customView;
            [btn setTitle:@"Next" forState:UIControlStateNormal];
            [cancelButton setTitle:@"Prev"];
            [stepThreeButton setTintColor:[UIColor blackColor]];
            break;
        }
        case 3:
        {
            UIButton* btn = (UIButton*)nextButton.customView;
            [btn setTitle:@"Send Invite" forState:UIControlStateNormal];
            [cancelButton setTitle:@"Prev"];
            [stepFourButton setTintColor:[UIColor blackColor]];
            break;
        }
        case 4:
            [stepDoneButton setTintColor:[UIColor blackColor]];
            break;
            
        default:
            break;
    }
}

- (void)showFinalLink:(NSString*)link
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
    {
        UIButton* btn = (UIButton*)nextButton.customView;
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        [cancelButton setTitle:@"Schedule another meeting"];
        [cancelButton setWidth:170.0];
        NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14.0],NSFontAttributeName, nil];
        [cancelButton setTitleTextAttributes:navbarTitleTextAttributes forState:UIControlStateNormal];
        
        [stepFourButton setTintColor:[UIColor whiteColor]];
        [stepDoneButton setTintColor:[UIColor blackColor]];
        ScheduleMeetingFinalVC* vc = [[ScheduleMeetingFinalVC alloc] initWithNibName:@"ScheduleMeetingFinalVC" bundle:nil];
        [vc setMeetingLink:link];
        [self pushViewController:vc animated:NO];
    }
    else
    {
        [[EventDocument sharedInstance] refreshMyMeetings];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showLogin
{
    UIButton* btn = (UIButton*)nextButton.customView;
    [btn setTitle:@"Login" forState:UIControlStateNormal];
}

-(UIToolbar*)getToolBar
{
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 88)];
    [v setBackgroundColor:[UIColor clearColor]];
    UIToolbar* lowertoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, 44)];
    [lowertoolbar setBarTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem* flexibleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 100, 36)];
    [btn setTitle:@"Next" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:151.0/255.0 blue:65.0/255.0 alpha:1.0]];
    UIBarButtonItem* next = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [next setTintColor:[UIColor whiteColor]];
    [next setWidth:100.0];
    
    UIBarButtonItem* prevBtn = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [prevBtn setTintColor:[UIColor colorWithRed:24.0/255.0 green:161.0/255.0 blue:226.0/255.0 alpha:1.0]];
    [prevBtn setWidth:100.0];
    
    [lowertoolbar setItems:[NSArray arrayWithObjects:flexibleBtn,prevBtn,next, nil]];
    
    [v addSubview:lowertoolbar];
    return v;
}
@end
