//
//  AuthorizationStatus.m
//  Crunn
//
//  Created by Ashish Maheshwari on 4/29/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "AuthorizationStatus.h"
#include <AssetsLibrary/ALAssetsLibrary.h>
#include <AVFoundation/AVFoundation.h>

@implementation AuthorizationStatus

+ (BOOL)isPhotoAlbumAllowedWithMessage:(BOOL)showalert
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status)
    {
        case ALAuthorizationStatusRestricted:
        {
            //Tell user access to the photos are restricted
            if(showalert)
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Access of photos is restricted. Please allow from privacy settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
        
            
            break;
        }
        case ALAuthorizationStatusDenied:
        {
            if(showalert)
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Access of photos has been denied. Please allow from privacy settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
            // Tell user access has previously been denied
        }
            
            break;
            
        case ALAuthorizationStatusNotDetermined:
        case ALAuthorizationStatusAuthorized:
            return YES;
            break;
    }
            return NO;
}

+ (BOOL)isCameraAllowedWithMessage:(BOOL)showalert
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status)
    {
        case AVAuthorizationStatusRestricted:
        {
            //Tell user access to the photos are restricted
            if(showalert)
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Access of camera is restricted. Please allow from privacy settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
            
            
            break;
        }
        case AVAuthorizationStatusDenied:
        {
            if(showalert)
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Access of camera has been denied. Please allow from privacy settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
            // Tell user access has previously been denied
        }
            
            break;
            
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusAuthorized:
            return YES;
            break;
    }
    return NO;
}

+ (BOOL)isAddressbookAllowedWithMessage:(BOOL)showalert
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusRestricted:
        {
            //Tell user access to the photos are restricted
            if(showalert)
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Access of phone contacts is restricted. Please allow from privacy settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
            
            
            break;
        }
        case kABAuthorizationStatusDenied:
        {
            if(showalert)
                [[[UIAlertView alloc] initWithTitle:@"" message:@"Access of contacts has been denied. Please allow from privacy settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;
            // Tell user access has previously been denied
        }
            
            break;
            
        case kABAuthorizationStatusNotDetermined:
        case kABAuthorizationStatusAuthorized:
            return YES;
            break;
    }
    return NO;
}

+ (BOOL)isMicroPhoneAllowedWithMessage:(BOOL)showAlert
{
    __block BOOL access = NO;
    while (access) {
       [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        access = granted;
    }];
    return access;
}
@end
