//
//  ViewController.m
//  AulaMapa
//
//  Created by Treinamento on 19/08/17.
//  Copyright © 2017 Treinamento. All rights reserved.
//

#import "ViewController.h"
#import "CelulaCustomizadaTableViewCell.h"

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
}

- (IBAction)searchButtonClick:(id)sender {
    [self startSearch:_txtSearch.text];
    
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

-(void)collectAddress{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    [geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = placemarks[0];
        NSLog(@"%@", placemark.thoroughfare);
        NSLog(@"%@", placemark.subLocality);
    }];
}

-(void)startSearch:(NSString *)searchString {
    
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
   
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    
    
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        
        if (error != nil) {
            [self.localSearch cancel];
            self.localSearch = nil;
            NSLog(@"Erro");
        } else {
            if([response mapItems].count > 0){
                self.arrayLocations = [response mapItems];
                [self.tableView reloadData];
                NSLog(@"%@", response);
            }else{
                NSLog(@"Erro");
            }
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil) {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self startSearch:self.txtSearch.text];
    [self.view endEditing:YES];
    return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayLocations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView setHidden:NO];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"celulaCustomizada" forIndexPath:indexPath];
    MKMapItem *item = self.arrayLocations[indexPath.row];
    cell.textLabel.text = item.placemark.name;
    return cell;
}

-(void)centerMap:(CLLocation *)location
{
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = location.coordinate.latitude;
    newRegion.center.longitude = location.coordinate.longitude;
    newRegion.span.latitudeDelta = 0.0005;
    newRegion.span.longitudeDelta = 0.0005;
    
    [self.mapView setRegion:newRegion];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView setHidden:YES];
    MKMapItem * myObj = self.arrayLocations[indexPath.row];
    CLLocation* location = myObj.placemark.location;
    [self centerMap:location];
    [self markPoint:location];
    
    
    
   /*
    
    [UITableView transitionWithView: self.tableViewResultAddress
                           duration:0.5
                            options: UIViewAnimationOptionTransitionFlipFromBottom
                         animations:^{
                             self.tableViewResultAddress.hidden = YES;
                             
                             
                         }completion: ^ (BOOL finished){
                             MKMapItem * myObj = self.resultAdress[ indexPath.row];
                             [self setPinOnMap:myObj.placemark.location];
                             [self centerMapWithLocation:myObj.placemark.location];
                         }];
*/
    }

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    UIImage *image = [UIImage imageNamed:@"mapPin"];
    
    MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"mapPin"];
    
    if(pinView != nil){
        pinView.annotation = annotation;
    }else{
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mapPin"];
        pinView.image = image;
        pinView.centerOffset = CGPointMake(0, -pinView.image.size.height / 2);
        
    }
    return pinView;
}

@end
