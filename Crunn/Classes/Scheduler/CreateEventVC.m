//
//  CreateEventVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "CreateEventVC.h"
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

@interface CreateEventVC ()
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
}

@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)eventSpeackAction:(id)sender;
- (IBAction)eventLocationSpeakAction:(id)sender;
- (IBAction)eventSummaryAction:(id)sender;
@end

@implementation CreateEventVC

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
    
    self.navigationItem.title = @"Create Event";
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createEventAction)];
    [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
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
    
    if(DEVICE_IS_TABLET)
        eventSummary.placeholder = @"Create detailed description of your event here...";
    else
        eventSummary.placeholder = @"Create detailed description of your event here...";
    
    [tbView registerNib:[UINib nibWithNibName:@"taskCell" bundle:nil]  forCellReuseIdentifier:@"taskCell"];
    [self createContent];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:scrollView selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:scrollView selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:scrollView name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:scrollView name:UIKeyboardWillHideNotification object:nil];
}

-(void)createContent{
    _startDate = [self defaultDate];
    _endDate = [_startDate dateByAddingTimeInterval:60*60];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, LLL d 'at' hh:mm a"];
    NSMutableDictionary* firstObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Start Date",@"title",[df stringFromDate:_startDate],@"name",@"calendar_btn.png",@"image", nil];
    NSMutableDictionary* secondObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"End Date",@"title",[df stringFromDate:_endDate],@"name",@"calendar_btn.png",@"image", nil];
    NSMutableDictionary* thirdObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Project",@"title",@"Not Selected",@"name",@"projectList_btn.png",@"image", nil];
    NSMutableDictionary* fourth = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Invite",@"title",@"None",@"name",@"assignee_btn.png",@"image", nil];
    contentArray = [[NSMutableArray alloc] initWithObjects:firstObject,secondObject,thirdObject,fourth, nil];
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
}
- (IBAction)priorityAction:(UISwitch*)sender
{
    
}


- (void)projectSelected:(Project*)project
{
    _selectedProject = project;
    NSMutableDictionary* d = [contentArray objectAtIndex:2];
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
            
            [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            else
            {
                
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
            [self startDateAction:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        case 1:
            [self endDateAction:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        case 2:
            [self projectListAction:nil];
            break;
        case 3:
            [self assigneeListAction:nil];
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
@end
