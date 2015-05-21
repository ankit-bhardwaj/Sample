//
//  ShowAttachmentVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/16/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface ShowAttachmentVC : UIViewController{

    IBOutlet UIWebView* webview;

}
@property (nonatomic, retain)NSString* url;
@property (nonatomic, retain)Attachment* attachment;

@end
