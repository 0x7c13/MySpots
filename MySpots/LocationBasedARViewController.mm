
//  metaio SDK
//
// Copyright 2007-2013 metaio GmbH. All rights reserved.
//

#include <metaioSDK/SensorsComponentIOS.h>
#import <QuartzCore/QuartzCore.h>
#import "LocationBasedARViewController.h"
#import "EAGLView.h"
#import "SpotsManager.h"
#import "URBAlertView.h"
#import "UIViewController+CWPopup.h"
#import "JDStatusBarNotification.h"
#import "MHNatGeoViewControllerTransition.h"

#import "Spot.h"
#import "AudioSpot.h"
#import "TextSpot.h"
#import "ImageSpot.h"

#import "TextViewController.h"
#import "AudioViewController.h"
#import "ImageViewController.h"

#define kDebugMode 0
#define kRangeOffset 10

@interface LocationBasedARViewController () <AudioViewControllerDelegate, TextViewControllerDelegate, ImageViewControllerDelegate>
- (UIImage*) getBillboardImageForTitle: (NSString*) title;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) URBAlertView *alertView;
@end


@implementation LocationBasedARViewController


#pragma mark - UIViewController lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setupLocationManager];
    
    bool success = m_metaioSDK->setTrackingConfiguration("GPS");
    if( !success)
        NSLog(@"No success setting the tracking configuration");
    
    metaio::SensorsComponentIOS* iosComponent = reinterpret_cast<metaio::SensorsComponentIOS*>(m_sensors);
    SensorsComponentImpl* iosImpl = iosComponent->getSensorComponentImpl();
    
    // if we want to use ImageBillboards, we should use UIBillboard Groups
	billboardGroup = m_metaioSDK->createBillboardGroup(1000, 1500);
	billboardGroup->setBillboardExpandFactors(0.8, 3, 10 );
    m_metaioSDK->setRendererClippingPlaneLimits(10, 100000000);
    
    m_metaioSDK->setLLAObjectRenderingLimits(1000, 1500);
    
    
    // Create radar object
    m_radar = m_metaioSDK->createRadar();
    m_radar->setBackgroundTexture([[[NSBundle mainBundle] pathForResource:@"radar"
																   ofType:@"png"
															  inDirectory:@"ImageRes"] UTF8String]);
    m_radar->setObjectsDefaultTexture([[[NSBundle mainBundle] pathForResource:@"yellow"
																	   ofType:@"png"
																  inDirectory:@"ImageRes"] UTF8String]);
    m_radar->setRelativeToScreen(metaio::IGeometry::ANCHOR_BR);
    
    
    for (Spot *spot in [SpotsManager sharedManager].spots) {
        metaio::LLACoordinate location = metaio::LLACoordinate(spot.latitude, spot.longitude, 0, 0);
        targetImage = [self getBillboardImageForTitle:spot.name];
        targetBillboard = m_metaioSDK->createGeometryFromCGImage([spot.name cStringUsingEncoding:NSUTF8StringEncoding], [targetImage CGImage], true);
        targetBillboard->setTranslationLLA(location);
        targetBillboard->setLLALimitsEnabled(true);
        targetBillboard->setScale(1.5f);
        targetBillboard->setName([spot.name cStringUsingEncoding:NSUTF8StringEncoding]);
        billboardGroup->addBillboard(targetBillboard);
        m_radar->add(targetBillboard);
    }
    
    //  metaio::SensorsComponentIOS* iosComponent = reinterpret_cast<metaio::SensorsComponentIOS*>(m_sensors);
    // SensorsComponentImpl* iosImpl = iosComponent->getSensorComponentImpl();
    [iosImpl setLocationManagerDelegate:self];
    
    iosComponent->start(metaio::ISensorsComponent::SENSOR_LOCATION);
}

- (void)setupLocationManager
{
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{	
	// if the renderer appears we start rendering and capturing the camera
    [self startAnimation];
	std::vector<metaio::Camera> cameras = m_metaioSDK->getCameraList();
	if(cameras.size()>0)
	{
		m_metaioSDK->startCamera(cameras[0]);
	} else {
		NSLog(@"No Camera Found");
	}
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// as soon as the view disappears, we stop rendering and stop the camera
    [self stopAnimation];	
    m_metaioSDK->stopCamera();
    metaio::SensorsComponentIOS* iosComponent = reinterpret_cast<metaio::SensorsComponentIOS*>(m_sensors);
    iosComponent->stop();
    [self.locationManager stopUpdatingLocation];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setGlView:nil];
    [super viewDidUnload];
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
        NSString *modelName =[NSString stringWithUTF8String:model->getName().c_str()];
#if kDebugMode
        NSLog(@"%@", modelName);
#endif
        
        for (Spot *targetSpot in [SpotsManager sharedManager].spots) {
            if ([modelName isEqualToString:targetSpot.name]) {
                
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
                break;
            }
        }
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
        imagePath = [[NSBundle mainBundle] pathForResource:@"poi_background"
													ofType:@"png"
											   inDirectory:@"ImageRes"];
    }
    else 
    {
        imagePath = [[NSBundle mainBundle] pathForResource:@"poi_background"
													ofType:@"png"
											   inDirectory:@"ImageRes"];
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
    CGContextSetRGBFillColor(currContext, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextSetTextDrawingMode(currContext, kCGTextFill);
    CGContextSetShouldAntialias(currContext, true);
  
    float border;
    
    if (title.length > 25) {
        border = 5 * scaleFactor;
    } else {
         border = (25 - title.length)*scaleFactor;
    }
    [title drawInRect:CGRectMake(border, border,
                                 bgImage.size.width - 2 * border,
                                 bgImage.size.height - 2 * border)
             withFont:[UIFont systemFontOfSize:13 * scaleFactor]];
    
    // retrieve the screenshot from the current context
    UIImage* blendetImage = UIGraphicsGetImageFromCurrentImageContext();	
    UIGraphicsEndImageContext();
    
    return blendetImage;
}


#pragma - CLLocationManagerDelegate

/*
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
#if kDebugMode
    NSLog(@"user did enter region");
#endif
    
    for (FBWaypoint *waypoint in self.goal.waypoints) {
        if ([region.identifier isEqualToString:waypoint.label]) {
            [FBDataHandler userDidVisitWaypoint:waypoint];
            
            // push notification here...
            [TSMessage showNotificationInViewController:self title:@"Congratulations!" subtitle:[NSString stringWithFormat:@"You have visited %@", waypoint.label] type:TSMessageNotificationTypeSuccess];
            
            // check whether brutus need to be shown on screen
            if ([FBDataHandler quizIsReadyForGoal:self.goal]) {
                brutus->setVisible(true);
            }
            break;
        }
    }
}
*/

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //CLLocation *location = [locations lastObject];
}


- (void)dismissViewController{
    [self dismissPopupViewControllerAnimated:YES completion:nil];
}

- (IBAction)exit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
