//
//  CSGeoARViewController.h
//  MySpots
//
//  Created by FlyinGeek on 11/2/13.
//  Copyright (c) 2013 CodeStrikers. All rights reserved.
//

#import "CSSpot.h"
#import "MetaioSDKViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

namespace metaio
{
    class IGeometry;   // forward declaration
}

@interface CSGeoARViewController : MetaioSDKViewController <CLLocationManagerDelegate>
{
    metaio::IBillboardGroup*   billboardGroup;   //!< Our default billboard group
    metaio::IGeometry* targetBillBoard;
    metaio::IRadar* m_radar;
    
    UIImage* targetImage;
    
    bool locUpdate;
}
@property (nonatomic, retain) CLLocation* currentLocation;				//!< Contains the current location
@property (nonatomic, strong) CSSpot *spot;

@end
