//
//  GetMoreTableFooter.m
//  mCampus
//
//  Created by Ashish Maheshwari on 7/19/10.
//  Copyright 2014 Erixir Inc Limited. All rights reserved.
//

#import "GetMoreTableFooter.h"

@implementation GetMoreTableFooter

@synthesize tapDelegate;

-(void)setPageSize:(NSInteger)s
{
	_size = s;
	//[_message setText:[NSString stringWithFormat:@"Show %d More",_size]];
	[_message setText:@""];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        // Initialization code
		_size = 10;
        
		//add label for message
		CGRect r = CGRectMake(0, 10,self.bounds.size.width, 30);
		_message = [[UILabel alloc] initWithFrame:r];
        _message.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[_message setBackgroundColor:[UIColor clearColor]];
		[_message setFont:[UIFont boldSystemFontOfSize:17]];
        [_message setTextAlignment:NSTextAlignmentCenter];
        UIColor* textColor = [UIColor blackColor];
		[_message setTextColor:textColor];
		[_message setAdjustsFontSizeToFitWidth:NO];
		[self addSubview:_message];
		
        //add spinner
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		 r = CGRectMake(r.origin.x - 40, self.bounds.size.height/2 - 10, 20, 20);
		[_spinner setFrame:r];
		[_spinner setHidesWhenStopped:YES];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [_spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        
		[self addSubview:_spinner];
		
//		//add button to read touch event
//		_button = [UIButton buttonWithType:UIButtonTypeCustom];
//		[_button setFrame:frame];
//		[_button addTarget:self action:@selector(viewDidTapped) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_button];
    }
    
	[self setState:TableFooterNormal];
    return self;
}


-(void)viewDidTapped
{
	if([tapDelegate respondsToSelector:@selector(didTappedFooterView:)] == NO)
		return;
	if (_state == TableFooterNormal) {
		[self setState:TableFooterLoading];
		[tapDelegate didTappedFooterView:self];
	}
}

-(TableFooterState)getState
{
    return _state;
}

-(void)setState:(TableFooterState)state
{
	switch (state) {
		case TableFooterNormal:
		{
			[_spinner stopAnimating];
			//[_message setText:[NSString stringWithFormat:@"Show %d More",_size]];
			[_message setText:@""];
			[_button setUserInteractionEnabled:YES];
			_state = TableFooterNormal;
			break;
		}
		case TableFooterLoading:
		{
			[_spinner startAnimating];
			[_message setText:@"Loading..."];
			[_button setUserInteractionEnabled:NO];
			_state = TableFooterLoading;
			break;
		}
        case TableFooterNoData:
		{
			[_spinner stopAnimating];
			[_message setText:@"No Data Found"];
			[_button setUserInteractionEnabled:NO];
			_state = TableFooterNoData;
			break;
		}
        case TableFooterNoMoreData:
		{
			[_spinner stopAnimating];
			[_message setText:@"No More Data"];
			[_button setUserInteractionEnabled:NO];
			_state = TableFooterNoMoreData;
			break;
		}
		default:
			break;
	}
}

-(void)setRecordLimit:(NSInteger)size
{
	_size = size;
	//[_message setText:[NSString stringWithFormat:@"Show %d More",_size]];
	[_message setText:@""];
}

-(void)setTextColor:(UIColor*)color
{
	[_message setTextColor:color];
}



@end
