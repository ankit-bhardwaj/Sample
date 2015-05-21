//
//  CenterViewController.h
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UIViewController{


    IBOutlet UITableView* tblView;
}
- (void)openPortfolioMenu:(id)note;
- (void)openProjectMenu:(id)note;
@end
