//
//  WelcomeVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 7/4/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "WelcomeVC.h"
#import "LoginVC.h"
#import "SignUpVC.h"
#import "Background.h"
#import "ScheduleMeetingStepOneVC.h"
#import "ScheduleNavigationVC.h"

@interface WelcomeVC ()
{
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIPageControl* pageControl;
    NSTimer* timer;
}
- (IBAction)loginAction:(id)sender;
- (IBAction)signupAction:(id)sender;
- (IBAction)pageControlAction:(UIPageControl*)sender;
- (IBAction)scheduleMeetingAction:(id)sender;

@end


@implementation WelcomeVC

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
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rect = scrollView.bounds;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if(rect.size.height < 345)
            rect.size.height -= 100;
        
        // Do any additional setup after loading the view from its nib.
        scrollView.contentSize = CGSizeMake(screenRect.size.width*4, rect.size.height);
    }
    else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||self.interfaceOrientation == UIInterfaceOrientationLandscapeRight )
    {
        // Do any additional setup after loading the view from its nib.
        scrollView.contentSize = CGSizeMake(screenRect.size.height*4, rect.size.height);
    }
    else
    {
        // Do any additional setup after loading the view from its nib.
        scrollView.contentSize = CGSizeMake(screenRect.size.width*4, rect.size.height);
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startSlide:) userInfo:nil repeats:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSUInteger)supportedInterfaceOrientations
//{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        return UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationLandscapeRight;
//    }
//    else
//    {
//        return UIInterfaceOrientationPortrait;
//    }
//}
//
//
////- (BOOL)shouldAutorotate
////{
////    return YES;
////}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    //Background* background = (Background*)self.view;
    //[background pauseMovie];
    
}

- (IBAction)loginAction:(id)sender
{
    LoginVC* vc = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)signupAction:(id)sender
{
    SignUpVC* vc = [[SignUpVC alloc] initWithNibName:@"SignUpVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)pageControlAction:(UIPageControl*)sender
{
    [scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width*pageControl.currentPage, 0, self.view.bounds.size.width, scrollView.frame.size.height) animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(startSlide:) userInfo:nil repeats:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [timer invalidate];
}


- (void)startSlide:(NSTimer*)timer
{
    int page = 0;
    if(pageControl.currentPage == (pageControl.numberOfPages-1))
        page = 0;
    else
        page = pageControl.currentPage+1;
     [scrollView scrollRectToVisible:CGRectMake(self.view.bounds.size.width*page, 0, self.view.bounds.size.width, scrollView.frame.size.height) animated:YES];
}

- (IBAction)scheduleMeetingAction:(id)sender
{
    ScheduleMeetingStepOneVC* vc = [[ScheduleMeetingStepOneVC alloc] initWithNibName:@"ScheduleMeetingStepOneVC" bundle:nil];
    ScheduleNavigationVC* navVC = [[ScheduleNavigationVC alloc] initWithRootViewController:vc];
    navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    //navVC.navigationBarHidden = YES;
    [self presentViewController:navVC animated:NO completion:^{
        
    }];
}

@end
