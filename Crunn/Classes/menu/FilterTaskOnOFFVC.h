//
//  FilterTaskOnOFFVC.h
//  Crunn
//
//  Created by Ashish Maheshwari on 8/22/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterTaskOnOFFVC : UIViewController

@property(nonatomic,retain)id target;
@property(nonatomic,assign)SEL action;
@property(nonatomic,assign)BOOL filterOn;
@end
