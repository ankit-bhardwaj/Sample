//
//  CreateTaskVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "CreateTaskVC.h"
#import "ProjectListVC.h"
#import "AssigneeListVC.h"
#import "PriorityListVC.h"
#import "taskCell.h"
#import "Portfolio.h"
#import "TaskDocument.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Additions.h"
#import "SpeechToTextModule.h"
#import "HPGrowingTextView.h"
#import "Kal.h"
#import "NSDate+Convenience.h"
#import "AttachmentButton.h"
#import "ImageMapVC.h"
#include <AssetsLibrary/AssetsLibrary.h>

#import <DBChooser/DBChooser.h>
#import <DBChooser/DBChooserResult.h>
#import "ShowAttachmentVC.h"
#import "GSAsynImageView.h"

@interface CreateTaskVC ()
{ 
    IBOutlet UITextField* taskName;
    IBOutlet HPGrowingTextView* taskSummary;
    IBOutlet UITableView* tbView;
    IBOutlet UISwitch* prioritySwitch;
    IBOutlet UIScrollView* attachmentsContainer;
    IBOutlet UIButton* attachFileBtn;
    NSMutableArray* contentArray;
    User* _selectedUser;
    Project* _selectedProject;
    NSDate*  _dueDate;
    NSString* _tempFolderPath;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIImageView* textViewPlacehoder;
    
    IBOutlet UIButton* taskNameMic;
    IBOutlet UIButton* taskSummaryMic;
    IBOutlet UIActivityIndicatorView* taskNameActivity;
    IBOutlet UIActivityIndicatorView* taskSummaryActivity;
    KalViewController* kal;
    UIPopoverController* datePopver;
    
    IBOutlet UIButton* reminderCrossBtn;
    IBOutlet UIButton* reminderBtn;
    UIPopoverController* imagePickerPopover;
    AutoReminder* _autoReminder;
    
    Task* _createdTask;
    NSMutableArray* _dpAttachments;
    IBOutlet UIView* fotterContentView;
}

@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)attachmentAction:(id)sender;
- (IBAction)priorityAction:(id)sender;
- (IBAction)taskSpeackAction:(id)sender;
- (IBAction)taskSummaryAction:(id)sender;
- (IBAction)setReminderAction:(UIButton*)sender;
- (IBAction)removeReminderAction:(UIButton*)sender;
@end

@implementation CreateTaskVC

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
    
    taskName.background = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    taskName.delegate = self;
    
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
    
    self.navigationItem.title = @"Create Task";
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createTaskAction)];
    [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    [v setBackgroundColor:[UIColor clearColor]];
    taskName.leftView = v;
    taskName.leftViewMode = UITextFieldViewModeAlways;
    
    taskSummary.minNumberOfLines = 1;
	taskSummary.maxNumberOfLines = 7;
    
	taskSummary.returnKeyType = UIReturnKeyDefault; //just as an example
	taskSummary.font = [UIFont systemFontOfSize:14.0f];
	taskSummary.delegate = self;

    taskSummary.backgroundColor = [UIColor clearColor];
    
    if(DEVICE_IS_TABLET)
        taskSummary.placeholder = @"Create detailed description of your task here...";
    else
        taskSummary.placeholder = @"Create detailed description of your task here...";
    
    [tbView registerNib:[UINib nibWithNibName:@"taskCell" bundle:nil]  forCellReuseIdentifier:@"taskCell"];
    [self createContent];
    
    [self cleanAllAttachments];
    
    _selectedUser = [User currentUser];
    
    [self adjustFooter];
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

    NSMutableDictionary* firstObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Project",@"title",@"Not Selected",@"name",@"projectList_btn.png",@"image", nil];
    if([TaskDocument sharedInstance].selectedPortfolio && [TaskDocument sharedInstance].selectedProject)
    {
        [firstObject setObject:[TaskDocument sharedInstance].selectedProject.ProjectName forKey:@"name"];
        _selectedProject = [TaskDocument sharedInstance].selectedProject;
    }
    NSMutableDictionary* secondObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Assignee",@"title",@"Me",@"name",@"assignee_btn.png",@"image", nil];
    NSMutableDictionary* thirdObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Due Date",@"title",@"None",@"name",@"calendar_btn.png",@"image", nil];
    contentArray = [[NSMutableArray alloc] initWithObjects:firstObject,secondObject,thirdObject, nil];
    [tbView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancelAction
{
    [self cleanAllAttachments];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)taskSpeackAction:(id)sender
{
    taskNameMic.enabled = NO;
    taskSummaryMic.enabled = NO;
    objc_setAssociatedObject(self.speechToTextObj, "textField", taskName, OBJC_ASSOCIATION_RETAIN);
    [self.speechToTextObj beginRecording];
}


- (IBAction)taskSummaryAction:(id)sender
{
    taskNameMic.enabled = NO;
    taskSummaryMic.enabled = NO;
    objc_setAssociatedObject(self.speechToTextObj, "textField", taskSummary, OBJC_ASSOCIATION_RETAIN);
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
                    if(txt == taskName)
                        taskName.text = [taskName.text stringByAppendingString:text];
                    else
                        taskSummary.text = [taskSummary.text stringByAppendingString:text];
                    
                }
            }
        }
    }
    taskNameMic.enabled = YES;
    taskSummaryMic.enabled = YES;
    if(txt == taskName)
    {
        taskNameMic.hidden = NO;
        [taskNameActivity stopAnimating];
        [taskName setInputView:nil];
    }
    else
    {
        taskSummaryMic.hidden = NO;
        [taskSummaryActivity stopAnimating];
        [taskSummary.internalTextView setInputView:nil];
    }
    objc_removeAssociatedObjects(self.speechToTextObj);
    return YES;
}
- (void)showSineWaveView:(SineWaveViewController *)view
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    [taskName resignFirstResponder];
    [taskSummary resignFirstResponder];
    if(txt == taskName)
    {
        [taskName setInputView:view.view];
        [taskName becomeFirstResponder];
    }
    else
    {
        [taskSummary.internalTextView setInputView:view.view];
        [taskSummary becomeFirstResponder];
    }
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    taskSummaryMic.enabled = YES;
    taskNameMic.enabled = YES;
    if(txt == taskName)
    {
        taskNameMic.hidden = NO;
        [taskNameActivity stopAnimating];
        [taskName resignFirstResponder];
        [taskName setInputView:nil];
    }
    else
    {
        taskSummaryMic.hidden = NO;
        [taskSummaryActivity stopAnimating];
        [taskSummary resignFirstResponder];
        [taskSummary.internalTextView setInputView:nil];
    }
}


- (void)showLoadingView
{
    UITextField* txt = objc_getAssociatedObject(self.speechToTextObj, "textField");
    if(txt == taskName)
    {
        taskNameMic.hidden = YES;
        taskNameActivity.hidden = NO;
        [taskNameActivity startAnimating];
    }
    else
    {
        taskSummaryMic.hidden = YES;
        taskSummaryActivity.hidden = NO;
        [taskSummaryActivity startAnimating];
    }
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}

- (void)createTaskAction
{
    [taskName resignFirstResponder];
    [taskSummary resignFirstResponder];
    
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(name))
    {
        msg = @"Please give your task a title.";
    }
    if(!_selectedProject)
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Please select a project."];
    }
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CREATETASK_ATTACHMENTS error:NULL];
        if(files && files.count >0)
            [self uploadFiles];
        else
            [self createTask];
    }
}

- (void)uploadFiles
{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CREATETASK_ATTACHMENTS error:NULL];
    NSMutableArray* tmp = [NSMutableArray array];
    for(NSString* file in files)
    {
        [tmp addObject:[CREATETASK_ATTACHMENTS stringByAppendingPathComponent:file]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTaskAttachmentCalllBack:) name:@"UploadTaskAttachmentNotifier" object:nil];
    [[TaskDocument sharedInstance] uploadTaskAttachments:tmp];
}

- (void)createTask
{
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* summary = [taskSummary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    User* user = [User currentUser];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:@"taskDescription"];
    if(NSSTRING_HAS_DATA(summary))
        [dict setObject:[summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"] forKey:@"taskDetails"];
    else
        [dict setObject:@"" forKey:@"taskDetails"];
    if(NSSTRING_HAS_DATA(_selectedUser.Email))
        [dict setObject:_selectedUser.Email forKey:@"assignedToEmail"];
    else{
        [dict setObject:user.Email forKey:@"assignedToEmail"];
    }
    [dict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"logInUserId"];
    [dict setObject:[NSString stringWithFormat:@"%d", _selectedProject.ProjectId] forKey:@"projectId"];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy H:'00'"];
    if(_dueDate)
        [dict setObject:[df stringFromDate:_dueDate] forKey:@"dueDate"];
    else
        [dict setObject:@"" forKey:@"dueDate"];
    [dict setObject:[NSString stringWithFormat:@"%@",prioritySwitch.on?@"High":@"Normal"] forKey:@"priority"];
    if(_tempFolderPath)
        [dict setObject:_tempFolderPath forKey:@"tempFolderName"];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"])
    {
        if(![LocationService isValidLocation])
        {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enable location services in iphone location settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else
        {
            [dict setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.longitude] forKey:@"longtitude"];
            [dict setObject:[LocationService addressString] forKey:@"locationAddress"];
        }
    }
    if([_dpAttachments count])
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dpAttachments options:0 error:&jsonError];
        [dict setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:@"dropBoxFiles"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createTaskCallBack:) name:@"CreateTaskNotifier" object:nil];
    [[TaskDocument sharedInstance] createTask:dict];
}

- (void)createTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(createTaskSuccess:) withObject:[note object] waitUntilDone:NO];
    
}



-(void)createTaskSuccess:(id)sender
{
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[Task class]])
    {
        _createdTask = (Task*)sender;
        if(_autoReminder)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setReminderNotifier:) name:@"SetReminderNotifier" object:nil];
            [[TaskDocument sharedInstance] setReminder:_autoReminder forTaskId:sender];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self resetAllData];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setReminderNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(setReminderCallBack:) withObject:[note object] waitUntilDone:NO];
}

-(void)setReminderCallBack:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[AutoReminder class]])
    {
        _createdTask.AutoReminder = (AutoReminder*)sender;
        _createdTask.HasReminder = YES;
        [self resetAllData];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)uploadTaskAttachmentCalllBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(uploadAttachmentSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

-(void)uploadAttachmentSuccess:(id)sender
{
    if ([sender isKindOfClass:[NSDictionary class]])
    {
        _tempFolderPath = [(NSDictionary*)sender objectForKey:@"TempFolderName"];
        [self createTask];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)resetAllData
{
    [self createContent];
    taskName.text = nil;
    taskSummary.text = nil;
    prioritySwitch.on = NO;
    [self cleanAllAttachments];
    
    
}

-(void)cleanAllAttachments{

    for (UIImageView* attachment in attachmentsContainer.subviews) {
        
        [attachment removeFromSuperview];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CREATETASK_ATTACHMENTS]) {
        [[NSFileManager defaultManager] removeItemAtPath:CREATETASK_ATTACHMENTS error:nil];
    }

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
    vc.selectedAssignee = _selectedUser;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navVC animated:YES completion:^{
        
    }];
}

- (IBAction)dueDateAction:(UIView*)sender
{
    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeSingle CalendarModeType:CalendarModeTypeDueDate];
    if(_dueDate)
        kal.selectedDate = _dueDate;
    else
        kal.selectedDate = [self defaultDate];
    kal.delegate = self;
   // dataSource = [[EventKitDataSource alloc] init];
    kal.dataSource = nil;
    kal.minAvailableDate = [NSDate date];
    kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateCancelAction:)];
    
    UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setDueDateAction:)];
    [setItem setWidth:50.0];
    UIBarButtonItem* clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(clearDueDateAction:)];
    if(_dueDate)
        kal.navigationItem.rightBarButtonItems = @[setItem,clearItem];
    else
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

- (void)setDueDateAction:(UIBarButtonItem*)item
{
    _dueDate = [kal actualDate];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, LLL d 'at' hh:mm a"];
    NSString *value =[dateformatter stringFromDate:_dueDate];
    
    if(DEVICE_IS_TABLET)
    {
        [datePopver dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    NSMutableDictionary* thirdObject = [contentArray lastObject];
    if(NSSTRING_HAS_DATA( value))
        [thirdObject setObject:value forKey:@"name"];
    else
        [thirdObject setObject:@"None" forKey:@"name"];
    [tbView reloadData];
    datePopver = nil;
    kal = nil;
}

- (void)clearDueDateAction:(UIBarButtonItem*)item
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
    _dueDate =  nil;
    NSMutableDictionary* thirdObject = [contentArray lastObject];
    [thirdObject setObject:@"None" forKey:@"name"];
    [tbView reloadData];
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

- (IBAction)attachmentAction:(UIButton*)sender
{
    if([taskName isFirstResponder])[taskName resignFirstResponder];
    if([taskSummary isFirstResponder])[taskSummary resignFirstResponder];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album",@"Take Photo",@"Video",@"Dropbox",nil];
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
    imagePickerPopover = nil;
    kal = nil;
}
- (IBAction)priorityAction:(UISwitch*)sender
{
    
}


- (void)projectSelected:(Project*)project
{
    _selectedProject = project;
    NSMutableDictionary* d = [contentArray firstObject];
    [d setObject:project.ProjectName forKey:@"name"];
    [tbView reloadData];
}

- (void)assigneeSelected:(User*)assignee
{
    _selectedUser = assignee;
    NSMutableDictionary* d = [contentArray objectAtIndex:1];
    if(assignee.FormattedName)
        [d setObject:assignee.FormattedName forKey:@"name"];
    else
        [d setObject:assignee.Email forKey:@"name"];
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
                imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                [imagePickerPopover setPopoverContentSize:CGSizeMake(320, 480)];
                CGRect rect = attachFileBtn.frame;
                rect.origin.y += 60;
                [imagePickerPopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            
            
        }
            break;
            
        case 1:{
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            else
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
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
                [self presentViewController:picker animated:YES completion:^{
                    
                }];
                
            }
            else
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
        case 3:{
            [self didDropboxPressChoose];
        }
            break;
            
        default:
            break;
    }
}

- (void)didDropboxPressChoose
{
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypePreview fromViewController:self
                                            completion:^(NSArray *results)
     {
         if ([results count]) {
             DBChooserResult* _result = results[0];
             int xoffset = 5;
             int yoffset = 5;
             
             for (UIImageView* attachment in attachmentsContainer.subviews) {
                 CGRect rect = attachment.frame;
                 if (rect.size.width == 54 && rect.size.height == 54) {
                     
                     xoffset += 5+rect.size.width;
                 }
                 
             }
             NSURL* thumbnailUrl = [_result thumbnails][@"64x64"] ;
             if(!thumbnailUrl)
                 thumbnailUrl = _result.iconURL;
             xoffset += 5;
             GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
             [attachmentImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailUrl]]];
             [attachmentsContainer addSubview:attachmentImage];
             [attachmentsContainer setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
             [[attachmentImage layer] setCornerRadius:3.0f];
             [[attachmentImage layer] setBorderWidth:1.0f];
             [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
             [[attachmentImage layer] setMasksToBounds:YES];
             [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
             attachmentImage.target = self;
             attachmentImage.action = @selector(showAttachment:);
             attachmentImage.serverAttachmentPath = [[_result link] absoluteString];
             

             if(!_dpAttachments)
                 _dpAttachments = [NSMutableArray new];
             [_dpAttachments addObject:[NSDictionary dictionaryWithObjectsAndKeys:[thumbnailUrl absoluteString],@"thumbnailLink",[NSNumber numberWithLongLong:_result.size],@"bytes",_result.link.absoluteString,@"link",_result.name,@"name",_result.iconURL.absoluteString,@"icon", nil]];
             [self adjustFooter];
         } else {
             //_result = nil;
             [[[UIAlertView alloc] initWithTitle:@"Dropbox" message:@"User cancelled!"
                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
              show];
         }
         
     }];
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
    
    cell.accessory.hidden = NO;
    if(indexPath.row == 0 && [TaskDocument sharedInstance].selectedPortfolio && [TaskDocument sharedInstance].selectedProject){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.accessory.hidden = YES;
    }
    else
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
            if(!([TaskDocument sharedInstance].selectedPortfolio && [TaskDocument sharedInstance].selectedProject))
                [self projectListAction:nil];
            break;
        case 1:
            [self assigneeListAction:nil];
            break;
        case 2:
            [self dueDateAction:[tableView cellForRowAtIndexPath:indexPath]];
            break;
            
        default:
            break;
    }
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
    
    for (UIImageView* attachment in attachmentsContainer.subviews) {
        CGRect rect = attachment.frame;
        if (rect.size.width == 54 && rect.size.height == 54) {
            
            xoffset += 5+rect.size.width;
        }
        
    }
    xoffset += 5;
    GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
    [attachmentImage setImage:image];
    [attachmentsContainer addSubview:attachmentImage];
    [attachmentsContainer setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
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
    
    [self adjustFooter];
}

-(void)showAttachment:(AttachmentButton*)sender
{
    if(!sender.localAttachmentPath)
    {
        ShowAttachmentVC* savc = [[ShowAttachmentVC alloc] initWithNibName:@"ShowAttachmentVC" bundle:nil];
        [savc setUrl:sender.serverAttachmentPath];
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
        [self presentViewController:navVC animated:YES completion:nil];
    }
    else
    {
        ImageMapVC* savc = [[ImageMapVC alloc] initWithNibName:@"ImageMapView" bundle:nil];
        savc.mapImageSrc = sender.localAttachmentPath;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
        [self presentViewController:navVC animated:YES completion:nil];
        
    }
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

- (IBAction)setReminderAction:(UIButton*)sender
{
    kal = [[KalViewController alloc] initWithSelectionMode:KalSelectionModeSingle CalendarModeType:CalendarModeTypeReminder];
    if(_autoReminder.DaysFrequency)
        [kal setReminderWithType:[_autoReminder getDaysFrequencyString]];
    if(_autoReminder.ReminderStartDate)
    {
        kal.selectedDate = _autoReminder.ReminderStartDate;
    }
    else
        kal.selectedDate = [self defaultReminderDate];
    kal.delegate = self;
    kal.dataSource = nil;
    kal.minAvailableDate = [NSDate date];
    kal.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dateCancelAction:)];
    
    UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setReminderDateAction:)];
    [setItem setWidth:50.0];
    UIBarButtonItem* clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(clearReminderDateAction:)];
    if(_dueDate)
        kal.navigationItem.rightBarButtonItems = @[setItem,clearItem];
    else
        kal.navigationItem.rightBarButtonItems = @[setItem];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:kal];
    if(DEVICE_IS_TABLET)
    {
        CGRect rect = sender.frame;
        rect.origin.y += 64;
        //kal.view.frame = CGRectMake(0, 0, 320, 560);
        datePopver = [[UIPopoverController alloc] initWithContentViewController:navController];
        [datePopver setPopoverContentSize:CGSizeMake(320, 560)];
        datePopver.delegate = self;
        [datePopver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
    else
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (IBAction)removeReminderAction:(UIButton*)sender
{
    reminderBtn.selected = NO;
    reminderCrossBtn.hidden = YES;
    _autoReminder = nil;
}

- (void)setReminderDateAction:(UIBarButtonItem*)item
{
    if(_autoReminder == nil)
        _autoReminder = [AutoReminder new];
    
    if([kal isAutoReminderOn])
    {
        [_autoReminder setDaysFrequencyFromString:[kal reminderFrequency]];
    }
    else
        _autoReminder.DaysFrequency = [NSNumber numberWithInt:0];
    
    _autoReminder.ReminderStartDate = [kal selectedDate];
//    if([_autoReminder.ReminderStartDate isEqual:[kal selectedDate]])
//        _autoReminder.IsReminderToday = YES;
//    else
//        _autoReminder.IsReminderToday = NO;
    
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          reminderBtn.titleLabel.font,NSFontAttributeName,
                                          nil];
    
    CGRect rect = reminderBtn.frame;
    rect.size.width = [[_autoReminder displayString] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, rect.size.height) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:attributesDictionary context:nil].size.width + 30;
    [reminderBtn setFrame:rect];
    
    [reminderBtn setTitle:[_autoReminder displayString] forState:UIControlStateSelected];
    
    rect = reminderCrossBtn.frame;
    rect.origin.x = reminderBtn.frame.size.width+reminderBtn.frame.origin.x;
    [reminderCrossBtn setFrame:rect];
    
    reminderBtn.selected = YES;
    reminderCrossBtn.hidden = NO;
    
    if(DEVICE_IS_TABLET)
    {
        [datePopver dismissPopoverAnimated:YES];
    }
    else
    {
        [kal dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    datePopver = nil;
    kal = nil;    
}

- (void)clearReminderDateAction:(UIBarButtonItem*)item
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
    _autoReminder =  nil;
    reminderBtn.selected = NO;
    reminderCrossBtn.hidden = YES;
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

- (void)adjustFooter
{
    if(attachmentsContainer.subviews.count)
    {
        CGRect rect = fotterContentView.frame;
        rect.origin.y = attachmentsContainer.frame.size.height+attachmentsContainer.frame.origin.y+5;
        [fotterContentView setFrame:rect];
    }
    else
    {
        CGRect rect = fotterContentView.frame;
        rect.origin.y = 244;
        [fotterContentView setFrame:rect];
    }
}
@end
