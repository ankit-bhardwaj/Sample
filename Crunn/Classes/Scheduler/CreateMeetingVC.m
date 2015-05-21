//
//  CreateMeetingVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/5/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "CreateMeetingVC.h"
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
#import "UserDocument.h"
#import "TimeZoneSelectorVC.h"
#import "ValidationHelper.h"
#import "DropdownActionSheet.h"
#import "DropDownControl.h"
#import "ScheduleDatePickerVC.h"
#import "ScheduleWelcomeVC.h"
#import "ShowAttachmentVC.h"
#include <DBChooser/DBChooser.h>
#import "GSAsynImageView.h"

@interface CreateMeetingVC ()
{ 
    IBOutlet UITextField* firstTxt;
    IBOutlet UITextField* lastTxt;
    IBOutlet UITextField* emailTxt;
    IBOutlet UITextField* titleText;
    IBOutlet UITextField* descText;
    IBOutlet UITextField* locText;
    IBOutlet UIButton*    timeZoneBtn;
    IBOutlet DropDownControl*    timeDurationBtn;
    IBOutlet UIButton*    inviteBtn;
    IBOutlet UIButton*    attachFileBtn;
    
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIScrollView* attachmentScrollView;
    
    MBProgressHUD *HUD;
    UIPopoverController* imagePickerPopover;
    NSMutableArray* _selectedUsers;
    DropdownActionSheet *dropDownActionSheet;
    
    NSMutableArray* _dpAttachments;
}

@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)timeZoneAction:(id)sender;
- (IBAction)timeDurationAction:(id)sender;
- (IBAction)attachmentAction:(id)sender;
- (IBAction)inviteAction:(id)sender;
- (IBAction)backAction:(id)sender;
@end

@implementation CreateMeetingVC

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
    
    //self.navigationController.navigationBarHidden = NO;
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
    //self.navigationItem.title = @"Step 1";
    
    //UIBarButtonItem * createBtn = [[UIBarButtonItem alloc] initWithTitle:@"Pick date(s)" style:UIBarButtonItemStylePlain target:self action:@selector(pickDateAction:)];
    //[self.navigationItem setRightBarButtonItem:createBtn animated:YES];
    
    //UIBarButtonItem * cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    //[self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
    
    [[UserDocument sharedInstance] fetchTimeZones];
    
    // Do any additional setup after loading the view from its nib.
    [scrollView setContentSize:CGSizeMake(320, 560)];
    
    firstTxt.layer.cornerRadius = 2.0;
    lastTxt.layer.cornerRadius = 2.0;
    emailTxt.layer.cornerRadius = 2.0;
    titleText.layer.cornerRadius = 2.0;
    descText.layer.cornerRadius = 2.0;
    locText.layer.cornerRadius = 2.0;
    timeDurationBtn.layer.cornerRadius = 2.0;
    timeZoneBtn.layer.cornerRadius = 2.0;
    
    firstTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lastTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    emailTxt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    titleText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    descText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    locText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    timeDurationBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    timeZoneBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    firstTxt.layer.borderWidth = 1.0;
    lastTxt.layer.borderWidth = 1.0;
    emailTxt.layer.borderWidth = 1.0;
    titleText.layer.borderWidth = 1.0;
    descText.layer.borderWidth = 1.0;
    locText.layer.borderWidth = 1.0;
    timeDurationBtn.layer.borderWidth = 1.0;
    timeZoneBtn.layer.borderWidth = 1.0;
    
    timeDurationBtn.delegate = self;
    timeDurationBtn.values = [NSArray arrayWithObjects:@"1",@"2",@"3", nil];
    timeDurationBtn.ownerView = self.view;
    
//    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"skip_schedule_welcome_screen"])
//    {
//        ScheduleWelcomeVC* vc = [[ScheduleWelcomeVC alloc] initWithNibName:@"ScheduleWelcomeVC" bundle:nil];
//        vc.parentVC = self;
//        vc.modalPresentationStyle = UIModalPresentationFormSheet;
//        [self presentViewController:vc animated:NO completion:^{
//            
//        }];
//    }
    
    
    firstTxt.leftView = [self leftViewWithImage:@"username_placehoder.png"];
    [firstTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    lastTxt.leftView = [self leftViewWithImage:@"username_placehoder.png"];
    [lastTxt setLeftViewMode:UITextFieldViewModeAlways];
    
    emailTxt.leftView = [self leftViewWithImage:@"email_placeholder.png"];
    [emailTxt setLeftViewMode:UITextFieldViewModeAlways];
//
//    titleText.leftView = [self leftViewWithImage:@"password_placeholder.png"];
//    [titleText setLeftViewMode:UITextFieldViewModeAlways];
//    
//    descText.leftView = [self leftViewWithImage:@"password_placeholder.png"];
//    [descText setLeftViewMode:UITextFieldViewModeAlways];
    
    
    //NSString* timeZone = [[NSTimeZone systemTimeZone] name];
    //[timeZoneBtn setTitle:timeZone forState:UIControlStateSelected];
    //timeZoneBtn.selected = YES;
    
    firstTxt.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"MeetingFirstName"];
    lastTxt.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"MeetingLastName"];
    emailTxt.text =[[NSUserDefaults standardUserDefaults] objectForKey:@"MeetingEmail"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"MeetingTimeZone"])
    {
        [timeZoneBtn setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"MeetingTimeZone"] forState:UIControlStateSelected];
        timeZoneBtn.selected = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _selectedUsers = [[NSMutableArray alloc] init];
    
//    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"skip_schedule_welcome_screen"])
//    {
//        ScheduleWelcomeVC* vc = [[ScheduleWelcomeVC alloc] initWithNibName:@"ScheduleWelcomeVC" bundle:nil];
//        [self presentViewController:vc animated:NO completion:nil];
//    }
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

-(IBAction)pickDateAction:(id)sender
{
    if(sender == nil)
    {
        if([firstTxt isFirstResponder])
            [firstTxt resignFirstResponder];
        else if([lastTxt isFirstResponder])
            [lastTxt resignFirstResponder];
        else if([emailTxt isFirstResponder])
            [emailTxt resignFirstResponder];
        else if([titleText isFirstResponder])
            [titleText resignFirstResponder];
        else if([descText isFirstResponder])
            [descText resignFirstResponder];
        else if([locText isFirstResponder])
            [locText resignFirstResponder];
    }
    NSString* first = [firstTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* last = [lastTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* email = [emailTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* title = [titleText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* desc = [descText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
     NSString* loc = [locText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString* msg = @"";
    if(!NSSTRING_HAS_DATA(title))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter Meeting title"];
    }
    if(!NSSTRING_HAS_DATA(first))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter First name"];
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
//    if([_selectedUsers count] == 0)
//    {
//        if(NSSTRING_HAS_DATA(msg))
//        {
//            msg = [msg stringByAppendingString:@"\n"];
//        }
//        msg = [msg stringByAppendingString:@"Enter invitee"];
//    }

    NSString* timeDuration = [timeDurationBtn titleForState:UIControlStateSelected];
    if([desc length] == 0)
        desc = @"";
    if([timeDuration length] == 0)
        timeDuration = @"1";
    
    if(NSSTRING_HAS_DATA(msg))
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else{
        NSString* timeZone = timeZoneBtn.selected?[timeZoneBtn titleForState:UIControlStateSelected]:@"";
        NSDictionary* CreatorDetails = [NSDictionary dictionaryWithObjectsAndKeys:email,@"Email",first,@"FirstName",last,@"LastName",timeZone,@"TimeZone", nil];
        [EventDocument sharedInstance].currentMeetingInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:CreatorDetails,@"CreatorDetails",title, @"Title",desc, @"Description",loc,@"Location",[NSNumber numberWithInteger:[timeDuration intValue]], @"Duration",[NSNumber numberWithInteger:0],@"ParentId", nil];
        
        ScheduleDatePickerVC* vc = [[ScheduleDatePickerVC alloc] initWithNibName:@"ScheduleDatePickerVC" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
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
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Error" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (IBAction)timeDurationAction:(id)sender
{
    [self.view endEditing:YES];
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

-(void)cancelAction
{
    [self.view endEditing:YES];
    [self cleanAllAttachments];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

-(void)cleanAllAttachments{
    
    for (UIImageView* attachment in attachmentScrollView.subviews)
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

- (IBAction)inviteAction:(id)sender
{
    [self.view endEditing:YES];
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

- (void)assigneeSelected:(NSMutableArray*)invitees
{
    _selectedUsers = invitees;
    NSMutableArray* array = [NSMutableArray array];
    for(User* user in _selectedUsers)
    {
        if(user.FormattedName)
            [array addObject:user.FormattedName];
        else
            [array addObject:user.Email];
    }
    if(array.count)
    {
        inviteBtn.selected = YES;
        [inviteBtn setTitle:[array componentsJoinedByString:@","] forState:UIControlStateSelected];
    }
}


- (void)dismissAlert:(UIAlertView*)av
{
    if(av.visible)
        [av dismissWithClickedButtonIndex:-1 animated:YES];
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
    {
       [self timeZoneAction:nil];
    }
    return YES;
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
            else
            {
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
            else
            {
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
             
             for (UIImageView* attachment in attachmentScrollView.subviews) {
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
             [attachmentScrollView addSubview:attachmentImage];
             [attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
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

- (void)dropdownControlDidCancel:(DropDownControl *)dtControl
{
    if (dropDownActionSheet) {
        [dropDownActionSheet slideOut];
    }
}

-(void)showDropDownOptions:(DropDownControl *)dropdown values:(NSArray *)values
{
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
    [EventDocument sharedInstance].selectedMeetingInterval = [value integerValue];
}


- (NSString*)validate
{
    NSString* first = [firstTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* last = [lastTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* email = [emailTxt.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* timeZone = timeZoneBtn.selected?[timeZoneBtn titleForState:UIControlStateSelected]:@"";
    NSString* msg = @"";

    if(!NSSTRING_HAS_DATA(first))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Enter First name"];
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
    if(!NSSTRING_HAS_DATA(timeZone))
    {
        if(NSSTRING_HAS_DATA(msg))
        {
            msg = [msg stringByAppendingString:@"\n"];
        }
        msg = [msg stringByAppendingString:@"Select Time Zone"];
    }
    
    if(NSSTRING_HAS_DATA(msg))
    {
        return msg;
    }
    [[NSUserDefaults standardUserDefaults] setObject:first forKey:@"MeetingFirstName"];
    [[NSUserDefaults standardUserDefaults] setObject:last forKey:@"MeetingLastName"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"MeetingEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:timeZone forKey:@"MeetingTimeZone"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary* CreatorDetails = [NSDictionary dictionaryWithObjectsAndKeys:email,@"Email",first,@"FirstName",last,@"LastName",timeZone,@"TimeZone", nil];
    
    [[EventDocument sharedInstance].currentMeetingInfo setObject:CreatorDetails forKey:@"CreatorDetails"];
        
    return nil;
}
@end
