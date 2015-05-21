//
//  GetMoreTableFooter.h
//  mCampus
//
//  Created by Ashish Maheshwari on 7/19/10.
//  Copyright 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TapDelegte <NSObject>

-(void)didTappedFooterView:(id)footerView;

@end

typedef enum{
	TableFooterNormal = 0,
	TableFooterLoading = 1,
    TableFooterNoData = 2,
    TableFooterNoMoreData = 3
} TableFooterState;


@interface GetMoreTableFooter : UIView {
	UIActivityIndicatorView *_spinner;
	UILabel *_message;
	id<TapDelegte> tapDelegate;
	UIButton *_button;
	NSInteger _state;
	NSInteger _size;
}
@property(nonatomic,retain) id<TapDelegte> tapDelegate;
-(void)setState:(TableFooterState)state;
-(TableFooterState)getState;
-(void)setPageSize:(NSInteger)s;
@end
