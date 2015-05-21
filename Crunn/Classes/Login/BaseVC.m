//
//  BaseVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 8/28/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "BaseVC.h"

@interface BaseVC ()

@end

@implementation BaseVC

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
    // Do any additional setup after loading the view.
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if([[UIScreen mainScreen] bounds].size.height > 480)
            backgroundImg.image = [UIImage imageNamed:@"background-518h@2x.png"];
        else
            backgroundImg.image = [UIImage imageNamed:@"background.png"];
    }
    else if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        backgroundImg.image = [UIImage imageNamed:@"background-Portrait~ipad.png"];
    else
        backgroundImg.image = [UIImage imageNamed:@"background-Landscape~ipad.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if([[UIScreen mainScreen] bounds].size.height > 480)
            backgroundImg.image = [UIImage imageNamed:@"background-518h@2x.png"];
        else
            backgroundImg.image = [UIImage imageNamed:@"background.png"];
    }
    else if(UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
        backgroundImg.image = [UIImage imageNamed:@"background-Portrait~ipad.png"];
    else
        backgroundImg.image = [UIImage imageNamed:@"background-Landscape~ipad.png"];
}
@end
