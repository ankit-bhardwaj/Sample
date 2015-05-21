//
//  ComposeCommentCell.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "ComposeCommentCell.h"
#import "Comment.h"
#import "GSAsynImageView.h"
#import "AttachmentButton.h"
#import "GSAsynImageView.h"
#import "SpeechToTextModule.h"
#import "TaskDocument.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Additions.h"
#include <DBChooser/DBChooser.h>
#import "ShowAttachmentVC.h"
#import "ImageMapVC.h"

@implementation ComposeCommentCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [[self.v layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[self.v layer] setBorderWidth:1.0f];
    [[self.v layer] setCornerRadius:5.0f];
    self.commentTextView.internalTextView.backgroundColor = [UIColor clearColor];
    self.commentTextView.placeholder = @"Write your comment...";
    self.commentTextView.maxNumberOfLines = 2;
    self.commentTextView.minNumberOfLines = 0;
    self.commentTextView.delegate = self;
}

- (void)setupCell
{
    self.speakBtn.enabled = YES;
    
    for (UIImageView* attachment in self.attachmentScrollView.subviews)
    {
        [attachment removeFromSuperview];
    }
    for(NSString* path in self.task.tempCommentFilePaths)
    {
        int xoffset = 5;
        int yoffset = 5;
        
        for (UIImageView* attachment in self.attachmentScrollView.subviews) {
            CGRect rect = attachment.frame;
            if (rect.size.width == 54 && rect.size.height == 54) {
                
                xoffset += 5+rect.size.width;
            }
            
        }
        xoffset += 5;
        GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
        if([path hasPrefix:@"http://"] || [path hasPrefix:@"https://"])
        {
            [attachmentImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]]];
            attachmentImage.serverAttachmentPath = path;
        }
        else
        {
            NSString* pathExtension = [[path lastPathComponent] pathExtension];
            if(![pathExtension isEqualToString:@"mp4"])
                [attachmentImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:path]]];
            else
                [attachmentImage setImage:[UIImage thumbnailFromVideoAtURL:[NSURL fileURLWithPath:path]]];
            attachmentImage.localAttachmentPath = path;
        }
        [self.attachmentScrollView addSubview:attachmentImage];
        [self.attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
        [[attachmentImage layer] setCornerRadius:3.0f];
        [[attachmentImage layer] setBorderWidth:1.0f];
        [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [[attachmentImage layer] setMasksToBounds:YES];
        [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
        attachmentImage.target = self;
        attachmentImage.action = @selector(showAttachment:);
        
    }
    self.postBtn.hidden = !self.task.editingComment;
    self.attachBtn.hidden = !self.task.editingComment;
    self.cancelBtn.hidden = !self.task.editingComment;
    if(self.task.editingComment)
    {
        self.commentTextView.text = self.task.tempComment;
    }
    else
    {
        self.commentTextView.text = @"";
    }
}

-(void)showAttachment:(AttachmentButton*)sender
{
    if(!sender.localAttachmentPath)
    {
        ShowAttachmentVC* savc = [[ShowAttachmentVC alloc] initWithNibName:@"ShowAttachmentVC" bundle:nil];
        [savc setUrl:sender.serverAttachmentPath];
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
        [(UIViewController*)self.target presentViewController:navVC animated:YES completion:nil];
    }
    else
    {
        ImageMapVC* savc = [[ImageMapVC alloc] initWithNibName:@"ImageMapView" bundle:nil];
        savc.mapImageSrc = sender.localAttachmentPath;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
        [(UIViewController*)self.target presentViewController:navVC animated:YES completion:nil];
        
    }
}


- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if(!self.task.editingComment)
    {
        [TaskDocument sharedInstance].editingComment++;
        self.commentTextView.isScrollable = YES;
        self.task.editingComment = YES;
        if(self.target && [self.target respondsToSelector:self.action])
        {
            [self.target performSelector:self.action withObject:self];
        }
        return NO;
    }
    else
        return YES;
    
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    self.task.tempComment = growingTextView.text;
}



- (IBAction)postAction:(id)sender
{
    [self.commentTextView resignFirstResponder];
    NSString* textString = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (NSSTRING_HAS_DATA(textString))
    {
        [MBProgressHUD showHUDAddedTo:[(UIViewController*)self.target view].superview animated:YES];
        
        NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] error:NULL];
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
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] error:NULL];
    NSMutableArray* tmp = [NSMutableArray array];
    for(NSString* file in files)
    {
        [tmp addObject:[[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] stringByAppendingPathComponent:file]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadTaskAttachmentCalllBack:) name:@"UploadTaskAttachmentNotifier" object:nil];
    [[TaskDocument sharedInstance] uploadTaskAttachments:tmp];
}

- (void)uploadComment
{
    NSString* textString = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableDictionary* jsonDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[User currentUser].UserId], @"logInUserId",self.task.taskId,@"taskId",[textString stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"],@"commentDetails",SESSION_KEY,@"sessionId",[NSNumber numberWithBool:NO],@"isNudge", nil];
    
    if(NSSTRING_HAS_DATA(_tempFolderPath))
    {
        [jsonDictionary setObject:_tempFolderPath forKey:@"tempFolderName"];
    }
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"])
    {
        if(![LocationService isValidLocation])
        {
            [MBProgressHUD hideAllHUDsForView:[(UIViewController*)self.target view].superview animated:YES];
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
    if([self.task.tempCommentDBFilePaths count])
    {
        NSError *jsonError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.task.tempCommentDBFilePaths options:0 error:&jsonError];
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
    [MBProgressHUD hideAllHUDsForView:[(UIViewController*)self.target view].superview animated:YES];
    _tempFolderPath = nil;
    if ([sender isKindOfClass:[Comment class]])
    {
        Comment* cmnt = (Comment*)sender;
        if(self.task.comments.count > 2)
            [self.task.comments removeObjectAtIndex:0];
        if(!cmnt.comment)
        {
            [[TaskDocument sharedInstance] refreshHomeFeed];
            cmnt.comment = self.commentTextView.text;
            cmnt.commenter = [User currentUser];
            NSDateFormatter*df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEE, MMM d 'at' h:mm a"];
            cmnt.createdDate = [df stringFromDate:[NSDate date]];
        }
        [self.task.comments addObject:sender];
        self.task.totalComments = [NSNumber numberWithInt:[self.task.totalComments intValue]+1];
        [self resetAllData];
        if(self.postTarget && [self.postTarget respondsToSelector:self.postAction])
        {
            [self.postTarget performSelector:self.postAction withObject:self];
        }
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
        [MBProgressHUD hideAllHUDsForView:[(UIViewController*)self.target view].superview animated:YES];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:(NSString*)sender delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)resetAllData
{
    [self.commentTextView.internalTextView setInputView:nil];
    [self.commentTextView resignFirstResponder];
    self.commentTextView.text = nil;
    self.task.editingComment = NO;
    self.task.attachComment = NO;
    self.task.tempComment = @"";
    
    [self cleanAllAttachments];
    [self.task.tempCommentFilePaths removeAllObjects];
    [self.task.tempCommentDBFilePaths removeAllObjects];
    [TaskDocument sharedInstance].editingComment--;
}

-(void)cleanAllAttachments{
    
    for (UIImageView* attachment in self.attachmentScrollView.subviews)
    {
        [attachment removeFromSuperview];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] error:nil];
    }
    
}

- (IBAction)cancelAction:(id)sender
{
    [self resetAllData];
    if(self.cancelTarget && [self.cancelTarget respondsToSelector:self.cancelAction])
    {
        [self.cancelTarget performSelector:self.cancelAction withObject:self];
    }
}

- (IBAction)attachAction:(id)sender
{
    [self.commentTextView resignFirstResponder];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Album",@"Take Photo",@"Video",@"Dropbox", nil];
    [actionSheet showInView:[(UIViewController*)self.target view]];
}

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
                [(UIViewController*)self.target presentViewController:picker animated:YES completion:^{
                
                }];
            }
            
        }
            break;
            
        case 1:{
            
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [AuthorizationStatus isCameraAllowedWithMessage:YES])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
                [(UIViewController*)self.target presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            else if([AuthorizationStatus isPhotoAlbumAllowedWithMessage:YES]){
                [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [(UIViewController*)self.target presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            
            
        }
            break;
            
        case 2:{
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [AuthorizationStatus isCameraAllowedWithMessage:YES])
            {
                [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
                [picker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
                [(UIViewController*)self.target presentViewController:picker animated:YES completion:^{
                    
                }];
            }
            else if([AuthorizationStatus isPhotoAlbumAllowedWithMessage:YES]){
                [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [(UIViewController*)self.target presentViewController:picker animated:YES completion:^{
                    
                }];
            }
           
            
            
        }
            break;
        case 3:{
            [self performSelector:@selector(didDropboxPressChoose) withObject:nil afterDelay:0.2];
            
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)didDropboxPressChoose
{
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypePreview fromViewController:self.target
                                            completion:^(NSArray *results)
     {
         if ([results count]) {
             DBChooserResult* _result = results[0];
             int xoffset = 5;
             int yoffset = 5;
             
             for (UIImageView* attachment in _attachmentScrollView.subviews) {
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
             //[attachmentImage setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:thumbnailUrl]]];
             [_attachmentScrollView addSubview:attachmentImage];
             [_attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
             [[attachmentImage layer] setCornerRadius:3.0f];
             [[attachmentImage layer] setBorderWidth:1.0f];
             [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
             [[attachmentImage layer] setMasksToBounds:YES];
             [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
             attachmentImage.target = self;
             attachmentImage.action = @selector(showAttachment:);
             attachmentImage.serverAttachmentPath = [[_result link] absoluteString];
   
             [self.task.tempCommentDBFilePaths addObject:[NSDictionary dictionaryWithObjectsAndKeys:[thumbnailUrl absoluteString],@"thumbnailLink",[NSNumber numberWithLongLong:_result.size],@"bytes",_result.link.absoluteString,@"link",_result.name,@"name",_result.iconURL.absoluteString,@"icon", nil]];
             [self.task.tempCommentFilePaths addObject:[thumbnailUrl absoluteString]];
             self.task.attachComment = YES;
             if(self.target && [self.target respondsToSelector:self.action])
             {
                 [self.target performSelector:self.action withObject:self];
             }
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* path = [CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]];
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //  dlog(@"info dict description = %@",[info description]);
    if ([type isEqualToString:(NSString *)kUTTypeMovie] ||
        [type isEqualToString:(NSString *)kUTTypeVideo]) { // movie != video
        
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        data = [NSData dataWithContentsOfURL:url];
        
        path = [[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",uuidString]];
        
        image = [UIImage thumbnailFromVideoAtURL:url];
        
        
    }
    else{
        image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        path = [[CREATE_HOME_COMMENT_ATTACHMENTS stringByAppendingPathComponent:[self.task.taskId stringValue]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",uuidString]];
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
    
    for (UIImageView* attachment in self.attachmentScrollView.subviews) {
        CGRect rect = attachment.frame;
        if (rect.size.width == 54 && rect.size.height == 54) {
            
            xoffset += 5+rect.size.width;
        }
        
    }
    xoffset += 5;
    GSAsynImageView* attachmentImage = [[GSAsynImageView alloc] initWithFrame:CGRectMake(xoffset, yoffset, 54, 54)];
    [attachmentImage setImage:image];
    [self.attachmentScrollView addSubview:attachmentImage];
    [self.attachmentScrollView setContentSize:CGSizeMake(attachmentImage.frame.origin.x + attachmentImage.frame.size.width + 5, 0)];
    [[attachmentImage layer] setCornerRadius:3.0f];
    [[attachmentImage layer] setBorderWidth:1.0f];
    [[attachmentImage layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [[attachmentImage layer] setMasksToBounds:YES];
    [attachmentImage setContentMode:UIViewContentModeScaleAspectFit];
    attachmentImage.target = self;
    attachmentImage.action = @selector(showAttachment:);
    attachmentImage.localAttachmentPath = path;
    
    [self.task.tempCommentFilePaths addObject:path];
    [data writeToFile:path atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.task.attachComment = YES;
    if(self.target && [self.target respondsToSelector:self.action])
    {
        [self.target performSelector:self.action withObject:self];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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
                    self.commentTextView.text = [self.commentTextView.text stringByAppendingString:text];
                    
                }
            }
        }
    }
    [self.commentTextView resignFirstResponder];
    [self.commentTextView.internalTextView setInputView:nil];
    self.speakBtn.hidden = NO;
    self.speakBtn.enabled = YES;
    [speakActivity stopAnimating];
    [self.commentTextView becomeFirstResponder];
    return YES;
}

- (void)showSineWaveView:(SineWaveViewController *)view
{
    [self.commentTextView resignFirstResponder];
    [self.commentTextView.internalTextView setInputView:view.view];
    [self.commentTextView becomeFirstResponder];
}

- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled
{
    //[self.commentTextView resignFirstResponder];
    //[self.commentTextView.internalTextView setInputView:nil];
    self.speakBtn.hidden = NO;
    self.speakBtn.enabled = YES;
}


- (void)showLoadingView
{
    self.speakBtn.hidden = YES;
    speakActivity.hidden = NO;
    [speakActivity startAnimating];
}
- (void)requestFailedWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
}

@end
