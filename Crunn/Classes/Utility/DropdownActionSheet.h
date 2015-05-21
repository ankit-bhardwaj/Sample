
#import <UIKit/UIKit.h>
#import "DropDownControl.h"



@interface DropdownActionSheet : UIViewController<UISearchBarDelegate> {
	UIView *actionSheetView;
    IBOutlet UIPickerView *pickerView;
    UISearchBar *searchbar;
    IBOutlet UIToolbar *dropDownToolBar;
}
@property(nonatomic, retain) IBOutlet UIView *actionSheetView;
@property(nonatomic, retain) DropDownControl *dropdownControl;
@property(nonatomic, retain) NSArray *values;
- (IBAction) slideOut;
-(void)setupView;
@end
