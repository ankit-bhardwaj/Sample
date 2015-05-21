//
//  ComposeCommentCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/14/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSAsynImageView.h"
#import "Comment.h"
#import "HPGrowingTextView.h"
#import "SpeechToTextModule.h"

@interface ComposeCommentCell : UITableViewCell
{
    NSString* _tempFolderPath;
    IBOutlet UIActivityIndicatorView* speakActivity;
}
@property (nonatomic, retain) IBOutlet GSAsynImageView* commenterImage;
@property (nonatomic, retain) IBOutlet HPGrowingTextView* commentTextView;
@property (nonatomic, retain) IBOutlet UIButton* speakBtn;
@property (nonatomic, retain) IBOutlet UIButton* postBtn;
@property (nonatomic, retain) IBOutlet UIButton* cancelBtn;
@property (nonatomic, retain) IBOutlet UIButton* attachBtn;
@property (nonatomic, retain) IBOutlet UIView* v;
@property (nonatomic, retain) IBOutlet UIScrollView* attachmentScrollView;

@property(nonatomic,strong)id target;
@property(nonatomic,assign)SEL action;
@property(nonatomic,strong)id cancelTarget;
@property(nonatomic,assign)SEL cancelAction;

@property(nonatomic,strong)id postTarget;
@property(nonatomic,assign)SEL postAction;

@property (nonatomic, retain) Task* task;

- (IBAction)speakAction:(id)sender;
- (IBAction)postAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)attachAction:(id)sender;

- (void)setupCell;
- (BOOL)didReceiveVoiceResponse:(NSData *)data;
- (void)showSineWaveView:(SineWaveViewController *)view;
- (void)dismissSineWaveView:(SineWaveViewController *)view cancelled:(BOOL)wasCancelled;
- (void)showLoadingView;
- (void)requestFailedWithError:(NSError *)error;
@end
