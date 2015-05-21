//
//  CreateTaskVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "EditTaskVC.h"
#import "ProjectListVC.h"
#import "AssigneeListVC.h"
#import "PriorityListVC.h"
#import "taskCell.h"
#import "Portfolio.h"
#import "TaskDocument.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+Additions.h"
#import "Comment.h"
#import "GSAsynImageView.h"
#import "SpeechToTextModule.h"
#import "HPGrowingTextView.h"
#import "StatusListVC.h"
#import "Kal.h"
#import "KalViewController.h"
#import "WYPopoverController.h"
#import "AttachmentButton.h"
#import "ImageMapVC.h"
#import "ShowAttachmentVC.h"
#include <DBChooser/DBChooser.h>
#import "GSAsynImageView.h"

@interface EditTaskVC ()
{ 
    IBOutlet UITextField* taskName;
    IBOutlet HPGrowingTextView* taskSummary;
    IBOutlet UIButton* attachmentBtn;
    IBOutlet UITableView* tbView;
    IBOutlet UISwitch* prioritySwitch;
    IBOutlet UIScrollView* attachmentsContainer;
    NSMutableArray* contentArray;
    User* _selectedUser;
    Project* _selectedProject;
    NSString* _selectedStatus;
    TaskStatus taskStatus;
    NSDate*  _dueDate;
    NSString* _tempFolderPath;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIImageView* textViewPlacehoder;
    
    IBOutlet UIButton* taskNameMic;
    IBOutlet UIButton* taskSummaryMic;
    IBOutlet UIActivityIndicatorView* taskNameActivity;
    IBOutlet UIActivityIndicatorView* taskSummaryActivity;
    
    UIPopoverController<NSObject>* statusPopver;
    UIPopoverController* datePopver;
    
    KalViewController* kal;
    
    IBOutlet UIButton* reminderCrossBtn;
    IBOutlet UIButton* reminderBtn;
    AutoReminder* _autoReminder;

    UIPopoverController* imagePickerPopover;
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

@implementation EditTaskVC

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
    textViewPlacehoder.image = [[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    
    taskName.enabled = self.task.CanEdit;
    taskSummary.editable = (self.task.CanEdit || self.task.CanEditAssignee);
    attachmentBtn.enabled = self.task.CanEdit;
    tbView.userInteractionEnabled = (self.task.CanEdit || self.task.CanEditAssignee);
    prioritySwitch.enabled = self.task.CanEdit;
    prioritySwitch.on = self.task.highPriority;
    
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
    
    self.navigationItem.title = @"Edit Task";
    
    UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(updateTaskAction)];
    if(self.task.CanEdit || self.task.CanEditAssignee)
        [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    [v setBackgroundColor:[UIColor clearColor]];
    taskName.leftView = v;
    taskName.leftViewMode = UITextFieldViewModeAlways;
    taskName.delegate = self;
    
    taskSummary.minNumberOfLines = 1;
	taskSummary.maxNumberOfLines = 7;
    
	taskSummary.returnKeyType = UIReturnKeyDefault; //just as an example
	taskSummary.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
	taskSummary.delegate = self;
    
    taskSummary.backgroundColor = [UIColor clearColor];
    
    if(!NSSTRING_HAS_DATA( self.task.summary))
        taskSummary.placeholder = @"Create detailed description of your task here...";

        taskSummary.text = self.task.summary;
        taskSummary.attributedText = self.task.attrSummary;
    
   
    taskName.text = self.task.name;
    
    if(self.task.HasReminder)
    {
        _autoReminder = self.task.AutoReminder;
        [reminderBtn setTitle:[_autoReminder displayString] forState:UIControlStateSelected];
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              reminderBtn.titleLabel.font,NSFontAttributeName,
                                              nil];
        
        CGRect rect = reminderBtn.frame;
        rect.size.width = [[_autoReminder displayString] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, rect.size.height) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:attributesDictionary context:nil].size.width + 30;
        [reminderBtn setFrame:rect];
            
        rect = reminderCrossBtn.frame;
        rect.origin.x = reminderBtn.frame.size.width+reminderBtn.frame.origin.x;
        [reminderCrossBtn setFrame:rect];
        reminderBtn.selected = YES;
        reminderCrossBtn.hidden = NO;
    }
  
   [tbView registerNib:[UINib nibWithNibName:@"taskCell" bundle:nil]  forCellReuseIdentifier:@"taskCell"];
    
    [self cleanAllAttachments];
    [self createContent];
    
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

    _selectedProject = self.task.project;
    _selectedStatus = self.task.StatusTypeDescription;
    taskStatus = [Task getTaskStatus:self.task.StatusTypeDescription];
    
    _selectedUser = self.task.assignee;
    NSString* dueDateString = [self.task.DueDateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (NSSTRING_HAS_DATA(dueDateString)) {
        
        _dueDate = [self datefromString:dueDateString];
    }
    else{
        _dueDate = nil;
    }
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    
     NSMutableDictionary* zeroObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Status",@"title",self.task.StatusTypeDescription,@"name",[self.task getTaskStatusImage],@"image", nil];
    
    NSMutableDictionary* firstObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Project",@"title",self.task.ProjectName,@"name",[UIImage imageNamed: @"projectList_btn.png"],@"image", nil];
    NSMutableDictionary* secondObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Assignee",@"title",self.task.assignee.FormattedName,@"name",[UIImage imageNamed:@"assignee_btn.png"],@"image", nil];
    NSMutableDictionary* thirdObject = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Due Date",@"title",_dueDate?[df stringFromDate:_dueDate]:@"None",@"name",[UIImage imageNamed:@"calendar_btn.png"],@"image", nil];
    contentArray = [[NSMutableArray alloc] initWithObjects:zeroObject,firstObject,secondObject,thirdObject, nil];
    
    NSArray* imageContentTypes = [NSArray arrayWithObjects:@"image/jpeg",@"image/png", nil];
    for(Attachment* attachment in self.task.Attachments)
    {
        if([imageContentTypes containsObject:attachment.ContentType])
        {
            int xoffset = 5;
            int yoffset = 5;
            for (UIImageView* attachment in attachmentsContainer.subviews)
            {
                CGRect rect = attachment.frame;
                if (rect.size.width == 54 && rect.size.height == 54)
                {
                    xoffset += 5+rect.size.width;
                }
            }
            xoffset += 5;
            GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
            attachmentImage.target = self;
            attachmentImage.action = @selector(showAttachment:);
            attachmentImage.attachment = attachment;
            [attachmentImage loadImageFromURLForAttachment:attachment];
            [attachmentsContainer addSubview:attachmentImage];
            [attachmentsContainer setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
            [[attachmentImage layer] setCornerRadius:3.0f];
            [[attachmentImage layer] setBorderWidth:1.0f];
            [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
            [[attachmentImage layer] setMasksToBounds:YES];
            [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
    
    [tbView reloadData];
}

-(void)showAttachment:(AttachmentButton*)sender
{
    if(sender.attachment)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowAttachment" object:sender.attachment];
    }
    else if(!sender.localAttachmentPath)
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancelAction
{
    [self cleanAllAttachments];
    [self.navigationController popViewControllerAnimated:YES];
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
    if(txt == taskName)
    {
        taskSummaryMic.enabled = YES;
        taskNameMic.enabled = YES;
        taskNameMic.hidden = NO;
        [taskNameActivity stopAnimating];
        [taskName setInputView:nil];
    }
    else
    {
        taskNameMic.enabled = YES;
        taskSummaryMic.enabled = YES;
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


- (void)updateTaskAction
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
    if(!_selectedStatus)
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Select status!"];
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
            [self updateTask];
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

- (void)updateTask
{
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* summary = [taskSummary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    User* user = [User currentUser];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.task.taskId forKey:@"taskId"];
    [dict setObject:name forKey:@"taskDescription"];
    if(NSSTRING_HAS_DATA(summary))
        [dict setObject:[summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"] forKey:@"taskDetails"];
    else
        [dict setObject:@"" forKey:@"taskDetails"];
    if(NSSTRING_HAS_DATA(_selectedUser.Email))
        [dict setObject:_selectedUser.Email forKey:@"assigneeEmail"];
    else{
        [dict setObject:user.Email forKey:@"assigneeEmail"];
    }
    [dict setObject:[self.task getTaskStatusName] forKey:@"taskStatus"];
    [dict setObject:[NSNumber numberWithInt:user.UserId] forKey:@"lastUpdatedById"];
    [dict setObject:self.task.CircleId forKey:@"circleId"];
    [dict setObject:self.task.GroupId forKey:@"groupId"];
    
    [dict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"logInUserId"];
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy H:'00'"];
    if(_dueDate)
        [dict setObject:[df stringFromDate:_dueDate] forKey:@"dueDate"];
    else
        [dict setObject:@"" forKey:@"dueDate"];
    [dict setObject:[NSString stringWithFormat:@"%@",prioritySwitch.on?@"High":@"Normal"] forKey:@"priority"];
    if(self.task.DoDateString)
        [dict setObject:self.task.DoDateString forKey:@"doDate"];
    else
        [dict setObject:@"" forKey:@"doDate"];
    
   if(_tempFolderPath)
       [dict setObject:_tempFolderPath forKey:@"tempFolderName"];
    
    if([_dpAttachments count])
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dpAttachments options:0 error:&jsonError];
        [dict setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:@"dropBoxFiles"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTaskCallBack:) name:@"UpdateTaskNotifier" object:nil];
    [[TaskDocument sharedInstance] updateTask:dict];
}

- (void)updateTaskCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(updateTaskSuccess:) withObject:[note object] waitUntilDone:NO];
    
}



-(void)updateTaskSuccess:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[NSNumber class]])
    {
        [self resetAllData];
        [self.navigationController popToRootViewControllerAnimated:YES];
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
        [self updateTask];
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

    for (UIImageView* attachment in attachmentsContainer.subviews)
    {
        [attachment removeFromSuperview];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CREATETASK_ATTACHMENTS])
    {
        [[NSFileManager defaultManager] removeItemAtPath:CREATETASK_ATTACHMENTS error:nil];
    }

}

-(NSString *)randomNumberGenerator
{
    char *characters="abcdef0123456789";
    int length=strlen(characters);
    char randomString[38];
    int i;
    for(i=0;i<36;i++)
    {
        if(i == 8 || i == 13 || i == 18 || i == 23)
            randomString[i]='-';
        else
            randomString[i] = characters[arc4random()%length];
    }
    randomString[i]='\0';
    NSString *returnString = [[NSString alloc] initWithCString:randomString encoding:NSUTF8StringEncoding];
    return returnString;
	
}

- (IBAction)statusListAction:(UIView*)sender
{
    if(self.task.CanEdit || self.task.CanEditAssignee)
    {
        StatusListVC* vc = [[StatusListVC alloc] initWithNibName:@"StatusListVC" bundle:nil];
        vc.target = self;
        vc.action = @selector(statusSelected:);
        vc.selectedStatus = _selectedStatus;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        if(DEVICE_IS_TABLET)
        {
            statusPopver = [[UIPopoverController alloc] initWithContentViewController:navVC];
            vc.popOver = statusPopver;
            [statusPopver setPopoverContentSize:CGSizeMake(320, 320)];
            statusPopver.delegate = self;
            [statusPopver presentPopoverFromRect:sender.frame inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            statusPopver = [[WYPopoverController alloc] initWithContentViewController:navVC];
            vc.popOver = statusPopver;
            [statusPopver setPopoverContentSize:CGSizeMake(280, 320)];
            [statusPopver setDelegate:self];
            [statusPopver presentPopoverFromRect:sender.frame inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        [self.view makeToast:@"You do not have permisson to access it."];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    //datePopver = nil;
    statusPopver = nil;
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    datePopver = nil;
    kal = nil;
    statusPopver = nil;
    imagePickerPopover = nil;
}

- (IBAction)projectListAction:(id)sender
{
    if(self.task.CanEdit)
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
    else
    {
        [self.view makeToast:@"You do not have permisson to access it."];
    }
}

- (IBAction)assigneeListAction:(id)sender
{
    if(self.task.CanEdit || self.task.CanEditAssignee)
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
    else
    {
        [self.view makeToast:@"You do not have permisson to access it."];
    }
}
- (IBAction)dueDateAction:(UIView*)sender
{
    if(self.task.CanEdit)
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
        
        UIBarButtonItem* setItem = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStylePlain target:self action:@selector(setDateAction:)];
        [setItem setWidth:50.0];
        UIBarButtonItem* clearItem = [[UIBarButtonItem alloc] initWithTitle:@"Remove" style:UIBarButtonItemStylePlain target:self action:@selector(clearDateAction:)];
        if(_dueDate)
            kal.navigationItem.rightBarButtonItems = @[setItem,clearItem];
        else
            kal.navigationItem.rightBarButtonItems = @[setItem];
        
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:kal];
        if(DEVICE_IS_TABLET)
        {
            //kal.view.frame = CGRectMake(0, 0, 320, 560);
            datePopver = [[UIPopoverController alloc] initWithContentViewController:navController];
            [datePopver setPopoverContentSize:CGSizeMake(320, 560)];
            datePopver.delegate = self;
            [datePopver presentPopoverFromRect:sender.frame inView:tbView permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight animated:YES];
        }
        else
        {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
        }
    }
    else
    {
        [self.view makeToast:@"You do not have permisson to access it."];
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

- (void)setDateAction:(UIBarButtonItem*)item
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

- (void)clearDateAction:(UIBarButtonItem*)item
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
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album",@"Take Photo",@"Video",@"Dropbox", nil];
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

- (IBAction)priorityAction:(UISwitch*)sender
{
    
}

- (void)statusSelected:(StatusListVC*)vc
{
    _selectedStatus = vc.selectedStatus;
    self.task.taskStatus = taskStatus = [Task getTaskStatus:_selectedStatus];
    NSMutableDictionary* d = [contentArray firstObject];
    [d setObject:_selectedStatus forKey:@"name"];
    
    [d setObject:[UIImage imageForStatus:_selectedStatus] forKey:@"image"];
    [tbView reloadData];
}



- (void)projectSelected:(Project*)project
{
    _selectedProject = project;
    
    NSMutableDictionary* d = [contentArray objectAtIndex:1];
    [d setObject:project.ProjectName forKey:@"name"];
    [tbView reloadData];
}

- (void)assigneeSelected:(User*)assignee
{
    _selectedUser = assignee;

    NSMutableDictionary* d = [contentArray objectAtIndex:2];
    if(assignee.FormattedName)
        [d setObject:assignee.FormattedName forKey:@"name"];
    else
        [d setObject:assignee.Email forKey:@"name"];
    [tbView reloadData];
}


- (NSDate *)datefromString:(NSString *)string
{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    NSString* dateString = [[string componentsSeparatedByString:@"|"] objectAtIndex:1];
    [dateformatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSDate *date =[dateformatter dateFromString:dateString];
    
    return date;
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
                CGRect rect = attachmentBtn.frame;
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
                    CGRect rect = attachmentBtn.frame;
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
                    CGRect rect = attachmentBtn.frame;
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
    if(indexPath.row == 1 && [TaskDocument sharedInstance].selectedPortfolio && [TaskDocument sharedInstance].selectedProject)
    {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.accessory.hidden = YES;
    }
    else
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    cell.accessoryView = nil;
    
    
    NSDictionary* d = [contentArray objectAtIndex:indexPath.row];
    cell.image.image = [d objectForKey:@"image"];
    cell.name.text = [d objectForKey:@"name"];
    cell.title.text = [d objectForKey:@"title"];
    return cell;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self statusListAction:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        case 1:
            if(!([TaskDocument sharedInstance].selectedPortfolio && [TaskDocument sharedInstance].selectedProject))
                [self projectListAction:nil];
            break;
        case 2:
            [self assigneeListAction:nil];
            break;
        case 3:
            [self dueDateAction:[tableView cellForRowAtIndexPath:indexPath]];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
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
    else
    {
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
    attachmentImage.target = self;
    attachmentImage.action = @selector(showAttachment:);
    attachmentImage.localAttachmentPath = path;
    
    [data writeToFile:path atomically:YES];
    if(imagePickerPopover)
    {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
    else
        [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self adjustFooter];
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
        [datePopver presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (IBAction)removeReminderAction:(UIButton*)sender
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeReminderNotifier:) name:@"RemoveReminderNotifier" object:nil];
    [[TaskDocument sharedInstance] removeReminder:_autoReminder forTaskId:self.task];
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
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setReminderNotifier:) name:@"SetReminderNotifier" object:nil];
    [[TaskDocument sharedInstance] setReminder:_autoReminder forTaskId:self.task];
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
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeReminderNotifier:) name:@"RemoveReminderNotifier" object:nil];
    [[TaskDocument sharedInstance] removeReminder:_autoReminder forTaskId:self.task];
}

- (void)setReminderNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(setReminderCallBack:) withObject:[note object] waitUntilDone:NO];
}

-(void)setReminderCallBack:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[AutoReminder class]])
    {
        [self.view makeToast:@"Reminder has set successfully."];
        
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)removeReminderNotifier:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(removeReminderCallBack:) withObject:[note object] waitUntilDone:NO];
}

-(void)removeReminderCallBack:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if ([sender isKindOfClass:[NSNumber class]] || [sender isKindOfClass:[AutoReminder class]])
    {
        _autoReminder =  nil;
        reminderBtn.selected = NO;
        reminderCrossBtn.hidden = YES;
        [self.view makeToast:@"Reminder has removed successfully."];
        
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (NSDate*)defaultReminderDate
{
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: date];
    [components setHour:0];
    [components setMinute: 0];
    [components setSecond: 1];
    NSDate *startDate = [gregorian dateFromComponents: components];
    return startDate;
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
        rect.origin.y = 260;
        [fotterContentView setFrame:rect];
    }
}

@end
