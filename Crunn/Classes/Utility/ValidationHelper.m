//
//  ValidationHelper.m
//  Dub
//
//  Created by Adam on 12/7/08.
//  Copyright 2008 Dub. All rights reserved.
//

#import "ValidationHelper.h"


@implementation ValidationHelper

+(BOOL) validateEmail: (NSString *) email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}



@end
