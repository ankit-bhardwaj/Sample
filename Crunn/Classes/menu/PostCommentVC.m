//
//  PostCommentVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 10/1/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "PostCommentVC.h"
#import "HPGrowingTextView.h"
#import "GSAsynImageView.h"
#import "SpeechToTextModule.h"
#import "TaskDocument.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Additions.h"
#include <DBChooser/DBChooser.h>

#define CREATECOMMENT_ATTACHMENTS  [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Createcommentattachment"]


@interface PostCommentVC ()
{
    IBOutlet HPGrowingTextView* txtView;
    IBOutlet GSAsynImageView* imageView;
    IBOutlet UIButton* postBtn;
    IBOutlet UIButton* cancelBtn;
    IBOutlet UIButton* speakBtn;
    IBOutlet UIScrollView* attachmentScrollView;
    NSString* _tempFolderPath;
    IBOutlet UIActivityIndicatorView* speakActivity;
    NSMutableArray* _dpAttachments;
}
@property(nonatomic, strong)SpeechToTextModule *speechToTextObj;

-(IBAction)postAction:(id)sender;
-(IBAction)cancelAction:(id)sender;
-(IBAction)attachmentAction:(id)sender;
-(IBAction)speakAction:(id)sender;
@end

@implementation PostCommentVC

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

    [[txtView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[txtView layer] setBorderWidth:1.0f];
    [[txtView layer] setCornerRadius:5.0f];
    txtView.contentInset = UIEdgeInsetsMake(10, 15, 0, 0);
    
	txtView.minNumberOfLines = 4;
	txtView.maxNumberOfLines = 4;
    txtView.isScrollable = YES;
	txtView.returnKeyType = UIReturnKeyDefault; //just as an example
	txtView.font = [UIFont systemFontOfSize:15.0f];
	txtView.delegate = self;
    txtView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    txtView.backgroundColor = [UIColor whiteColor];

    txtView.placeholder = @"Write comment...";
    [txtView becomeFirstResponder];
    
    
    User* user = [User currentUser];
    [imageView loadImageFromURL:user.MobileImageUrl];
    
    self.speechToTextObj = [[SpeechToTextModule alloc] initWithCustomDisplay:@"SineWaveViewController"];
    [self.speechToTextObj setDelegate:self];
    
    [self cleanAllAttachments];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)postAction:(id)sender
{
    [self resignTextView];
    NSString* textString = [txtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (NSSTRING_HAS_DATA(textString))
    {
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Write comment." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTaskAttachmentCalllBack:) name:@"UploadTaskAttachmentNotifier" object:nil];
    [[TaskDocument sharedInstance] uploadTaskAttachments:tmp];
}

- (void)uploadComment
{
    NSString* textString = [txtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[User currentUser].UserId], @"logInUserId",self.task.taskId,@"taskId",[textString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"],@"commentDetails",SESSION_KEY,@"sessionId",[NSNumber numberWithBool:NO],@"isNudge", nil];
    
    if(NSSTRING_HAS_DATA(_tempFolderPath))
    {
        [jsonDictionary setObject:_tempFolderPath forKey:@"tempFolderName"];
    }
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
            [jsonDictionary setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.latitude] forKey:@"latitude"];
            [jsonDictionary setObject:[NSNumber numberWithDouble:[LocationService locationCoordinate].coordinate.longitude] forKey:@"longtitude"];
            [jsonDictionary setObject:[LocationService addressString] forKey:@"locationAddress"];
        }
    }
    if([_dpAttachments count])
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_dpAttachments options:0 error:&jsonError];
        [jsonDictionary setObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:@"dropBoxFiles"];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommentCallBack:) name:@"PostCommentNotifier" object:nil];
    [[TaskDocument sharedInstance] postComment:jsonDictionary];
}

- (void)postCommentCallBack:(NSNotification*)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[note name] object:nil];
    [self performSelectorOnMainThread:@selector(postComment:) withObject:[note object] waitUntilDone:NO];
}

- (void)postComment:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.view.superview animated:YES];
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[Comment class]])
    {
        [self.task.comments insertObject:sender atIndex:0];
        self.task.totalComments = [NSNumber numberWithInt:[self.task.totalComments intValue]+1];
        [self resetAllData];
        self.speechToTextObj.delegate = nil;
        [self.view removeFromSuperview];
        [TaskDocument sharedInstance].homeFeedTaskUpdateRequire = YES;
        [self.parentViewController viewWillAppear:NO];
        [self removeFromParentViewController];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)uploadTaskAttachmentCalllBack:(NSNotification*)note
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
        [MBProgressHUD hideAllHUDsForView:self.view.superview animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)refresh
{
    [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    ;
    [[TaskDocument sharedInstance] refreshTaskCommentsForId:self.task.taskId];
}

-(void)resetAllData
{
    [self resignTextView];
    txtView.text = nil;
    
    [self cleanAllAttachments];
}

-(void)cleanAllAttachments{
    
    for (UIImageView* attachment in attachmentScrollView.subviews) {
        
        [attachment removeFromSuperview];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:CREATECOMMENT_ATTACHMENTS]) {
        [[NSFileManager defaultManager] removeItemAtPath:CREATECOMMENT_ATTACHMENTS error:nil];
    }
    
}

-(void)resignTextView
{
	[txtView resignFirstResponder];
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
             UIImageView* attachmentImage = [[UIImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
             [attachmentImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailUrl]]];
             [attachmentScrollView addSubview:attachmentImage];
             [attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
             [[attachmentImage layer] setCornerRadius:3.0f];
             [[attachmentImage layer] setBorderWidth:1.0f];
             [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
             [[attachmentImage layer] setMasksToBounds:YES];
             [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
             
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
    
    for (UIImageView* attachment in attachmentScrollView.subviews) {
        CGRect rect = attachment.frame;
        if (rect.size.width == 54 && rect.size.height == 54) {
            
            xoffset += 5+rect.size.width;
        }
        
    }
    xoffset += 5;
    UIImageView* attachmentImage = [[UIImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
    [attachmentImage setImage:image];
    [attachmentScrollView addSubview:attachmentImage];
    [attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
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

-(IBAction)cancelAction:(id)sender
{
    self.speechToTextObj.delegate = nil;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}




-(IBAction)attachmentAction:(id)sender
{
    [self resignTextView];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album",@"Take Photo",@"Video",@"Dropbox", nil];
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

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextVie
{
    return YES;
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView
{
    return YES;
}

-(IBAction)speakAction:(id)sender
{
    speakBtn.enabled = NO;
    [self.speechToTextObj beginRecording];
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
                    
                    txtView.text = [txtView.text stringByAppendingString:text];
                    
                }
            }
        }
    }
    [txtView.internalTextView setInputView:nil];
    speakBtn.hidden = NO;
    speakBtn.enabled = YES;
    [speakActivity stopAnimating];
    return YES;
}

- (void)showSineWaveView:(SineWaveViewController *)view
{
    [txtView.internalTextView setInputView:view.view];
    [txtView becomeFirstResponder];
}
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    speakBtn.hidden = NO;
    speakBtn.enabled = YES;
    //[txtView resignFirstResponder];
    [txtView.internalTextView setInputView:nil];
}


- (void)showLoadingView
{
    speakBtn.hidden = YES;
    speakActivity.hidden = NO;
    [speakActivity startAnimating];
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}

@end
