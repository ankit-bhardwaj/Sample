//
//  Copyright 2011 Astegic Inc. All rights reserved.right 2011 Astegic Inc. All rights reserved.
//

#import "LocationService.h"


#define kWAIT_FOR_BETTER_LOCATION   1.5
#define kFAILED_TO_GET_LOCATION     60
#define kLSTimeoutSec               20


static LocationService* singleton()
{
    static dispatch_once_t once;
    static LocationService*  sLocation;
    dispatch_once(&once, ^{
        sLocation = [[LocationService alloc] init];
    });
    return sLocation;
}

@implementation LocationService

@synthesize locationManager, bestLocation,_latitude,_longitude,_speed,_altitude,_bearing;


- (id) init 
{
	self = [super init];
	if (self != nil) 
	{
		bestLocation = nil;
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
//            [self.locationManager requestAlwaysAuthorization];
	}
	return self;
}


+(void) start
{
    LocationService*    locService = singleton();
    if([CLLocationManager locationServicesEnabled])
        [locService.locationManager startUpdatingLocation];
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [locService.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locService.locationManager requestWhenInUseAuthorization];
}

+(void) stop
{
    LocationService*    locService = singleton();
	[locService.locationManager stopUpdatingLocation];
}

// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	LocationService*    locService = singleton();
	locService.bestLocation = newLocation;
    if(!locService.geocoder)
    {
        locService.geocoder = [[CLGeocoder alloc] init];
        [locService.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(placemarks.count)
            {
                CLPlacemark* mark = [placemarks firstObject];
                locService.address =  [[ABCreateStringWithAddressDictionary( mark.addressDictionary,TRUE) stringByReplacingOccurrencesOfString:@"\n" withString:@","] stringByReplacingOccurrencesOfString:@"?" withString:@""];
            }
            else
                locService.address = nil;
            locService.geocoder = nil;
        }];
    }

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil]];
}

+(NSString*) addressString{
    LocationService*    locService = singleton();
    if(locService.address)
        return locService.address;
    else
        return @"";
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        LocationService*    locService = singleton();
        [locService.locationManager startUpdatingLocation];
    }
}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
        
    }
    else if([error code] == kCLErrorLocationUnknown){
    
    
    }
    else if([error code] == kCLErrorNetwork){
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Network Error!" message:@"Please check your network connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }    
	else
	{
		NSLog(@"location search failed: %@", [error localizedDescription]);
	}
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationFound" object:nil]];
}



+(CLLocation*) locationCoordinate
{
    LocationService*    locService = singleton();
    CLLocation* location;
    if(locService.bestLocation)
        location =locService.bestLocation;
    else
        location =locService.locationManager.location;
    return location;
} 

- (NSString*) toDegrees: (double) val
{
    double d = val<0?-val:val;
    double min = fmod(d,1)*60.0;
    double sec = fmod(min,1)*60;
    return [NSString stringWithFormat:@"%0.f˚  %0.f'  %0.2f\"",floor(d),floor(min),sec];
}

+(NSString*) latitude
{
    LocationService*    locService = singleton();
    NSMutableString* str = [NSMutableString string];
    CLLocation* location;
    if(locService.bestLocation)
        location =locService.bestLocation;
    else
        location =locService.locationManager.location;
    if(CLLocationCoordinate2DIsValid(location.coordinate))
    {
        if(locService.bestLocation.coordinate.latitude < 0)
            [str appendString:@"S "];
        else
            [str appendString:@"N "];
    
        [str appendFormat:[locService toDegrees:location.coordinate.latitude]];
    }
    return str;
}

+(NSString*) longitude
{
    LocationService*    locService = singleton();
    NSMutableString* str = [NSMutableString string];
    CLLocation* location;
    if(locService.bestLocation)
        location =locService.bestLocation;
    else
        location =locService.locationManager.location;
    if(CLLocationCoordinate2DIsValid(location.coordinate))
    {
        if(locService.bestLocation.coordinate.longitude < 0)
            [str appendString:@"S "];
        else
            [str appendString:@"N "];
        
        [str appendFormat:[locService toDegrees:location.coordinate.longitude]];
    }
    return str;
}

+(NSString*) speed
{
    LocationService*    locService = singleton();
    CLLocation* location;
    if(locService.bestLocation)
        location =locService.bestLocation;
    else
        location =locService.locationManager.location;
    if(location.speed > 0)
    {
        double speed = (3600.0/1609.344)*location.speed;
        return [NSString stringWithFormat:@"%0.2f mph",speed];
    }
    return @"";
}

+(NSString*) altitude
{
    LocationService*    locService = singleton();
    CLLocation* location;
    if(locService.bestLocation)
        location =locService.bestLocation;
    else
        location =locService.locationManager.location;
    double altitude = 3.2808399*location.altitude;
    return [NSString stringWithFormat:@"%0.2f ft",altitude];
}

+(NSString*) bearing
{
    LocationService*    locService = singleton();
    CLLocation* location;
    if(locService.bestLocation)
        location =locService.bestLocation;
    else
        location =locService.locationManager.location;
    return [NSString stringWithFormat:@"%0.2f",location.course];
}

+(BOOL) isValidLocation
{
    BOOL valid = [CLLocationManager locationServicesEnabled];
    LocationService*    locService = singleton();
    CLLocationCoordinate2D coord;
    if(locService.bestLocation)
        coord =locService.bestLocation.coordinate;
    else
        coord =locService.locationManager.location.coordinate;
    valid = CLLocationCoordinate2DIsValid(coord);
    if(valid)
    {
        if(coord.latitude == 0.0f || coord.longitude == 0.0f)
            valid = NO;
    }
    if(valid)
    {
        if(kCLAuthorizationStatusNotDetermined == [CLLocationManager authorizationStatus] || kCLAuthorizationStatusRestricted == [CLLocationManager authorizationStatus] || kCLAuthorizationStatusDenied == [CLLocationManager authorizationStatus])
            valid = NO;
    }
    return valid;
    
}

#define KEY_INFO_APP_NAME @"CFBundleDisplayName"
+(BOOL)locationServiceAvailable:(BOOL)showAlert
{
	BOOL isServicePresent = [CLLocationManager locationServicesEnabled];
   
	if(! isServicePresent && showAlert)
	{
		NSDictionary *infoPList = [[NSBundle mainBundle] infoDictionary];
		NSString *appName = [infoPList objectForKey:KEY_INFO_APP_NAME];
		if(! appName) appName = @"Grapple";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:appName message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[alertView show];
	}
	return isServicePresent;
}

@end