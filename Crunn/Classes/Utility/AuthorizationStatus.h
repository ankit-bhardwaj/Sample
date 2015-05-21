//
//  AuthorizationStatus.h
//  Crunn
//
//  Created by Ashish Maheshwari on 4/29/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorizationStatus : NSObject

+ (BOOL)isPhotoAlbumAllowedWithMessage:(BOOL)showalert;
+ (BOOL)isCameraAllowedWithMessage:(BOOL)showalert;
+ (BOOL)isAddressbookAllowedWithMessage:(BOOL)showalert;
+ (BOOL)isMicroPhoneAllowedWithMessage:(BOOL)showAlert;

@end
