//
//  CSGeoARViewController.m
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CSGeoARViewController.h"
#import "EAGLView.h"
#include <metaioSDK/SensorsComponentIOS.h>

@interface CSGeoARViewController ()
- (UIImage*) getBillboardImageForTitle: (NSString*) title;
@end

@implementation CSGeoARViewController
@synthesize currentLocation;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    bool success = m_metaioSDK->setTrackingConfiguration("GPS");
    if(!success)
        NSLog(@"No success setting the tracking configuration");
    
    
    // if we want to use ImageBillboards, we should use UIBillboard Groups
	billboardGroup = m_metaioSDK->createBillboardGroup(580, 800);
	billboardGroup->setBillboardExpandFactors(0.8, 3, 10 );
    m_metaioSDK->setRendererClippingPlaneLimits( 10, 10000000 );
    
    // load the content after some delay to let the GPS initialize
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:1];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    locUpdate = true;
}

- (void)updateLocation
{
    NSLog(@"Location update is received");
    metaio::LLACoordinate currentPosition = m_sensors->getLocation();
    
    // let's create some positions around us
    metaio::LLACoordinate target= metaio::LLACoordinate(self.spot.latitude,self.spot.longitude, currentLocation.altitude, currentPosition.accuracy);
    
    if (targetBillboard)
    {
        targetBillboard->setTranslationLLA(target);
    }
}



- (void)viewWillAppear:(BOOL)animated
{
	// if the renderer appears we start rendering and capturing the camera
    [self startAnimation];
    m_metaioSDK->startCamera(0);
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
	// as soon as the view disappears, we stop rendering and stop the camera
    [self stopAnimation];
    m_metaioSDK->stopCamera();
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setGlView:nil];
    [super viewDidUnload];
}


- (void)loadContent
{
    locUpdate = false;
    
    // now let's load the content
    
    
    // hopefully we already have a location, so we can position our testcontent nearby
    metaio::LLACoordinate currentPosition = m_sensors->getLocation();
    if( currentPosition.accuracy > 0.0f )
    {
        // Creat the waypoints
        metaio::LLACoordinate target = metaio::LLACoordinate(self.spot.latitude, self.spot.longitude, currentLocation.altitude, currentPosition.accuracy);
        

        // load a few billboards
        targetImage = [self getBillboardImageForTitle:self.spot.name];
        targetBillboard = m_metaioSDK->createGeometryFromCGImage("target", [targetImage CGImage], true);
        targetBillboard->setTranslationLLA(target);
        targetBillboard->setLLALimitsEnabled(true);
        billboardGroup->addBillboard(targetBillboard);
        
        // Create radar object
        m_radar = m_metaioSDK->createRadar();
        m_radar->setBackgroundTexture([[[NSBundle mainBundle] pathForResource:@"radar" ofType:@"png" inDirectory:@"ImageRes"] UTF8String]);
        m_radar->setObjectsDefaultTexture([[[NSBundle mainBundle] pathForResource:@"yellow" ofType:@"png" inDirectory:@"ImageRes"] UTF8String]);
        m_radar->setRelativeToScreen(metaio::IGeometry::ANCHOR_TL);
        
        // Add geometries to the radar
        m_radar->add(targetBillboard);
        
		metaio::SensorsComponentIOS* iosComponent = reinterpret_cast<metaio::SensorsComponentIOS*>(m_sensors);
		SensorsComponentImpl* iosImpl = iosComponent->getSensorComponentImpl();
		[iosImpl setLocationManagerDelegate:self];
        
		iosComponent->start(metaio::ISensorsComponent::SENSOR_LOCATION);
		
        //CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //locationManager.delegate = self;
        //[locationManager startUpdatingLocation];
    }
    else
    {
        // try again after some delay
        [self performSelector:@selector(loadContent) withObject:nil afterDelay:1];
    }
}



#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:glView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = glView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_metaioSDK->getGeometryFromScreenCoordinates(loc.x * scale, loc.y * scale, true);
	
	if ( model )
	{
        metaio::LLACoordinate modelCoordinate = model->getTranslationLLA();
		NSLog(@"You picked a model at location %f, %f!", modelCoordinate.latitude, modelCoordinate.longitude);
        m_radar->setObjectsDefaultTexture([[[NSBundle mainBundle] pathForResource:@"yellow" ofType:@"png" inDirectory:@"ImageRes"] UTF8String]);
        m_radar->setObjectTexture(model, [[[NSBundle mainBundle] pathForResource:@"red" ofType:@"png" inDirectory:@"ImageRes"] UTF8String]);
        
        /*
        if (self.waypoint.latitude == modelCoordinate.latitude && self.waypoint.longitude == modelCoordinate.longitude) {
            self.descriptionTextView.text = [NSString stringWithString:self.waypoint.description];
            
            CLLocationCoordinate2D targetPlace, currentPlace;
            targetPlace.latitude = self.waypoint.latitude;
            targetPlace.longitude = self.waypoint.longitude;
            
            metaio::LLACoordinate currentPosition = m_sensors->getLocation();
            currentPlace.latitude = currentPosition.latitude;
            currentPlace.longitude = currentPosition.longitude;
            
            double distance = [self kilometresBetweenPlace1:targetPlace andPlace2:currentPlace];
            
            //self.descriptionTextView.text = [self.descriptionTextView.text stringByAppendingString:[NSString stringWithFormat:@" with in %lf km", distance]];
            self.descriptionTextView.text = [NSString stringWithFormat:@"Distance: %.2lf", distance];
        }
         */
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches
}

- (void)drawFrame
{
    // tell the superclass to renderer
    [super drawFrame];
    if (locUpdate)
    {
        [self updateLocation];
        locUpdate = false;
    }
}



#pragma mark - Helper methods

- (UIImage*) getBillboardImageForTitle: (NSString*) title
{
    // first lets find out if we're drawing retina resolution or not
    float scaleFactor = [UIScreen mainScreen].scale;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        scaleFactor = 2;        // draw in high-res for iPad
    
    // then lets draw
    UIImage* bgImage = nil;
    NSString* imagePath;
    if( scaleFactor == 1 )	// potentially this is not necessary anyway, because iOS automatically picks 2x version for iPhone4
    {
        imagePath = [[NSBundle mainBundle] pathForResource:@"POI_bg" ofType:@"png" inDirectory:@"ImageRes"];
    }
    else
    {
        imagePath = [[NSBundle mainBundle] pathForResource:@"POI_bg@2x" ofType:@"png" inDirectory:@"ImageRes"];
    }
    
    bgImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    UIGraphicsBeginImageContext( bgImage.size );			// create a new image context
    CGContextRef currContext = UIGraphicsGetCurrentContext();
    
    // mirror the context transformation to draw the images correctly
    CGContextTranslateCTM( currContext, 0, bgImage.size.height );
    CGContextScaleCTM(currContext, 1.0, -1.0);
    CGContextDrawImage(currContext,  CGRectMake(0, 0, bgImage.size.width, bgImage.size.height), [bgImage CGImage]);
    
    // now bring the context transformation back to what it was before
    CGContextScaleCTM(currContext, 1.0, -1.0);
    CGContextTranslateCTM( currContext, 0, -bgImage.size.height );
    
    // and add some text...
    CGContextSetRGBFillColor(currContext, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextSetTextDrawingMode(currContext, kCGTextFill);
    CGContextSetShouldAntialias(currContext, true);
   
    // draw the heading
    float border = 5*scaleFactor;
    [title drawInRect:CGRectMake(border, border,
                                 bgImage.size.width - 2 * border,
                                 bgImage.size.height - 2 * border )
             withFont:[UIFont systemFontOfSize:5*scaleFactor]];
    
    // retrieve the screenshot from the current context
    UIImage* blendetImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return blendetImage;
}

#pragma Math methods

const double PIx = 3.141592653589793;
const double RADIO = 6371; // Mean radius of Earth in Km

double convertToRadians(double val) {
    
    return val * PIx / 180;
}

-(double)kilometresBetweenPlace1:(CLLocationCoordinate2D) place1 andPlace2:(CLLocationCoordinate2D) place2 {
    
    double dlon = convertToRadians(place2.longitude - place1.longitude);
    double dlat = convertToRadians(place2.latitude - place1.latitude);
    
    double a = ( pow(sin(dlat / 2), 2) + cos(convertToRadians(place1.latitude))) * cos(convertToRadians(place2.latitude)) * pow(sin(dlon / 2), 2);
    double angle = 2 * asin(sqrt(a));
    
    return angle * RADIO;
}

- (void)onBtnClosePushed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
