//
//  Copyright 2011 Astegic Inc. All rights reserved.
//
/*! \file LocationService.h
 \brief Description
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

/**
 * LocationService for handling user location.
 */
@interface LocationService : NSObject <CLLocationManagerDelegate> 
{
	CLLocationManager*      locationManager;
	CLLocation*             bestLocation;
    NSString*               _latitude;
    NSString*               _longitude;
    NSString*               _speed;
    NSString*               _altitude;
    NSString*               _bearing;
    
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *bestLocation;
@property (nonatomic, retain) NSString*               _latitude;
@property (nonatomic, retain) NSString*               _longitude;
@property (nonatomic, retain) NSString*               _speed;
@property (nonatomic, retain) NSString*               _altitude;
@property (nonatomic, retain) NSString*               _bearing;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) CLGeocoder* geocoder;


/**
 start getting location updates.
 */
+(void)start;           

/**
 stop getting location updates.
 */
+(void)stop;     


/**
 *Create LocationService and returns its best location.
 \return CLLocation object.
 */
+(CLLocation*) locationCoordinate;

/**
 getting best location cordinate latitude.
 \return best location cordinate latitude with north south indication.
 */
+(NSString*) latitude;
/**
 getting best location cordinate longitude.
 \return best location cordinate longitude with north south indication.
 */
+(NSString*) longitude;
/**
 getting Speed of user in miles per hr.
 \return speed of user.
 */
+(NSString*) speed;
/**
 getting altitude of user in miles per feet.
 \return altitude of user.
 */
+(NSString*) altitude;
/**
 getting best location course.
 \return best location course.
 */
+(NSString*) bearing;

+(NSString*) addressString;


/**
 *Check for location service availability and show alert according to the argument.
 \param showAlert shows an alert if 'YES'
 \return YES if location service available.
 */
+(BOOL)locationServiceAvailable:(BOOL)showAlert;


/**
 This method will convert double value to degrees
 return the degrres after formatting it as string.
 **/
- (NSString*) toDegrees: (double) val;

/**
 this method will check about validation of location
 return YES if it is a valid location.
 **/
+(BOOL) isValidLocation;

@end

