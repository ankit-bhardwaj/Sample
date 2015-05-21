//
//  CreateEventVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ScheduleMeetingStepOneVC.h"
#import "ProjectListVC.h"
#import "AssigneeListVC.h"
#import "PriorityListVC.h"
#import "taskCell.h"
#import "Portfolio.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Additions.h"
#import "SpeechToTextModule.h"
#import "HPGrowingTextView.h"
#import "Kal.h"
#import "NSDate+Convenience.h"
#import "AttachmentButton.h"
#import "ImageMapVC.h"
#include <AssetsLibrary/AssetsLibrary.h>
#import "EventDocument.h"
#import "Event.h"
#import "ScheduleWelcomeVC.h"
#import "DropDownControl.h"
#import "DropdownActionSheet.h"
#import "CreateMeetingVC.h"
#import "ScheduleDatePickerVC.h"
#import "ScheduleInviteesVC.h"
#import "GSAsynImageView.h"


@interface ScheduleMeetingStepOneVC ()
{ 
    IBOutlet UITextField* eventName;
    IBOutlet UITextField* eventLocation;
    IBOutlet HPGrowingTextView* eventSummary;
    IBOutlet UITableView* tbView;
    NSMutableArray* contentArray;
    NSMutableArray* _selectedUsers;
    Project* _selectedProject;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIImageView* textViewPlacehoder;
    
    IBOutlet UIButton* eventNameMic;
    IBOutlet UIButton* eventLocationMic;
    IBOutlet UIButton* eventSummaryMic;
    IBOutlet UIActivityIndicatorView* eventNameActivity;
    IBOutlet UIActivityIndicatorView* eventLocationActivity;
    IBOutlet UIActivityIndicatorView* eventSummaryActivity;
    KalViewController* kal;
    UIPopoverController* datePopver;
    
    AutoReminder* _autoReminder;
    
    Event* _createdEvent;
    
    DropdownActionSheet* dropDownActionSheet;
    
    IBOutlet UIToolbar* upperToolBar;
    IBOutlet UIToolbar* lowerToolBar;
    IBOutlet UIBarButtonItem* stepOneBtn;
    IBOutlet UIBarButtonItem* stepTwoBtn;
    IBOutlet UIBarButtonItem* stepThreeBtn;
    IBOutlet UIBarButtonItem* stepFourBtn;
    IBOutlet UIScrollView* attachmentScrollView;
    UIPopoverController* imagePickerPopover;
    IBOutlet UIButton*    attachFileBtn;

    int currentStep;
}

@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)eventSpeackAction:(id)sender;
- (IBAction)eventLocationSpeakAction:(id)sender;
- (IBAction)eventSummaryAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)attachmentAction:(UIButton*)sender;
@end

@implementation ScheduleMeetingStepOneVC

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
    
    //[self.navigationController.view addSubview:upperToolBar];
    CGRect rect = lowerToolBar.frame;
    rect.origin.y = self.view.bounds.size.height - rect.size.height;
    [lowerToolBar setFrame:rect];
    //[self.navigationController.view addSubview:lowerToolBar];
    // Do any additional setup after loading the view from its nib.
    
    self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechToTextObj setDelegate:self];
    
    eventName.background = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    eventName.delegate = self;
    
    eventLocation.background = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    eventLocation.delegate = self;
    
    textViewPlacehoder.image = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
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
    
    //self.navigationItem.title = @"Create Event";
    
    //UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createEventAction)];
    //[self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    //UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    //[self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    [v setBackgroundColor:[UIColor clearColor]];
    eventName.leftView = v;
    eventName.leftViewMode = UITextFieldViewModeAlways;
    
    UIView* v1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    [v1 setBackgroundColor:[UIColor clearColor]];
    eventLocation.leftView = v1;
    eventLocation.leftViewMode = UITextFieldViewModeAlways;
    
    eventSummary.minNumberOfLines = 1;
	eventSummary.maxNumberOfLines = 7;
    
	eventSummary.returnKeyType = UIReturnKeyDefault; //just as an example
	eventSummary.font = [UIFont systemFontOfSize:14.0f];
	eventSummary.delegate = self;

    eventSummary.backgroundColor = [UIColor clearColor];
    
    eventName.placeholder = @"Give your meeting a title...";

    eventSummary.placeholder = @"Details of your meeting (optional)...";
    
    [tbView registerNib:[UINib nibWithNibName:@"taskCell" bundle:nil]  forCellReuseIdentifier:@"taskCell"];
    [self createContent];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"skip_schedule_welcome_screen"])
    {
        ScheduleWelcomeVC* vc = [[ScheduleWelcomeVC alloc] initWithNibName:@"ScheduleWelcomeVC" bundle:nil];
        vc.parentVC = self;
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:vc animated:NO completion:^{
            
        }];
    }
    [EventDocument sharedInstance].selectedMeetingInterval = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearData) name:@"ClearData" object:nil];
}

- (void)clearData
{
    eventName.text = @"";
    eventSummary.text = @"";
    NSMutableDictionary* d = [contentArray lastObject];
    [d setObject:@"1 Hour" forKey:@"name"];
    [tbView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:scrollView name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:scrollView name:UIKeyboardWillHideNotification object:nil];
}

-(void)createContent{

    NSMutableDictionary* firstObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Meeting Duration",@"title",@"1 Hour",@"name",@"calendar_btn.png",@"image", nil];
    NSMutableDictionary* secObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Project",@"title",@"Not Selected",@"name",@"projectList_btn.png",@"image", nil];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
    {
        contentArray = [[NSMutableArray alloc] initWithObjects:firstObject, nil];
    }
    else
    {
        contentArray = [[NSMutableArray alloc] initWithObjects:firstObject,secObject, nil];
    }
    [tbView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancelAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)eventSpeackAction:(id)sender
{
    eventNameMic.enabled = NO;
    eventLocationMic.enabled = NO;
    eventSummaryMic.enabled = NO;
    objc_setAssociatedObject(self.speechToTextObj, "textField", eventName, OBJC_ASSOCIATION_RETAIN);
    [self.speechToTextObj beginRecording];
}


- (IBAction)eventSummaryAction:(id)sender
{
    eventNameMic.enabled = NO;
    eventLocationMic.enabled = NO;
    eventSummaryMic.enabled = NO;
    objc_setAssociatedObject(self.speechToTextObj, "textField", eventSummary, OBJC_ASSOCIATION_RETAIN);
    [self.speechToTextObj beginRecording];
}

#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"Response: %@",response);
    NSString* str = [[response componentsSeparatedByString:@"\n"] lastObject];
    if(NSSTRING_HAS_DATA(str))
    {
        NSData* streamData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:streamData options:NSJSONReadingMutableContainers error:NULL];
        
        NSArray* result = [dict objectForKey:@"result"];
        if(result && result.count)
        {
            NSDictionary* d = [result firstObject];
            NSArray* alternatives = [d objectForKey:@"alternative"];
            if(alternatives && alternatives.count)
            {
                NSDictionary* alternative = [alternatives firstObject];
                NSString* text = [alternative objectForKey:@"transcript"];
                if(NSSTRING_HAS_DATA(text))
                {
                    if(txt == eventName)
                        eventName.text = [eventName.text stringByAppendingString:text];
                    else if(txt == eventLocation)
                        eventLocation.text = [eventLocation.text stringByAppendingString:text];
                    else
                        eventSummary.text = [eventSummary.text stringByAppendingString:text];
                    
                }
            }
        }
    }
    eventNameMic.enabled = YES;
    eventLocationMic.enabled = YES;
    eventSummaryMic.enabled = YES;
    if(txt == eventName)
    {
        eventNameMic.hidden = NO;
        [eventNameActivity stopAnimating];
        [eventName setInputView:nil];
    }
    else if(txt == eventLocation)
    {
        eventLocationMic.hidden = NO;
        [eventLocationActivity stopAnimating];
        [eventLocation setInputView:nil];
    }
    else
    {
        eventSummaryMic.hidden = NO;
        [eventSummaryActivity stopAnimating];
        [eventSummary.internalTextView setInputView:nil];
    }
    objc_removeAssociatedObjects(self.speechToTextObj);
    return YES;
}
- (void)showSineWaveView:(SineWaveViewController *)view
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    [eventName resignFirstResponder];
    [eventLocation resignFirstResponder];
    [eventSummary resignFirstResponder];
    if(txt == eventName)
    {
        [eventName setInputView:view.view];
        [eventName becomeFirstResponder];
    }
    else if(txt == eventLocation)
    {
        [eventLocation setInputView:view.view];
        [eventLocation becomeFirstResponder];
    }
    else
    {
        [eventSummary.internalTextView setInputView:view.view];
        [eventSummary becomeFirstResponder];
    }
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    eventSummaryMic.enabled = YES;
    eventLocationMic.enabled = YES;
    eventNameMic.enabled = YES;
    if(txt == eventName)
    {
        eventNameMic.hidden = NO;
        [eventNameActivity stopAnimating];
        [eventName resignFirstResponder];
        [eventName setInputView:nil];
    }
    else if(txt == eventLocation)
    {
        eventLocationMic.hidden = NO;
        [eventLocationActivity stopAnimating];
        [eventLocation resignFirstResponder];
        [eventLocation setInputView:nil];
    }
    else
    {
        eventSummaryMic.hidden = NO;
        [eventSummaryActivity stopAnimating];
        [eventSummary resignFirstResponder];
        [eventSummary.internalTextView setInputView:nil];
    }
}


- (void)showLoadingView
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    if(txt == eventName)
    {
        eventNameMic.hidden = YES;
        eventNameActivity.hidden = NO;
        [eventNameActivity startAnimating];
    }
    else if(txt == eventLocation)
    {
        eventLocationMic.hidden = YES;
        eventLocationActivity.hidden = NO;
        [eventLocationActivity startAnimating];
    }
    else
    {
        eventSummaryMic.hidden = YES;
        eventSummaryActivity.hidden = NO;
        [eventSummaryActivity startAnimating];
    }
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}

- (void)createEventAction
{
    [eventName resignFirstResponder];
    [eventLocation resignFirstResponder];
    [eventSummary resignFirstResponder];
    
    NSString* name = [eventName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(name))
    {
        msg = @"Please give your event a title.";
    }
//    if(!_selectedProject)
//    {
//        if(NSSTRING_HAS_DATA(msg))
//        {
//            msg = [msg stringByAppendingString:@"\n"];
//        }
//        msg = [msg stringByAppendingString:@"Please select a project."];
//    }
    if([_startDate compare:_endDate] != NSOrderedAscending)
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"End date can not be greater than end date."];
    }
    
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [self createEvent];
    }
}



- (void)createEvent
{
    NSString* name = [eventName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* loc = [eventLocation.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* summary = [eventSummary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    User* user = [User currentUser];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSMutableDictionary* meetingDict = [NSMutableDictionary dictionary];
    [meetingDict setObject:name forKey:@"Title"];
    if(NSSTRING_HAS_DATA(summary))
        [meetingDict setObject:[summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"] forKey:@"Description"];
    else
        [meetingDict setObject:@"" forKey:@"Description"];
    
    if(NSSTRING_HAS_DATA(loc))
        [meetingDict setObject:loc forKey:@"Location"];
    else
        [meetingDict setObject:@"" forKey:@"Location"];
    
    [meetingDict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"LoggedInUserId"];
    
    
    NSMutableArray* invitees =[NSMutableArray array];
    for(User* user in _selectedUsers)
    {
        if(NSSTRING_HAS_DATA(user.Email))
            [invitees addObject:user.Email];
    }
    //[dict setObject:invitees forKey:@"Invitees"];
        
    
    
    [dict setObject:[NSString stringWithFormat:@"%lu", (unsigned long)_selectedProject.ProjectId] forKey:@"projectId"];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy H:'00'"];
    
    [dict setObject:[df stringFromDate:_startDate] forKey:@"StartDate"];
    [dict setObject:[df stringFromDate:_endDate] forKey:@"EndDate"];

    [dict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"LogInUserId"];
    
    [dict setObject:meetingDict forKey:@"Meeting"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createEventCallBack:) name:@"CreateEventNotifier" object:nil];
    [[EventDocument sharedInstance] createEvent:dict];
}

- (void)createEventCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(createEventSuccess:) withObject:[note object] waitUntilDone:NO];
    
}



-(void)createEventSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[Event class]])
    {
        _createdEvent = (Event*)sender;
        [self resetAllData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


-(void)resetAllData
{
    [self createContent];
    eventName.text = nil;
    eventSummary.text = nil;
    eventLocation.text = nil;
}


- (IBAction)projectListAction:(id)sender
{
    ProjectListVC* vc = [[ProjectListVC alloc] initWithNibName:@"ProjectListVC" bundle:nil];
    vc.target = self;
    vc.action = @selector(projectSelected:);
    vc.selectedProject = _selectedProject;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (IBAction)assigneeListAction:(id)sender
{
    AssigneeListVC* vc = [[AssigneeListVC alloc] initWithNibName:@"AssigneeListVC" bundle:nil];
    vc.target = self;
    vc.action = @selector(assigneeSelected:);
    vc.selectedAssignees = _selectedUsers;
    vc.isMultiSelect = YES;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (IBAction)startDateAction:(UIView*)sender
{
    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeSingle CalendarModeType:CalendarModeTypeDueDate];
    kal.selectedDate = _startDate;
    kal.delegate = self;
    kal.dataSource = nil;
    kal.minAvailableDate = [NSDate date];
    kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateCancelAction:)];
    
    UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setStartDateAction:)];
    [setItem setWidth:50.0];
    
   kal.navigationItem.rightBarButtonItems = @[setItem];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:kal];
    if(DEVICE_IS_TABLET)
    {
        CGRect rect = sender.frame;
        //kal.view.frame = CGRectMake(0, 0, 320, 560);
        datePopver = [[UIPopoverController alloc] initWithContentViewController:navController];
        [datePopver setPopoverContentSize:CGSizeMake(320, 560)];
        datePopver.delegate = self;
        [datePopver presentPopoverFromRect:rect inView:tbView permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight animated:YES];
    }
    else
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}


- (void)setStartDateAction:(UIBarButtonItem*)item
{
    _startDate = [kal actualDate];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, LLL d 'at' hh:mm a"];
    NSString *value =[dateformatter stringFromDate:_startDate];
    
    if(DEVICE_IS_TABLET)
    {
        [datePopver dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    NSMutableDictionary* thirdObject = [contentArray firstObject];
    if(NSSTRING_HAS_DATA( value))
        [thirdObject setObject:value forKey:@"name"];
    else
        [thirdObject setObject:@"None" forKey:@"name"];
    [tbView reloadData];
    datePopver = nil;
    kal = nil;
}



- (IBAction)endDateAction:(UIView*)sender
{
    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeSingle CalendarModeType:CalendarModeTypeDueDate];
    kal.selectedDate = _endDate;
    kal.delegate = self;
    kal.dataSource = nil;
    kal.minAvailableDate = [NSDate date];
    kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateCancelAction:)];
    
    UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setEndDateAction:)];
    [setItem setWidth:50.0];
    
    kal.navigationItem.rightBarButtonItems = @[setItem];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:kal];
    if(DEVICE_IS_TABLET)
    {
        CGRect rect = sender.frame;
        //kal.view.frame = CGRectMake(0, 0, 320, 560);
        datePopver = [[UIPopoverController alloc] initWithContentViewController:navController];
        [datePopver setPopoverContentSize:CGSizeMake(320, 560)];
        datePopver.delegate = self;
        [datePopver presentPopoverFromRect:rect inView:tbView permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight animated:YES];
    }
    else
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}


- (void)setEndDateAction:(UIBarButtonItem*)item
{
    _endDate = [kal actualDate];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, LLL d 'at' hh:mm a"];
    NSString *value =[dateformatter stringFromDate:_endDate];
    
    if(DEVICE_IS_TABLET)
    {
        [datePopver dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    NSMutableDictionary* thirdObject = [contentArray objectAtIndex:1];
    if(NSSTRING_HAS_DATA( value))
        [thirdObject setObject:value forKey:@"name"];
    else
        [thirdObject setObject:@"None" forKey:@"name"];
    [tbView reloadData];
    datePopver = nil;
    kal = nil;
}

- (void)dateCancelAction:(UIBarButtonItem*)item
{
    if(DEVICE_IS_TABLET)
    {
        [datePopver dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (NSDate*)defaultDate
{
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour: 17];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *startDate = [gregorian dateFromComponents: components];
    return startDate;
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIColor *customTitleColor = [UIColor
                                 colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [button setTitleColor:customTitleColor forState:UIControlStateNormal];
            [button setTitleColor:customTitleColor forState:UIControlStateSelected];
        }
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    datePopver = nil;
    kal = nil;
    imagePickerPopover = nil;

}
- (IBAction)priorityAction:(UISwitch*)sender
{
    
}


- (void)projectSelected:(Project*)project
{
    _selectedProject = project;
    NSMutableDictionary* d = [contentArray objectAtIndex:1];
    [d setObject:project.ProjectName forKey:@"name"];
    [tbView reloadData];
}

- (void)assigneeSelected:(NSMutableArray*)invitees
{
    _selectedUsers = invitees;
    NSMutableDictionary* d = [contentArray lastObject];
    NSMutableArray* array = [NSMutableArray array];
    for(User* user in _selectedUsers)
    {
        if(user.FormattedName)
            [array addObject:user.FormattedName];
        else
            [array addObject:user.Email];
    }
    if([array count])
        [d setObject:[array componentsJoinedByString:@","] forKey:@"name"];
    [tbView reloadData];
}

- (void)prioritySelected:(NSString*)priority
{
    //[assigneeBtn setTitle:assignee forState:UIControlStateNormal];
}



#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [contentArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"taskCell";
    
    taskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[taskCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    if(indexPath.row == 0)
    {
        DropDownControl* dp = [[DropDownControl alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44)];
        dp.delegate = self;
        dp.ownerView = self.view;
        [dp setValues:[NSArray arrayWithObjects:@"1 Hour",@"2 Hour",@"3 Hour",@"4 Hour",@"5 Hour",@"6 Hour",@"All day", nil]];
        [cell.contentView addSubview:dp];
    }
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    cell.accessoryView = nil;
    
    
    NSDictionary* d = [contentArray objectAtIndex:indexPath.row];
    cell.image.image = [UIImage imageNamed:[d objectForKey:@"image"]];
    cell.name.text = [d objectForKey:@"name"];
    cell.title.text = [d objectForKey:@"title"];
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            [self projectListAction:nil];
            break;
        case 2:
            break;
            
        default:
            break;
    }
}


- (NSDate*)defaultReminderDate
{
    NSDate *date = [NSDate date];
//    NSCalendar *gregorian = [NSCalendar currentCalendar];
//    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
//    [components setHour:0];
//    [components setMinute: 0];
//    [components setSecond: 1];
//    NSDate *startDate = [gregorian dateFromComponents: components];
    return date;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger namelen = [string length] > 0?([textField.text length]+[string length]):([textField.text length]-1);
    if([string length] > 0 && namelen > 100)
    {
        textField.text = [textField.text stringByAppendingString:[string substringToIndex:(100-[textField.text length])]];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger namelen = [text length] > 0?([growingTextView.text length]+[text length]):([growingTextView.text length]-1);
    if([text length] > 0 && namelen > 500)
    {
        growingTextView.text = [growingTextView.text stringByAppendingString:[text substringToIndex:(500-[growingTextView.text length])]];
        return NO;
    }
    return YES;
}
- (void)dropdownControlDidCancel:(DropDownControl *)dtControl
{
    if (dropDownActionSheet) {
        [dropDownActionSheet slideOut];
    }
}

-(void)showDropDownOptions:(DropDownControl *)dropdown values:(NSArray *)values
{
    [self.view endEditing:YES];
    dropDownActionSheet = [[DropdownActionSheet alloc]initWithNibName:@"DropdownActionSheet" bundle:nil];
    CGRect rect = self.navigationController.view.bounds;
    rect.origin = CGPointMake(0, 0);
    UIView *view = dropDownActionSheet.view;
    view.frame = rect;
    [self.navigationController.view addSubview:view];
    dropDownActionSheet.dropdownControl = dropdown;
    dropDownActionSheet.values = values;
    [dropDownActionSheet setupView];
    [dropDownActionSheet viewWillAppear:NO];
}

- (void)dropdown:(DropDownControl *)dropdown didSelectValue:(NSString *)value
{
    dropdown.selected = YES;
    [dropdown setTitle:value forState:UIControlStateSelected];
    if (dropDownActionSheet) {
        [dropDownActionSheet slideOut];
    }
    
    NSMutableDictionary* d = [contentArray lastObject];
    
    if([value isEqualToString:@"All day"])
    {
        [EventDocument sharedInstance].selectedMeetingInterval = 24;
        [d setObject:[NSString stringWithFormat:@"All day"] forKey:@"name"];
    }
    else
    {
        [d setObject:value forKey:@"name"];
        [EventDocument sharedInstance].selectedMeetingInterval = [value intValue];
    }
    
    [tbView reloadData];
}

- (IBAction)attachmentAction:(UIButton*)sender
{
    [self.view endEditing:YES];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album",@"Take Photo",@"Video", nil];
    if(DEVICE_IS_TABLET)
    {
        CGRect rect = sender.frame;
        rect.origin.x-=20;
        rect.origin.y+=60;
        [actionSheet showFromRect:rect inView:self.view animated:YES];
    }
    else
        [actionSheet showInView:self.view];
    
    
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = nil;
    NSData* data = nil;
    NSString* path = CREATETASK_ATTACHMENTS;
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //  dlog(@"info dict description = %@",[info description]);
    if ([type isEqualToString:(NSString *)kUTTypeMovie] ||
        [type isEqualToString:(NSString *)kUTTypeVideo]) { // movie != video
        
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        data = [NSData dataWithContentsOfURL:url];
        
        path = [CREATETASK_ATTACHMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",uuidString]];
        
        image = [UIImage thumbnailFromVideoAtURL:url];
        
        
    }
    else{
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        path = [CREATETASK_ATTACHMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uuidString]];
        UIImage* compressedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 640)
                                                 interpolationQuality:kCGInterpolationMedium];
        data = UIImageJPEGRepresentation(compressedImage,1.0);
        if([data length] > 30000)
        {
            data = UIImageJPEGRepresentation(compressedImage,0.1);
        }
    }
    
    int xoffset = 5;
    int yoffset = 5;
    
    for (UIImageView* attachment in attachmentScrollView.subviews) {
        CGRect rect = attachment.frame;
        if (rect.size.width == 54 && rect.size.height == 54) {
            
            xoffset += 5+rect.size.width;
        }
        
    }
    xoffset += 5;
    GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
    [attachmentImage setImage:image];
    [attachmentScrollView addSubview:attachmentImage];
    [attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
    [[attachmentImage layer] setCornerRadius:3.0f];
    [[attachmentImage layer] setBorderWidth:1.0f];
    [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[attachmentImage layer] setMasksToBounds:YES];
    [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
    if (![[NSFileManager defaultManager] fileExistsAtPath:CREATETASK_ATTACHMENTS]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:CREATETASK_ATTACHMENTS withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:path atomically:YES];
    attachmentImage.target = self;
    attachmentImage.action = @selector(showAttachment:);
    attachmentImage.localAttachmentPath = path;
    
    if(imagePickerPopover)
    {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}

-(void)showAttachment:(AttachmentButton*)sender
{
    NSString* path = sender.localAttachmentPath;
    ImageMapVC* savc = [[ImageMapVC alloc] initWithNibName:@"ImageMapView" bundle:nil];
    savc.mapImageSrc = path;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
    [self presentViewController:navVC animated:YES completion:nil];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    if(imagePickerPopover)
    {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self performSelector:@selector(openAttachmentOptions:) withObject:[NSNumber numberWithInteger:buttonIndex] afterDelay:0.1];
    
}

- (void)openAttachmentOptions:(NSNumber*)buttonIndex
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    switch ([buttonIndex integerValue]) {
            
        case 0:{
            
            if([AuthorizationStatus isPhotoAlbumAllowedWithMessage:YES])
            {
            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            else
            {
                imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                [imagePickerPopover setPopoverContentSize:CGSizeMake(320, 480)];
                CGRect rect = attachFileBtn.frame;
                rect.origin.y += 60;
                [imagePickerPopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            }
            
        }
            break;
            
        case 1:{
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [AuthorizationStatus isCameraAllowedWithMessage:YES])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            else if([AuthorizationStatus isPhotoAlbumAllowedWithMessage:YES])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
                else
                {
                    imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                    [imagePickerPopover setPopoverContentSize:CGSizeMake(320, 480)];
                    CGRect rect = attachFileBtn.frame;
                    rect.origin.y += 60;
                    [imagePickerPopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            }
            
            
        }
            break;
            
        case 2:{
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [AuthorizationStatus isCameraAllowedWithMessage:YES])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
                
            }
            else if([AuthorizationStatus isPhotoAlbumAllowedWithMessage:YES])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
                else
                {
                    imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                    [imagePickerPopover setPopoverContentSize:CGSizeMake(320, 480)];
                    CGRect rect = attachFileBtn.frame;
                    rect.origin.y += 60;
                    [imagePickerPopover presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
                
            }
            
            
        }
            break;
        case 3:{
            
            
            
        }
            break;
            
        default:
            break;
    }
    
}



-(void)cleanAllAttachments{
    
    for (UIImageView* attachment in attachmentScrollView.subviews) {
        
        [attachment removeFromSuperview];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CREATETASK_ATTACHMENTS]) {
        [[NSFileManager defaultManager] removeItemAtPath:CREATETASK_ATTACHMENTS error:nil];
    }
    
}



- (NSString*)validate
{
    NSString* name = [eventName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!NSSTRING_HAS_DATA( name))
        return @"Please enter event title";
    
    NSString* desc = [eventSummary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!NSSTRING_HAS_DATA( desc))
        desc = @"";
    
    [[EventDocument sharedInstance].currentMeetingInfo setObject:name forKey:@"Title"];
    [[EventDocument sharedInstance].currentMeetingInfo setObject:desc forKey:@"Description"];
    [[EventDocument sharedInstance].currentMeetingInfo setObject:@"" forKey:@"Location"];
    
    if([EventDocument sharedInstance].selectedMeetingInterval > 6)
        [[EventDocument sharedInstance].currentMeetingInfo setObject:[NSNumber numberWithInteger:7] forKey:@"Duration"];
    else
        [[EventDocument sharedInstance].currentMeetingInfo setObject:[NSNumber numberWithInteger:[EventDocument sharedInstance].selectedMeetingInterval] forKey:@"Duration"];
    
    if(_selectedProject)
        [[EventDocument sharedInstance].currentMeetingInfo setObject:[NSNumber numberWithInteger:_selectedProject.ProjectId] forKey:@"ParentId"];
    else
        [[EventDocument sharedInstance].currentMeetingInfo setObject:[NSNumber numberWithInteger:0] forKey:@"ParentId"];
    
    return nil;
}
@end
