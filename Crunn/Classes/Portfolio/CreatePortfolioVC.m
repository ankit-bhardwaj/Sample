//
//  CreatePortfolioVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "CreatePortfolioVC.h"
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
#import "ShowAttachmentVC.h"
#include <DBChooser/DBChooser.h>
#import "PortfolioDetailVC.h"
#import "HomeVC.h"
#import "GSAsynImageView.h"

@interface CreatePortfolioVC ()
{ 
    IBOutlet UITextField* taskName;
    IBOutlet HPGrowingTextView* taskSummary;
    IBOutlet UIScrollView* attachmentsContainer;
    IBOutlet UIButton* attachFileBtn;
    NSString* _tempFolderPath;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIImageView* textViewPlacehoder;
    
    IBOutlet UIButton* taskNameMic;
    IBOutlet UIButton* taskSummaryMic;
    IBOutlet UIActivityIndicatorView* taskNameActivity;
    IBOutlet UIActivityIndicatorView* taskSummaryActivity;
    
    UIPopoverController* imagePickerPopover;
    NSMutableArray* _dpAttachments;
}

@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)attachmentAction:(id)sender;
- (IBAction)taskSpeackAction:(id)sender;
- (IBAction)taskSummaryAction:(id)sender;
@end

@implementation CreatePortfolioVC

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
    
    
    if(self.portfolioType == CreateTypePortfolio || self.portfolioType == CreateTypeProject)
    {
        UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createAction)];
        [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    }
    else
    {
        UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(createAction)];
        [self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    }
    
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
    
    
    
    [self cleanAllAttachments];

    taskSummary.placeholder = @"Add a description (optional)";
    
    if(self.portfolioType == CreateTypePortfolio)
    {
        self.navigationItem.title = @"Create Portfolio";
        attachFileBtn.hidden = YES;
        taskName.placeholder = @"Portfolio name";
    }
    else if(self.portfolioType == CreateTypeProject)
    {
        self.navigationItem.title = @"Create Project";
        taskName.placeholder = @"Project name";
    }
    else if(self.portfolioType == EditTypePortfolio)
    {
        self.navigationItem.title = @"Edit Portfolio";
        attachFileBtn.hidden = YES;
        taskName.placeholder = @"Portfolio name";
        taskName.text = self.selectedPortfolio.PortfolioName;
        taskSummary.text = self.selectedPortfolio.PortfolioDescription;
        //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector   (getPortfolioUserListCallBack:) name:@"GetPortfolioNotifier" object:nil];
        //[[TaskDocument sharedInstance] getPortfolio:self.selectedPortfolio];
    }
    else if(self.portfolioType == EditTypeProject)
    {
        self.navigationItem.title = @"Edit Project";
        taskName.placeholder = @"Project name";
        taskName.text = self.selectedProject.ProjectName;
        taskSummary.text = self.selectedProject.ProjectDescription;
        //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector   (getProjectUserListCallBack:) name:@"GetProjectNotifier" object:nil];
        //[[TaskDocument sharedInstance] getProject:self.selectedProject];
    }
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getPortfolioUserListCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    Portfolio* portfolio = [note object];
    if(portfolio && [portfolio isKindOfClass:[Portfolio class]])
    {
        self.selectedPortfolio.PortfolioDescription = portfolio.PortfolioDescription;
    }
    [self performSelectorOnMainThread:@selector(reloadView) withObject:[note object] waitUntilDone:NO];
}

- (void)getProjectUserListCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    Project* project = [note object];
    if(project && [project isKindOfClass:[Project class]])
    {
        self.selectedProject.ProjectDescription = project.ProjectDescription;
    }
    [self performSelectorOnMainThread:@selector(reloadView) withObject:[note object] waitUntilDone:NO];
}

- (void)reloadView
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    if(self.portfolioType == EditTypePortfolio)
    {
        taskName.text = self.selectedPortfolio.PortfolioName;
        taskSummary.text = self.selectedPortfolio.PortfolioDescription;
    }
    else if(self.portfolioType == EditTypeProject)
    {
        taskName.text = self.selectedProject.ProjectName;
        taskSummary.text = self.selectedProject.ProjectDescription;
    }
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
    taskNameMic.enabled = YES;
    taskSummaryMic.enabled = YES;
    if(txt == taskName)
    {
        taskNameMic.hidden = NO;
        [taskNameActivity stopAnimating];
        [taskName resignFirstResponder];
        [taskName setInputView:nil];
    }
    else
    {
        taskSummary.hidden = NO;
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

- (void)createAction
{
    [taskName resignFirstResponder];
    [taskSummary resignFirstResponder];
    
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(name))
    {
        if(self.portfolioType == CreateTypePortfolio)
            msg = @"Enter portfolio name.";
        else
            msg = @"Enter project name.";
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
        {
            if(self.portfolioType == CreateTypePortfolio || self.portfolioType == EditTypePortfolio)
                [self createPortfolio];
            else
                [self createProject];
        }
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

- (void)createPortfolio
{
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* summary = [taskSummary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    User* user = [User currentUser];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:@"portfolioName"];
    if(NSSTRING_HAS_DATA(summary))
        [dict setObject:[summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"] forKey:@"portfolioDesc"];
    else
        [dict setObject:@"" forKey:@"portfolioDesc"];
    
    [dict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"logInUserId"];
    
    if([_dpAttachments count])
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dpAttachments options:0 error:&jsonError];
        [dict setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:@"dropBoxFiles"];
    }
    
    if(self.portfolioType == CreateTypePortfolio)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createPortfolioCallBack:) name:@"CreatePortfolioNotifier" object:nil];
        [[TaskDocument sharedInstance] createPortfolio:dict];
    }
    else if(self.portfolioType == EditTypePortfolio)
    {
        [dict setObject:[NSString stringWithFormat:@"%ld", self.selectedPortfolio.PortfolioId] forKey:@"portfolioId"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createPortfolioCallBack:) name:@"EditPortfolioNotifier" object:nil];
        [[TaskDocument sharedInstance] editPortfolio:dict];
    }
}

- (void)createPortfolioCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(createPortfolioSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

-(void)createPortfolioSuccess:(id)sender
{
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[NSNumber class]])
    {
        
        if(self.portfolioType == CreateTypePortfolio)
        {
            Portfolio*object = [Portfolio new];
            object.PortfolioId = [(NSNumber*)sender intValue];
            object.PortfolioDescription = taskSummary.text;
            object.PortfolioName = taskName.text;
            ProjectUser* owner = [ProjectUser new];
            owner.UserProfile = [User currentUser];
            object.Owner = owner;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPortfolioCallBack:) name:@"GetPortfolioNotifier" object:nil];
            [[TaskDocument sharedInstance] getPortfolio:object];
            return;
            
            PortfolioDetailVC* vc = [[PortfolioDetailVC alloc] initWithNibName:@"PortfolioDetailVC" bundle:nil];
            vc.portfolioType = DetailTypePortfolio;
            vc.selectedPortfolio = object;
            [self.navigationController pushViewController:vc animated:YES];
            [self resetAllData];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self resetAllData];
            [self dismissViewControllerAnimated:YES completion:^{
                
                self.selectedPortfolio.PortfolioName = taskName.text;
                self.selectedPortfolio.PortfolioId = [(NSNumber*)sender integerValue];
                [self.view makeToast:@"Portfolio edited successfully."];
            }];
        }
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getProjectCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openProjectMenu:) withObject:[note object] waitUntilDone:NO];
}

- (void)openProjectMenu:(id)note
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    Project* project = note;
    if(project && [project isKindOfClass:[Project class]])
    {
        //[TaskDocument sharedInstance].hasJustCreatedPortfolio = YES;
        [self resetAllData];
        [TaskDocument sharedInstance].selectedProject = project;
        [TaskDocument sharedInstance].selectedPortfolio = self.selectedPortfolio;
        [self dismissViewControllerAnimated:YES completion:^{
            [self.view makeToast:@"Portfolio created successfully."];
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            UINavigationController * navigationController = (UINavigationController*)drwayer.centerViewController;
            HomeVC *centerViewController = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
            [navigationController setViewControllers:[NSArray arrayWithObject:centerViewController]];
            [drwayer setCenterViewController:navigationController withCloseAnimation:NO completion:^(BOOL finished) {
                [centerViewController openProjectMenu:project];
            }];
        }];
    }
}

- (void)getPortfolioCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(openPortfolioMenu:) withObject:[note object] waitUntilDone:NO];
}

- (void)openPortfolioMenu:(id)note
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    Portfolio* portfolio = note;
    if(portfolio && [portfolio isKindOfClass:[Portfolio class]])
    {
        //[TaskDocument sharedInstance].hasJustCreatedPortfolio = YES;
        [self resetAllData];
        [TaskDocument sharedInstance].selectedPortfolio = portfolio;
        [TaskDocument sharedInstance].selectedProject = nil;
        [self dismissViewControllerAnimated:YES completion:^{
            [self.view makeToast:@"Project created successfully."];
            MMDrawerController* drwayer = [APPDELEGATE drawerController];
            UINavigationController * navigationController = (UINavigationController*)drwayer.centerViewController;
            HomeVC *centerViewController = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
            [navigationController setViewControllers:[NSArray arrayWithObject:centerViewController]];
            [drwayer setCenterViewController:navigationController withCloseAnimation:NO completion:^(BOOL finished) {
                [centerViewController openPortfolioMenu:portfolio];
            }];
        }];
    }
}

- (void)createProject
{
    NSString* name = [taskName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* summary = [taskSummary.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    User* user = [User currentUser];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:name forKey:@"projectName"];
    if(NSSTRING_HAS_DATA(summary))
        [dict setObject:[summary stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"] forKey:@"projectDesc"];
    else
        [dict setObject:@"" forKey:@"projectDesc"];
    
    [dict setObject:[NSString stringWithFormat:@"%ld", self.selectedPortfolio.PortfolioId] forKey:@"portfolioId"];
    
    [dict setObject:[NSString stringWithFormat:@"%d", user.UserId] forKey:@"logInUserId"];
    
    if(_tempFolderPath)
        [dict setObject:_tempFolderPath forKey:@"tempFolderName"];
    
    if([_dpAttachments count])
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dpAttachments options:0 error:&jsonError];
        [dict setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:@"dropBoxFiles"];
    }
    
    if(self.portfolioType == CreateTypeProject)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createProjectCallBack:) name:@"CreateProjectNotifier" object:nil];
        [[TaskDocument sharedInstance] createProject:dict];
    }
    else if(self.portfolioType == EditTypeProject)
    {
        [dict setObject:[NSString stringWithFormat:@"%ld", self.selectedProject.ProjectId] forKey:@"projectId"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createProjectCallBack:) name:@"EditProjectNotifier" object:nil];
        [[TaskDocument sharedInstance] editProject:dict];
    }
    
    
}

- (void)createProjectCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(createProjectSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

-(void)createProjectSuccess:(id)sender
{
    
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[NSNumber class]])
    {
        if(self.portfolioType == CreateTypeProject)
        {
            Project*object = [Project new];
            object.ProjectId = [(NSNumber*)sender intValue];
            object.ProjectDescription = taskSummary.text;
            object.ProjectName = taskName.text;
            ProjectUser* owner = [ProjectUser new];
            owner.UserProfile = [User currentUser];
            object.Owner = owner;\
            [[TaskDocument sharedInstance] setSelectedProject:object];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getProjectCallBack:) name:@"GetProjectNotifier" object:nil];
            [[TaskDocument sharedInstance] getProject:object];
            
            return;
            
            PortfolioDetailVC* vc = [[PortfolioDetailVC alloc] initWithNibName:@"PortfolioDetailVC" bundle:nil];
            vc.portfolioType = DetailTypeProject;
            
            vc.selectedProject = object;
            [self.navigationController pushViewController:vc animated:YES];
            [self resetAllData];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self resetAllData];
            [self dismissViewControllerAnimated:YES completion:^{
                self.selectedProject.ProjectName = taskName.text;
                self.selectedProject.ProjectId = [(NSNumber*)sender integerValue];
                [self.view makeToast:@"Project edited successfully."];
            }];
        }
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
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
        [self createProject];
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
    taskName.text = nil;
    taskSummary.text = nil;
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

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    imagePickerPopover = nil;
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
         } else {
             //_result = nil;
             [[[UIAlertView alloc] initWithTitle:@"Dropbox" message:@"User cancelled!"
                                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
              show];
         }
         
     }];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger namelen = [string length] > 0?([textField.text length]+[string length]):([textField.text length]-1);
    if([string length] > 0 && namelen > 50)
    {
        textField.text = [textField.text stringByAppendingString:[string substringToIndex:(50-[textField.text length])]];
        return NO;
    }
    return YES;
}

@end
