//
//  DropDownControl.m
//  mSpectrum
//
//  Created by Prakash Gupta on 22/08/13.
//  Copyright (c) 2013 Astegic. All rights reserved.
//

#import "DropDownControl.h"
@interface DropDownControl ()
{
    BOOL isObserver;
    NSString *tempSelectedValue;
}
@property(nonatomic, retain) UITableView *tablePicker;
@property(nonatomic, retain) UIPopoverController  *popover;
@property(nonatomic, retain) NSArray *filteredArray;
@end

@implementation DropDownControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_tablePicker) {
        [_tablePicker setFrame:CGRectMake(0, 3, self.bounds.size.width,self.bounds.size.height)];
    }
}

- (void)openPopOver
{
    _filteredArray = nil;
    self.filteredArray = [NSArray arrayWithArray:self.values];
    if(_picker)
    {
        //[_picker release];
        _picker = nil;
    }
    if(_delegate && [_delegate respondsToSelector:@selector(dropdownControlDidClicked:)])
    {
        [_delegate performSelector:@selector(dropdownControlDidClicked:) withObject:self];
    }
        
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        _picker.backgroundColor = [UIColor clearColor];
        [_picker setShowsSelectionIndicator:_values.count > 0 ? YES : NO];
        _picker.delegate = self;
        _picker.dataSource = self;
        
        UIViewController *pickerController = [[UIViewController alloc] init];
        [pickerController setView:_picker];
        UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:pickerController];
        navcon.navigationBarHidden = YES;
        UIPopoverController *pickerPopover = [[UIPopoverController alloc] initWithContentViewController:navcon];
        [pickerPopover setPopoverContentSize:CGSizeMake(320, 256)];
        [pickerPopover presentPopoverFromRect:[self.ownerView convertRect:CGRectMake(self.bounds.size.width/2, self.bounds.size.height/2, 1, 1) fromView:self] inView:self.ownerView permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:YES];
        pickerPopover.delegate = self;
        self.popover = pickerPopover;
        
        //[pickerController release];
        //[navcon release];
        //[pickerPopover release];
        isObserver = YES;
        [_ownerView addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) context:NULL];
    }else
    {
        [_delegate showDropDownOptions:self values:_values];
    }
    
    if(_selectedValue)
    {
        NSUInteger index = [_filteredArray indexOfObject:_selectedValue];
        if(index != NSNotFound)
        {
            [self setTitle:_selectedValue forState:(UIControlStateNormal)];
            [_picker selectRow:index inComponent:0 animated:NO];
            
        }
    }
    
    
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _ownerView)
    {
        CGRect rect = [self.ownerView convertRect:CGRectMake(self.bounds.size.width/2, self.bounds.size.height/2, 1, 1) fromView:self];
        [_popover presentPopoverFromRect:rect inView:self.ownerView permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) animated:NO];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if(popoverController.isPopoverVisible)
    {
        if (isObserver) {
            [_ownerView removeObserver:self forKeyPath:@"frame" context:NULL];
            isObserver = NO;
        }
    }
    return YES;
}


#pragma mark -
#pragma mark UITableView delegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filteredArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0f;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *CellIdentifier = @"defaultCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setBackgroundColor:[UIColor clearColor]];
            UIImageView* imgViewcheckmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uncheck.png"]];
            [cell setAccessoryView:imgViewcheckmark];
            //[imgViewcheckmark release];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                cell.textLabel.numberOfLines = 2;
            }
        }
   
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.textLabel.text = ([_filteredArray objectAtIndex:indexPath.row]);
    
    
    
    
    if ([self.selectedValue isEqual:[_filteredArray objectAtIndex:indexPath.row]]) {
        
        UIImageView* imgView = (UIImageView*)cell.accessoryView;
        [imgView setImage:[UIImage imageNamed:@"tick_icon.png"]];
        
    }
    else{
        UIImageView* imgView = (UIImageView*)cell.accessoryView;
        [imgView setImage:[UIImage imageNamed:@"uncheck.png"]];
    
    }
          return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([self.selectedValue isEqual:[_filteredArray objectAtIndex:indexPath.row]])
    {
        //[self.selectedValue release];
        self.selectedValue = nil;
    }
    else
        self.selectedValue = [_filteredArray objectAtIndex:indexPath.row];
    [tableView reloadData];
    if(_delegate && [_delegate respondsToSelector:@selector(dropdown:didSelectValue:)])
    {
        [_delegate performSelector:@selector(dropdown:didSelectValue:) withObject:self withObject:_selectedValue];
    }
}


#pragma mark - 

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    [pickerView setShowsSelectionIndicator:_filteredArray.count > 0 ? YES : NO];
    return _filteredArray.count > 0 ? _filteredArray.count : 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _filteredArray.count ? ([_filteredArray objectAtIndex:row]) : @"No Value Found.";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(_filteredArray.count)
    {
        if (row>=0) {
            NSString *opt = [_filteredArray objectAtIndex:row];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.selectedValue = opt;
                if(_delegate && [_delegate respondsToSelector:@selector(dropdown:didSelectValue:)])
                {
                    [_delegate performSelector:@selector(dropdown:didSelectValue:) withObject:self withObject:_selectedValue];
                    [self setTitle:opt forState:UIControlStateNormal];
                }
            }else
            {
                tempSelectedValue = opt;
            }
        }
        else
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                self.selectedValue = nil;
                if(_delegate && [_delegate respondsToSelector:@selector(dropdown:didSelectValue:)])
                {
                    [_delegate performSelector:@selector(dropdown:didSelectValue:) withObject:self withObject:_selectedValue];
                    //[self setTitle:@"Select an Item" forState:UIControlStateNormal];
                }
            }else
            {
                tempSelectedValue = nil;
            }
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            if(_popover.isPopoverVisible)
            {
                if (isObserver) {
                    isObserver = NO;
                    [_ownerView removeObserver:self forKeyPath:@"frame" context:NULL];
                }
            }
            [_popover dismissPopoverAnimated:YES];
        }
    }
}
#pragma mark -
#pragma mark search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kAnimatePicker" object:nil];
    }
    
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *text = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(text.length > 0)
        self.filteredArray = [self.values filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"option contains[c] %@", text]];
    else
        self.filteredArray = [NSArray arrayWithArray:self.values];
    
    [_picker reloadComponent:0];
    [_picker selectRow:0 inComponent:0 animated:YES];
}

-(void)setSelectedValue:(NSString *)selectedValue
{
    if(!_selectedValue ||![_selectedValue isEqual:selectedValue])
    {
        if(_selectedValue)
        {
            //[_selectedValue release];
            _selectedValue = nil;
        }
        
        _selectedValue = selectedValue;
    }

}
    

-(void)setSelectedOption:(NSString *)selectedValue
{
    for (NSString *opt in _values) {
        if ([opt isEqualToString:selectedValue]) {
            [self setSelectedValue:opt];
            break;
        }
    }
}

- (void)setValues:(NSArray *)values
{
    if(_values)
    {
        //[_values release];
        _values = nil;
    }
    _values = values;
    tempSelectedValue = [values firstObject];
    
    if(_filteredArray == nil)
        self.filteredArray = [NSArray arrayWithArray:self.values];
    
    //if ([self.filteredArray count] > 3) {
        
        [self addTarget:self action:@selector(openPopOver) forControlEvents:UIControlEventTouchUpInside];
        [self setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentLeft)];
        [self setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        
        [self setReversesTitleShadowWhenHighlighted:YES];
        
        
        
    //}

}

- (void)cancel:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(dropdownControlDidCancel:)]) {
        [_delegate dropdownControlDidCancel:self];
    }
}

- (void)done:(id)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(dropdown:didSelectValue:)])
    {
        //if (tempSelectedValue) {
            [_delegate performSelector:@selector(dropdown:didSelectValue:) withObject:self withObject:tempSelectedValue];
            //[self setTitle:tempSelectedValue forState:UIControlStateNormal];
            self.selectedValue = tempSelectedValue;
        //}
    }
}

@end
