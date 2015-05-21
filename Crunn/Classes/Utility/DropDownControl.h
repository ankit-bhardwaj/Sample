//
//  DropDownControl.h
//  mSpectrum
//
//  Created by Prakash Gupta on 22/08/13.
//  Copyright (c) 2013 Astegic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DropDownControl;
@protocol DropDownControlDelegate<NSObject>
@optional
- (void)dropdown:(DropDownControl *)dropdown didSelectValue:(NSString *)value;
- (void)dropdownControlDidClicked:(DropDownControl *)dropdown;
- (void)dropdownControlDidCancel:(DropDownControl *)dtControl;
-(void)showDropDownOptions:(DropDownControl *)dropdown values:(NSArray *)values;
@end

@interface DropDownControl : UIButton<UIPickerViewDataSource, UIPickerViewDelegate, UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>
@property(nonatomic, retain) UIPickerView *picker;
@property(nonatomic, retain) UIView *ownerView;
@property(nonatomic, retain) NSArray *values;
@property(nonatomic, assign) NSString *selectedValue;
@property(nonatomic, assign) id<DropDownControlDelegate> delegate;
-(void)setSelectedOption:(NSString *)selectedValue;
- (void)cancel:(id)sender;
- (void)done:(id)sender;
@end
