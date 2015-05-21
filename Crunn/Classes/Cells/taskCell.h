//
//  taskCell.h
//  Crunn
//
//  Created by Ashish Maheshwari on 7/10/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface taskCell : UITableViewCell{

    
}
@property (nonatomic,retain) IBOutlet UIImageView* image;
@property (nonatomic,retain) IBOutlet UIView* container;
@property (nonatomic,retain) IBOutlet UILabel* title;
@property (nonatomic,retain) IBOutlet UILabel* name;
@property (nonatomic,retain) IBOutlet UIImageView* accessory;
@end
