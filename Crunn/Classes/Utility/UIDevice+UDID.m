//
//  UIDevice+UDID.m
//  dubnet
//
//  Created by Stanislav on 5/13/13.
//  Copyright (c) 2013 Erixir Inc Limited. All rights reserved.
//

#import "UIDevice+UDID.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation UIDevice (UDID)

- (NSString*)getDeviceUniqueKey {
    
    NSString *newUDID = nil;
    
    //first try the recommended new API
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        newUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    //then try the mac address
    if ((newUDID == nil) || (newUDID.length == 0) || ([self isAllZeros:newUDID])) {
        newUDID = [self getMacAddress];
    }
    
    //then try to create a new UUID
    if ((newUDID == nil) || (newUDID.length == 0) || ([self isAllZeros:newUDID])) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        if (uuid) {
            newUDID = (NSString *)CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            [newUDID autorelease];
        }
    }
    
    //if somehow all of these fails, just make sure we don't crash by having blank UDID
    if ((newUDID == nil) || (newUDID.length == 0) || ([self isAllZeros:newUDID])) {
        newUDID = @"";
    }
    
    return newUDID;
}

- (NSString*)getMacAddress {
    
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = (char*)malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL) {
        //dlog(@"Error: %@", errorFlag);
        return nil;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    //NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return [macAddressString stringByReplacingOccurrencesOfString:@":" withString:@""];
}


- (BOOL)isAllZeros:(NSString*)udid {
    NSString *deviceIdStripped = [udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    deviceIdStripped = [deviceIdStripped stringByReplacingOccurrencesOfString:@"0" withString:@""];
    
    return (deviceIdStripped.length == 0);
}

@end
