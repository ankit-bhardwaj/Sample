//
//  MapVC.m
//  Crunn
//
//  Created by Ashish Maheshwari on 3/24/15.
//  Copyright (c) 2015 Ashish sharma. All rights reserved.
//

#import "MapVC.h"
#include <MapKit/MapKit.h>
#include <AddressBookUI/AddressBookUI.h>

@interface MapVC ()
{
    IBOutlet MKMapView* mapView;
}
@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [mapView addAnnotation:self.location];
    [mapView showAnnotations:[NSArray arrayWithObject:self.location] animated:YES];
    
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Get Location" style:UIBarButtonItemStylePlain target:self  action:@selector(openMap)];
    if(!self.location.address)
    {
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:[self.location.latitude boolValue] longitude:[self.location.longitude boolValue]] completionHandler:^(NSArray *placemarks, NSError *error) {
            if(placemarks.count)
            {
                CLPlacemark* mark = [placemarks firstObject];
                self.location.address = [[ABCreateStringWithAddressDictionary( mark.addressDictionary,TRUE) stringByReplacingOccurrencesOfString:@"\n" withString:@","] stringByReplacingOccurrencesOfString:@"?" withString:@""];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView* v = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Loc"];
    if(!v)
        v = [[MKPinAnnotationView alloc] initWithAnnotation:self.location reuseIdentifier:@"Loc"];
    v.annotation = self.location;
    v.pinColor = MKPinAnnotationColorRed;
    v.canShowCallout = YES;
    v.animatesDrop = YES;
    return v;
}

- (void)openMap
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"maps://saddr=Current+Location&daddr=%f,%f",[self.location.latitude doubleValue],[self.location.longitude doubleValue]]]];
}

@end
