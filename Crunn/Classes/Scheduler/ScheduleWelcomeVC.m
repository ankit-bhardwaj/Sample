//
//  ScheduleWelcomeVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 12/30/14.
//  Copyright (c) 2014 Ashish sharma. All rights reserved.
//

#import "ScheduleWelcomeVC.h"
#import "CreateMeetingVC.h"

@interface ScheduleWelcomeVC ()
{
    IBOutlet UISwitch* skipSwitch;
}
- (IBAction)backAction:(id)sender;
- (IBAction)continueAction:(id)sender;
@end

@implementation ScheduleWelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.parentVC.navigationController dismissViewControllerAnimated:NO completion:nil];
    }];
}
- (IBAction)continueAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:skipSwitch.on forKey:@"skip_schedule_welcome_screen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
