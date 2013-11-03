//
//  CSSpotsMapViewController.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CSDataHandler.h"

@interface CSSpotsMapViewController : UIViewController <MKMapViewDelegate, CSDataHandlerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
