//
//  MeetingCommentVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "MeetingCommentVC.h"
#import "EventDocument.h"
#import "CommentCell.h"
#import "Comment.h"
#import "WYPopoverController.h"
#import "UserListVC.h"
#import "MeetingDetailVC.h"
#import "HPGrowingTextView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Additions.h"
#import "GSAsynImageView.h"
#import "SpeechToTextModule.h"


#define CREATECOMMENT_ATTACHMENTS  [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Createcommentattachment"]
@interface MeetingCommentVC ()
{
    IBOutlet UILabel* taskName;
    IBOutlet UILabel* taskDetail;
    IBOutlet UILabel* taskDescription;
    IBOutlet UITableView* tableView;
    IBOutlet UILabel* noCommentLabel;
    IBOutlet UIButton* userListBtn;
    IBOutlet UIScrollView* attachmentsContainer;
    IBOutlet GSAsynImageView* creatorImage;
    IBOutlet UIButton* previousBtn;
    
    WYPopoverController* userListPopOver;
    HPGrowingTextView *textView;
    UIView *containerView;
    NSString* _tempFolderPath;
    UIButton *postBtn;
    UIActivityIndicatorView* speakActivity;
    
    NSMutableArray* _taskComments;
}
@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;
- (IBAction)openTaskDetail:(id)sender;
- (IBAction)openUserList:(id)sender;
@end

@implementation MeetingCommentVC

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
    
    _taskComments = [[NSMutableArray alloc] initWithArray:self.meeting.MeetingComments];
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechToTextObj setDelegate:self];
    
    NSString* nibName = @"CommentCell";
    [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:nibName];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tag = 1001;
    //[tableView addSubview:refreshControl];
    //[refreshControl beginRefreshing];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTaskCommentCallBack:) name:@"GetTaskCommentNotifier" object:nil];
    
    //[[TaskDocument sharedInstance] refreshTaskCommentsForId:self.meeting.MeetingId];
    
    // Do any additional setup after loading the view from its nib.
    taskName.text = self.meeting.Title;
  

    taskDetail.text = [[self.meeting.CreatedOnTimeString componentsSeparatedByString:@"|"] firstObject];
    
    
    NSMutableAttributedString* attrs = [[NSMutableAttributedString alloc] initWithData:[self.meeting.Description dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}documentAttributes:nil error:nil];
    NSMutableDictionary* tmp= [NSMutableDictionary dictionary];
    [attrs enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, [attrs length]) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        UIFont *font = (UIFont*)value;
        [tmp setObject:[font fontDescriptor] forKey:NSStringFromRange(range)];
    }];
    
    for(NSString* r in [tmp allKeys])
    {
        NSRange range = NSRangeFromString(r);
        UIFontDescriptor* des = [tmp objectForKey:r];
        NSString* fontface = [des objectForKey:UIFontDescriptorFaceAttribute];
        des = [des fontDescriptorWithFamily:@"Helvetica"];
        des = [des fontDescriptorWithFace:fontface];
        UIFont* font = [UIFont fontWithDescriptor:des size:11.0];
        [attrs addAttribute:NSFontAttributeName value:font range:range];
    }
    taskDescription.attributedText = attrs;
    
    
    [creatorImage loadImageFromURL:self.meeting.CreatorDetails.MobileImageUrl];
    
    if (DEVICE_IS_TABLET) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidChangeFrame:)
                                                     name:UIKeyboardDidChangeFrameNotification
                                                   object:nil];
    }
    else{
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
	[self addPostView];
    [self cleanAllAttachments];
    if([_taskComments count] == [self.meeting.TotalComments intValue])
    {
        previousBtn.hidden = YES;
    }
    else
    {
        previousBtn.hidden = NO;
    }
    tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.composeComment)
    {
        [textView becomeFirstResponder];
    }
}

-(void)addPostView{

    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(40, 3, 240, 22)];
    //[[textView layer] setBorderColor:[UIColor grayColor].CGColor];
    //[[textView layer] setBorderWidth:1.0f];
    //[[textView layer] setCornerRadius:3.0f];
    //[[textView layer] setMasksToBounds:YES];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 5;
    
	textView.returnKeyType = UIReturnKeyDefault; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Type your comment here...";
    
    UIImageView* placeholder = [[UIImageView alloc] initWithFrame:CGRectMake(40, 29, 240, 10)];
    [placeholder setContentMode:UIViewContentModeRedraw];
    [placeholder setImage:[[UIImage imageNamed:@"blue_placeholder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
    [placeholder setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    
    [self.view addSubview:containerView];
	
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    //[containerView addSubview:imageView];
    
    [containerView addSubview:textView];
    [containerView addSubview:placeholder];
    
    UIButton* attachmentbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    attachmentbutton.frame = CGRectMake(0, 8, 40, 27);
    attachmentbutton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
	[attachmentbutton setImage:[UIImage imageNamed:@"iconAttachment.png"] forState:UIControlStateNormal];
    [attachmentbutton addTarget:self action:@selector(addAttachmentAction:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:attachmentbutton];
    
	postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	postBtn.frame = CGRectMake(containerView.frame.size.width - 40, 8, 40, 27);
    postBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[postBtn setImage:[UIImage imageNamed:@"icon_Speak.png"] forState:UIControlStateNormal];
    [postBtn setImage:[UIImage imageNamed:@"post_arrow.png"] forState:UIControlStateSelected];
    
    [postBtn setTitleColor:[UIColor colorWithRed:0.0 green:122/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
	[postBtn addTarget:self action:@selector(postAction:) forControlEvents:UIControlEventTouchUpInside];
	[containerView addSubview:postBtn];
    
    speakActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [speakActivity setFrame:postBtn.frame];
    [speakActivity setHidesWhenStopped:YES];
    speakActivity.hidden = YES;
    [containerView addSubview:speakActivity];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [containerView setBackgroundColor:[UIColor whiteColor]];

}


#pragma mark - SpeechToTextModule Delegate -
- (BOOL)didReceiveVoiceResponse:(NSData *)data
{
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

                    textView.text = [textView.text stringByAppendingString:text];
                    
                }
            }
        }
    }
    [textView.internalTextView setInputView:nil];
    [speakActivity stopAnimating];
    postBtn.hidden = NO;
    postBtn.userInteractionEnabled = YES;
    postBtn.selected = YES;
    return YES;
}

- (void)showSineWaveView:(SineWaveViewController *)view
{
    [textView.internalTextView setInputView:view.view];
    [textView becomeFirstResponder];
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    [textView resignFirstResponder];
    [textView.internalTextView setInputView:nil];
    [speakActivity stopAnimating];
    postBtn.hidden = NO;
    postBtn.userInteractionEnabled = YES;
    postBtn.selected = YES;
}


- (void)showLoadingView
{
    postBtn.hidden = YES;
    speakActivity.hidden = NO;
    [speakActivity startAnimating];
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}


-(void)addAttachmentAction:(UIButton*)sender{
    [self resignTextView];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album",@"Take Photo",@"Video", nil];
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

-(void)postAction:(UIButton*)btn
{
    if(!postBtn.selected)
    {
        postBtn.userInteractionEnabled = NO;
        [self.speechToTextObj beginRecording];
        return;
    }
    NSString* textString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (NSSTRING_HAS_DATA(textString))
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CREATECOMMENT_ATTACHMENTS error:NULL];
        if(files && files.count > 0)
        {
            [self uploadFiles];
        }
        else
        {
            [self uploadComment];
        }
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please type a comment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)uploadFiles
{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CREATECOMMENT_ATTACHMENTS error:NULL];
    NSMutableArray* tmp = [NSMutableArray array];
    for(NSString* file in files)
    {
        [tmp addObject:[CREATECOMMENT_ATTACHMENTS stringByAppendingPathComponent:file]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadCommentAttachmentCalllBack:) name:@"UploadAttachmentNotifier" object:nil];
    [[EventDocument sharedInstance] uploadAttachments:tmp];
}

- (void)uploadComment
{
    NSString* textString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[User currentUser].UserId], @"LogInUserId",self.meeting.MeetingId,@"MeetingId",[textString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"],@"Comment", nil];
    
    if(NSSTRING_HAS_DATA(_tempFolderPath))
    {
        [jsonDictionary setObject:_tempFolderPath forKey:@"tempFolderName"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommentCallBack:) name:@"PostCommentNotifier" object:nil];
    [[EventDocument sharedInstance] postComment:[NSDictionary dictionaryWithObject:jsonDictionary forKey:@"msgIn"]];
}

- (void)postCommentCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(postComment:) withObject:[note object] waitUntilDone:NO];
}

- (void)postComment:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[Comment class]] || [sender isKindOfClass:[NSNumber class]])
    {
        Comment* cmnt = nil;
        if([sender isKindOfClass:[NSNumber class]])
        {
            cmnt = [Comment new];
            cmnt.comment = textView.text;
            cmnt.commenter = [User currentUser];
            NSDateFormatter* df = [NSDateFormatter new];
            [df setDateFormat:@"EEE, MMM d 'at' h:mm a"];
            cmnt.createdDate = [df stringFromDate:[NSDate date]];
        }
        else
        {
            cmnt = (Comment*)sender;
            if(!cmnt.createdDate)
            {
                NSDateFormatter* df = [NSDateFormatter new];
                [df setDateFormat:@"EEE, MMM d 'at' h:mm a"];
                cmnt.createdDate = [df stringFromDate:[NSDate date]];
            }
            cmnt.commenter = [User currentUser];
        }
        [self.meeting.MeetingComments addObject:cmnt];
        [_taskComments addObject:cmnt];
        self.meeting.TotalComments = [NSNumber numberWithInt:[self.meeting.TotalComments intValue]+1];
        [self resetAllData];
        
        [tableView beginUpdates];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        if([_taskComments count]==0)
        {
            [tableView reloadData];
            [tableView setTableHeaderView:noCommentLabel];
        }
        else
        {
            [tableView setTableHeaderView:nil];
        }
        if([_taskComments count] ==[self.meeting.TotalComments intValue])
        {
            previousBtn.hidden = YES;
        }
        else
        {
            previousBtn.hidden = NO;
        }
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)uploadCommentAttachmentCalllBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(uploadAttachmentSuccess:) withObject:[note object] waitUntilDone:NO];
    
}

-(void)uploadAttachmentSuccess:(NSDictionary*)sender
{
    if ([sender isKindOfClass:[NSDictionary class]])
    {
        _tempFolderPath = [(NSDictionary*)sender objectForKey:@"TempFolderName"];
        [self uploadComment];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)refresh
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ;
    [[EventDocument sharedInstance] refreshMyMeetings];
}

-(void)resetAllData
{
    //[self refresh];
    [attachmentsContainer removeFromSuperview];
    CGRect containerFrame = containerView.frame;
    [self resignTextView];
    containerFrame.origin.y = self.view.frame.size.height - containerFrame.size.height;
    containerView.frame = containerFrame;
    textView.text = nil;
    postBtn.selected = NO;
    
    [self cleanAllAttachments];
}

-(void)cleanAllAttachments{
    
    for (UIImageView* attachment in attachmentsContainer.subviews) {
        
        [attachment removeFromSuperview];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CREATECOMMENT_ATTACHMENTS]) {
        [[NSFileManager defaultManager] removeItemAtPath:CREATECOMMENT_ATTACHMENTS error:nil];
    }
    
}

-(void)resignTextView
{
	[textView resignFirstResponder];
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
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            
            
        }
            break;
            
        case 1:{
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
                
            }
            else{
                [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            // objc_setAssociatedObject(picker, "injurybtn", sender, OBJC_ASSOCIATION_ASSIGN);
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            
        }
            break;
            
        case 2:{
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
                
            }
            else{
                [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            // objc_setAssociatedObject(picker, "injurybtn", sender, OBJC_ASSOCIATION_ASSIGN);
            [self presentViewController:picker animated:YES completion:^{
                
            }];
            
            
        }
            break;
        case 3:{
            
            
            
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    if (![self.view.subviews containsObject:attachmentsContainer]) {
        CGRect attachmentContainerFrame = attachmentsContainer.frame;
        attachmentContainerFrame.origin.y = self.view.frame.size.height - attachmentsContainer.frame.size.height;
        attachmentsContainer.frame = attachmentContainerFrame;
        
        [self.view addSubview:attachmentsContainer];
        
        CGRect containerViewFrame = containerView.frame;
        containerViewFrame.origin.y = self.view.frame.size.height - containerViewFrame.size.height- attachmentsContainer.frame.size.height;
        containerView.frame = containerViewFrame;
        
    }
    
    UIImage *image = nil;
    NSData* data = nil;
    NSString* path = CREATECOMMENT_ATTACHMENTS;
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //  dlog(@"info dict description = %@",[info description]);
    if ([type isEqualToString:(NSString *)kUTTypeMovie] ||
        [type isEqualToString:(NSString *)kUTTypeVideo]) { // movie != video
        
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        data = [NSData dataWithContentsOfURL:url];
        
        path = [CREATECOMMENT_ATTACHMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",uuidString]];
        
        image = [UIImage thumbnailFromVideoAtURL:url];
        
        
    }
    else{
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        path = [CREATECOMMENT_ATTACHMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uuidString]];
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
    UIImageView* attachmentImage = [[UIImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
    [attachmentImage setImage:image];
    [attachmentsContainer addSubview:attachmentImage];
    [attachmentsContainer setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
    [[attachmentImage layer] setCornerRadius:3.0f];
    [[attachmentImage layer] setBorderWidth:1.0f];
    [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[attachmentImage layer] setMasksToBounds:YES];
    [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
    if (![[NSFileManager defaultManager] fileExistsAtPath:CREATECOMMENT_ATTACHMENTS]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:CREATECOMMENT_ATTACHMENTS withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [data writeToFile:path atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}




- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGRect keyboardBounds = [self.view convertRect:keyboardEndFrame fromView:nil];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect containerFrame = containerView.frame;

    
    if (CGRectIntersectsRect(keyboardBounds, self.view.frame)) {
        // Keyboard is visible
                if ([self.view.subviews containsObject:attachmentsContainer]) {
            
            containerFrame.origin.y = keyboardBounds.origin.y - containerFrame.size.height - attachmentsContainer.frame.size.height;
            
            CGRect attachmentsContainerframe = attachmentsContainer.frame;
            attachmentsContainerframe.origin.y = containerFrame.origin.y+containerFrame.size.height;
            attachmentsContainer.frame = attachmentsContainerframe;
        }
        else{
            containerFrame.origin.y = keyboardBounds.origin.y - containerFrame.size.height;
        }
		
        
        
        


    } else {
        // Keyboard is hidden
        if ([self.view.subviews containsObject:attachmentsContainer]) {
            
            containerFrame.origin.y = keyboardBounds.origin.y - containerFrame.size.height-attachmentsContainer.frame.size.height;
            
            CGRect attachmentsContainerframe = attachmentsContainer.frame;
            attachmentsContainerframe.origin.y = containerFrame.origin.y+containerFrame.size.height;
            attachmentsContainer.frame = attachmentsContainerframe;
            
            
        }
        else{
            containerFrame.origin.y = keyboardBounds.origin.y - containerFrame.size.height;
        }

    }
    // set views with new info
    containerView.frame = containerFrame;
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
    // animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];

	CGRect containerFrame = containerView.frame;
    if ([self.view.subviews containsObject:attachmentsContainer]) {
    
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height + attachmentsContainer.frame.size.height);
        
        CGRect attachmentsContainerframe = attachmentsContainer.frame;
        attachmentsContainerframe.origin.y = containerFrame.origin.y+containerFrame.size.height;
        attachmentsContainer.frame = attachmentsContainerframe;
    }
    else{
        containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    }
		
	// set views with new info
	containerView.frame = containerFrame;
    
	
	// commit animations
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	
	// get a rect for the textView frame
    // animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	CGRect containerFrame = containerView.frame;
    

    if ([self.view.subviews containsObject:attachmentsContainer]) {
    
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height-attachmentsContainer.frame.size.height;
        
        CGRect attachmentsContainerframe = attachmentsContainer.frame;
        attachmentsContainerframe.origin.y = containerFrame.origin.y+containerFrame.size.height;
        attachmentsContainer.frame = attachmentsContainerframe;

        
    }
    else{
        containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    }
    
    
	
	
    
	// set views with new info
	containerView.frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextVie
{
    postBtn.selected = YES;
    return YES;
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView
{
    if(!NSSTRING_HAS_DATA( growingTextView.text))
        postBtn.selected = NO;
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh:(UIRefreshControl*)control
{
    [control beginRefreshing];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ;
    [[EventDocument sharedInstance] refreshMyMeetings];
}

- (void)getTaskCommentCallBack:(NSNotification*)note
{
    [self performSelectorOnMainThread:@selector(reloadView:) withObject:[note object] waitUntilDone:NO];
}

- (void)reloadView:(NSArray*)obj
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIRefreshControl* cnt = (UIRefreshControl*)[tableView viewWithTag:1001];
    [cnt endRefreshing];
    [_taskComments removeAllObjects];
    [_taskComments addObjectsFromArray:self.meeting.MeetingComments];
    if(obj && [obj isKindOfClass:[NSArray class]] && obj.count)
    {
        [tableView reloadData];
    }
    
    if([_taskComments count]==0)
    {
        [tableView reloadData];
        [tableView setTableHeaderView:noCommentLabel];
    }
    else
    {
        [tableView setTableHeaderView:nil];
    }
    if([_taskComments count] ==[self.meeting.TotalComments intValue])
    {
        previousBtn.hidden = YES;
    }
    else
    {
        previousBtn.hidden = NO;
    }
}


- (IBAction)openTaskDetail:(id)sender
{
    MeetingDetailVC* vc = [[MeetingDetailVC alloc] initWithNibName:@"MeetingDetailVC" bundle:nil];
    [vc setMeeting:self.meeting];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)openUserList:(id)sender
{
    NSArray* arr = self.meeting.ParticipantsList;
    UserListVC* vc = [[UserListVC alloc] initWithNibName:@"UserListVC" bundle:nil];
    vc.userList = arr;
    CGRect rect = userListBtn.frame;
    if([[[UIDevice currentDevice]systemVersion] floatValue]>= 7.0)
        rect.origin.y += 60;
    if(DEVICE_IS_TABLET)
    {
        userListPopOver = [[UIPopoverController alloc] initWithContentViewController:vc];
        [userListPopOver setPopoverContentSize:CGSizeMake(280, MIN(([UIScreen mainScreen].bounds.size.height - 200), arr.count*32))];
        userListPopOver.delegate = self;
        [userListPopOver presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        userListPopOver = [[WYPopoverController alloc] initWithContentViewController:vc];
        [userListPopOver setPopoverContentSize:CGSizeMake(280, MIN(([UIScreen mainScreen].bounds.size.height - 200), arr.count*32))];
        [userListPopOver setDelegate:self];
    
        [userListPopOver presentPopoverFromRect:rect inView:self.navigationController.view permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
    }

}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)popoverController
{
    userListPopOver = nil;
    return YES;
}

-(void)showFullComment:(CommentCell*)cell{

    NSIndexPath* indexpath = [tableView indexPathForCell:cell];
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];

}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_taskComments count];
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return the number of rows in the section.
    CGFloat rowHeight = 0;
    
    Comment* comment = [_taskComments objectAtIndex:indexPath.row];
    float w;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
    {
        w = CGRectGetHeight([UIScreen mainScreen].bounds) - 60;
    }
    else
    {
        w = CGRectGetWidth([UIScreen mainScreen].bounds) - 60;
    }
    rowHeight += [comment cellHeightForWidth:w];
    return MAX(60.0,rowHeight);
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* nibName = @"CommentCell";
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:nibName forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nibName];
        cell.comment.numberOfLines = 0;
    }
    cell.showReadMore = YES;
    Comment* commment = [_taskComments objectAtIndex:indexPath.row];
    float w;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(application.statusBarOrientation))
    {
        w = CGRectGetHeight([UIScreen mainScreen].bounds) - 60;
    }
    else
    {
        w = CGRectGetWidth([UIScreen mainScreen].bounds) - 60;
    }
    [cell fillDataWithComment:commment forWidth:w];
    cell.readMoreTarget = self;
    cell.readMoreAction = @selector(showFullComment:);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteComment:)];
    [longPress setNumberOfTouchesRequired:1];
    [longPress setMinimumPressDuration:0.5];
    [cell.contentView addGestureRecognizer:longPress];
    objc_setAssociatedObject(longPress, "Comment", cell, OBJC_ASSOCIATION_ASSIGN);
    return cell;
}

- (void)deleteComment:(UILongPressGestureRecognizer*)recong
{
    if(recong.state == UIGestureRecognizerStateBegan)
    {
        CommentCell* cell = objc_getAssociatedObject(recong, "Comment");
        Comment* comment = cell.commentObj;
        if (comment.IsDeleted)
        {
            [self.view makeToast:@"This comment is already deleted."];
            
        }
        else if (!(comment.CanDelete || comment.commenter.UserId == [User currentUser].UserId))
        {
            [self.view makeToast:@"You can't delete this comment."];
            
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to delete this comment?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert show];
            objc_setAssociatedObject(alert, "AlertComment", comment, OBJC_ASSOCIATION_RETAIN);
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        ;
        Comment* comment = objc_getAssociatedObject(alertView, "AlertComment");
        objc_removeAssociatedObjects(alertView);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCallBack:) name:@"DeleteCommentNotifier" object:nil];
        //[[TaskDocument sharedInstance] deleteComment:comment ofTaskId:self.meeting.MeetingId];
    }
}

- (void)deleteCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(deleteCommentReload:) withObject:[note object] waitUntilDone:NO];
}

-(void)deleteCommentReload:(id)object
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if(object && [object isKindOfClass:[NSString class]])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:object delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
      [self refresh];
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if([tableView numberOfSections])
    {
        [tableView beginUpdates];
        [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, ([tableView numberOfSections]-1))] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
    
}
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
