//
//  ScheduleNavigationVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 1/10/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleNavigationVC : UINavigationController

- (void)showFinalLink:(NSString*)link;
- (void)showLogin;
-(UIToolbar*)getToolBar;
@end
