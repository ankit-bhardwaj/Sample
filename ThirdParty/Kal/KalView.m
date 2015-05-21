/*
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"
#import "WYPopoverController.h"
#import "ReminderTypeVC.h"

@interface KalView ()

- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void)addSubviewsToContentView:(UIView *)contentView;
- (void)setHeaderTitleText:(NSString *)text;

@end

static const CGFloat kHeaderHeight = 68.f;
static const CGFloat kMonthLabelHeight = 17.f;

@implementation KalView
{
    UIPopoverController* reminderTypePopover;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic
{
    if ((self = [super initWithFrame:frame])) {
        self.delegate = theDelegate;
        logic = theLogic;
        [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = RGBCOLOR(246, 246, 246);
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, kHeaderHeight)];
        [self addSubviewsToHeaderView:headerView];
        [self addSubview:headerView];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, frame.size.width, frame.size.height - kHeaderHeight)];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubviewsToContentView:contentView];
        [self addSubview:contentView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic withModeType:(KalViewModeType)mode
{
    if ((self = [super initWithFrame:frame])) {
        self.delegate = theDelegate;
        logic = theLogic;
        [logic addObserver:self forKeyPath:@"selectedMonthNameAndYear" options:NSKeyValueObservingOptionNew context:NULL];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = RGBCOLOR(246, 246, 246);
        self.modeType = mode;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, kHeaderHeight)];
        [self addSubviewsToHeaderView:headerView];
        [self addSubview:headerView];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, kHeaderHeight, frame.size.width, frame.size.height - kHeaderHeight)];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubviewsToContentView:contentView];
        [self addSubview:contentView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    [NSException raise:@"Incomplete initializer" format:@"KalView must be initialized with a delegate and a KalLogic. Use the initWithFrame:delegate:logic: method."];
    return nil;
}

- (void)redrawEntireMonth { [self jumpToSelectedMonth]; }

- (void)slideDown { [self.gridView slideDown]; }
- (void)slideUp { [self.gridView slideUp]; }

- (void)removeDate:(NSDate*)date { [self.gridView includeDate:date]; }


- (void)showPreviousMonth
{
    if (!self.gridView.transitioning)
        [self.delegate showPreviousMonth];
}

- (void)showFollowingMonth
{
    if (!self.gridView.transitioning)
        [self.delegate showFollowingMonth];
}

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
    const CGFloat kChangeMonthButtonWidth = 46.0f;
    const CGFloat kChangeMonthButtonHeight = 30.0f;
    const CGFloat kMonthLabelWidth = 200.0f;
    const CGFloat kHeaderVerticalAdjust = 13.f;
    
    // Create the previous month button on the left side of the view
    CGRect previousMonthButtonFrame = CGRectMake(self.left,
                                                 kHeaderVerticalAdjust,
                                                 kChangeMonthButtonWidth,
                                                 kChangeMonthButtonHeight);
    UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
    [previousMonthButton setAccessibilityLabel:NSLocalizedString(@"Previous month", nil)];
    [previousMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"] forState:UIControlStateNormal];
    previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:previousMonthButton];
    
    // Draw the selected month name centered and at the top of the view
    CGRect monthLabelFrame = CGRectMake((self.width/2.0f) - (kMonthLabelWidth/2.0f),
                                        kHeaderVerticalAdjust,
                                        kMonthLabelWidth,
                                        kMonthLabelHeight);
    headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
    headerTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
    headerTitleLabel.textAlignment = UITextAlignmentCenter;
    headerTitleLabel.textColor = kDarkGrayColor;
    [self setHeaderTitleText:[logic selectedMonthNameAndYear]];
    [headerView addSubview:headerTitleLabel];
    
    // Create the next month button on the right side of the view
    CGRect nextMonthButtonFrame = CGRectMake(self.width - kChangeMonthButtonWidth,
                                             kHeaderVerticalAdjust,
                                             kChangeMonthButtonWidth,
                                             kChangeMonthButtonHeight);
    UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
    [nextMonthButton setAccessibilityLabel:NSLocalizedString(@"Next month", nil)];
    [nextMonthButton setImage:[UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"] forState:UIControlStateNormal];
    nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:nextMonthButton];
    
    // Add column labels for each weekday (adjusting based on the current locale's first weekday)
    NSArray *weekdayNames = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
    NSArray *fullWeekdayNames = [[[NSDateFormatter alloc] init] standaloneWeekdaySymbols];
    NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
    NSUInteger i = firstWeekday - 1;
    for (CGFloat xOffset = 0.f; xOffset < headerView.width; xOffset += 46.f, i = (i+1)%7) {
        CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, kHeaderHeight - 15.f);
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
        weekdayLabel.backgroundColor = [UIColor clearColor];
        weekdayLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        weekdayLabel.textAlignment = UITextAlignmentCenter;
        weekdayLabel.textColor = kGrayColor;
        weekdayLabel.text = [weekdayNames objectAtIndex:i];
        [weekdayLabel setAccessibilityLabel:[fullWeekdayNames objectAtIndex:i]];
        [headerView addSubview:weekdayLabel];
    }
}

- (void)addSubviewsToContentView:(UIView *)contentView
{
    // Both the tile grid and the list of events will automatically lay themselves
    // out to fit the # of weeks in the currently displayed month.
    // So the only part of the frame that we need to specify is the width.
    CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, 0.f);
    
    // The tile grid (the calendar body)
    self.gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic:logic delegate:self.delegate];
    [self.gridView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [contentView addSubview:self.gridView];
    
    // The list of events for the selected day
    self.tableView = [[UITableView alloc] initWithFrame:fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:self.tableView];
    if(self.modeType != KalViewModeTypeNone)self.tableView.hidden = YES;
    
    self.bottomView = [[UIView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
    self.bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview:self.bottomView];
    
    if(self.modeType == KalViewModeTypeDueDate)
    {
        self.hourlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        [self.hourlbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:60.0]];
        [self.hourlbl setTextColor:[UIColor grayColor]];
        [self.bottomView addSubview:self.hourlbl];
        self.hourlbl.autoresizingMask = UIViewAutoresizingNone;
        self.hourlbl.center = CGPointMake(self.bottomView.bounds.size.width/2.0 - 50, self.bottomView.bounds.size.height/2.0 + 60);
        [self.hourlbl setText:@"17"];
        
        
        upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [upBtn setImage:[UIImage imageNamed:@"cal_up_arrow.png"] forState:UIControlStateNormal];
        upBtn.autoresizingMask = UIViewAutoresizingNone;
        [upBtn addTarget:self action:@selector(timeUpAction:) forControlEvents:UIControlEventTouchDown];
        [upBtn setFrame:CGRectMake(0, 0, 24, 24)];
        upBtn.center = CGPointMake(self.bottomView.bounds.size.width/2.0, self.bottomView.bounds.size.height/2.0+46.0);
        [self.bottomView addSubview:upBtn];
        
        downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [downBtn setImage:[UIImage imageNamed:@"cal_down_arrow.png"] forState:UIControlStateNormal];
        downBtn.autoresizingMask = UIViewAutoresizingNone;
        [downBtn addTarget:self action:@selector(timeDownAction:) forControlEvents:UIControlEventTouchDown];
        [downBtn setFrame:CGRectMake(0, 0, 24, 24)];
        downBtn.center = CGPointMake(self.bottomView.bounds.size.width/2.0, self.bottomView.bounds.size.height/2.0+76.0);
        [self.bottomView addSubview:downBtn];
        
        self.minlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        [self.minlbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:60.0]];
        self.minlbl.autoresizingMask = UIViewAutoresizingNone;
        [self.minlbl setTextColor:[UIColor grayColor]];
        [self.bottomView addSubview:self.minlbl];
        self.minlbl.center = CGPointMake(self.bottomView.bounds.size.width/2.0 + 50, self.bottomView.bounds.size.height/2.0 + 60);
        [self.minlbl setText:@"00"];
    }
    else if(self.modeType == KalViewModeTypeReminder)
    {
        _reminderEverySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(10, 30, 40, 45)];
        self.reminderEverySwitch.autoresizingMask = UIViewAutoresizingNone;
        [self.bottomView addSubview:self.reminderEverySwitch];
        [self.reminderEverySwitch setOn:YES];
        
        
        UILabel* reminderLbl = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 140, 30)];
        [reminderLbl setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]];
        [reminderLbl setTextColor:[UIColor colorWithRed:29.0/255.0 green:153.0/255.0 blue:202.0/255.0 alpha:1.0]];
        [self.bottomView addSubview:reminderLbl];
        reminderLbl.autoresizingMask = UIViewAutoresizingNone;
        [reminderLbl setText:@"Remind every"];
        
        self.reminderType = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *bgImage = [UIImage imageNamed:@"dropdown.png"];
        //UIImage *strechablImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 0)];
        [self.reminderType setBackgroundImage:bgImage forState:UIControlStateNormal];
        self.reminderType.autoresizingMask = UIViewAutoresizingNone;
        [self.reminderType addTarget:self action:@selector(reminderSelectionAction:) forControlEvents:UIControlEventTouchDown];
        [self.reminderType setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentLeft)];
        [self.reminderType setContentEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
        [self.reminderType setFrame:CGRectMake(190, 20, 120, 50)];
        self.reminderType.titleLabel.textColor = [UIColor blackColor];
        [self.reminderType setTitle:@"week" forState:UIControlStateNormal];
        [self.reminderType setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.bottomView addSubview:self.reminderType];
        
    }
    
    // Trigger the initial KVO update to finish the contentView layout
    [self.gridView sizeToFit];
}


- (void)reminderSelectionAction:(UIButton*)sender
{
    ReminderTypeVC* vc = [[ReminderTypeVC alloc] init];
    vc.target = self;
    vc.action = @selector(reminderSelected:);
    vc.selectedType = self.reminderType.titleLabel.text;
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    if(([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad))
    {
        reminderTypePopover = [[UIPopoverController alloc] initWithContentViewController:navVC];
        vc.popOver = reminderTypePopover;
        [reminderTypePopover setPopoverContentSize:CGSizeMake(320, 320)];
        reminderTypePopover.delegate = self;
        [reminderTypePopover presentPopoverFromRect:sender.frame inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        reminderTypePopover = [[WYPopoverController alloc] initWithContentViewController:vc];
        vc.popOver = reminderTypePopover;
        [reminderTypePopover setPopoverContentSize:CGSizeMake(220, 360)];
        [reminderTypePopover setDelegate:self];
        CGRect rect = sender.frame;
        rect.origin.x -= 30;
        rect.origin.y -= 30;
        [reminderTypePopover presentPopoverFromRect:rect inView:sender permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    reminderTypePopover = nil;
    return YES;
}

/* Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    reminderTypePopover = nil;
}

- (void)reminderSelected:(NSString*)type
{
    [self.reminderType setTitle:type forState:UIControlStateNormal];
}

- (void)timeDownAction:(UIButton*)btn
{
    downBtn.enabled = YES;
    upBtn.enabled = YES;
    if([[self.hourlbl text] intValue] == 1)
        downBtn.enabled = NO;
    self.hourlbl.text = [NSString stringWithFormat:@"%02d",([[self.hourlbl text] intValue]-1)];
        
}

- (void)timeUpAction:(UIButton*)btn
{
    downBtn.enabled = YES;
    upBtn.enabled = YES;
    if([[self.hourlbl text] intValue] == 22)
        upBtn.enabled = NO;
    self.hourlbl.text = [NSString stringWithFormat:@"%02d",([[self.hourlbl text] intValue]+1)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.gridView && [keyPath isEqualToString:@"frame"]) {
        
        /* Animate tableView filling the remaining space after the
         * gridView expanded or contracted to fit the # of weeks
         * for the month that is being displayed.
         *
         * This observer method will be called when gridView's height
         * changes, which we know to occur inside a Core Animation
         * transaction. Hence, when I set the "frame" property on
         * tableView here, I do not need to wrap it in a
         * [UIView beginAnimations:context:].
         */
        CGFloat gridBottom = self.gridView.top + self.gridView.height;
        CGRect frame = self.tableView.frame;
        frame.origin.y = gridBottom;
        frame.size.height = self.tableView.superview.height - gridBottom;
        self.tableView.frame = frame;
        
        self.bottomView.frame = frame;
        
    } else if ([keyPath isEqualToString:@"selectedMonthNameAndYear"]) {
        [self setHeaderTitleText:[change objectForKey:NSKeyValueChangeNewKey]];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setHeaderTitleText:(NSString *)text
{
    if([text isKindOfClass:[NSString class]])
        [headerTitleLabel setText:text];
    [headerTitleLabel sizeToFit];
    headerTitleLabel.left = floorf(self.width/2.f - headerTitleLabel.width/2.f);
}

- (void)jumpToSelectedMonth { [self.gridView jumpToSelectedMonth]; }

- (BOOL)isSliding { return self.gridView.transitioning; }

- (void)markTilesForDates:(NSArray *)dates { [self.gridView markTilesForDates:dates]; }

- (void)dealloc
{
    [logic removeObserver:self forKeyPath:@"selectedMonthNameAndYear"];
    
    [self.gridView removeObserver:self forKeyPath:@"frame"];
}

@end
