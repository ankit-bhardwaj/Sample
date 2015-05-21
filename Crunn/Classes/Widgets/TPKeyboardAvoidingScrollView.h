//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//
/*! \file TPKeyboardAvoidingScrollView.h
 \brief Description
 */

#import <UIKit/UIKit.h>
#import "UIView+ResignResponder.h"
/**
 *SubClass of UIScrollView that add auto scroll functionality.
 */
@interface TPKeyboardAvoidingScrollView : AutoResignScrollView {
    CGRect priorFrame;
}

@end
