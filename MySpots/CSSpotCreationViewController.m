//
//  CSSpotCreationViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSDataHandler.h"
#import "CSSpot.h"
#import "URBAlertView.h"
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

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) URBAlertView *alertView;

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
    
    URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:@"Warnning:" message:@"Spot Name Cannot be empty!"];
	alertView.blurBackground = NO;
	[alertView addButtonWithTitle:@"OK"];
	[alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        // do stuff here
		[self.alertView hideWithCompletionBlock:^{
            if (buttonIndex == 0) {
            }
		}];
	}];
	
	self.alertView = alertView;
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
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
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
    //NSLog(@"%@", [CSUtilities hexStringFromColor:self.grayTag.backgroundColor]);
}

- (IBAction)redTagPressed:(id)sender {
    self.tagView.backgroundColor = self.redTag.backgroundColor;
    //NSLog(@"%@", [CSUtilities hexStringFromColor:self.redTag.backgroundColor]);
}

- (IBAction)greenTagPressed:(id)sender {
    self.tagView.backgroundColor = self.greenTag.backgroundColor;
    //NSLog(@"%@", [CSUtilities hexStringFromColor:self.greenTag.backgroundColor]);
}

- (IBAction)pinkTagPressed:(id)sender {
    self.tagView.backgroundColor = self.pinkTag.backgroundColor;
    //NSLog(@"%@", [CSUtilities hexStringFromColor:self.pinkTag.backgroundColor]);
}

- (IBAction)yellowTagPressed:(id)sender {
    self.tagView.backgroundColor = self.yellowTag.backgroundColor;
    //NSLog(@"%@", [CSUtilities hexStringFromColor:self.yellowTag.backgroundColor]);
}

- (IBAction)blueTagPressed:(id)sender {
    self.tagView.backgroundColor = self.blueTag.backgroundColor;
    //NSLog(@"%@", [CSUtilities hexStringFromColor:self.blueTag.backgroundColor]);
}


- (IBAction)createButtonPressed:(id)sender {
    
    if ([self.spotNameTextField.text isEqualToString:@""]) {
        [self.alertView showWithAnimation:URBAlertAnimationDefault];
    }else {
        NSDate *currentDateTime = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE,MM-dd-yyyy HH:mm:ss"];
        NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
        
        CSSpot *newSpot = [[CSSpot alloc] initWithName:self.spotNameTextField.text
                                                  time:dateInStringFormated
                                             longitude:self.locationManager.location.coordinate.longitude
                                              latitude:self.locationManager.location.coordinate.latitude
                                              tagColor:[CSUtilities hexStringFromColor:self.tagView.backgroundColor]];
        CSDataHandler *dataHandler = [CSDataHandler sharedInstance];
        [dataHandler updateWithNewSpot:newSpot];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
