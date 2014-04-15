//
//  SpotCreationViewController.m
//  MySpots
//
//  Created by Jiaqi Liu on 3/18/14.
//  Copyright (c) 2014 OSU. All rights reserved.
//

#import "Utilities.h"
#import "SpotsManager.h"
#import "SpotCreationViewController.h"
#import "PECropViewController.h"
#import "SWSnapshotStackView.h"
#import "UIColor+MLPFlatColors.h"
#import "MHNatGeoViewControllerTransition.h"
#import "URBAlertView.h"
#import "TSMessage.h"
#import "JDStatusBarNotification.h"
#import <MapKit/MapKit.h>

@interface SpotCreationViewController () <UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *addSpotButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextStepButton;
@property (weak, nonatomic) IBOutlet UILabel *spotAddressLabel;

@property (nonatomic) URBAlertView *alertView;
@property (nonatomic) CLGeocoder *geoCoder;
@property (nonatomic) CLLocationManager *locationManager;
@property (strong) NSString *currentAddress;
@property (strong) CLLocation *currentLocation;

@end

@implementation SpotCreationViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [Utilities addBackgroundImageToView:self.view withImageName:@"bg_1.jpg"];
    [Utilities makeTransparentBarsForViewController:self];
    
    self.addSpotButton.layer.cornerRadius = 10;
    [self.nextStepButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Chalkduster" size:20.0f], UITextAttributeFont,nil]
                         forState:UIControlStateNormal];
    
    
    // 3.5-inch iPhone tweaks
    {
        CGFloat yOffset = DEVICE_IS_4INCH_IPHONE ? 0 : -65;
        
        self.addSpotButton.frame = CGRectMake(self.addSpotButton.frame.origin.x, self.addSpotButton.frame.origin.y, self.addSpotButton.frame.size.width, self.addSpotButton.frame.size.height + yOffset);
        
        [self.addSpotButton.layer addSublayer:[Utilities addDashedBorderToView:self.addSpotButton
                                                                     withColor:[UIColor flatWhiteColor].CGColor]];
    }
    
    self.nextStepButton.enabled = NO;
    self.mapView.layer.cornerRadius = 15;
    self.mapView.hidden = YES;
    
    _geoCoder = [[CLGeocoder alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Spot Creation Screen";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
    [super viewDidDisappear:animated];
}

- (IBAction)addSpotButtonPressed:(id)sender {
    
    [self.locationManager startUpdatingLocation];
    self.addSpotButton.hidden = YES;
    [self executeAnimation];
}

- (IBAction)nextStepButtonPressed:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    __block __strong typeof(_currentAddress) strongCurrentAddress = _currentAddress;
    __block __strong typeof(_currentLocation) strongCurrentLocation = _currentLocation;
    NSLog(@"%@", self.currentLocation);
    
    self.alertView = [URBAlertView dialogWithTitle:@"Give a name" message:@"Give a name to this spot:"];
    [self.alertView addButtonWithTitle:@"Cancel"];
    [self.alertView addButtonWithTitle:@"Confirm"];
    [self.alertView addTextFieldWithPlaceholder:_currentAddress secure:NO];
    [self.alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
        
        if (buttonIndex == 1) {
            
            if (([alertView textForTextFieldAtIndex:0].length == 0 && [[SpotsManager sharedManager] containsSpotByName:strongCurrentAddress]) || ([alertView textForTextFieldAtIndex:0].length != 0 && [[SpotsManager sharedManager] containsSpotByName:[alertView textForTextFieldAtIndex:0]])) {

                [JDStatusBarNotification showWithStatus:@"A spot with same name already exists!" dismissAfter:2.0f styleName:JDStatusBarStyleSuccess];
                CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
                anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
                anim.autoreverses = YES ;
                anim.repeatCount = 2.0f ;
                anim.duration = 0.07f ;
                [alertView.layer addAnimation:anim forKey:nil] ;
            }
            else if ([alertView textForTextFieldAtIndex:0].length == 0) {
                
                [alertView hideWithAnimation:URBAlertAnimationDefault completionBlock:^{
                    [SpotsManager sharedManager].tempSpot = [[Spot alloc]initWithName:strongCurrentAddress latitude:strongCurrentLocation.coordinate.latitude longitude:strongCurrentLocation.coordinate.longitude];
                    
                    NSLog(@"%@, %f, %f", strongCurrentAddress, weakSelf.locationManager.location.coordinate.latitude, weakSelf.locationManager.location.coordinate.longitude);
                    
                    [weakSelf performSegueWithIdentifier:@"spotChosenSegue" sender:weakSelf];
                }];
            } else {
                [alertView hideWithAnimation:URBAlertAnimationDefault completionBlock:^{
                    
                    [SpotsManager sharedManager].tempSpot = [[Spot alloc]initWithName:[alertView textForTextFieldAtIndex:0] latitude:strongCurrentLocation.coordinate.latitude longitude:strongCurrentLocation.coordinate.longitude];
                    
                    NSLog(@"%@ %f, %f", [alertView textForTextFieldAtIndex:0], strongCurrentLocation.coordinate.latitude, strongCurrentLocation.coordinate.longitude);
                    [weakSelf performSegueWithIdentifier:@"spotChosenSegue" sender:weakSelf];
                }];
            }
            
        } else if (buttonIndex == 0) {
            [alertView hideWithAnimation:URBAlertAnimationDefault];
        }
        
    }];
    [self.alertView showWithAnimation:URBAlertAnimationDefault];

}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [[SpotsManager sharedManager] setTempSpot:nil];
    [self.navigationController dismissNatGeoViewController];
}

- (void)executeAnimation
{
    CGRect initRect = self.mapView.frame;
    self.mapView.frame = CGRectMake(initRect.origin.x - 25, initRect.origin.y - 25, initRect.size.width + 50, initRect.size.height + 50);
    self.mapView.alpha = 0.0f;
    self.mapView.hidden = NO;
    
    [UIView animateWithDuration:1.0f delay:.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.mapView.alpha = 1.0f;
        self.mapView.frame = initRect;
    }completion:nil];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - CLLocationManager delegate method


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!(((CLLocation *)[locations lastObject]).coordinate.latitude == 0.f && ((CLLocation *)locations[0]).coordinate.longitude == 0.f)) {
        _currentLocation = [locations lastObject];
        [self updateCurrentAddress];
        self.nextStepButton.enabled = YES;
    }
    
    self.mapView.showsUserLocation = YES;
    
    MKMapRect zoomRect = MKMapRectNull;
    MKMapPoint annotationPoint = MKMapPointForCoordinate(((CLLocation *)locations[0]).coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x - 1000.f, annotationPoint.y - 1000.f, 2000.f, 2000.f);
    zoomRect = MKMapRectUnion(zoomRect, pointRect);
    
    [self.mapView setVisibleMapRect:zoomRect animated:YES];
}

- (void)updateCurrentAddress {
    
    [self.geoCoder reverseGeocodeLocation:self.locationManager.location
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            
                            dispatch_async(dispatch_get_main_queue(),^ {
                                // do stuff with placemarks on the main thread
                                
                                if (placemarks.count == 1) {
                                    
                                    CLPlacemark *place = [placemarks objectAtIndex:0];
                                    
                                    NSString *city = place.locality;
                                    NSString *state = place.administrativeArea;
                                    NSString *addressNum = place.subThoroughfare;
                                    NSString *address = place.thoroughfare;
                                    NSString *postalCode = place.postalCode;
                                    
                                    self.spotAddressLabel.numberOfLines = 3;
                                    self.spotAddressLabel.font = [UIFont fontWithName:@"Chalkduster" size:17.f];
                                    
                                    if (addressNum) {
                                        _currentAddress = [NSString stringWithFormat:@"%@ %@ %@,%@,%@",addressNum, address, city, state, postalCode];
                                        //NSLog(@"%@", self.currentAddress);
                                    } else {
                                        _currentAddress = [NSString stringWithFormat:@"%@ %@,%@,%@", address, city, state, postalCode];
                                        //NSLog(@"%@", self.currentAddress);
                                    }
                                    
                                    self.spotAddressLabel.text = [@"You are now at: " stringByAppendingString:_currentAddress];
                                }
                            });
                            
                        }];
}



@end
