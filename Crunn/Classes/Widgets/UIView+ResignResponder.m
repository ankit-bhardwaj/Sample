//
//  UIView+ResignResponder.m
//  M-Spectrum
//
//  Created by Lightygalaxy on 10/02/10.
//  Copyright 2010 Erixir Inc Limited All rights reserved.
//

#import "UIView+ResignResponder.h"
//#import "UIComboBox.h"

@implementation UIView (ResignFirtsResponder)

//- (BOOL)resignFirstResonder
//{
//    if (self.isFirstResponder) {
//        [self resignFirstResponder];
//        return YES;     
//    }
//    for (UIView *subView in self.subviews)
//    {
//        if ([subView isKindOfClass:[UITextField class]]||[subView isKindOfClass:[UITextView class]])
//        {
//            [subView resignFirstResponder];
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if ([self isKindOfClass:[UIPickerView class]] || [self isKindOfClass:[UITextView class]] ) {
//        return;
//    }
//	[self resignFirstResonder];
//	[super touchesBegan:touches withEvent:event];
//}

@end

@implementation AutoResignScrollView

- (BOOL)resignFirstResonder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in self.subviews) {
        if (subView.isFirstResponder) {
            [subView resignFirstResponder];
            return YES;
        }
        for (UIView *subsubView in subView.subviews)
        {
            if ([subsubView isKindOfClass:[UITextField class]]||[subsubView isKindOfClass:[UITextView class]])
            {
                [subsubView resignFirstResponder];
                return YES;
            }
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([self isKindOfClass:[UITextView class]]))
        [self resignFirstResonder];
	[super touchesBegan:touches withEvent:event];
}

@end

@implementation AutoResignTableView

- (BOOL)resignFirstResonder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if (subView.isFirstResponder) {
            [subView resignFirstResponder];
            return YES;
        }
        for (UIView *subsubView in subView.subviews)
        {
            if ([subsubView isKindOfClass:[UITextField class]]||[subsubView isKindOfClass:[UITextView class]])
            {
                [subsubView resignFirstResponder];
                return YES;
            }
        }
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!([self isKindOfClass:[UITextView class]]))
        [self resignFirstResonder];
	[super touchesBegan:touches withEvent:event];
}

@end


