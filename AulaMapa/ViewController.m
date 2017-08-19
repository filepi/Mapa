//
//  ViewController.m
//  AulaMapa
//
//  Created by Treinamento on 19/08/17.
//  Copyright © 2017 Treinamento. All rights reserved.
//

#import "ViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController ()


@end

@implementation ViewController

float lat, lng;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLocationService];
    
    if (IS_OS_8_OR_LATER)
    {
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
     lat = self.locationManager.location.coordinate.latitude;
    lng = self.locationManager.location.coordinate.longitude;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showCurrentLocation:(id)sender {
   
    
    NSLog(@"Lat = %f, Lng = %f",lat,lng);
    
    
    [self markPoint];
    [self centerMap];

}

-(void)centerMap
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = lat;
    newRegion.center.longitude = lng;
    newRegion.span.latitudeDelta = 0.0005;
    newRegion.span.longitudeDelta = 0.0005;
    
    [self.mapView setRegion:newRegion];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initLocationService
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.locationManager startUpdatingHeading];
}

-(void)markPoint
{
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lng);
    point.title = @"Dois Unidos";
    point.coordinate = coordinate;
    [self.mapView addAnnotation:point];
}

@end
