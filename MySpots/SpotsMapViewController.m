//
//  SpotsMapViewController.m
//  MySpots
//
//  Created by FlyinGeek on 4/13/14.
//  Copyright (c) 2014 CodeStrikers. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "SpotsManager.h"
#import "SpotsMapViewController.h"

#import "Utilities.h"
#import "UIViewController+CWPopup.h"
#import "JDStatusBarNotification.h"
#import "MHNatGeoViewControllerTransition.h"


@interface MyMKPinAnnotationView : MKPinAnnotationView

@property (nonatomic) NSString *title;

@end

@implementation MyMKPinAnnotationView


@end

@interface SpotsMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation SpotsMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:self.view.frame];
    [self.view addSubview:toolbarBackground];
    [self.view sendSubviewToBack:toolbarBackground];
    
    self.useBlurForPopup = NO;
    
    [self setupSpots];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [self viewOfAllSpots];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSpots) name:@"SpotsDataChanged" object:nil];
}

- (IBAction)refreshButtonPressed:(id)sender {
    [self viewOfAllSpots];
}

- (IBAction)backButtonPressed:(id)sender {
    
    [self.tabBarController dismissNatGeoViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
    [super viewDidDisappear:animated];
}

#pragma MapKit delegate

//creates the pinView on the map.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MKPointAnnotation*)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        ((MKUserLocation *)annotation).title = @"You are here!";
        return nil;
    }
    
    static NSString *identifier = @"myAnnotation";
    
    MyMKPinAnnotationView * annotationView = (MyMKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView)
    {
        annotationView = [[MyMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
        annotationView.title = annotation.title;
    }else {
        annotationView.annotation = annotation;
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
    return annotationView;
    
}

//When the info button is clicked it will zoom into a smaller radius around point of interest
- (void)mapView:(MKMapView *)mapView annotationView:(MKPointAnnotation *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(view.coordinate, 100, 100);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

}

- (void)setupSpots
{
    [self.mapView removeAnnotations:[self.mapView.annotations filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"!(self isKindOfClass: %@)", [MKUserLocation class]]]];
    
    for (Spot *spot in [SpotsManager sharedManager].spots) {
        
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(spot.latitude, spot.longitude);
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = coords;
        point.title = spot.name;
        [self.mapView addAnnotation:point];
    }
}

- (void)viewOfAllSpots
{
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    const float offset = 1000.0f;
    
    [self.mapView setVisibleMapRect:MKMapRectMake(zoomRect.origin.x - offset, zoomRect.origin.y - offset, zoomRect.size.width + 2*offset, zoomRect.size.height + 2*offset) animated:YES];
}

#pragma - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.mapView.showsUserLocation = YES;
}

- (IBAction)quitButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate dismissViewController];
    }
}

@end

