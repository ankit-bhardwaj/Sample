//
//  FilterTaskOnOFFVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 8/22/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "FilterTaskOnOFFVC.h"

@interface FilterTaskOnOFFVC (){
    IBOutlet UISwitch* filterSwitch;
    IBOutlet UIButton* dismissBtn;
}

@end

@implementation FilterTaskOnOFFVC

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
    filterSwitch.on = self.filterOn;
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)filterSwitchValueChanged:(UISwitch*)sender{

    if(self.target && [self.target respondsToSelector:self.action])
    {
        [self.target performSelector:self.action withObject:sender afterDelay:1.0f];
    }
}

-(IBAction)dismissPopOver:(UIButton*)sender{
    
    if(self.target && [self.target respondsToSelector:self.action])
    {
        [self.target performSelector:self.action withObject:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
