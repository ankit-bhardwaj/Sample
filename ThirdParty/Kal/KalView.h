/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>
#import "KalGridView.h"

@class KalLogic;
@protocol KalViewDelegate, KalDataSourceCallbacks;

/*
 *    KalView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalViewController).
 *
 *  KalViewController uses KalView as its view.
 *  KalView defines a view hierarchy that looks like the following:
 *
 *       +-----------------------------------------+
 *       |                header view              |
 *       +-----------------------------------------+
 *       |                                         |
 *       |                                         |
 *       |                                         |
 *       |                 grid view               |
 *       |             (the calendar grid)         |
 *       |                                         |
 *       |                                         |
 *       +-----------------------------------------+
 *       |                                         |
 *       |           table view (events)           |
 *       |                                         |
 *       +-----------------------------------------+
 *
 */
typedef enum
{
    KalViewModeTypeNone     = 0,
    KalViewModeTypeDueDate  = 1,
    KalViewModeTypeReminder = 2,
    KalViewModeTypeMeeting  = 3
}KalViewModeType;

@interface KalView : UIView
{
  UILabel *headerTitleLabel;
  KalLogic *logic;
    UIButton* upBtn;
    UIButton* downBtn;
}

@property (nonatomic, weak) id<KalViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) KalGridView *gridView;
@property (nonatomic, strong) UILabel* hourlbl;
@property (nonatomic, strong) UILabel* minlbl;
@property (nonatomic, strong) UISwitch* reminderEverySwitch;
@property (nonatomic, strong) UIButton* reminderType;
@property (nonatomic, assign) KalViewModeType modeType;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)delegate logic:(KalLogic *)logic;
- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic withModeType:(KalViewModeType)mode;
- (BOOL)isSliding;
- (void)markTilesForDates:(NSArray *)dates;
- (void)redrawEntireMonth;
- (void)removeDate:(NSDate*)date;
// These 3 methods are exposed for the delegate. They should be called 
// *after* the KalLogic has moved to the month specified by the user.
- (void)slideDown;
- (void)slideUp;
- (void)jumpToSelectedMonth;    // change months without animation (i.e. when directly switching to "Today")

@end

#pragma mark -

@protocol KalViewDelegate

@optional

- (void)showPreviousMonth;
- (void)showFollowingMonth;
- (void)didSelectDate:(NSDate *)date;
- (void)didSelectBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (void)tapOnDate:(NSDate *)date;

@end
