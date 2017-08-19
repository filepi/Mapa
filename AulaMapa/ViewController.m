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
    
    [self centerMap];

}

-(void)centerMap
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = lat;
    newRegion.center.longitude = lng;
    newRegion.span.latitudeDelta = 0.0005;
    newRegion.span.longitudeDelta = 0.0005;
    
    [self colectAddress];
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
    [self addGestureToMap];
}

- (IBAction)removeLocation:(id)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];
}


-(void)markPoint: (CLLocation*) lugar
{
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lugar.coordinate.latitude, lugar.coordinate.longitude);
    point.title = @"location";
    point.coordinate = coordinate;
    [self.mapView addAnnotation:point];
}

-(void)addGestureToMap{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.delaysTouchesBegan = YES;
    
    [tapGesture setCancelsTouchesInView:YES];
    [self.mapView addGestureRecognizer:tapGesture];
}

-(void)tapMap:(UITapGestureRecognizer *)recognizer{
    CGPoint touchPoint = [recognizer locationInView:self.mapView];
    
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    CLLocation *location  = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    
    [self markPoint:location];
}

-(void)colectAddress{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = placemarks[0];
        NSLog(@"%@", placemark.thoroughfare);
        NSLog(@"%@", placemark.subLocality);
    }];
}

@end
