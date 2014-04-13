//
//  SpotsMapViewController.m
//  MySpots
//
//  Created by FlyinGeek on 4/13/14.
//  Copyright (c) 2014 CodeStrikers. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "Spot.h"
#import "TextSpot.h"
#import "ImageSpot.h"
#import "AudioSpot.h"

#import "TextViewController.h"
#import "ImageViewController.h"
#import "AudioViewController.h"

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

@interface SpotsMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, ImageViewControllerDelegate, AudioViewControllerDelegate, TextViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation SpotsMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    if (![view isKindOfClass:[MyMKPinAnnotationView class]]) {
        return;
    }

    Spot *targetSpot = [[SpotsManager sharedManager] spotByName:view.title];
    
    if ([targetSpot isKindOfClass:[TextSpot class]]) {
        
        TextViewController *textVC = [[TextViewController alloc] initWithNibName:@"TextViewController" bundle:nil];
        [(TextSpot *)targetSpot decryptHiddenTextWithCompletionBlock:^(NSString *hiddenText){
            textVC.hiddenText = hiddenText;
        }];
        textVC.spot = targetSpot;
        textVC.delegate = self;
        [self presentPopupViewController:textVC animated:YES completion:nil];
        
    } else if ([targetSpot isKindOfClass:[ImageSpot class]]) {
        
        [JDStatusBarNotification showWithStatus:@"Decrypting..." styleName:JDStatusBarStyleError];
        
        [(ImageSpot *)targetSpot decryptHiddenImagesWithCompletionBlock:^(NSArray *images){
            
            ImageViewController *imageVC = [[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil];
            imageVC.hiddenImages = images;
            imageVC.spot = targetSpot;
            imageVC.delegate = self;
            [self presentPopupViewController:imageVC animated:YES completion:nil];
            [JDStatusBarNotification showWithStatus:@"Decryption succeeded!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
        }];
    } else if ([targetSpot isKindOfClass:[AudioSpot class]]) {
        
        [JDStatusBarNotification showWithStatus:@"Decrypting..." styleName:JDStatusBarStyleError];
        
        [(AudioSpot *)targetSpot decryptHiddenAudioWithCompletionBlock:^(NSData *hiddenAudioData){
            
            AudioViewController *audioVC = [[AudioViewController alloc] initWithNibName:@"AudioViewController" bundle:nil];
            audioVC.hiddenAudioData = hiddenAudioData;
            audioVC.spot = targetSpot;
            audioVC.delegate = self;
            [self presentPopupViewController:audioVC animated:YES completion:nil];
            [JDStatusBarNotification showWithStatus:@"Decryption succeeded!" dismissAfter:1.0f styleName:JDStatusBarStyleSuccess];
        }];
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(view.coordinate, 100, 100);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

}

- (void)dismissViewController
{
    [self dismissPopupViewControllerAnimated:YES completion:nil];
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

/*
- (IBAction)resetView:(id)sender {
    [self viewOfAllWaypoints];
}
 */

#pragma - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.mapView.showsUserLocation = YES;
}
@end

