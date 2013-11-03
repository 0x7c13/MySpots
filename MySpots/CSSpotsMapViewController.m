//
//  CSSpotsMapViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSSpotsMapViewController.h"

@interface CSSpotsMapViewController ()

@end

@implementation CSSpotsMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.mapView.delegate = self;
    
    // Get the json data from the url
    CSDataHandler *handler = [CSDataHandler sharedInstance];
    handler.delegate = self;
    [handler getSpots];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitButtonPressed:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
//creates the pinView on the map.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MKPointAnnotation*)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = @"myAnnotation";
    
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    }else {
        annotationView.annotation = annotation;
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
    return annotationView;
    
}

//When the info button is clicked it will zoom into a smaller radius around point of interest
- (void)mapView:(MKMapView *)mapView annotationView:(MKPointAnnotation *)view calloutAccessoryControlTapped:(UIControl *)control
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(view.coordinate, 1500, 1500);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}
//Used for the right button in the navigation bar.
//Zooms the map back out to a full view
-(void)viewAllUSA{
    CLLocationCoordinate2D cord;
    cord.latitude =
    38.754083;
    cord.longitude = -97.998047;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(cord, 5000000, 5000000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}


- (void)spotsLoaded:(NSMutableArray *)spots
{
    for (CSSpot *spot in spots) {
        
        CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(spot.latitude, spot.longitude);
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = coords;
        point.title = spot.name;
        //The data isnt set in the json. This is dummycoded so it works
        point.subtitle = spot.time;
        [self.mapView addAnnotation:point];
    }
}



@end
