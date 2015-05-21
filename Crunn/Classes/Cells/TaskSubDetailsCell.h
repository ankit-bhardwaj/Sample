//
//  TaskSubDetailsCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/15/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskSubDetailsCell : UITableViewCell
@property (nonatomic, retain)IBOutlet UILabel* subDetailLabel;
@property(nonatomic, retain)IBOutlet UIView* priorityView;
@property(nonatomic, retain)IBOutlet UIView* visibleToView;
@property(nonatomic, retain)IBOutlet UILabel* priorityLabel;
@property(nonatomic, retain)IBOutlet UIImageView* priorityImage;
@property(nonatomic, retain)IBOutlet UILabel* statusLabel;
@property(nonatomic, retain)IBOutlet UILabel* visibletoLabel;
@property(nonatomic, retain)IBOutlet UIImageView* visibletoImage;
@property(nonatomic, retain)IBOutlet UIImageView* signalImage;
@property(nonatomic, retain)IBOutlet UIImageView* statusImage;
@property (nonatomic, retain) IBOutlet UIButton* readMore;
@property (nonatomic, retain) IBOutlet UIButton* reminderBtn;
@property(nonatomic, retain)IBOutlet UILabel* reminderLabel;

@property (nonatomic, assign) BOOL showReadMore;
@property(nonatomic,strong)id readMoreTarget;
@property(nonatomic,assign)SEL readMoreAction;

@property(nonatomic,strong)id reminderTarget;
@property(nonatomic,assign)SEL reminderAction;


-(IBAction)reminder:(UIButton*)sender;

@end

