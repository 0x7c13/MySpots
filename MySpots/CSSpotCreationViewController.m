//
//  CSSpotCreationViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSSpotCreationViewController.h"

@interface CSSpotCreationViewController ()

@property (weak, nonatomic) IBOutlet UIView *grayTag;
@property (weak, nonatomic) IBOutlet UIView *redTag;
@property (weak, nonatomic) IBOutlet UIView *greenTag;
@property (weak, nonatomic) IBOutlet UIView *pinkTag;
@property (weak, nonatomic) IBOutlet UIView *yellowTag;
@property (weak, nonatomic) IBOutlet UIView *blueTag;

@property (weak, nonatomic) IBOutlet UIView *tagView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextField *spotNameTextField;

@end

@implementation CSSpotCreationViewController

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
    
    self.grayTag.layer.cornerRadius= 30.0/2;
    self.grayTag.clipsToBounds = YES;
    self.redTag.layer.cornerRadius= 30.0/2;
    self.redTag.clipsToBounds = YES;
    self.greenTag.layer.cornerRadius= 30.0/2;
    self.greenTag.clipsToBounds = YES;
    self.pinkTag.layer.cornerRadius= 30.0/2;
    self.pinkTag.clipsToBounds = YES;
    self.yellowTag.layer.cornerRadius= 30.0/2;
    self.yellowTag.clipsToBounds = YES;
    self.blueTag.layer.cornerRadius= 30.0/2;
    self.blueTag.clipsToBounds = YES;
    
    self.tagView.layer.cornerRadius= 20.0/2;
    self.tagView.clipsToBounds = YES;
    
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE,MM-dd-yyyy HH:mm:ss"];
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    self.timeLabel.text = dateInStringFormated;
    
    [self initSpot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initSpot
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coords;
    [self.mapView addAnnotation:point];
    
    MKMapRect zoomRect = MKMapRectNull;
    MKMapPoint annotationPoint = MKMapPointForCoordinate(point.coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    zoomRect = MKMapRectUnion(zoomRect, pointRect);

    [self.mapView setVisibleMapRect:zoomRect animated:YES];

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

- (IBAction)grayTagPressed:(id)sender {
    self.tagView.backgroundColor = self.grayTag.backgroundColor;
    NSLog(@"%@", [CSUtilities colorToWeb:self.grayTag.backgroundColor]);
}

- (IBAction)redTagPressed:(id)sender {
    self.tagView.backgroundColor = self.redTag.backgroundColor;
    NSLog(@"%@", [CSUtilities colorToWeb:self.redTag.backgroundColor]);
}

- (IBAction)greenTagPressed:(id)sender {
    self.tagView.backgroundColor = self.greenTag.backgroundColor;
    NSLog(@"%@", [CSUtilities colorToWeb:self.greenTag.backgroundColor]);
}

- (IBAction)pinkTagPressed:(id)sender {
    self.tagView.backgroundColor = self.pinkTag.backgroundColor;
    NSLog(@"%@", [CSUtilities colorToWeb:self.pinkTag.backgroundColor]);
}

- (IBAction)yellowTagPressed:(id)sender {
    self.tagView.backgroundColor = self.yellowTag.backgroundColor;
    NSLog(@"%@", [CSUtilities colorToWeb:self.yellowTag.backgroundColor]);
}

- (IBAction)blueTagPressed:(id)sender {
    self.tagView.backgroundColor = self.blueTag.backgroundColor;
    NSLog(@"%@", [CSUtilities colorToWeb:self.blueTag.backgroundColor]);
}



#pragma delegates


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.20f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView commitAnimations];
    return YES;
}





@end
