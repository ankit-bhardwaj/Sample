
#import "DropdownActionSheet.h"

@interface DropdownActionSheet ()
-(void) slideIn;
@end

@implementation DropdownActionSheet

@synthesize actionSheetView,dropdownControl,values;

- (void)viewWillAppear:(BOOL)animated {
	//slide in the filter view from the bottom
    
	[self slideIn];
    [super viewWillDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

-(void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(animateView) name:@"kAnimatePicker" object:nil];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [super viewDidLoad];
    
}
-(void)animateView

{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.33];
    [actionSheetView setFrame:CGRectMake(0, actionSheetView.frame.origin.y- 216, actionSheetView.frame.size.width, actionSheetView.frame.size.height)];
    [UIView commitAnimations];
}
-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)setupView
{
    if ([dropDownToolBar respondsToSelector:@selector(barTintColor)]) {
        dropDownToolBar.barTintColor = [UIColor
                                        colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
    }else
    {
        dropDownToolBar.tintColor = [UIColor
                                     colorWithRed:6.0/255.0 green:108.0/255.0 blue:173.0/255.0 alpha:1.0f];
    }
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:dropdownControl action:@selector(cancel:)];
    cancel.tintColor = [UIColor whiteColor];
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:dropdownControl action:@selector(done:)];
    UIBarButtonItem *flexi = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixed setWidth:10];
    
    done.tintColor = [UIColor whiteColor];
    dropDownToolBar.items = [NSArray arrayWithObjects:fixed,cancel,flexi,done,fixed, nil];
    //[cancel release];
    //[done release];
    //[flexi release];
    //[searchBarItem release];
    pickerView.backgroundColor = [UIColor clearColor];
    [pickerView setShowsSelectionIndicator:values.count > 0 ? YES : NO];
    pickerView.delegate = dropdownControl;
    pickerView.dataSource = dropdownControl;
    dropdownControl.picker = pickerView;
    [pickerView reloadAllComponents];
}

- (void)slideIn {
	//shouldAutoRotate = NO;
	//set initial location at bottom of view
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
    [self.view addSubview:self.actionSheetView];
	
    //animate to new location, determined by height of the view in the NIB
    [UIView beginAnimations:@"presentWithSuperview" context:nil];
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height - self.actionSheetView.bounds.size.height);
	
    self.actionSheetView.frame = frame;
    [UIView commitAnimations];
}

- (void) slideOut {
	//shouldAutoRotate = YES;
	//do what you need to do with information gathered from the custom action sheet. E.g., apply data filter on parent view.
	
	[UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
	
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
    // Move this view to bottom of superview
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
	
    [UIView commitAnimations]; 
}

// Method called when removeFromSuperviewWithAnimation's animation completes
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
    }
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}



#pragma mark -
#pragma mark search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.33];
    [actionSheetView setFrame:CGRectMake(0, actionSheetView.frame.origin.y- 216, actionSheetView.frame.size.width, actionSheetView.frame.size.height)];
    [UIView commitAnimations];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

@end
