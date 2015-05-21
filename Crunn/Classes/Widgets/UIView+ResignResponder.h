//
//  UIView+ResignResponder.h
//  M-Spectrum
//
//  Created by Lightygalaxy on 10/02/10.
//  Copyright 2010 Erixir Inc Limited All rights reserved.
//
/*! \file UIView+ResignResponder.h
 \brief Description
 */
#import <UIKit/UIKit.h>

/**
    Category of UIView including functionality to resign first responder when this view is touched.
 */
@interface UIView (ResignFirtsResponder)


/**
 Call resignFirstResponder of all containing subviews.
 \return YES if subview resigns as first responder.
 */
- (BOOL)resignFirstResonder;

@end

/**
 Category of UIScrollView including functionality to resign first responder when this view is touched.
 */
@interface AutoResignScrollView : UIScrollView

/**
 Call resignFirstResponder of all containing subviews.
 \return YES if subview resigns as first responder.
 */
- (BOOL)resignFirstResonder;

@end

/**
 Category of UIScrollView including functionality to resign first responder when this view is touched.
 */
@interface AutoResignTableView : UITableView

/**
 Call resignFirstResponder of all containing subviews.
 \return YES if subview resigns as first responder.
 */
- (BOOL)resignFirstResonder;

@end
