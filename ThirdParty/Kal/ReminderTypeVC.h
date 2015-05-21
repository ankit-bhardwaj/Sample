//
//  ReminderTypeVC.h
//  Kal
//
//  Created by Ashish Maheshwari on 10/30/14.
//
//

#import <UIKit/UIKit.h>

@interface ReminderTypeVC : UITableViewController

@property(nonatomic,strong)id target;

@property(nonatomic,assign)SEL action;

@property(nonatomic,retain)NSString* selectedType;

@property(nonatomic,retain)UIPopoverController* popOver;

@end
